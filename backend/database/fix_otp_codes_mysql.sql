-- Fix otp_codes table to allow null user_id
USE auth_db;

-- Drop foreign key constraint first
SET @constraint_name = (
    SELECT CONSTRAINT_NAME 
    FROM information_schema.KEY_COLUMN_USAGE 
    WHERE TABLE_SCHEMA = 'auth_db' 
    AND TABLE_NAME = 'otp_codes' 
    AND COLUMN_NAME = 'user_id' 
    AND REFERENCED_TABLE_NAME IS NOT NULL
    LIMIT 1
);

SET @sql = IF(@constraint_name IS NOT NULL, 
    CONCAT('ALTER TABLE otp_codes DROP FOREIGN KEY ', @constraint_name), 
    'SELECT "No foreign key to drop"');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Make user_id nullable
ALTER TABLE otp_codes MODIFY COLUMN user_id BIGINT NULL;

-- Add email column if it doesn't exist
SET @col_exists = (
    SELECT COUNT(*) 
    FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = 'auth_db' 
    AND TABLE_NAME = 'otp_codes' 
    AND COLUMN_NAME = 'email'
);

SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE otp_codes ADD COLUMN email VARCHAR(255) NULL AFTER user_id', 
    'SELECT "Email column already exists"');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Re-add foreign key constraint (nullable)
ALTER TABLE otp_codes 
ADD CONSTRAINT fk_otp_user 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_otp_codes_email ON otp_codes(email);
CREATE INDEX IF NOT EXISTS idx_otp_codes_email_otp_type ON otp_codes(email, otp_code, type, used);
