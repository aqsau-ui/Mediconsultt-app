pipeline {
    agent any
    options {
        timeout(time: 60, unit: 'MINUTES')
    }
    
    environment {
        DOCKER_IMAGE = 'aqsaimtiaz/mediconsult-app'
        // Hardcoded email for notifications
        NOTIFICATION_EMAIL = 'aqsaimtiaz823@gmail.com'
        GIT_AUTHOR_EMAIL = ''
        GIT_AUTHOR_NAME = ''
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                echo '📥 Checking out code from GitHub...'
                checkout scm
                
                script {
                    // Extract Git author email and name for logging
                    try {
                        env.GIT_AUTHOR_EMAIL = sh(
                            script: "git log -1 --pretty=format:'%ae'",
                            returnStdout: true
                        ).trim()
                        
                        env.GIT_AUTHOR_NAME = sh(
                            script: "git log -1 --pretty=format:'%an'",
                            returnStdout: true
                        ).trim()
                        
                        echo "✓ Git Author: ${env.GIT_AUTHOR_NAME} <${env.GIT_AUTHOR_EMAIL}>"
                    } catch (Exception e) {
                        echo "⚠ Could not extract Git author info: ${e.message}"
                        env.GIT_AUTHOR_EMAIL = 'N/A'
                        env.GIT_AUTHOR_NAME = 'Unknown'
                    }
                    
                    // Force use of hardcoded email for notifications
                    echo "✓ Notification email set to: ${env.NOTIFICATION_EMAIL}"
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                '''
                echo '✓ Docker image built successfully'
            }
        }
        
        stage('Start Application Stack') {
            steps {
                echo '🚀 Starting application with docker compose...'
                sh '''
                    # Stop any existing containers
                    docker compose -f docker-compose.yml down || true
                    
                    # Start fresh containers
                    docker compose -f docker-compose.yml up -d
                    
                    # Wait for services to be ready
                    echo "Waiting for application to be ready..."
                    sleep 15
                    
                    # Verify containers are running
                    docker compose ps
                '''
                echo '✓ Application started successfully'
            }
        }
        
        stage('Install Test Dependencies') {
            steps {
                echo '📦 Installing test dependencies...'
                sh '''
                    pip3 install -r tests/requirements-test.txt || pip install -r tests/requirements-test.txt
                '''
                echo '✓ Test dependencies installed'
            }
        }
        
        stage('Run Selenium Tests') {
            steps {
                echo '🧪 Running Selenium automated tests...'
                script {
                    try {
                        sh '''
                            cd tests
                            python3 test_mediconsult.py || python test_mediconsult.py
                        '''
                        echo '✅ All tests passed!'
                    } catch (Exception e) {
                        echo '❌ Tests failed!'
                        throw e
                    }
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                echo '🧹 Cleaning up containers...'
                sh '''
                    docker compose -f docker-compose.yml down
                '''
                echo '✓ Cleanup complete'
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully!'
            emailext(
                to: "${env.NOTIFICATION_EMAIL}",  // Uses hardcoded email
                subject: "✅ SUCCESS: Selenium Tests Passed - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <html>
                    <head>
                        <style>
                            body { font-family: Arial, sans-serif; line-height: 1.6; }
                            .header { background-color: #28a745; color: white; padding: 20px; text-align: center; }
                            .content { padding: 20px; }
                            .details { background-color: #f8f9fa; padding: 15px; border-left: 4px solid #28a745; }
                            .footer { background-color: #f1f1f1; padding: 10px; text-align: center; font-size: 12px; }
                            table { width: 100%; border-collapse: collapse; margin: 10px 0; }
                            th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
                            th { background-color: #28a745; color: white; }
                            a { color: #007bff; text-decoration: none; }
                        </style>
                    </head>
                    <body>
                        <div class="header">
                            <h1>✅ Build Successful!</h1>
                            <p>All Selenium Tests Passed</p>
                        </div>
                        
                        <div class="content">
                            <h2>Build Information</h2>
                            <table>
                                <tr>
                                    <th>Property</th>
                                    <th>Value</th>
                                </tr>
                                <tr>
                                    <td><strong>Project</strong></td>
                                    <td>${env.JOB_NAME}</td>
                                </tr>
                                <tr>
                                    <td><strong>Build Number</strong></td>
                                    <td>#${env.BUILD_NUMBER}</td>
                                </tr>
                                <tr>
                                    <td><strong>Status</strong></td>
                                    <td style="color: green; font-weight: bold;">SUCCESS</td>
                                </tr>
                                <tr>
                                    <td><strong>Triggered By</strong></td>
                                    <td>${env.GIT_AUTHOR_NAME} &lt;${env.GIT_AUTHOR_EMAIL}&gt;</td>
                                </tr>
                                <tr>
                                    <td><strong>Build URL</strong></td>
                                    <td><a href="${env.BUILD_URL}">${env.BUILD_URL}</a></td>
                                </tr>
                                <tr>
                                    <td><strong>Notification Sent To</strong></td>
                                    <td>${env.NOTIFICATION_EMAIL}</td>
                                </tr>
                            </table>
                            
                            <h2>Test Results Summary</h2>
                            <div class="details">
                                <p>✅ <strong>All Selenium tests passed successfully!</strong></p>
                                <ul>
                                    <li>Homepage load test ✓</li>
                                    <li>Patient registration test ✓</li>
                                    <li>Duplicate email validation ✓</li>
                                    <li>Patient login test ✓</li>
                                    <li>Invalid login test ✓</li>
                                    <li>Doctor login test ✓</li>
                                    <li>Admin login test ✓</li>
                                    <li>View doctors list test ✓</li>
                                    <li>Navigation test ✓</li>
                                    <li>Logout functionality test ✓</li>
                                    <li>Form validation test ✓</li>
                                    <li>Page responsiveness test ✓</li>
                                </ul>
                            </div>
                            
                            <h2>Quick Links</h2>
                                <li><a href="${env.BUILD_URL}">View Build Details</a></li>
                                <li><a href="${env.BUILD_URL}console">View Console Output</a></li>
                                <li><a href="${env.BUILD_URL}changes">View Changes</a></li>
                            </ul>
                        </div>
                        
                        <div class="footer">
                            <p>This is an automated email from Jenkins CI/CD Pipeline</p>
                            <p>Assignment 3 - CSC483 DevOps - COMSATS University</p>
                        </div>
                    </body>
                    </html>
                """,
                mimeType: 'text/html'
            )
            
            echo "✉ Success email sent to: ${env.NOTIFICATION_EMAIL}"
        }
        
        failure {
            echo '❌ Pipeline failed!'
            emailext(
                to: "${env.NOTIFICATION_EMAIL}",  // Uses hardcoded email
                subject: "❌ FAILURE: Selenium Tests Failed - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <html>
                    <head>
                        <style>
                            body { font-family: Arial, sans-serif; line-height: 1.6; }
                            .header { background-color: #dc3545; color: white; padding: 20px; text-align: center; }
                            .content { padding: 20px; }
                            .details { background-color: #f8f9fa; padding: 15px; border-left: 4px solid #dc3545; }
                            .footer { background-color: #f1f1f1; padding: 10px; text-align: center; font-size: 12px; }
                            table { width: 100%; border-collapse: collapse; margin: 10px 0; }
                            th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
                            th { background-color: #dc3545; color: white; }
                            a { color: #007bff; text-decoration: none; }
                        </style>
                    </head>
                    <body>
                        <div class="header">
                            <h1>❌ Build Failed!</h1>
                            <p>Selenium Tests Failed or Build Error</p>
                        </div>
                        
                        <div class="content">
                            <h2>Build Information</h2>
                            <table>
                                <tr>
                                    <th>Property</th>
                                    <th>Value</th>
                                </tr>
                                <tr>
                                    <td><strong>Project</strong></td>
                                    <td>${env.JOB_NAME}</td>
                                </tr>
                                <tr>
                                    <td><strong>Build Number</strong></td>
                                    <td>#${env.BUILD_NUMBER}</td>
                                </tr>
                                <tr>
                                    <td><strong>Status</strong></td>
                                    <td style="color: red; font-weight: bold;">FAILURE</td>
                                </tr>
                                <tr>
                                    <td><strong>Triggered By</strong></td>
                                    <td>${env.GIT_AUTHOR_NAME} &lt;${env.GIT_AUTHOR_EMAIL}&gt;</td>
                                </tr>
                                <tr>
                                    <td><strong>Build URL</strong></td>
                                    <td><a href="${env.BUILD_URL}">${env.BUILD_URL}</a></td>
                                </tr>
                                <tr>
                                    <td><strong>Notification Sent To</strong></td>
                                    <td>${env.NOTIFICATION_EMAIL}</td>
                                </tr>
                            </table>
                            
                            <h2>Failure Details</h2>
                            <div class="details">
                                <p>❌ <strong>One or more tests failed or build encountered an error.</strong></p>
                                <p><strong>Action Required:</strong></p>
                                <ul>
                                    <li>Review the console output for error details</li>
                                    <li>Check which tests failed</li>
                                    <li>Fix the issues in your code</li>
                                    <li>Push the fixes to trigger a new build</li>
                                </ul>
                            </div>
                            
                            <h2>Quick Links</h2>
                            <ul>
                                <li><a href="${env.BUILD_URL}">View Build Details</a></li>
                                <li><a href="${env.BUILD_URL}console">View Console Output (Check Here First!)</a></li>
                                <li><a href="${env.BUILD_URL}changes">View Changes</a></li>
                            </ul>
                        </div>
                        
                        <div class="footer">
                            <p>This is an automated email from Jenkins CI/CD Pipeline</p>
                            <p>Assignment 3 - CSC483 DevOps - COMSATS University</p>
                        </div>
                    </body>
                    </html>
                """,
                mimeType: 'text/html'
            )
            
            echo "✉ Failure email sent to: ${env.NOTIFICATION_EMAIL}"
        }
        
        always {
            echo '🧹 Performing final cleanup...'
            sh '''
                # Ensure all containers are stopped
                docker compose -f docker-compose.yml down || true
            '''
            echo "Pipeline execution completed at: ${new Date()}"
        }
    }
}
