# Complex Queries with Joins

This document demonstrates advanced SQL join techniques for retrieving data from multiple related tables in the AirBnB database.

## Overview

SQL joins are fundamental for combining data from multiple tables based on related columns. This script showcases various join types and their practical applications in a real-world database scenario.

## Join Types Implemented

### 1. INNER JOIN

**Purpose**: Retrieve records that have matching values in both tables.

**Query**: Bookings with User Details

```sql
SELECT b.booking_id, b.start_date, b.end_date, b.status,
       u.first_name, u.last_name, u.email
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
ORDER BY b.created_at DESC;
```

**Use Case**: Get all bookings along with the complete user information for users who made those bookings.

### 2. LEFT JOIN

**Purpose**: Retrieve all records from the left table and matching records from the right table.

**Query**: Properties with Reviews

```sql
SELECT p.property_id, p.name, p.pricepernight,
       r.review_id, r.rating, r.comment
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
ORDER BY p.property_id, r.created_at DESC;
```

**Use Case**: Show all properties including those that haven't received any reviews yet.

### 3. FULL OUTER JOIN (Simulated)

**Purpose**: Retrieve all records from both tables, including unmatched records.

**Implementation**: Since MySQL doesn't natively support FULL OUTER JOIN, we use UNION to combine LEFT JOIN and RIGHT JOIN results.

```sql
SELECT u.user_id, u.first_name, u.last_name, b.booking_id, b.status
FROM User u LEFT JOIN Booking b ON u.user_id = b.user_id
UNION
SELECT u.user_id, u.first_name, u.last_name, b.booking_id, b.status
FROM User u RIGHT JOIN Booking b ON u.user_id = b.user_id
WHERE u.user_id IS NULL;
```

**Use Case**: Show all users and all bookings, even if some users have no bookings or some bookings are orphaned.

## Advanced Join Examples

### Multi-table Joins

**Property Details with Location and Host Information**
```sql
SELECT p.name, h.first_name, h.last_name, l.city, l.country,
       COUNT(b.booking_id) as total_bookings,
       AVG(r.rating) as average_rating
FROM Property p
INNER JOIN User h ON p.host_id = h.user_id
INNER JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name, h.first_name, h.last_name, l.city, l.country
ORDER BY total_bookings DESC, average_rating DESC;
```

### Complex Business Logic Joins

**Complete Booking Information with Payment Details**
```sql
SELECT b.booking_id, g.first_name as guest_name, p.name as property_name,
       h.first_name as host_name, l.city, b.start_date, b.end_date,
       pay.amount, pay.payment_method, pay.payment_status
FROM Booking b
INNER JOIN User g ON b.user_id = g.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User h ON p.host_id = h.user_id
INNER JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed'
ORDER BY b.created_at DESC;
```

## Performance Considerations

### Index Usage

The joins in this script rely on the following indexes for optimal performance:

- `idx_booking_user` on `Booking(user_id)`
- `idx_booking_property` on `Booking(property_id)`
- `idx_property_host` on `Property(host_id)`
- `idx_property_location` on `Property(location_id)`
- `idx_review_property` on `Review(property_id)`
- `idx_payment_booking` on `Payment(booking_id)`

### Query Optimization Tips

1. **Use INNER JOIN when possible** - It's generally faster than LEFT/RIGHT JOIN
2. **Filter early** - Use WHERE clauses to reduce the dataset before joining
3. **Order matters** - Place the table with the most selective conditions first
4. **Use EXPLAIN** - Analyze query execution plans to identify bottlenecks

## Real-world Applications

### Business Intelligence Queries

These join patterns are commonly used for:

- **Revenue Reports**: Combining booking, payment, and property data
- **User Analytics**: Analyzing user behavior across bookings and reviews
- **Property Performance**: Evaluating property success metrics
- **Geographic Analysis**: Understanding location-based trends

### Data Integrity Checks

Joins help identify data quality issues:

- **Orphaned Records**: Using FULL OUTER JOIN to find unmatched data
- **Missing Relationships**: LEFT JOIN to find records without related data
- **Data Consistency**: Verifying foreign key relationships

## Best Practices

1. **Always specify JOIN conditions** - Avoid accidental Cartesian products
2. **Use table aliases** - Improve readability and reduce typing
3. **Consider NULL handling** - Be aware of how JOINs handle NULL values
4. **Test with different data volumes** - Performance characteristics change with scale
5. **Document complex joins** - Explain business logic for future maintainers

## Usage Instructions

1. Ensure the database schema is created and populated with sample data
2. Run the queries in sequence to see different join behaviors
3. Use EXPLAIN to analyze query execution plans
4. Modify the queries to test different scenarios

## Files

- `joins_queries.sql` - Complete SQL script with all join examples
- `README.md` - This documentation file
