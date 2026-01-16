# Database Schema Setup

This directory contains SQL scripts to manually create the database and tables for the authentication application.

## Quick Start

### MySQL

```bash
# Option 1: Using MySQL command line
mysql -u root -p < mysql_schema.sql

# Option 2: Using MySQL client
mysql -u root -p
source mysql_schema.sql
```

### PostgreSQL

```bash
# Option 1: Using psql command line
psql -U postgres -f postgresql_schema.sql

# Option 2: Using psql client
psql -U postgres
\i postgresql_schema.sql
```

## Files

- **`mysql_schema.sql`** - Complete MySQL schema with indexes and constraints
- **`postgresql_schema.sql`** - Complete PostgreSQL schema with indexes and constraints
- **`schema.sql`** - Universal template (requires minor adjustments)

## Tables

### `users`
- `id` - Primary key (BIGINT/BIGSERIAL)
- `username` - Unique username (VARCHAR(50))
- `email` - Unique email address (VARCHAR(255))
- `password` - BCrypt hashed password (VARCHAR(255))
- `role` - User role: USER or ADMIN (VARCHAR(20))
- `is_verified` - Email verification status (BOOLEAN)
- `created_at` - Account creation timestamp (TIMESTAMP)

### `otp_codes`
- `id` - Primary key (BIGINT/BIGSERIAL)
- `user_id` - Foreign key to users table (BIGINT)
- `otp_code` - 6-digit OTP code (VARCHAR(6))
- `expiry_time` - OTP expiration timestamp (TIMESTAMP)
- `type` - OTP type: REGISTRATION or RESET_PASSWORD (VARCHAR(20))
- `used` - Whether OTP has been used (BOOLEAN)

## Automatic Table Creation

If you're using Spring Boot with `spring.jpa.hibernate.ddl-auto=update` in `application.properties`, the tables will be created automatically. These SQL scripts are provided for:

1. Manual database setup
2. Production deployments
3. Understanding the schema structure
4. Database migrations

## Verification

After running the schema, verify with:

**MySQL:**
```sql
SHOW TABLES;
DESCRIBE users;
DESCRIBE otp_codes;
```

**PostgreSQL:**
```sql
\dt
\d users
\d otp_codes
```
