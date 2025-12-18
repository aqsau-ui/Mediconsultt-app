pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "aqsaimtiaz/mediconsult-app"
        GIT_COMMIT_EMAIL = sh(
            script: "git log -1 --pretty=format:'%ae'",
            returnStdout: true
        ).trim()
    }
    
    stages {
        stage("Checkout Code") {
            steps {
                echo "📥 Checking out code from GitHub..."
                checkout scm
                sh """
                    echo "Current Branch: \$(git branch --show-current)"
                    echo "Last Commit: \$(git log -1 --oneline)"
                    echo "Commit Author Email: ${GIT_COMMIT_EMAIL}"
                """
            }
        }
        
        stage("Build Docker Image") {
            steps {
                echo "🐳 Building Docker image..."
                sh """
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                    echo "✅ Image built: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                """
            }
        }
        
        stage("Run Automated Tests") {
            steps {
                echo "🧪 Running Selenium Tests in Containerized Environment..."
                sh """
                    # Clean up any existing test containers
                    docker-compose -f docker-compose-test.yml down -v || true
                    
                    # Start test environment
                    echo "Starting test environment..."
                    docker-compose -f docker-compose-test.yml up -d mongodb_test web_test
                    
                    # Wait for application to be healthy
                    echo "Waiting for application to be ready..."
                    sleep 30
                    
                    # Check if web app is accessible
                    docker-compose -f docker-compose-test.yml exec -T web_test curl -f http://localhost:8501 || echo "Web app starting..."
                    sleep 10
                    
                    # Run Selenium tests
                    echo "Running Selenium tests..."
                    docker-compose -f docker-compose-test.yml run --rm selenium_tests || TEST_EXIT_CODE=\$?
                    
                    # Copy test results
                    mkdir -p test-results
                    docker cp mediconsult_selenium_tests:/app/test-results/. ./test-results/ || echo "No test results to copy"
                    
                    # Clean up test containers
                    docker-compose -f docker-compose-test.yml down -v
                    
                    # Check test results
                    if [ -f test-results/test_summary.txt ]; then
                        echo "=== TEST RESULTS ==="
                        cat test-results/test_summary.txt
                    fi
                    
                    # Exit with test status
                    exit \${TEST_EXIT_CODE:-0}
                """
            }
        }
        
        stage("Deploy CI Application") {
            steps {
                echo "🚀 Deploying CI application..."
                sh """
                    # Stop existing CI containers
                    docker-compose -f docker-compose-ci.yml down || true
                    
                    # Start CI environment
                    docker-compose -f docker-compose-ci.yml up -d --build
                    
                    # Wait for MongoDB healthcheck
                    echo "Waiting for MongoDB to be healthy..."
                    timeout 60 bash -c 'until docker inspect mediconsult_mongodb_ci --format="{{.State.Health.Status}}" | grep -q "healthy"; do echo "MongoDB not healthy yet..."; sleep 5; done' || true
                    
                    # Wait for application
                    echo "Waiting for application to start..."
                    sleep 10
                    
                    echo "=== CONTAINER STATUS ==="
                    docker-compose -f docker-compose-ci.yml ps
                    
                    echo "=== HEALTH STATUS ==="
                    docker inspect mediconsult_mongodb_ci --format="MongoDB Health: {{.State.Health.Status}}" || true
                    
                    echo "=== APPLICATION TEST ==="
                    curl -f http://localhost:8502 && echo "✅ CI App is running on port 8502" || echo "⚠ Check manually"
                """
            }
        }
        
        stage("Verification") {
            steps {
                echo "✅ Pipeline execution complete!"
                sh """
                    echo "========================================"
                    echo "BUILD NUMBER: ${BUILD_NUMBER}"
                    echo "DOCKER IMAGE: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                    echo "CI APP URL: http://13.61.145.186:8502"
                    echo "PROD APP URL: http://13.61.145.186:8501"
                    echo "========================================"
                """
            }
        }
    }
    
    post {
        always {
            echo "📧 Sending test results email..."
            script {
                def testResults = ""
                if (fileExists('test-results/test_summary.txt')) {
                    testResults = readFile('test-results/test_summary.txt')
                } else {
                    testResults = "Test results not available"
                }
                
                emailext(
                    to: "${GIT_COMMIT_EMAIL}",
                    subject: "Jenkins Build #${BUILD_NUMBER} - ${currentBuild.currentResult}",
                    body: """
                    <html>
                    <body>
                        <h2>Jenkins Pipeline Execution Results</h2>
                        <p><strong>Build Number:</strong> ${BUILD_NUMBER}</p>
                        <p><strong>Build Status:</strong> ${currentBuild.currentResult}</p>
                        <p><strong>Project:</strong> ${env.JOB_NAME}</p>
                        <p><strong>Duration:</strong> ${currentBuild.durationString}</p>
                        
                        <h3>Test Results:</h3>
                        <pre>${testResults}</pre>
                        
                        <h3>Deployment URLs:</h3>
                        <ul>
                            <li><strong>CI Environment:</strong> http://13.61.145.186:8502</li>
                            <li><strong>Production:</strong> http://13.61.145.186:8501</li>
                        </ul>
                        
                        <p><a href="${env.BUILD_URL}">View Full Build Log</a></p>
                    </body>
                    </html>
                    """,
                    mimeType: 'text/html',
                    attachLog: true
                )
            }
        }
        
        success {
            echo "🎉 PIPELINE SUCCESSFUL!"
            echo "✅ All tests passed"
            echo "✅ Application deployed successfully"
        }
        
        failure {
            echo "❌ PIPELINE FAILED"
            echo "Check the logs above for details"
        }
    }
}