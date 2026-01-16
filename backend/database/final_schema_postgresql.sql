-- ============================================
-- FINAL DATABASE SCHEMA - Auth Application (PostgreSQL)
-- Complete setup with all fixes applied
-- ============================================

-- Create database (run as superuser)
-- CREATE DATABASE auth_db;
-- \c auth_db;

-- ============================================
-- Table: users
-- Stores verified user accounts
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for users table
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_is_verified ON users(is_verified);

-- ============================================
-- Table: pending_registrations
-- Stores unverified registration data temporarily
-- Data is moved to users table after email verification
-- ============================================
CREATE TABLE IF NOT EXISTS pending_registrations (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for pending_registrations table
CREATE INDEX IF NOT EXISTS idx_pending_registrations_email ON pending_registrations(email);
CREATE INDEX IF NOT EXISTS idx_pending_registrations_username ON pending_registrations(username);

-- ============================================
-- Table: otp_codes
-- Stores OTP codes for email verification and password reset
-- user_id is NULL for registration OTPs (before user exists)
-- email is used for registration OTPs
-- ============================================
CREATE TABLE IF NOT EXISTS otp_codes (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NULL,  -- NULL for registration OTPs, NOT NULL for password reset
    email VARCHAR(255) NULL,  -- Used for registration OTPs before user exists
    otp_code VARCHAR(6) NOT NULL,
    expiry_time TIMESTAMP NOT NULL,
    type VARCHAR(20) NOT NULL,  -- 'REGISTRATION' or 'RESET_PASSWORD'
    used BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Foreign key constraint (nullable for registration OTPs)
    CONSTRAINT fk_otp_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
);

-- Create indexes for otp_codes table
CREATE INDEX IF NOT EXISTS idx_otp_codes_user_id ON otp_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_otp_codes_email ON otp_codes(email);
CREATE INDEX IF NOT EXISTS idx_otp_codes_otp_code ON otp_codes(otp_code);
CREATE INDEX IF NOT EXISTS idx_otp_codes_expiry_time ON otp_codes(expiry_time);
CREATE INDEX IF NOT EXISTS idx_otp_codes_type ON otp_codes(type);
CREATE INDEX IF NOT EXISTS idx_otp_codes_used ON otp_codes(used);
CREATE INDEX IF NOT EXISTS idx_otp_codes_user_otp_type ON otp_codes(user_id, otp_code, type, used);
CREATE INDEX IF NOT EXISTS idx_otp_codes_email_otp_type ON otp_codes(email, otp_code, type, used);

-- ============================================
-- Optional: Cleanup function for expired OTPs
-- ============================================
CREATE OR REPLACE FUNCTION cleanup_expired_otps()
RETURNS void AS $$
BEGIN
    DELETE FROM otp_codes 
    WHERE expiry_time < NOW();
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Verification Queries
-- ============================================
-- Run these to verify the schema:
-- \dt
-- \d users
-- \d pending_registrations
-- \d otp_codes
-- \di

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
