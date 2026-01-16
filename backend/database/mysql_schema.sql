-- ============================================
-- MySQL Database Schema for Auth Application
-- ============================================

-- Create database (if not exists)
CREATE DATABASE IF NOT EXISTS auth_db;
USE auth_db;

-- ============================================
-- Table: users
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
    INDEX idx_email (email),
    INDEX idx_username (username),
    INDEX idx_role (role),
    INDEX idx_is_verified (is_verified)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Table: pending_registrations
-- Stores unverified registration data (temporary)
-- ============================================
CREATE TABLE IF NOT EXISTS pending_registrations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes for performance
    INDEX idx_email (email),
    INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Table: otp_codes
-- ============================================
CREATE TABLE IF NOT EXISTS otp_codes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NULL,
    email VARCHAR(255) NULL,
    otp_code VARCHAR(6) NOT NULL,
    expiry_time TIMESTAMP NOT NULL,
    type VARCHAR(20) NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Foreign key constraint (nullable for registration OTPs)
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes for performance
    INDEX idx_user_id (user_id),
    INDEX idx_email (email),
    INDEX idx_otp_code (otp_code),
    INDEX idx_expiry_time (expiry_time),
    INDEX idx_type (type),
    INDEX idx_used (used),
    INDEX idx_user_otp_type (user_id, otp_code, type, used),
    INDEX idx_email_otp_type (email, otp_code, type, used)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Optional: Create indexes for common queries
-- ============================================

-- Index for finding valid OTPs for a user
-- Already created above as composite index

-- ============================================
-- Sample Data (Optional - for testing)
-- ============================================
-- Uncomment below to insert test data

/*
INSERT INTO users (username, email, password, role, is_verified) VALUES
('admin', 'admin@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN', TRUE),
('testuser', 'test@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'USER', FALSE);
*/

-- ============================================
-- Verification Queries
-- ============================================
-- Run these to verify the schema:
-- SHOW TABLES;
-- DESCRIBE users;
-- DESCRIBE pending_registrations;
-- DESCRIBE otp_codes;
-- SHOW INDEXES FROM users;
-- SHOW INDEXES FROM otp_codes;
