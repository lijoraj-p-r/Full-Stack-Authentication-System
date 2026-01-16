# Registration Flow Changes

## Overview

The registration flow has been updated so that **user data is only saved to the database AFTER email verification**. Previously, users were created immediately upon registration and only marked as verified after OTP confirmation.

## New Flow

### Before (Old Flow):
1. User registers → User created in `users` table immediately (unverified)
2. OTP sent to email
3. User verifies OTP → User marked as verified

### After (New Flow):
1. User registers → Data stored in `pending_registrations` table (temporary)
2. OTP sent to email
3. User verifies OTP → User created in `users` table (verified) + Pending registration deleted

## Changes Made

### 1. New Entity: `PendingRegistration`
- Stores unverified registration data temporarily
- Fields: id, username, email, password (hashed), role, created_at
- Table: `pending_registrations`

### 2. Updated Entity: `OtpCode`
- Added `email` field (nullable) to support OTPs for pending registrations
- `user_id` is now nullable (for registration OTPs before user exists)

### 3. New Service: `PendingRegistrationService`
- Manages temporary registration data
- Methods:
  - `createPendingRegistration()` - Store registration data temporarily
  - `findByEmail()` - Retrieve pending registration
  - `deleteByEmail()` - Clean up after verification

### 4. Updated Service: `OtpService`
- Added `createOtpForEmail()` - Create OTP for email (no user required)
- Added `verifyOtpByEmail()` - Verify OTP using email
- Updated `createOtp()` to support both user-based and email-based OTPs

### 5. Updated Service: `AuthService`
- `register()` - Now creates pending registration instead of user
- `verifyOtp()` - Creates user only after OTP verification
- Uses `createUserWithHashedPassword()` to avoid double hashing

### 6. Updated Service: `UserService`
- Added `createUserWithHashedPassword()` - Create user with pre-hashed password
- Added `existsByEmail()` and `existsByUsername()` - Check if user exists
- Added `saveUser()` - Save user entity

### 7. Database Schema Updates
- Added `pending_registrations` table
- Updated `otp_codes` table to include `email` field (nullable)
- Made `user_id` nullable in `otp_codes` table

## Security Benefits

1. **No Unverified Users**: Users are only created after email verification
2. **Clean Database**: No unverified accounts cluttering the users table
3. **Automatic Cleanup**: Pending registrations are deleted after verification
4. **Email Validation**: Ensures email ownership before account creation

## Database Migration

If you have existing data, you'll need to:

1. **Run the updated SQL schema** to create `pending_registrations` table
2. **Update `otp_codes` table** to add `email` column and make `user_id` nullable

### MySQL Migration:
```sql
ALTER TABLE otp_codes 
ADD COLUMN email VARCHAR(255) NULL AFTER user_id,
MODIFY COLUMN user_id BIGINT NULL;
```

### PostgreSQL Migration:
```sql
ALTER TABLE otp_codes 
ADD COLUMN email VARCHAR(255) NULL,
ALTER COLUMN user_id DROP NOT NULL;
```

## Testing

1. Register a new user → Check `pending_registrations` table (should have entry)
2. Check `users` table → Should NOT have the new user yet
3. Verify OTP → Check `users` table (should have user, verified=true)
4. Check `pending_registrations` → Entry should be deleted

## Notes

- Pending registrations are automatically cleaned up after successful verification
- OTP expiration (5 minutes) still applies
- Rate limiting still works for OTP requests
- Password reset flow remains unchanged (requires existing user)
