pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "aqsaimtiaz/mediconsult-app"
        APP_URL = "http://localhost:8501"
    }
    
    stages {
        stage("Checkout Code") {
            steps {
                echo "📥 Checking out code from GitHub..."
                checkout scm
            }
        }
        
        stage("Build Docker Image") {
            steps {
                echo "🐳 Building Docker image..."
                script {
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
        
        stage("Deploy Application") {
            steps {
                echo "🚀 Deploying application for testing..."
                script {
                    sh """
                        # Stop any existing containers
                        docker-compose down || true
                        
                        # Start fresh containers
                        docker-compose up -d
                        
                        # Wait for MongoDB to be healthy
                        echo "Waiting for MongoDB to be healthy..."
                        timeout 60 bash -c 'until docker inspect mediconsult_mongodb --format="{{.State.Health.Status}}" | grep -q "healthy"; do echo "MongoDB not ready yet..."; sleep 5; done'
                        
                        # Wait for app to fully start
                        echo "Waiting for application to start..."
                        sleep 15
                        
                        # Verify containers are running
                        docker ps
                        
                        # Test application is responding
                        curl -f ${APP_URL} && echo "✅ Application is running!" || (echo "❌ Application failed to start" && exit 1)
                    """
                }
            }
        }
        
        stage("Run Selenium Tests") {
            steps {
                echo "🧪 Running Selenium automated tests..."
                script {
                    // Build test container
                    sh """
                        # Create test Dockerfile if not exists
                        cat > Dockerfile.test << 'EOF'
FROM python:3.10-slim

# Install Chrome and dependencies
RUN apt-get update && apt-get install -y \\
    wget \\
    gnupg \\
    unzip \\
    curl \\
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \\
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \\
    && apt-get update \\
    && apt-get install -y google-chrome-stable \\
    && rm -rf /var/lib/apt/lists/*

# Install ChromeDriver
RUN CHROMEDRIVER_VERSION=\$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE) \\
    && wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/\${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip \\
    && unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ \\
    && rm /tmp/chromedriver.zip \\
    && chmod +x /usr/local/bin/chromedriver

# Set working directory
WORKDIR /tests

# Copy test requirements and install
COPY tests/requirements-test.txt .
RUN pip install --no-cache-dir -r requirements-test.txt

# Copy test files
COPY tests/ .

CMD ["python", "-m", "unittest", "discover", "-v"]
EOF

                        # Build test image
                        docker build -f Dockerfile.test -t mediconsult-tests:${BUILD_NUMBER} .
                        
                        # Run tests and capture results
                        docker run --rm \\
                            --network host \\
                            -e APP_URL=${APP_URL} \\
                            mediconsult-tests:${BUILD_NUMBER} > test_results.txt 2>&1 || true
                        
                        # Display test results
                        cat test_results.txt
                        
                        # Check if tests passed
                        if grep -q "OK" test_results.txt || grep -q "Ran.*0 failures" test_results.txt; then
                            echo "✅ All tests passed!"
                            exit 0
                        else
                            echo "❌ Some tests failed!"
                            exit 1
                        fi
                    """
                }
            }
        }
        
        stage("Cleanup") {
            steps {
                echo "🧹 Cleaning up test environment..."
                script {
                    sh """
                        docker-compose down
                        docker rmi mediconsult-tests:${BUILD_NUMBER} || true
                    """
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Archive test results
                archiveArtifacts artifacts: 'test_results.txt', allowEmptyArchive: true
                
                // Get commit author email
                def authorEmail = sh(
                    script: 'git log -1 --pretty=format:"%ae"',
                    returnStdout: true
                ).trim()
                
                // Get commit message
                def commitMsg = sh(
                    script: 'git log -1 --pretty=format:"%s"',
                    returnStdout: true
                ).trim()
                
                // Read test results
                def testResults = readFile('test_results.txt').trim()
                
                // Determine status
                def status = currentBuild.result ?: 'SUCCESS'
                def emoji = status == 'SUCCESS' ? '✅' : '❌'
                
                // Send email
                emailext(
                    to: "${authorEmail}",
                    subject: "${emoji} Jenkins Pipeline ${status}: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                    body: """
<h2>${emoji} Jenkins Pipeline ${status}</h2>

<h3>Build Information:</h3>
<ul>
    <li><strong>Job:</strong> ${env.JOB_NAME}</li>
    <li><strong>Build Number:</strong> ${env.BUILD_NUMBER}</li>
    <li><strong>Status:</strong> ${status}</li>
    <li><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></li>
</ul>

<h3>Commit Information:</h3>
<ul>
    <li><strong>Author:</strong> ${authorEmail}</li>
    <li><strong>Message:</strong> ${commitMsg}</li>
</ul>

<h3>Test Results:</h3>
<pre>${testResults}</pre>

<p>Check the <a href="${env.BUILD_URL}console">console output</a> for more details.</p>
""",
                    mimeType: 'text/html'
                )
            }
        }
        success {
            echo "🎉 PIPELINE SUCCESSFUL! Tests passed and email sent."
        }
        failure {
            echo "❌ PIPELINE FAILED! Check test results and email notification."
        }
    }
}
