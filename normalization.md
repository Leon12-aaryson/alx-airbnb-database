# Database Normalization Analysis - AirBnB Platform

## Overview

This document provides a comprehensive analysis of the AirBnB database schema normalization, ensuring compliance with Third Normal Form (3NF) principles. The analysis examines each entity for potential redundancies, dependencies, and normalization violations.

## Normalization Principles Review

### First Normal Form (1NF)

- **Requirement**: Each table cell contains only atomic (indivisible) values
- **Requirement**: Each record is unique
- **Requirement**: No repeating groups

### Second Normal Form (2NF)

- **Requirement**: Must be in 1NF
- **Requirement**: All non-key attributes are fully functionally dependent on the primary key
- **Requirement**: No partial dependencies on composite keys

### Third Normal Form (3NF)

- **Requirement**: Must be in 2NF
- **Requirement**: No transitive dependencies
- **Requirement**: All non-key attributes depend directly on the primary key

## Current Schema Analysis

### 1. User Entity Analysis

**Current Structure:**

```sql
User (
    user_id: UUID PRIMARY KEY,
    first_name: VARCHAR NOT NULL,
    last_name: VARCHAR NOT NULL,
    email: VARCHAR UNIQUE NOT NULL,
    password_hash: VARCHAR NOT NULL,
    phone_number: VARCHAR NULL,
    role: ENUM(guest, host, admin) NOT NULL,
    created_at: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Normalization Assessment:**

- **1NF**: All attributes contain atomic values
- **2NF**: Single primary key, no partial dependencies
- **3NF**: No transitive dependencies identified

**Recommendation**: No changes required - already in 3NF

### 2. Property Entity Analysis

**Current Structure:**

```sql
Property (
    property_id: UUID PRIMARY KEY,
    host_id: UUID FOREIGN KEY REFERENCES User(user_id),
    name: VARCHAR NOT NULL,
    description: TEXT NOT NULL,
    location: VARCHAR NOT NULL,
    pricepernight: DECIMAL NOT NULL,
    created_at: TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at: TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
```

**Normalization Issues Identified:**

- **Location Field**: The `location` field is too generic and may contain non-atomic data
- **Potential Location Redundancy**: Multiple properties may share the same location details

**Proposed Normalization:**

**Step 1**: Create separate Location entity

```sql
Location (
    location_id: UUID PRIMARY KEY,
    country: VARCHAR NOT NULL,
    state_province: VARCHAR NOT NULL,
    city: VARCHAR NOT NULL,
    address: VARCHAR NOT NULL,
    postal_code: VARCHAR NULL,
    latitude: DECIMAL(10,8) NULL,
    longitude: DECIMAL(11,8) NULL
)
```

**Step 2**: Update Property entity

```sql
Property (
    property_id: UUID PRIMARY KEY,
    host_id: UUID FOREIGN KEY REFERENCES User(user_id),
    location_id: UUID FOREIGN KEY REFERENCES Location(location_id),
    name: VARCHAR NOT NULL,
    description: TEXT NOT NULL,
    pricepernight: DECIMAL NOT NULL,
    created_at: TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at: TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
```

**Benefits:**

- Eliminates location data redundancy
- Enables better location-based queries
- Supports geographic data types
- Maintains data consistency

### 3. Booking Entity Analysis

**Current Structure:**

```sql
Booking (
    booking_id: UUID PRIMARY KEY,
    property_id: UUID FOREIGN KEY REFERENCES Property(property_id),
    user_id: UUID FOREIGN KEY REFERENCES User(user_id),
    start_date: DATE NOT NULL,
    end_date: DATE NOT NULL,
    total_price: DECIMAL NOT NULL,
    status: ENUM(pending, confirmed, canceled) NOT NULL,
    created_at: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Normalization Issues Identified:**

- **Calculated Field**: `total_price` can be derived from `pricepernight * number_of_nights`
- **Potential Transitive Dependency**: Total price depends on property price and booking duration

**Proposed Normalization:**

**Option 1**: Remove calculated field (Recommended)

```sql
Booking (
    booking_id: UUID PRIMARY KEY,
    property_id: UUID FOREIGN KEY REFERENCES Property(property_id),
    user_id: UUID FOREIGN KEY REFERENCES User(user_id),
    start_date: DATE NOT NULL,
    end_date: DATE NOT NULL,
    status: ENUM(pending, confirmed, canceled) NOT NULL,
    created_at: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Option 2**: Keep for performance but add constraints

```sql
-- Add CHECK constraint to ensure data consistency
ALTER TABLE Booking ADD CONSTRAINT check_total_price 
CHECK (total_price = (
    SELECT pricepernight * (end_date - start_date) 
    FROM Property WHERE property_id = Booking.property_id
));
```

**Recommendation**: Remove `total_price` and calculate dynamically to maintain 3NF

### 4. Payment Entity Analysis

**Current Structure:**

```sql
Payment (
    payment_id: UUID PRIMARY KEY,
    booking_id: UUID FOREIGN KEY REFERENCES Booking(booking_id),
    amount: DECIMAL NOT NULL,
    payment_date: TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method: ENUM(credit_card, paypal, stripe) NOT NULL
)
```

**Normalization Assessment:**

- **1NF**: All attributes contain atomic values
- **2NF**: Single primary key, no partial dependencies
- **3NF**: No transitive dependencies

**Recommendation**: No changes required - already in 3NF

### 5. Review Entity Analysis

**Current Structure:**

```sql
Review (
    review_id: UUID PRIMARY KEY,
    property_id: UUID FOREIGN KEY REFERENCES Property(property_id),
    user_id: UUID FOREIGN KEY REFERENCES User(user_id),
    rating: INTEGER CHECK(rating >= 1 AND rating <= 5) NOT NULL,
    comment: TEXT NOT NULL,
    created_at: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Normalization Assessment:**

- **1NF**: All attributes contain atomic values
- **2NF**: Single primary key, no partial dependencies
- **3NF**: No transitive dependencies

**Recommendation**: No changes required - already in 3NF

### 6. Message Entity Analysis

**Current Structure:**

```sql
Message (
    message_id: UUID PRIMARY KEY,
    sender_id: UUID FOREIGN KEY REFERENCES User(user_id),
    recipient_id: UUID FOREIGN KEY REFERENCES User(user_id),
    message_body: TEXT NOT NULL,
    sent_at: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Normalization Assessment:**

- **1NF**: All attributes contain atomic values
- **2NF**: Single primary key, no partial dependencies
- **3NF**: No transitive dependencies

**Recommendation**: No changes required - already in 3NF

## Normalization Implementation Steps

### Step 1: Create Location Entity

```sql
CREATE TABLE Location (
    location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country VARCHAR(100) NOT NULL,
    state_province VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_location_city (city),
    INDEX idx_location_country (country),
    INDEX idx_location_coordinates (latitude, longitude)
);
```

### Step 2: Migrate Property Data

```sql
-- Add location_id to Property table
ALTER TABLE Property ADD COLUMN location_id UUID;

-- Create Location records from existing Property data
INSERT INTO Location (country, state_province, city, address)
SELECT DISTINCT 
    -- Parse location string to extract components
    -- This would need custom logic based on location format
    SUBSTRING_INDEX(location, ',', -1) as country,
    SUBSTRING_INDEX(SUBSTRING_INDEX(location, ',', -2), ',', 1) as state_province,
    SUBSTRING_INDEX(SUBSTRING_INDEX(location, ',', -3), ',', 1) as city,
    SUBSTRING_INDEX(location, ',', 1) as address
FROM Property;

-- Update Property records with location_id
UPDATE Property p 
JOIN Location l ON (
    -- Match logic based on parsed location data
)
SET p.location_id = l.location_id;

-- Remove old location column
ALTER TABLE Property DROP COLUMN location;

-- Add foreign key constraint
ALTER TABLE Property ADD CONSTRAINT fk_property_location 
FOREIGN KEY (location_id) REFERENCES Location(location_id);
```

### Step 3: Update Booking Entity

```sql
-- Remove calculated total_price field
ALTER TABLE Booking DROP COLUMN total_price;

-- Create view for backward compatibility
CREATE VIEW BookingWithTotal AS
SELECT 
    b.*,
    (p.pricepernight * DATEDIFF(b.end_date, b.start_date)) as total_price
FROM Booking b
JOIN Property p ON b.property_id = p.property_id;
```

## Final Normalized Schema

### Entities in 3NF

1. **User** - No changes required
2. **Location** - New entity to eliminate redundancy
3. **Property** - Updated to reference Location
4. **Booking** - Removed calculated field
5. **Payment** - No changes required
6. **Review** - No changes required
7. **Message** - No changes required

### Benefits of Normalization

1. **Data Integrity**: Eliminates redundant data and inconsistencies
2. **Storage Efficiency**: Reduces storage requirements
3. **Maintenance**: Easier to update location information
4. **Query Performance**: Better indexing on normalized location data
5. **Scalability**: More flexible for future enhancements

### Trade-offs Considered

1. **Query Complexity**: Some queries require additional JOINs
2. **Performance**: May need materialized views for frequently accessed calculated fields
3. **Migration Effort**: Requires data migration for existing systems

## Conclusion

The proposed normalization brings the AirBnB database schema into full compliance with Third Normal Form (3NF) by:

1. **Eliminating Redundancy**: Location data is normalized into a separate entity
2. **Removing Calculated Fields**: Total price is computed dynamically
3. **Maintaining Data Integrity**: All entities have proper dependencies on primary keys
4. **Ensuring Atomic Values**: All attributes contain indivisible data

The normalized schema provides a solid foundation for a scalable, maintainable AirBnB platform while preserving data integrity and reducing storage overhead.
