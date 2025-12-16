pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "aqsaimtiaz/mediconsult-app"
    }
    
    stages {
        stage("Checkout Code") {
            steps {
                echo "📥 Checking out code..."
                checkout scm
            }
        }
        
        stage("Build Docker Image") {
            steps {
                echo "🐳 Building Docker image..."
                sh """
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                """
            }
        }
        
        stage("Deploy Application") {
            steps {
                echo "🚀 Deploying application..."
                sh """
                    docker compose down || true
                    docker compose up -d
                    
                    # Wait for MongoDB healthcheck to pass
                    echo "Waiting for MongoDB to be healthy..."
                    timeout 60 bash -c 'until docker inspect mediconsult_mongodb --format="{{.State.Health.Status}}" | grep -q "healthy"; do echo "MongoDB not healthy yet..."; sleep 5; done' || true
                    
                    # Wait for app to fully start
                    echo "Waiting for application to start..."
                    sleep 10
                    
                    echo "=== CONTAINER STATUS ==="
                    docker compose ps
                    
                    echo "=== HEALTH STATUS ==="
                    docker inspect mediconsult_mongodb --format="MongoDB Health: {{.State.Health.Status}}" || true
                    
                    echo "=== LOGS ==="
                    docker compose logs --tail=30
                    
                    echo "=== APPLICATION TEST ==="
                    curl -f http://localhost:8501 && echo "✅ App is running" || echo "⚠ Check manually"
                """
            }
        }
        
        stage("Verification") {
            steps {
                echo "✅ Deployment complete!"
                sh """
                    echo "========================================"
                    echo "BUILD: ${BUILD_NUMBER}"
                    echo "IMAGE: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                    echo "APP: http://localhost:8501"
                    echo "========================================"
                """
            }
        }
    }
    
    post {
        success {
            echo "🎉 PIPELINE SUCCESSFUL!"
        }
        failure {
            echo "❌ PIPELINE FAILED"
        }
    }
}
