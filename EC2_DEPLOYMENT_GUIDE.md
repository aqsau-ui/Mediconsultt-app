# Complete Deployment Guide - Assignment 2

## Part I: EC2 Deployment (Production)

### Step 1: Prepare EC2 Instance

**SSH into your EC2:**
```bash
ssh -i your-key.pem ubuntu@13.61.145.186
```

**Install Docker and Docker Compose:**
```bash
# Update system
sudo apt update
sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker ubuntu
newgrp docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
docker --version
docker-compose --version
```

### Step 2: Deploy Application on EC2

**Clone your repository:**
```bash
cd ~
git clone https://github.com/aqsau-ui/Mediconsultt-app.git
cd Mediconsultt-app
```

**Start the application:**
```bash
# Login to Docker Hub (to pull your image)
docker login
# Enter: aqsaimtiaz / your-password

# Start containers with Part I compose file
docker-compose up -d

# Wait for MongoDB to be healthy
sleep 30

# Check status
docker ps

# Check logs
docker logs mediconsult_web
docker logs mediconsult_mongodb

# Check MongoDB health
docker inspect mediconsult_mongodb --format='{{.State.Health.Status}}'
```

**Test locally on EC2:**
```bash
curl http://localhost:8501
```

### Step 3: Configure EC2 Security Group

In AWS Console:
1. Go to EC2 → Instances → Select your instance
2. Click **Security** tab
3. Click on the Security Group
4. **Edit inbound rules** → **Add rule**:
   - Type: **Custom TCP**
   - Port: **8501**
   - Source: **0.0.0.0/0** (Anywhere)
   - Description: "Streamlit Web App"
5. Save rules

### Step 4: Verify Access

Open browser: **http://13.61.145.186:8501**

---

## Part II: Jenkins CI/CD Setup

### Step 1: Install Jenkins on EC2

**Option A: Same EC2 or Option B: New EC2**

I recommend using the **same EC2** for this assignment.

**Install Jenkins:**
```bash
# Install Java (required for Jenkins)
sudo apt install -y openjdk-11-jdk

# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Add jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

**Configure Security Group for Jenkins:**
- Add inbound rule: **Port 8080** from **0.0.0.0/0**

**Access Jenkins:**
- http://13.61.145.186:8080
- Enter initial admin password
- Install suggested plugins
- Create admin user

### Step 2: Configure Jenkins

**Install Required Plugins:**
1. Manage Jenkins → Plugins → Available
2. Search and install:
   - **Git plugin**
   - **Pipeline plugin**
   - **Docker Pipeline plugin**
3. Restart Jenkins

### Step 3: Create Jenkins Pipeline Job

**Create New Job:**
1. Dashboard → New Item
2. Name: `MediConsult-CI-CD`
3. Type: **Pipeline**
4. Click OK

**Configure Job:**
- **General:**
  - Description: "MediConsult containerized build pipeline"
  - ✓ GitHub project: `https://github.com/aqsau-ui/Mediconsultt-app/`

- **Build Triggers:**
  - ✓ GitHub hook trigger for GITScm polling

- **Pipeline:**
  - Definition: **Pipeline script from SCM**
  - SCM: **Git**
  - Repository URL: `https://github.com/aqsau-ui/Mediconsultt-app.git`
  - Branch: `*/main`
  - Script Path: `Jenkinsfile`

**Save**

### Step 4: Update Jenkinsfile for Part II

The Jenkinsfile should use `docker-compose-ci.yml` instead of `docker-compose.yml`:

```groovy
stage("Deploy CI Application") {
    steps {
        sh """
            docker-compose -f docker-compose-ci.yml down || true
            docker-compose -f docker-compose-ci.yml up -d --build
            sleep 30
            docker-compose -f docker-compose-ci.yml ps
        """
    }
}
```

### Step 5: Test Pipeline

1. Click **Build Now**
2. Watch console output
3. Verify:
   - Code pulled from GitHub ✓
   - Image built ✓
   - Containers started with code volume ✓
   - Port 8502 accessible ✓

**Test CI environment:**
```bash
# On EC2
curl http://localhost:8502
```

**From browser:**
http://13.61.145.186:8502

---

## Key Differences: Part I vs Part II

| Aspect | Part I (Production) | Part II (CI/CD) |
|--------|-------------------|----------------|
| **Docker Compose File** | `docker-compose.yml` | `docker-compose-ci.yml` |
| **Image Source** | Pre-built from Docker Hub | Built locally from Dockerfile |
| **Code** | Baked into image | Mounted as volume |
| **Web Port** | 8501 | 8502 |
| **MongoDB Port** | 27017 | 27018 |
| **Container Names** | mediconsult_web, mediconsult_mongodb | mediconsult_web_ci, mediconsult_mongodb_ci |
| **Purpose** | Production deployment | CI/CD testing |

---

## Troubleshooting

### MongoDB Connection Error on EC2

If you still get the error, check:

```bash
# Check if containers are on same network
docker network ls
docker network inspect mediconsultt-app_default

# Check DNS resolution inside container
docker exec mediconsult_web ping mongodb

# Check MongoDB logs
docker logs mediconsult_mongodb

# Check if MongoDB is actually healthy
docker inspect mediconsult_mongodb --format='{{.State.Health.Status}}'
```

### If healthcheck not working:

Your EC2 might have an older docker-compose version. Check:
```bash
docker-compose --version
```

If version < 2.20, update docker-compose or modify healthcheck syntax.

---

## Final Checklist

### Part I:
- [ ] EC2 instance running
- [ ] Docker and Docker Compose installed
- [ ] Security group allows port 8501
- [ ] Code cloned on EC2
- [ ] docker-compose.yml deployed
- [ ] MongoDB volume persistent
- [ ] App accessible: http://13.61.145.186:8501

### Part II:
- [ ] Jenkins installed on EC2
- [ ] Security group allows port 8080
- [ ] Jenkins plugins installed
- [ ] Pipeline job created
- [ ] docker-compose-ci.yml created
- [ ] Jenkinsfile uses docker-compose-ci.yml
- [ ] Code mounted as volume
- [ ] Different ports used (8502, 27018)
- [ ] Pipeline builds successfully
- [ ] CI app accessible: http://13.61.145.186:8502

---

## For Report: Screenshots Needed

1. **Part I:**
   - Docker Hub showing your pushed image
   - EC2 instance details
   - docker-compose.yml file
   - `docker ps` output showing containers
   - Browser showing app at EC2 IP:8501
   - Dockerfile content

2. **Part II:**
   - Jenkins dashboard
   - Jenkins pipeline configuration
   - docker-compose-ci.yml showing code volume mount
   - Jenkinsfile content
   - Pipeline build success
   - Console output
   - `docker ps` showing CI containers with different names
   - Browser showing app at EC2 IP:8502

---

**Need help with a specific step? Let me know which part you're stuck on!**
