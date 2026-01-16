-- ============================================
-- Universal Database Schema Template
-- Works with both MySQL and PostgreSQL (with minor adjustments)
-- ============================================

-- MySQL: CREATE DATABASE IF NOT EXISTS auth_db;
-- PostgreSQL: CREATE DATABASE auth_db; (run as superuser)

-- MySQL: USE auth_db;
-- PostgreSQL: \c auth_db;

-- ============================================
-- Table: users
-- Stores user account information
-- ============================================
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,  -- PostgreSQL: BIGSERIAL PRIMARY KEY
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Table: otp_codes
-- Stores one-time password codes for email verification and password reset
-- ============================================
CREATE TABLE otp_codes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,  -- PostgreSQL: BIGSERIAL PRIMARY KEY
    user_id BIGINT NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    expiry_time TIMESTAMP NOT NULL,
    type VARCHAR(20) NOT NULL,  -- 'REGISTRATION' or 'RESET_PASSWORD'
    used BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Foreign key constraint
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- Indexes for Performance
-- ============================================

-- Users table indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_verified ON users(is_verified);

-- OTP codes table indexes
CREATE INDEX idx_otp_codes_user_id ON otp_codes(user_id);
CREATE INDEX idx_otp_codes_otp_code ON otp_codes(otp_code);
CREATE INDEX idx_otp_codes_expiry_time ON otp_codes(expiry_time);
CREATE INDEX idx_otp_codes_type ON otp_codes(type);
CREATE INDEX idx_otp_codes_used ON otp_codes(used);
CREATE INDEX idx_otp_codes_composite ON otp_codes(user_id, otp_code, type, used);

-- ============================================
-- Notes:
-- ============================================
-- 1. For MySQL: Use mysql_schema.sql
-- 2. For PostgreSQL: Use postgresql_schema.sql
-- 3. Adjust AUTO_INCREMENT (MySQL) to BIGSERIAL (PostgreSQL)
-- 4. Spring Boot will auto-create tables if spring.jpa.hibernate.ddl-auto=update
-- 5. This script is for manual database setup
