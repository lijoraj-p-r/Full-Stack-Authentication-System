-- ============================================
-- RUN THIS TO FIX THE ERROR
-- Execute: mysql -u root -p auth_db < RUN_THIS_FIX.sql
-- ============================================

USE auth_db;

-- Step 1: Show current constraints
SHOW CREATE TABLE otp_codes\G

-- Step 2: Drop foreign key (adjust name if needed from Step 1)
ALTER TABLE otp_codes DROP FOREIGN KEY otp_codes_ibfk_1;

-- Step 3: Make user_id nullable
ALTER TABLE otp_codes MODIFY COLUMN user_id BIGINT NULL;

-- Step 4: Add email column (ignore error if already exists)
ALTER TABLE otp_codes ADD COLUMN email VARCHAR(255) NULL AFTER user_id;

-- Step 5: Re-add foreign key
ALTER TABLE otp_codes 
ADD CONSTRAINT fk_otp_user 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Step 6: Add indexes
CREATE INDEX idx_otp_codes_email ON otp_codes(email);
CREATE INDEX idx_otp_codes_email_otp_type ON otp_codes(email, otp_code, type, used);

-- Verify
DESCRIBE otp_codes;
