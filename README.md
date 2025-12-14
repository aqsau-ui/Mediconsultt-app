# MediConsult - Patient-Doctor Consultation Portal

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()
[![Tests](https://img.shields.io/badge/tests-12%20passed-success)]()
[![Docker](https://img.shields.io/badge/docker-ready-blue)]()

A containerized web application for patient-doctor consultations with automated testing and CI/CD pipeline.

## 📋 Project Overview

**Course:** CSC483 – Topics in Computer Science II (DevOps)  
**Institution:** COMSATS University, Islamabad  
**Assignment:** 3 - Automated Testing and CI/CD Pipeline

This project demonstrates:
- Containerized deployment using Docker
- Automated testing with Selenium WebDriver
- CI/CD pipeline with Jenkins
- Email notifications for test results

## 🏗️ Architecture

```
┌─────────────────┐
│   GitHub Repo   │
└────────┬────────┘
         │ Push/Webhook
         ↓
┌─────────────────┐
│     Jenkins     │
│   (AWS EC2)     │
└────────┬────────┘
         │ Build & Test
         ↓
┌─────────────────┐      ┌──────────────┐
│  Docker Stack   │──────│   MongoDB    │
│   Streamlit     │      │  (Persistent)│
└─────────────────┘      └──────────────┘
         │
         ↓
┌─────────────────┐
│ Selenium Tests  │
│  (12 Tests)     │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Email Report   │
│ to Collaborator │
└─────────────────┘
```

## 🚀 Features

### Application Features
- **Patient Dashboard**: Book consultations, view history
- **Doctor Dashboard**: Manage appointments, view patient details
- **Admin Dashboard**: User management, system overview
- **MongoDB Database**: Persistent data storage
- **Authentication**: Secure login system with bcrypt

### Testing & CI/CD
- **12 Automated Selenium Tests** covering:
  - Homepage loading
  - User registration (positive & negative)
  - Login flows (patient, doctor, admin)
  - Navigation and UI interactions
  - Form validation
  - Logout functionality
- **Headless Chrome** for CI/CD compatibility
- **Jenkins Pipeline** with automatic triggers
- **Email Notifications** to Git committer

## 📦 Tech Stack

- **Frontend/Backend**: Streamlit (Python)
- **Database**: MongoDB
- **Testing**: Selenium WebDriver, Python unittest
- **Containerization**: Docker, Docker Compose
- **CI/CD**: Jenkins
- **Cloud**: AWS EC2

## 🔧 Installation & Setup

### Prerequisites
- Docker & Docker Compose
- Python 3.10+
- Git

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR-USERNAME/mediconsult-devops.git
   cd mediconsult-devops
   ```

2. **Start the application**
   ```bash
   docker-compose up -d
   ```

3. **Access the application**
   - Open browser: http://localhost:8501
   - Default admin credentials:
     - Email: `admin@mediconsult.com`
     - Password: `admin123`

4. **Run tests**
   ```bash
   pip install -r tests/requirements-test.txt
   python tests/test_mediconsult.py
   ```

## 🧪 Testing

### Test Suite

12 comprehensive test cases covering:

| # | Test Case | Description |
|---|-----------|-------------|
| 1 | Homepage Load | Verifies application loads correctly |
| 2 | Patient Registration | Tests valid registration flow |
| 3 | Duplicate Email | Validates duplicate email handling |
| 4 | Patient Login | Tests patient login with valid credentials |
| 5 | Invalid Login | Validates rejection of invalid credentials |
| 6 | Doctor Login | Tests doctor role access |
| 7 | Admin Login | Tests admin dashboard access |
| 8 | View Doctors List | Validates doctor listing feature |
| 9 | Navigation | Tests UI navigation between sections |
| 10 | Logout | Verifies logout functionality |
| 11 | Form Validation | Tests empty field validation |
| 12 | Page Responsiveness | Tests page load consistency |

### Running Tests Locally

```bash
# Ensure app is running
docker-compose up -d

# Install test dependencies
pip install -r tests/requirements-test.txt

# Run tests
python tests/test_mediconsult.py
```

### Test Results

```
===============================================================================
TEST EXECUTION SUMMARY
===============================================================================
Tests Run: 12
Successes: 12
Failures: 0
Errors: 0
===============================================================================
```

## 🔄 CI/CD Pipeline

### Jenkins Pipeline Stages

1. **Checkout Code** - Clone repository from GitHub
2. **Build Docker Image** - Build application container
3. **Start Application Stack** - Launch app and database
4. **Install Test Dependencies** - Install Selenium and requirements
5. **Run Selenium Tests** - Execute 12 automated tests
6. **Cleanup** - Stop containers
7. **Email Notification** - Send results to Git committer

### Triggering the Pipeline

The pipeline automatically triggers on:
- Git push to main branch
- Pull request merge
- Manual trigger from Jenkins UI

### Email Notifications

- **Success**: Green email with test summary
- **Failure**: Red email with error details
- **Recipient**: Git committer's email address

## 📁 Project Structure

```
mediconsult-devops/
├── mediconsult_app.py          # Main Streamlit application
├── config.py                   # Configuration settings
├── requirements.txt            # Python dependencies
├── Dockerfile                  # Docker image definition
├── docker-compose.yml          # Multi-container setup
├── Jenkinsfile                 # CI/CD pipeline definition
├── .gitignore                  # Git ignore rules
├── README.md                   # This file
│
├── database/                   # Database utilities
│   ├── connection.py
│   └── init.py
│
├── models/                     # Data models
│   └── __init__.py
│
├── pages/                      # Dashboard pages
│   ├── admin_dashboard.py
│   ├── doctor_dashboard.py
│   └── patient_dashboard.py
│
├── utils/                      # Utility functions
│   └── __init__.py
│
└── tests/                      # Test suite
    ├── test_mediconsult.py     # 12 Selenium tests
    └── requirements-test.txt   # Test dependencies
```

## 🐳 Docker Configuration

### Services

**Web Application:**
- Image: `aqsaimtiaz/mediconsult-app:latest`
- Port: 8501
- Dependencies: MongoDB

**MongoDB:**
- Image: `mongo:latest`
- Port: 27017
- Volume: `mongodb_data` (persistent)

### Commands

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f web

# Stop services
docker-compose down

# Rebuild images
docker-compose build --no-cache
```

## 👥 Collaborators

- **Instructor**: qasimalik@gmail.com (GitHub collaborator)

### Adding Instructor as Collaborator

1. Go to repository **Settings** → **Collaborators**
2. Click **Add people**
3. Enter: `qasimalik@gmail.com`
4. Send invitation

## 📧 Email Configuration

### Jenkins Setup

1. Install **Email Extension Plugin**
2. Configure SMTP settings:
   - Gmail: `smtp.gmail.com:587`
   - Use App Password
3. Test email configuration
4. Pipeline will auto-send to Git committer

### Testing Email Flow

```bash
git add .
git commit -m "Test email notification"
git push origin main
```

Expected: Email received with test results

## 🔒 Security Notes

- Admin credentials are for testing only
- Use environment variables for secrets in production
- MongoDB should have authentication enabled for production
- HTTPS recommended for production deployment

## 📊 Monitoring

### Jenkins Dashboard
- Build history
- Test trends
- Console output
- Email delivery status

### Docker Health
```bash
docker ps                    # Check running containers
docker stats                 # Resource usage
docker-compose logs          # Application logs
```

## 🎯 Assignment Requirements

### Part I: Selenium Tests ✅
- ✅ 12 automated test cases (requirement: minimum 10)
- ✅ Headless Chrome for CI/CD
- ✅ Comprehensive test coverage
- ✅ Test report generation

### Part II: Jenkins Pipeline ✅
- ✅ Automated build and test
- ✅ GitHub webhook integration
- ✅ Email notifications to collaborator
- ✅ Dockerized test environment

## 📝 Report

Report includes:
- Screenshots of:
  - GitHub repository with collaborator
  - Jenkins pipeline execution
  - Email notifications (success/failure)
  - Test results
  - Docker containers running
- Step-by-step setup instructions
- Jenkinsfile code
- Test case descriptions

## 🤝 Contributing

This is an academic project. For issues or questions:
- Contact instructor: qasimalik@gmail.com
- Create GitHub issue

## 📄 License

Academic project for CSC483 course at COMSATS University.

## 🙏 Acknowledgments

- COMSATS University, Islamabad
- Instructor: Qasim Malik
- Course: CSC483 – DevOps

---

**Last Updated**: December 2025  
**Course**: CSC483 – Topics in Computer Science II (DevOps)  
**Institution**: COMSATS University, Islamabad
