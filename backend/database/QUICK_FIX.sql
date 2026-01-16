-- QUICK FIX: Run this in MySQL to fix the otp_codes table
-- This makes user_id nullable so registration OTPs can work

USE auth_db;

-- Find and drop the foreign key constraint
-- Check what the constraint name is first:
SHOW CREATE TABLE otp_codes;

-- Then drop it (replace 'otp_codes_ibfk_1' with actual name from above):
ALTER TABLE otp_codes DROP FOREIGN KEY otp_codes_ibfk_1;

-- Make user_id nullable
ALTER TABLE otp_codes MODIFY COLUMN user_id BIGINT NULL;

-- Add email column if missing (check first to avoid error)
-- If column exists, this will error but that's okay - just continue
ALTER TABLE otp_codes ADD COLUMN email VARCHAR(255) NULL AFTER user_id;

-- Re-add foreign key (allowing null)
ALTER TABLE otp_codes 
ADD CONSTRAINT fk_otp_user 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_otp_codes_email ON otp_codes(email);
CREATE INDEX IF NOT EXISTS idx_otp_codes_email_otp_type ON otp_codes(email, otp_code, type, used);
