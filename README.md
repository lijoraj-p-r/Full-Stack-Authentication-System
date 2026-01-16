# 🔐 Full-Stack Authentication System

<div align="center">

![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-brightgreen.svg)
![React](https://img.shields.io/badge/React-18.2.0-blue.svg)
![Java](https://img.shields.io/badge/Java-17-orange.svg)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

**A production-ready authentication system with OTP verification, JWT tokens, and role-based access control**

[Features](#-features) • [Quick Start](#-quick-start) • [API Docs](#-api-documentation) • [Architecture](#-architecture)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Quick Start](#-quick-start)
- [Configuration](#-configuration)
- [API Documentation](#-api-documentation)
- [Project Structure](#-project-structure)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)
- [Development](#-development)

---

## 🎯 Overview

A modern, secure authentication system built with **Spring Boot** and **React**. This application provides a complete authentication flow including user registration, email verification via OTP, secure login with JWT tokens, password reset functionality, and role-based access control.

### What Makes This Special?

✨ **Production-Ready** - Built with security best practices  
🚀 **Modern Stack** - Latest Spring Boot 3.2 & React 18  
🔒 **Secure by Default** - BCrypt, JWT, CORS, Rate Limiting  
📧 **Email Integration** - OTP verification via email  
🎨 **Beautiful UI** - Material-UI components with responsive design  
⚡ **Fast Development** - Hot reload, clear structure, comprehensive docs

---

## ✨ Features

### 🔑 Authentication & Security
- [x] **User Registration** with email validation
- [x] **OTP-based Email Verification** (5-minute expiration)
- [x] **Secure Login** with JWT access & refresh tokens
- [x] **Password Reset** via email OTP
- [x] **BCrypt Password Hashing** with salt rounds
- [x] **Role-Based Access Control** (USER, ADMIN)
- [x] **Rate Limiting** for OTP requests (prevents spam)

### 🛡️ Validation & Error Handling
- [x] **Frontend Validation** - Real-time form validation
- [x] **Backend Validation** - Bean Validation annotations
- [x] **Global Exception Handling** - Consistent error responses
- [x] **Password Strength** - Min 8 chars, uppercase, number required

### 🎨 User Experience
- [x] **Responsive Design** - Works on all devices
- [x] **Toast Notifications** - User-friendly feedback
- [x] **Protected Routes** - Automatic redirects
- [x] **Loading States** - Better UX during API calls

---

## 🛠️ Tech Stack

### Backend
| Technology | Version | Purpose |
|------------|---------|---------|
| **Spring Boot** | 3.2.0 | Main framework |
| **Spring Security** | Latest | Authentication & Authorization |
| **Spring Data JPA** | Latest | Database operations |
| **JWT (JJWT)** | 0.12.3 | Token-based auth |
| **BCrypt** | Built-in | Password encryption |
| **Spring Mail** | Latest | Email service |
| **Lombok** | Latest | Reduce boilerplate |
| **MySQL/PostgreSQL** | 8.0+ | Database |

### Frontend
| Technology | Version | Purpose |
|------------|---------|---------|
| **React** | 18.2.0 | UI framework |
| **React Router** | 6.20.0 | Navigation |
| **Material-UI** | 5.15.0 | UI components |
| **Axios** | 1.6.2 | HTTP client |
| **React Toastify** | 9.1.3 | Notifications |

---

## 🏗️ Architecture

### System Flow

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   React     │  HTTP   │  Spring Boot │   JPA   │   MySQL     │
│  Frontend   │◄───────►│   Backend    │◄───────►│  Database   │
└─────────────┘         └──────────────┘         └─────────────┘
      │                        │                        │
      │                        │                        │
      │                        ▼                        │
      │              ┌──────────────────┐                │
      │              │  Spring Security │                │
      │              │  + JWT Filter    │                │
      │              └──────────────────┘                │
      │                        │                        │
      │                        ▼                        │
      │              ┌──────────────────┐                │
      │              │  Email Service  │                │
      │              │  (SMTP/Gmail)    │                │
      │              └──────────────────┘                │
      │                                                  │
      └──────────────────────────────────────────────────┘
```

### Authentication Flow

```
Registration Flow:
User → Register → OTP Email → Verify OTP → Login → Dashboard

Login Flow:
User → Login → JWT Token → Protected Routes

Password Reset Flow:
User → Forgot Password → OTP Email → Verify OTP → Reset Password → Login
```

### Backend Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Controllers Layer                     │
│  (AuthController, UserController)                        │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                    Service Layer                         │
│  (AuthService, UserService, OtpService, EmailService)   │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                  Repository Layer                        │
│  (UserRepository, OtpCodeRepository)                    │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                    Database                              │
│  (users, otp_codes tables)                              │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

Make sure you have the following installed:

- ☕ **Java 17+** - [Download](https://adoptium.net/)
- 📦 **Maven 3.6+** - [Download](https://maven.apache.org/)
- 🟢 **Node.js 16+** & **npm** - [Download](https://nodejs.org/)
- 🗄️ **MySQL 8+** or **PostgreSQL 12+** - [Download MySQL](https://dev.mysql.com/downloads/) | [Download PostgreSQL](https://www.postgresql.org/download/)
- 📧 **Gmail Account** (for OTP emails)

### 1️⃣ Clone & Setup Database

```bash
# Create database
mysql -u root -p
CREATE DATABASE auth_db;
exit;
```

### 2️⃣ Backend Setup

```bash
# Navigate to backend
cd backend

# Configure application.properties
# Update database credentials and email settings
nano src/main/resources/application.properties

# Build and run
mvn clean install
mvn spring-boot:run
```

✅ Backend running on `http://localhost:8080`

### 3️⃣ Frontend Setup

```bash
# Navigate to frontend (in a new terminal)
cd frontend

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Start development server
npm start
```

✅ Frontend running on `http://localhost:3000`

### 4️⃣ Test the Application

1. Open `http://localhost:3000`
2. Click **Sign Up**
3. Register with your email
4. Check email for OTP
5. Verify and login!

---

## ⚙️ Configuration

### Backend Configuration

Edit `backend/src/main/resources/application.properties`:

```properties
# Database
spring.datasource.url=jdbc:mysql://localhost:3306/auth_db
spring.datasource.username=root
spring.datasource.password=your_password

# Email (Gmail)
spring.mail.username=your-email@gmail.com
spring.mail.password=your-app-password  # Generate from Google Account

# JWT Secret (IMPORTANT: Change in production!)
jwt.secret=your-256-bit-secret-key-minimum-32-characters-long

# OTP Settings
otp.expiration.minutes=5
otp.rate-limit.minutes=1
```

### Gmail App Password Setup

1. Go to [Google Account](https://myaccount.google.com/)
2. Enable **2-Step Verification**
3. Go to [App Passwords](https://myaccount.google.com/apppasswords)
4. Generate app password for "Mail"
5. Use the generated password in `spring.mail.password`

### Frontend Configuration

Create `frontend/.env`:

```env
REACT_APP_API_URL=http://localhost:8080/api
```

---

## 📚 API Documentation

### Base URL
```
http://localhost:8080/api
```

### Authentication Endpoints

#### 🔵 Register User

```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "SecurePass123"
}
```

**Response:**
```json
{
  "message": "Registration successful. OTP sent to your email."
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john@example.com",
    "password": "SecurePass123"
  }'
```

---

#### 🔵 Verify OTP

```http
POST /api/auth/verify-otp
Content-Type: application/json

{
  "email": "john@example.com",
  "otpCode": "123456"
}
```

**Response:**
```json
{
  "message": "Email verified successfully. You can now login."
}
```

---

#### 🔵 Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123"
}
```

**Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "user": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "role": "USER",
    "isVerified": true,
    "createdAt": "2024-01-15T10:30:00"
  }
}
```

**JavaScript Example:**
```javascript
const response = await fetch('http://localhost:8080/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'john@example.com',
    password: 'SecurePass123'
  })
});

const data = await response.json();
localStorage.setItem('accessToken', data.accessToken);
```

---

#### 🔵 Forgot Password

```http
POST /api/auth/forgot-password
Content-Type: application/json

{
  "email": "john@example.com"
}
```

**Response:**
```json
{
  "message": "OTP sent to your email for password reset."
}
```

---

#### 🔵 Reset Password

```http
POST /api/auth/reset-password
Content-Type: application/json

{
  "email": "john@example.com",
  "otpCode": "123456",
  "newPassword": "NewSecurePass123"
}
```

**Response:**
```json
{
  "message": "Password reset successfully. You can now login with your new password."
}
```

---

### User Endpoints

#### 🔒 Get Current User (Protected)

```http
GET /api/users/me
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "id": 1,
  "username": "johndoe",
  "email": "john@example.com",
  "role": "USER",
  "isVerified": true,
  "createdAt": "2024-01-15T10:30:00"
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:8080/api/users/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## 📁 Project Structure

```
SpringBootFullStack/
│
├── 📂 backend/
│   ├── 📂 src/main/
│   │   ├── 📂 java/com/example/auth/
│   │   │   ├── 📂 config/              # Security, CORS config
│   │   │   │   ├── SecurityConfig.java
│   │   │   │   └── UserDetailsServiceImpl.java
│   │   │   ├── 📂 controller/          # REST endpoints
│   │   │   │   ├── AuthController.java
│   │   │   │   └── UserController.java
│   │   │   ├── 📂 dto/                 # Data Transfer Objects
│   │   │   │   ├── RegisterRequest.java
│   │   │   │   ├── LoginRequest.java
│   │   │   │   └── AuthResponse.java
│   │   │   ├── 📂 entity/              # JPA entities
│   │   │   │   ├── User.java
│   │   │   │   └── OtpCode.java
│   │   │   ├── 📂 exception/           # Error handling
│   │   │   │   └── GlobalExceptionHandler.java
│   │   │   ├── 📂 repository/          # Data access
│   │   │   │   ├── UserRepository.java
│   │   │   │   └── OtpCodeRepository.java
│   │   │   ├── 📂 security/            # JWT filter
│   │   │   │   └── JwtAuthenticationFilter.java
│   │   │   └── 📂 service/             # Business logic
│   │   │       ├── AuthService.java
│   │   │       ├── UserService.java
│   │   │       ├── OtpService.java
│   │   │       ├── EmailService.java
│   │   │       └── JwtService.java
│   │   └── 📂 resources/
│   │       └── application.properties
│   └── pom.xml
│
└── 📂 frontend/
    ├── 📂 src/
    │   ├── 📂 components/              # Reusable components
    │   │   └── PrivateRoute.js
    │   ├── 📂 pages/                   # Page components
    │   │   ├── Login.js
    │   │   ├── SignUp.js
    │   │   ├── ForgotPassword.js
    │   │   └── Dashboard.js
    │   ├── 📂 services/                # API calls
    │   │   └── api.js
    │   ├── 📂 utils/                   # Helpers
    │   │   └── validation.js
    │   ├── App.js
    │   └── index.js
    ├── package.json
    └── .env.example
```

---

## 🔒 Security

### Security Features

| Feature | Implementation | Description |
|---------|---------------|-------------|
| **Password Hashing** | BCrypt | Salted password hashing |
| **JWT Tokens** | JJWT Library | Access + Refresh tokens |
| **CORS** | Spring Security | Configured for frontend origin |
| **Rate Limiting** | Custom Service | OTP request throttling |
| **Input Validation** | Bean Validation | Frontend + Backend validation |
| **SQL Injection** | JPA | Parameterized queries |
| **XSS Protection** | React | Built-in XSS protection |

### Password Requirements

- ✅ Minimum 8 characters
- ✅ At least one uppercase letter
- ✅ At least one number

### JWT Token Structure

```json
{
  "sub": "user@example.com",
  "role": "USER",
  "iat": 1705315200,
  "exp": 1705401600
}
```

### Security Best Practices

1. **Change JWT Secret** - Use a strong, random secret (min 32 chars)
2. **Use HTTPS** - In production, always use HTTPS
3. **Environment Variables** - Never commit secrets to git
4. **Rate Limiting** - Already implemented for OTP
5. **Token Expiration** - Tokens expire after 24 hours

---

## 🐛 Troubleshooting

### ❌ Email Not Sending

**Problem:** OTP emails not received

**Solutions:**
```bash
# 1. Verify Gmail App Password
# Use App Password, not regular password

# 2. Check application.properties
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your-email@gmail.com
spring.mail.password=your-app-password

# 3. Test SMTP connection
telnet smtp.gmail.com 587
```

---

### ❌ Database Connection Failed

**Problem:** Cannot connect to database

**Solutions:**
```bash
# 1. Verify database is running
mysql -u root -p
SHOW DATABASES;

# 2. Check credentials in application.properties
spring.datasource.username=root
spring.datasource.password=your_password

# 3. Verify database exists
CREATE DATABASE IF NOT EXISTS auth_db;
```

---

### ❌ CORS Errors

**Problem:** Frontend can't call backend API

**Solutions:**
```properties
# In application.properties, verify:
cors.allowed-origins=http://localhost:3000

# Check browser console for specific error
# Ensure backend is running on port 8080
```

---

### ❌ JWT Token Invalid

**Problem:** Token authentication fails

**Solutions:**
```bash
# 1. Verify JWT secret is set
jwt.secret=your-256-bit-secret-key

# 2. Check token expiration
jwt.expiration=86400000  # 24 hours

# 3. Verify Authorization header format
Authorization: Bearer <token>
```

---

## 💻 Development

### Running Tests

```bash
# Backend tests
cd backend
mvn test

# Frontend tests
cd frontend
npm test
```

### Building for Production

```bash
# Backend JAR
cd backend
mvn clean package
java -jar target/auth-service-1.0.0.jar

# Frontend build
cd frontend
npm run build
# Serve build/ folder with nginx/apache
```

### Development Tips

```bash
# Hot reload (backend)
# Spring Boot DevTools enables auto-restart

# Hot reload (frontend)
# React automatically reloads on file changes

# View logs
tail -f backend/logs/application.log
```

### Code Style

- **Backend:** Follow Spring Boot conventions
- **Frontend:** ESLint + Prettier recommended
- **Naming:** camelCase for variables, PascalCase for classes

---

## 📊 Database Schema

### Users Table

```sql
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### OTP Codes Table

```sql
CREATE TABLE otp_codes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    expiry_time TIMESTAMP NOT NULL,
    type VARCHAR(20) NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. 🍴 Fork the repository
2. 🌿 Create a feature branch (`git checkout -b feature/amazing-feature`)
3. 💾 Commit your changes (`git commit -m 'Add amazing feature'`)
4. 📤 Push to the branch (`git push origin feature/amazing-feature`)
5. 🔄 Open a Pull Request

### Contribution Guidelines

- Follow existing code style
- Add tests for new features
- Update documentation
- Ensure all tests pass

---

## 📝 License

This project is licensed under the **MIT License** - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- **Spring Boot** - Amazing Java framework
- **React** - Powerful UI library
- **Material-UI** - Beautiful components
- **Community** - For all the support and feedback

---

<div align="center">

**Made with ❤️ using Spring Boot & React**

⭐ Star this repo if you find it helpful!

[Report Bug](https://github.com/your-repo/issues) • [Request Feature](https://github.com/your-repo/issues)

</div>
