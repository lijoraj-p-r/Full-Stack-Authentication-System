-- ============================================
-- Migration Script: Fix otp_codes table
-- Makes user_id nullable and adds email column
-- ============================================

-- For MySQL
USE auth_db;

-- Drop foreign key constraint first (if exists)
ALTER TABLE otp_codes DROP FOREIGN KEY IF EXISTS otp_codes_ibfk_1;

-- Make user_id nullable
ALTER TABLE otp_codes MODIFY COLUMN user_id BIGINT NULL;

-- Add email column if it doesn't exist
ALTER TABLE otp_codes 
ADD COLUMN IF NOT EXISTS email VARCHAR(255) NULL AFTER user_id;

-- Re-add foreign key constraint (nullable)
ALTER TABLE otp_codes 
ADD CONSTRAINT fk_otp_user 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Add index for email
CREATE INDEX IF NOT EXISTS idx_otp_codes_email ON otp_codes(email);
CREATE INDEX IF NOT EXISTS idx_otp_codes_email_otp_type ON otp_codes(email, otp_code, type, used);
