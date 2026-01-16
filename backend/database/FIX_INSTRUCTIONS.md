# Fix OTP Codes Table - Instructions

## Problem
The `otp_codes` table has `user_id` as NOT NULL, but we need it to be nullable for registration OTPs (before user is created).

## Solution

### Option 1: Run SQL Migration (Recommended)

1. **Find the foreign key constraint name:**
```sql
SELECT CONSTRAINT_NAME 
FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'auth_db' 
AND TABLE_NAME = 'otp_codes' 
AND COLUMN_NAME = 'user_id' 
AND REFERENCED_TABLE_NAME IS NOT NULL;
```

2. **Run the migration script:**
```bash
mysql -u root -p auth_db < backend/database/fix_otp_codes_simple.sql
```

Or manually in MySQL:
```sql
USE auth_db;

-- Drop foreign key (replace constraint name if different)
ALTER TABLE otp_codes DROP FOREIGN KEY otp_codes_ibfk_1;

-- Make user_id nullable
ALTER TABLE otp_codes MODIFY COLUMN user_id BIGINT NULL;

-- Add email column
ALTER TABLE otp_codes ADD COLUMN email VARCHAR(255) NULL AFTER user_id;

-- Re-add foreign key
ALTER TABLE otp_codes 
ADD CONSTRAINT fk_otp_user 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Add indexes
CREATE INDEX idx_otp_codes_email ON otp_codes(email);
CREATE INDEX idx_otp_codes_email_otp_type ON otp_codes(email, otp_code, type, used);
```

### Option 2: Let Hibernate Update (If ddl-auto=update)

1. **Restart the Spring Boot application**
2. Hibernate should automatically update the schema
3. If it doesn't work, use Option 1

### Option 3: Drop and Recreate Table

**⚠️ WARNING: This will delete all OTP codes!**

```sql
USE auth_db;
DROP TABLE IF EXISTS otp_codes;

-- Then restart the app, Hibernate will recreate it
```

## Verification

After running the migration, verify with:
```sql
DESCRIBE otp_codes;
-- Check that user_id shows NULL in the Null column
-- Check that email column exists
```

## After Fix

The application should now work correctly:
- Registration OTPs can be created without a user_id
- Password reset OTPs still work with user_id
- Both email and user_id can be used for OTP lookups
