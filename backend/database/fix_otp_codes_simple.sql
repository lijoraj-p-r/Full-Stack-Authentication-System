-- ============================================
-- Simple Migration: Fix otp_codes table
-- Run this SQL script to fix the user_id constraint
-- ============================================

USE auth_db;

-- Step 1: Drop the existing foreign key constraint
-- (Replace 'otp_codes_ibfk_1' with your actual constraint name if different)
ALTER TABLE otp_codes DROP FOREIGN KEY otp_codes_ibfk_1;

-- Step 2: Make user_id nullable
ALTER TABLE otp_codes MODIFY COLUMN user_id BIGINT NULL;

-- Step 3: Add email column (if it doesn't exist)
ALTER TABLE otp_codes ADD COLUMN email VARCHAR(255) NULL AFTER user_id;

-- Step 4: Re-add foreign key constraint (allowing null)
ALTER TABLE otp_codes 
ADD CONSTRAINT fk_otp_user 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Step 5: Add indexes for email-based queries
CREATE INDEX idx_otp_codes_email ON otp_codes(email);
CREATE INDEX idx_otp_codes_email_otp_type ON otp_codes(email, otp_code, type, used);
