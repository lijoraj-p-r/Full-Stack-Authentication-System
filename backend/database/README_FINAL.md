# Final Database Schema

This directory contains the **final, complete database schema** with all fixes applied.

## Files

- **`final_schema.sql`** - MySQL complete schema (USE THIS)
- **`final_schema_postgresql.sql`** - PostgreSQL complete schema

## Quick Setup

### MySQL
```bash
mysql -u root -p < backend/database/final_schema.sql
```

### PostgreSQL
```bash
psql -U postgres -f backend/database/final_schema_postgresql.sql
```

## Database Structure

### 1. `users` Table
- Stores **verified** user accounts only
- Users are created **after** email verification
- Fields: id, username, email, password, role, is_verified, created_at

### 2. `pending_registrations` Table
- Stores **temporary** registration data
- Used during registration before email verification
- Deleted after successful verification
- Fields: id, username, email, password, role, created_at

### 3. `otp_codes` Table
- Stores OTP codes for verification
- **user_id** is NULL for registration OTPs (before user exists)
- **email** is used for registration OTPs
- Fields: id, user_id (nullable), email (nullable), otp_code, expiry_time, type, used

## Registration Flow

```
1. User registers
   ↓
2. Data saved to pending_registrations
   ↓
3. OTP created in otp_codes (with email, no user_id)
   ↓
4. OTP sent to email
   ↓
5. User verifies OTP
   ↓
6. User created in users table (verified=true)
   ↓
7. pending_registration deleted
```

## Password Reset Flow

```
1. User requests password reset
   ↓
2. OTP created in otp_codes (with user_id, no email)
   ↓
3. OTP sent to email
   ↓
4. User verifies OTP
   ↓
5. Password updated
```

## Key Features

✅ **No unverified users** - Users only exist after verification  
✅ **Nullable user_id** - Supports registration OTPs  
✅ **Email-based OTPs** - For pending registrations  
✅ **Automatic cleanup** - Pending registrations deleted after verification  
✅ **Proper indexes** - Optimized for all query patterns  
✅ **Foreign keys** - Maintains referential integrity  

## Migration from Old Schema

If you have an existing database:

1. **Backup your data**
2. **Drop old tables** (if starting fresh):
   ```sql
   DROP TABLE IF EXISTS otp_codes;
   DROP TABLE IF EXISTS users;
   ```
3. **Run final_schema.sql** to recreate with correct structure

Or use the migration scripts in this directory to update existing tables.

## Verification

After running the schema, verify with:

**MySQL:**
```sql
SHOW TABLES;
DESCRIBE users;
DESCRIBE pending_registrations;
DESCRIBE otp_codes;
```

**PostgreSQL:**
```sql
\dt
\d users
\d pending_registrations
\d otp_codes
```

## Notes

- All tables use UTF8MB4 encoding (MySQL) for full Unicode support
- Timestamps use CURRENT_TIMESTAMP as default
- Foreign keys cascade on delete
- Indexes optimized for common query patterns
- OTP expiration: 5 minutes
- Rate limiting: 1 OTP per minute
