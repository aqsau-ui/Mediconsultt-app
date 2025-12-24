# Assignment 4 - Kubernetes Deployment Guide

## Step-by-Step Deployment Instructions

### Step 1: Install minikube on EC2 Instance

SSH to your EC2 instance and run:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker (if not installed)
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version

# Start minikube cluster
minikube start --driver=docker --cpus=2 --memory=2048

# Verify cluster is running
kubectl cluster-info
kubectl get nodes

# Enable metrics server for HPA
minikube addons enable metrics-server
```

### Step 2: Clone Repository and Navigate to k8s Directory

```bash
cd ~
git clone https://github.com/aqsau-ui/Mediconsultt-app.git
cd Mediconsultt-app/k8s
```

### Step 3: Deploy MongoDB with Persistent Volume

```bash
# Apply PVC first
kubectl apply -f mongodb-pvc.yaml

# Verify PVC is created
kubectl get pvc

# Deploy MongoDB
kubectl apply -f mongodb-deployment.yaml

# Apply MongoDB Service
kubectl apply -f mongodb-service.yaml

# Verify MongoDB pods and service
kubectl get pods -l app=mongodb
kubectl get svc mongodb
```

### Step 4: Deploy Web Application

```bash
# Deploy web application
kubectl apply -f web-deployment.yaml

# Apply web service
kubectl apply -f web-service.yaml

# Verify web pods and service
kubectl get pods -l app=mediconsult-web
kubectl get svc mediconsult-web-service
```

### Step 5: Apply HorizontalPodAutoscaler

```bash
# Apply HPA
kubectl apply -f web-hpa.yaml

# Verify HPA is created
kubectl get hpa
```

### Step 6: Access Application via NodePort

```bash
# Get minikube IP
minikube ip

# Get service URL
minikube service mediconsult-web-service --url

# Test locally on EC2
curl $(minikube service mediconsult-web-service --url)
```

### Step 7: Install and Configure ngrok

```bash
# Download ngrok
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar -xvzf ngrok-v3-stable-linux-amd64.tgz
sudo mv ngrok /usr/local/bin/

# Sign up at https://ngrok.com and get your authtoken
ngrok config add-authtoken YOUR_AUTH_TOKEN

# Get the NodePort for web service
kubectl get svc mediconsult-web-service
# Note the NodePort (30501)

# Get minikube IP
MINIKUBE_IP=$(minikube ip)

# Start ngrok tunnel for web application
ngrok http http://$MINIKUBE_IP:30501 &

# Start ngrok tunnel for minikube dashboard (in another terminal)
# First, start the dashboard
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' &

# Then tunnel it
ngrok http 8001 &
```

**Alternative: Use screen/tmux for persistent tunnels**

```bash
# Install screen
sudo apt install screen -y

# Start screen session for app tunnel
screen -S app-tunnel
ngrok http http://$(minikube ip):30501
# Press Ctrl+A, then D to detach

# Start screen session for dashboard tunnel
screen -S dashboard-tunnel
kubectl proxy --address='0.0.0.0' --accept-hosts='.*'
# In another terminal:
screen -S dashboard-ngrok
ngrok http 8001
# Press Ctrl+A, then D to detach

# List screen sessions
screen -ls

# Reattach to a session if needed
screen -r app-tunnel
```

### Step 8: Verify Deployments

```bash
# Check all resources
kubectl get all

# Check HPA status
kubectl get hpa

# Check persistent volume
kubectl get pv,pvc

# View pod logs
kubectl logs -l app=mediconsult-web

# View dashboard
minikube dashboard --url
```

### Step 9: Test Autoscaling

Generate load to test HPA:

```bash
# Install Apache Bench
sudo apt install apache2-utils -y

# Generate load (replace with your ngrok URL)
ab -n 10000 -c 100 YOUR_NGROK_URL/

# Watch HPA in action
kubectl get hpa -w
```

## Useful Commands

```bash
# View all resources
kubectl get all

# Describe deployment
kubectl describe deployment mediconsult-web-deployment

# View logs
kubectl logs -f <pod-name>

# Delete all resources
kubectl delete -f .

# Restart minikube
minikube stop
minikube start

# Access minikube dashboard
minikube dashboard
```

## Troubleshooting

**If pods are not starting:**
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

**If HPA shows "unknown" metrics:**
```bash
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml
minikube addons enable metrics-server
kubectl top nodes
kubectl top pods
```

**If ngrok tunnel fails:**
- Check if port is accessible: `curl http://$(minikube ip):30501`
- Verify ngrok authtoken is configured
- Check firewall rules on EC2

## What to Submit

1. **Google Form URLs:**
   - Application tunnel URL (ngrok URL for port 30501)
   - Dashboard tunnel URL (ngrok URL for kubectl proxy)

2. **Report with:**
   - Screenshots of all kubectl commands
   - Screenshot of running pods
   - Screenshot of HPA working
   - Screenshot of ngrok tunnels
   - Screenshot of application in browser
   - Screenshot of minikube dashboard
   - All YAML files included
   - Dockerfile included
