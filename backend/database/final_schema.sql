-- ============================================
-- FINAL DATABASE SCHEMA - Auth Application
-- Complete setup with all fixes applied
-- ============================================

-- Create database
CREATE DATABASE IF NOT EXISTS auth_db;
USE auth_db;

-- ============================================
-- Table: users
-- Stores verified user accounts
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes for performance
    INDEX idx_users_email (email),
    INDEX idx_users_username (username),
    INDEX idx_users_role (role),
    INDEX idx_users_is_verified (is_verified)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Table: pending_registrations
-- Stores unverified registration data temporarily
-- Data is moved to users table after email verification
-- ============================================
CREATE TABLE IF NOT EXISTS pending_registrations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes for performance
    INDEX idx_pending_registrations_email (email),
    INDEX idx_pending_registrations_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Table: otp_codes
-- Stores OTP codes for email verification and password reset
-- user_id is NULL for registration OTPs (before user exists)
-- email is used for registration OTPs
-- ============================================
CREATE TABLE IF NOT EXISTS otp_codes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NULL,  -- NULL for registration OTPs, NOT NULL for password reset
    email VARCHAR(255) NULL,  -- Used for registration OTPs before user exists
    otp_code VARCHAR(6) NOT NULL,
    expiry_time TIMESTAMP NOT NULL,
    type VARCHAR(20) NOT NULL,  -- 'REGISTRATION' or 'RESET_PASSWORD'
    used BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Foreign key constraint (nullable for registration OTPs)
    CONSTRAINT fk_otp_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes for performance
    INDEX idx_otp_codes_user_id (user_id),
    INDEX idx_otp_codes_email (email),
    INDEX idx_otp_codes_otp_code (otp_code),
    INDEX idx_otp_codes_expiry_time (expiry_time),
    INDEX idx_otp_codes_type (type),
    INDEX idx_otp_codes_used (used),
    INDEX idx_otp_codes_user_otp_type (user_id, otp_code, type, used),
    INDEX idx_otp_codes_email_otp_type (email, otp_code, type, used)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Verification Queries
-- ============================================
-- Run these to verify the schema:
-- SHOW TABLES;
-- DESCRIBE users;
-- DESCRIBE pending_registrations;
-- DESCRIBE otp_codes;
-- SHOW INDEXES FROM users;
-- SHOW INDEXES FROM pending_registrations;
-- SHOW INDEXES FROM otp_codes;

-- ============================================
-- Notes
-- ============================================
-- 1. Users are only created AFTER email verification
-- 2. Registration flow:
--    - User registers → Data saved to pending_registrations
--    - OTP sent → Stored in otp_codes with email (no user_id)
--    - User verifies OTP → User created in users table, pending_registration deleted
-- 3. Password reset flow:
--    - User requests reset → OTP stored in otp_codes with user_id (no email)
--    - User verifies OTP → Password updated
-- 4. OTP expires after 5 minutes
-- 5. Rate limiting: 1 OTP per minute per email/user
