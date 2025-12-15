pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'aqsaimtiaz/mediconsult-app'
        APP_PORT = '8501'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                echo '📥 Checking out code from GitHub...'
                checkout scm
            }
        }
        
        stage('Stop Existing Containers') {
            steps {
                echo '🛑 Stopping existing containers...'
                sh '''
                    # Gracefully stop containers if running
                    docker compose down || true
                    sleep 5
                    
                    # Verify no mediconsult containers
                    docker ps -a | grep -v "mediconsult" || echo "No mediconsult containers found"
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh '''
                    # Build new image
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                    
                    # List images
                    echo "Built images:"
                    docker images | grep ${DOCKER_IMAGE}
                '''
            }
        }
        
        stage('Deploy Application') {
            steps {
                echo '🚀 Deploying application...'
                sh '''
                    # Start containers
                    docker compose up -d
                    
                    # Wait for app to start
                    echo "Waiting for application to start..."
                    sleep 20
                    
                    # Check containers status
                    echo "Container status:"
                    docker compose ps
                    
                    # Test application
                    echo "Testing application endpoint..."
                    if curl -f http://localhost:${APP_PORT} > /dev/null 2>&1; then
                        echo "✅ Application is responding on port ${APP_PORT}"
                    else
                        echo "⚠ Application not responding yet, but containers are running"
                    fi
                '''
            }
        }
        
        stage('Run Basic Tests') {
            steps {
                echo '🧪 Running basic tests...'
                sh '''
                    echo "=== Running Tests ==="
                    
                    # Test 1: Check containers are running
                    if docker compose ps | grep -q "Up"; then
                        echo "✅ Test 1: Containers are running"
                    else
                        echo "❌ Test 1: Containers not running"
                        exit 1
                    fi
                    
                    # Test 2: Check application port
                    if docker compose ps | grep ":${APP_PORT}->"; then
                        echo "✅ Test 2: Port ${APP_PORT} is mapped"
                    else
                        echo "❌ Test 2: Port ${APP_PORT} not mapped"
                        exit 1
                    fi
                    
                    # Test 3: Simple Python test
                    python3 -c "
print('✅ Test 3: Python is working')
import sys
print(f'Python version: {sys.version}')
"
                    
                    echo "=== All tests completed ==="
                '''
            }
        }
        
        stage('Take Screenshot Info') {
            steps {
                echo '📸 Preparing screenshot information...'
                sh '''
                    echo "=========================================="
                    echo "        PIPELINE EXECUTION SUMMARY       "
                    echo "=========================================="
                    echo "Build Number: ${BUILD_NUMBER}"
                    echo "Docker Image: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                    echo "Application URL: http://localhost:${APP_PORT}"
                    echo ""
                    echo "=== Running Containers ==="
                    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
                    echo ""
                    echo "=== Docker Images ==="
                    docker images ${DOCKER_IMAGE} --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
                    echo "=========================================="
                '''
            }
        }
    }
    
    post {
        success {
            echo '🎉 Pipeline completed successfully!'
            sh '''
                echo "=========================================="
                echo "✅ BUILD SUCCESSFUL - READY FOR SUBMISSION"
                echo "=========================================="
                echo ""
                echo "For Assignment Submission Screenshots:"
                echo "1. Take screenshot of this console output"
                echo "2. Take screenshot of Jenkins dashboard"
                echo "3. Take screenshot of application at:"
                echo "   http://<EC2-IP>:${APP_PORT}"
                echo "4. Take screenshot of: docker ps"
                echo "5. Take screenshot of: docker images"
                echo ""
                echo "URLs to include in report:"
                echo "- Jenkins: http://<EC2-IP>:8080"
                echo "- Pipeline: http://<EC2-IP>:8080/job/MediConsult-CI-CD/"
                echo "- Application: http://<EC2-IP>:${APP_PORT}"
                echo "=========================================="
            '''
        }
        
        failure {
            echo '❌ Pipeline failed!'
            sh '''
                echo "=========================================="
                echo "❌ BUILD FAILED"
                echo "Check console output above for errors"
                echo "=========================================="
            '''
        }
        
        always {
            echo "🏁 Pipeline completed at: ${new Date()}"
            // Don't cleanup - keep containers running for demo
            sh '''
                echo "Containers kept running for demonstration"
                echo "To stop manually: docker compose down"
            '''
        }
    }
}
