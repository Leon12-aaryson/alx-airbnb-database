# AirBnB Database Project

## Overview

This repository contains a comprehensive database design and implementation for an AirBnB-style rental platform. The project follows database normalization principles, implements Third Normal Form (3NF) compliance, and provides production-ready SQL scripts.

## Project Structure

```text
alx-airbnb-database/
├── ERD/                           # Entity-Relationship Diagram documentation
│   ├── requirements.md            # Database specification with ER diagram description
│   ├── DrawIO_Instructions.md     # Visual diagram creation guide
│   └── README.md                 # ER documentation summary
├── database-script-0x01/         # SQL schema implementation
│   ├── schema.sql                # Complete database creation script
│   └── README.md                 # Database implementation guide
├── normalization.md              # Database normalization analysis (3NF)
└── README.md                     # This main project documentation
```

## Database Architecture

### 🏗️ Core Entities

1. **User** - Platform users (guests, hosts, administrators)
2. **Location** - Normalized location data (countries, cities, addresses)
3. **Property** - Rental properties with detailed information
4. **Booking** - Reservation system with date management
5. **Payment** - Financial transactions with status tracking
6. **Review** - User feedback and rating system
7. **Message** - Inter-user communication platform

### 🔗 Key Relationships

- **One-to-Many**: User → Properties (host relationship)
- **One-to-Many**: Location → Properties (location reference)
- **One-to-Many**: User → Bookings (guest bookings)
- **One-to-Many**: Property → Bookings (property reservations)
- **One-to-One**: Booking → Payment (payment per booking)
- **Many-to-Many**: User ↔ Messages (communication system)

## Features

### ✅ Database Normalization (3NF)

- **First Normal Form (1NF)**: Atomic values, unique records
- **Second Normal Form (2NF)**: No partial dependencies
- **Third Normal Form (3NF)**: No transitive dependencies
- **Location Normalization**: Eliminated redundant location data
- **Calculated Field Removal**: Dynamic price calculation

### 🛡️ Data Integrity

- **Primary Keys**: UUID-based unique identifiers
- **Foreign Keys**: Referential integrity with cascade options
- **Check Constraints**: Data validation and business rules
- **Unique Constraints**: Prevent duplicate data
- **Triggers**: Automated business logic enforcement

### ⚡ Performance Optimization

- **Strategic Indexing**: Optimized for common query patterns
- **Materialized Views**: Pre-calculated data for performance
- **Query Optimization**: Efficient data access patterns
- **Partitioning Ready**: Scalable for large datasets

### 🔒 Security Features

- **Input Validation**: SQL injection prevention
- **Data Encryption**: Password hashing requirements
- **Access Control**: Role-based permissions
- **Audit Trail**: Timestamp tracking

## Quick Start

### Prerequisites

- MySQL 8.0+ or MariaDB 10.4+
- Database administration privileges
- UTF8MB4 character set support

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd alx-airbnb-database
   ```

2. **Create the database:**
   ```bash
   mysql -u root -p < database-script-0x01/schema.sql
   ```

3. **Verify installation:**
   ```sql
   USE airbnb_db;
   SHOW TABLES;
   SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'airbnb_db';
   ```

## Documentation

### 📊 Entity-Relationship Diagram

- **Location**: `ERD/requirements.md` - Complete database specification
- **Visual Guide**: `ERD/DrawIO_Instructions.md` - Step-by-step diagram creation
- **Summary**: `ERD/README.md` - Quick reference guide

### 🗄️ Database Implementation

- **Schema Script**: `database-script-0x01/schema.sql` - Complete SQL implementation
- **Implementation Guide**: `database-script-0x01/README.md` - Detailed setup instructions

### 📝 Normalization Analysis

- **Analysis Document**: `normalization.md` - Comprehensive 3NF compliance review

## Technical Specifications

### Database Engine
- **Type**: Relational Database (MySQL/MariaDB)
- **Engine**: InnoDB with ACID compliance
- **Character Set**: UTF8MB4 for international support
- **Collation**: UTF8MB4_unicode_ci

### Data Types
- **Identifiers**: CHAR(36) UUID format
- **Text**: VARCHAR with appropriate limits
- **Numeric**: DECIMAL for financial precision
- **Temporal**: TIMESTAMP with timezone support
- **Enums**: Controlled vocabulary fields

### Performance Metrics
- **Tables**: 7 normalized entities
- **Indexes**: 25+ strategic indexes
- **Views**: 3 optimized views
- **Triggers**: 2 business logic triggers
- **Constraints**: 20+ data validation rules

## Usage Examples

### Basic Operations

```sql
-- Insert a new user
INSERT INTO User (first_name, last_name, email, password_hash) 
VALUES ('John', 'Doe', 'john@example.com', 'hashed_password');

-- Create a property listing
INSERT INTO Property (host_id, location_id, name, description, pricepernight) 
VALUES ('host_uuid', 'location_uuid', 'Cozy Apartment', 'Downtown location', 150.00);

-- Make a booking
INSERT INTO Booking (property_id, user_id, start_date, end_date) 
VALUES ('property_uuid', 'guest_uuid', '2024-07-01', '2024-07-05');
```

### Advanced Queries

```sql
-- Get booking details with calculated total
SELECT * FROM BookingDetails WHERE user_id = 'user_uuid';

-- Find available properties for specific dates
SELECT p.* FROM PropertyWithLocation p
WHERE p.property_id NOT IN (
    SELECT property_id FROM Booking 
    WHERE status = 'confirmed' 
    AND '2024-07-01' BETWEEN start_date AND end_date
);

-- User activity statistics
SELECT * FROM UserStats WHERE user_id = 'user_uuid';
```

## Development Workflow

### Phase 1: Design ✅
- [x] Entity-Relationship modeling
- [x] Normalization analysis (3NF)
- [x] Constraint definition
- [x] Index planning

### Phase 2: Implementation ✅
- [x] SQL schema creation
- [x] Constraint implementation
- [x] Index optimization
- [x] View creation
- [x] Trigger development

### Phase 3: Testing (Next)
- [ ] Data integrity testing
- [ ] Performance benchmarking
- [ ] Security validation
- [ ] Load testing

### Phase 4: Deployment (Future)
- [ ] Production environment setup
- [ ] Migration scripts
- [ ] Monitoring implementation
- [ ] Backup strategies

## Contributing

### Code Standards
- Follow SQL formatting conventions
- Include comprehensive comments
- Test all constraints and triggers
- Document schema changes

### Review Process
1. Entity relationship validation
2. Normalization compliance check
3. Performance impact assessment
4. Security review

## Support

### Resources
- **Database Documentation**: See individual README files
- **Schema Reference**: `database-script-0x01/schema.sql`
- **Normalization Guide**: `normalization.md`

### Common Issues
- **UUID Support**: Ensure MySQL version compatibility
- **Character Set**: Verify UTF8MB4 configuration
- **Performance**: Monitor index usage and query patterns

## License

This project is part of the ALX Software Engineering program educational curriculum.

---

**Built with ❤️ for scalable, maintainable database design**
