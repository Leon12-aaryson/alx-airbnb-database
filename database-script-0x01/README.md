# AirBnB Database Schema - SQL Scripts

## Overview

This directory contains SQL scripts to create and manage the AirBnB platform database schema. The schema follows Third Normal Form (3NF) principles and includes comprehensive constraints, indexes, and optimization features.

## Files Structure

```text
database-script-0x01/
├── schema.sql          # Complete database schema creation script
└── README.md          # This documentation file
```

## Database Schema Features

### 🗄️ Normalized Entities (3NF Compliant)

1. **User** - Platform users (guests, hosts, admins)
2. **Location** - Normalized location data (eliminates redundancy)
3. **Property** - Rental properties with location references
4. **Booking** - Reservation records (without calculated fields)
5. **Payment** - Payment transactions with status tracking
6. **Review** - User reviews with rating constraints
7. **Message** - Inter-user communication system

### 🔗 Relationships

- **User → Property** (1:M) - Host relationship
- **Location → Property** (1:M) - Location reference
- **User → Booking** (1:M) - Guest bookings
- **Property → Booking** (1:M) - Property reservations
- **Booking → Payment** (1:1) - Payment per booking
- **User → Review** (1:M) - User reviews
- **Property → Review** (1:M) - Property reviews
- **User → Message** (M:M) - Messaging system

## Schema Implementation

### Prerequisites

- MySQL 8.0+ or MariaDB 10.4+
- Database user with CREATE, ALTER, INSERT privileges
- UTF8MB4 character set support

### Installation Steps

1. **Connect to MySQL server:**

   ```bash
   mysql -u username -p
   ```

2. **Execute the schema script:**

   ```sql
   SOURCE /path/to/schema.sql;
   ```

   Or run directly:

   ```bash
   mysql -u username -p < schema.sql
   ```

3. **Verify installation:**

   ```sql
   USE airbnb_db;
   SHOW TABLES;
   ```

## Key Features

### 🛡️ Data Integrity

#### Constraints

- **Primary Keys:** UUID-based unique identifiers
- **Foreign Keys:** Referential integrity with CASCADE options
- **Check Constraints:** Data validation (ratings 1-5, positive prices)
- **Unique Constraints:** Prevent duplicate reviews, ensure email uniqueness

#### Validation Rules

- Email format validation with regex
- Phone number format validation
- Date range validation for bookings
- Geographic coordinate bounds checking

### ⚡ Performance Optimization

#### Indexes

```sql
-- User indexes
idx_user_email, idx_user_role, idx_user_created_at

-- Property indexes
idx_property_host, idx_property_location, idx_property_price

-- Booking indexes
idx_booking_dates, idx_booking_status, idx_booking_property

-- Location indexes
idx_location_coordinates, idx_location_city, idx_location_country

-- Message indexes
idx_message_unread, idx_message_sent_at, idx_message_type
```

#### Views for Common Queries

- **BookingDetails** - Bookings with calculated total price
- **PropertyWithLocation** - Properties with full location data
- **UserStats** - User statistics and activity metrics

### 🔄 Business Logic

#### Triggers

1. **Auto-role Update** - Convert guest to host when creating property
2. **Booking Overlap Prevention** - Prevent double bookings for same dates
3. **Data Consistency** - Maintain referential integrity

#### Enhanced Features

- **Payment Status Tracking** - pending, completed, failed, refunded
- **Message Types** - inquiry, booking, general, support
- **Booking Status Flow** - pending → confirmed/canceled
- **Read Receipts** - Message read tracking

## Database Usage Examples

### Basic Operations

#### Insert a New User

```sql
INSERT INTO User (first_name, last_name, email, password_hash, role) 
VALUES ('John', 'Doe', 'john@example.com', 'hashed_password', 'guest');
```

#### Create a Location

```sql
INSERT INTO Location (country, state_province, city, address) 
VALUES ('USA', 'California', 'San Francisco', '123 Market St');
```

#### Add a Property

```sql
INSERT INTO Property (host_id, location_id, name, description, pricepernight) 
VALUES ('user_uuid', 'location_uuid', 'Cozy Apartment', 'Beautiful downtown apartment', 150.00);
```

#### Make a Booking

```sql
INSERT INTO Booking (property_id, user_id, start_date, end_date) 
VALUES ('property_uuid', 'user_uuid', '2024-07-01', '2024-07-05');
```

### Advanced Queries

#### Get Booking with Total Price

```sql
SELECT * FROM BookingDetails 
WHERE user_id = 'user_uuid' 
ORDER BY created_at DESC;
```

#### Find Available Properties

```sql
SELECT p.*, l.city, l.country 
FROM PropertyWithLocation p
WHERE p.property_id NOT IN (
    SELECT DISTINCT property_id 
    FROM Booking 
    WHERE status = 'confirmed' 
    AND '2024-07-01' BETWEEN start_date AND end_date
);
```

#### User Activity Summary

```sql
SELECT * FROM UserStats 
WHERE user_id = 'user_uuid';
```

## Data Types and Constraints

### Field Specifications

| Entity | Field | Type | Constraints |
|--------|-------|------|-------------|
| User | user_id | CHAR(36) | PRIMARY KEY, UUID |
| User | email | VARCHAR(255) | UNIQUE, NOT NULL, Email format |
| User | role | ENUM | guest/host/admin |
| Location | latitude | DECIMAL(10,8) | -90 to 90 |
| Location | longitude | DECIMAL(11,8) | -180 to 180 |
| Property | pricepernight | DECIMAL(10,2) | > 0 |
| Booking | start_date | DATE | >= CURDATE() |
| Review | rating | INTEGER | 1 to 5 |
| Payment | amount | DECIMAL(10,2) | > 0 |

### Enum Values

```sql
-- User roles
ENUM('guest', 'host', 'admin')

-- Booking status
ENUM('pending', 'confirmed', 'canceled')

-- Payment methods
ENUM('credit_card', 'paypal', 'stripe', 'bank_transfer')

-- Payment status
ENUM('pending', 'completed', 'failed', 'refunded')

-- Message types
ENUM('inquiry', 'booking', 'general', 'support')
```

## Security Considerations

### Data Protection

- Password hashing required (never store plain text)
- Email validation to prevent injection
- Input sanitization through constraints
- Proper foreign key relationships

### Access Control

- Separate database users for different application components
- Principle of least privilege for database access
- Regular security audits recommended

## Migration and Maintenance

### Schema Updates

- Use ALTER TABLE statements for schema modifications
- Backup database before major changes
- Test migrations on staging environment first

### Performance Monitoring

- Monitor query performance with EXPLAIN
- Analyze slow query logs
- Consider partitioning for large tables
- Regular index optimization

### Backup Strategy

```bash
# Full database backup
mysqldump -u username -p airbnb_db > airbnb_backup.sql

# Schema-only backup
mysqldump -u username -p --no-data airbnb_db > airbnb_schema.sql
```

## Troubleshooting

### Common Issues

1. **UUID Generation**
   - Ensure MySQL version supports UUID() function
   - Alternative: Use application-generated UUIDs

2. **Character Set Issues**
   - Verify UTF8MB4 support for emoji and international characters
   - Check collation settings

3. **Foreign Key Constraints**
   - Ensure parent records exist before inserting child records
   - Check cascade rules for deletions

4. **Index Performance**
   - Monitor index usage with performance schema
   - Drop unused indexes to save space

### Validation Queries

```sql
-- Check table sizes
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size in MB'
FROM information_schema.tables 
WHERE table_schema = 'airbnb_db';

-- Check constraint violations
SELECT * FROM information_schema.table_constraints 
WHERE table_schema = 'airbnb_db';

-- Verify data integrity
SELECT COUNT(*) as total_users FROM User;
SELECT COUNT(*) as total_properties FROM Property;
SELECT COUNT(*) as total_bookings FROM Booking;
```

## Support and Documentation

- **Database Version**: MySQL 8.0+ / MariaDB 10.4+
- **Character Set**: UTF8MB4
- **Engine**: InnoDB
- **Normalization Level**: Third Normal Form (3NF)

For additional support or questions about the database schema, refer to the normalization documentation in the parent directory.
