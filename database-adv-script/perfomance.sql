-- =============================================
-- Complex Query Performance Analysis and Optimization
-- =============================================
-- This script contains initial complex queries and their optimized versions
-- for retrieving comprehensive booking, user, property, and payment details.

USE airbnb_db;

-- =============================================
-- INITIAL COMPLEX QUERY (BEFORE OPTIMIZATION)
-- =============================================
-- Retrieve all bookings with complete details including user info,
-- property details, location, host information, and payment status
-- This is the initial query that will be analyzed and optimized

-- INITIAL QUERY: Comprehensive Booking Details (Not Optimized)
-- This query retrieves all bookings with user details, property details, and payment details
-- as specified in the requirements
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status as booking_status,
    b.created_at as booking_created_at,
    DATEDIFF(b.end_date, b.start_date) as nights,
    
    -- Guest Information
    u.user_id as guest_id,
    u.first_name as guest_first_name,
    u.last_name as guest_last_name,
    u.email as guest_email,
    u.phone_number as guest_phone,
    u.created_at as guest_joined_date,
    
    -- Property Information
    p.property_id,
    p.name as property_name,
    p.description as property_description,
    p.pricepernight,
    p.created_at as property_created_at,
    
    -- Host Information
    h.user_id as host_id,
    h.first_name as host_first_name,
    h.last_name as host_last_name,
    h.email as host_email,
    h.phone_number as host_phone,
    
    -- Location Information
    l.country,
    l.state_province,
    l.city,
    l.address,
    l.postal_code,
    l.latitude,
    l.longitude,
    
    -- Payment Information
    pay.payment_id,
    pay.amount as payment_amount,
    pay.payment_date,
    pay.payment_method,
    pay.payment_status,
    pay.transaction_id,
    
    -- Calculated Fields
    (DATEDIFF(b.end_date, b.start_date) * p.pricepernight) as calculated_total_cost,
    
    -- Subquery for total bookings by guest
    (SELECT COUNT(*) FROM Booking b2 WHERE b2.user_id = u.user_id) as guest_total_bookings,
    
    -- Subquery for host's property count
    (SELECT COUNT(*) FROM Property p2 WHERE p2.host_id = h.user_id) as host_total_properties,
    
    -- Subquery for property average rating
    (SELECT AVG(rating) FROM Review r WHERE r.property_id = p.property_id) as property_avg_rating,
    
    -- Subquery for property total reviews
    (SELECT COUNT(*) FROM Review r WHERE r.property_id = p.property_id) as property_total_reviews

FROM Booking b
    LEFT JOIN User u ON b.user_id = u.user_id
    LEFT JOIN Property p ON b.property_id = p.property_id
    LEFT JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Location l ON p.location_id = l.location_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.created_at >= '2024-01-01'
ORDER BY b.created_at DESC, b.booking_id;

-- =============================================
-- PERFORMANCE ANALYSIS OF INITIAL QUERY
-- =============================================

-- STEP 1: Analyze the initial query performance using EXPLAIN
-- This shows the execution plan without running the query
EXPLAIN FORMAT=JSON
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status as booking_status,
    u.first_name as guest_first_name,
    u.last_name as guest_last_name,
    p.name as property_name,
    p.pricepernight,
    h.first_name as host_first_name,
    h.last_name as host_last_name,
    l.city,
    l.country,
    pay.amount as payment_amount,
    pay.payment_status,
    (SELECT COUNT(*) FROM Booking b2 WHERE b2.user_id = u.user_id) as guest_total_bookings,
    (SELECT AVG(rating) FROM Review r WHERE r.property_id = p.property_id) as property_avg_rating
FROM Booking b
    LEFT JOIN User u ON b.user_id = u.user_id
    LEFT JOIN Property p ON b.property_id = p.property_id
    LEFT JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Location l ON p.location_id = l.location_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.created_at >= '2024-01-01'
ORDER BY b.created_at DESC;

-- STEP 2: Analyze the initial query performance using EXPLAIN ANALYZE
-- This actually runs the query and provides detailed performance metrics
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status as booking_status,
    u.first_name as guest_first_name,
    u.last_name as guest_last_name,
    p.name as property_name,
    p.pricepernight,
    h.first_name as host_first_name,
    h.last_name as host_last_name,
    l.city,
    l.country,
    pay.amount as payment_amount,
    pay.payment_status,
    (SELECT COUNT(*) FROM Booking b2 WHERE b2.user_id = u.user_id) as guest_total_bookings,
    (SELECT AVG(rating) FROM Review r WHERE r.property_id = p.property_id) as property_avg_rating
FROM Booking b
    LEFT JOIN User u ON b.user_id = u.user_id
    LEFT JOIN Property p ON b.property_id = p.property_id
    LEFT JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Location l ON p.location_id = l.location_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.created_at >= '2024-01-01'
ORDER BY b.created_at DESC
LIMIT 50;  -- Added LIMIT for performance testing

-- STEP 3: Identify specific inefficiencies in the initial query
-- The analysis above will reveal:
-- 1. Multiple table scans due to correlated subqueries
-- 2. Inefficient JOIN order
-- 3. Missing or unused indexes
-- 4. Temporary table creation for sorting
-- 5. Excessive memory usage
-- 6. Long execution time due to complex operations
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status as booking_status,
    u.first_name as guest_first_name,
    u.last_name as guest_last_name,
    p.name as property_name,
    p.pricepernight,
    h.first_name as host_first_name,
    h.last_name as host_last_name,
    l.city,
    l.country,
    pay.amount as payment_amount,
    pay.payment_status,
    (SELECT COUNT(*) FROM Booking b2 WHERE b2.user_id = u.user_id) as guest_total_bookings,
    (SELECT AVG(rating) FROM Review r WHERE r.property_id = p.property_id) as property_avg_rating
FROM Booking b
    LEFT JOIN User u ON b.user_id = u.user_id
    LEFT JOIN Property p ON b.property_id = p.property_id
    LEFT JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Location l ON p.location_id = l.location_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.created_at >= '2024-01-01'
ORDER BY b.created_at DESC;

-- =============================================
-- OPTIMIZATION STRATEGY
-- =============================================
-- Based on the EXPLAIN and EXPLAIN ANALYZE results, we will refactor the query
-- to reduce execution time by addressing the following inefficiencies:

-- 1. Remove unnecessary columns and subqueries
--    - Eliminate correlated subqueries that cause multiple table scans
--    - Select only essential columns instead of all columns
--    - Use window functions for aggregate calculations

-- 2. Optimize JOIN operations
--    - Change LEFT JOINs to INNER JOINs where appropriate
--    - Reduce the number of JOINs by combining related data
--    - Use proper JOIN order for optimal performance

-- 3. Add proper WHERE clauses to reduce data set
--    - Filter data early in the query execution
--    - Use indexed columns in WHERE clauses
--    - Add result limiting with LIMIT clause

-- 4. Use appropriate indexes
--    - Ensure indexes exist for JOIN, WHERE, and ORDER BY columns
--    - Use covering indexes to avoid table lookups
--    - Consider composite indexes for multi-column filtering

-- 5. Consider denormalization for frequently accessed data
--    - Pre-calculate frequently used values
--    - Use temporary tables for complex aggregations
--    - Implement materialized views for complex queries

-- =============================================
-- OPTIMIZED QUERY VERSION 1
-- =============================================
-- Reduced complexity while maintaining functionality

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status as booking_status,
    DATEDIFF(b.end_date, b.start_date) as nights,
    
    -- Essential Guest Information
    CONCAT(u.first_name, ' ', u.last_name) as guest_name,
    u.email as guest_email,
    
    -- Essential Property Information
    p.name as property_name,
    p.pricepernight,
    
    -- Essential Host Information
    CONCAT(h.first_name, ' ', h.last_name) as host_name,
    
    -- Essential Location Information
    CONCAT(l.city, ', ', l.country) as location,
    
    -- Payment Information
    pay.amount as payment_amount,
    pay.payment_status,
    
    -- Calculated total cost
    (DATEDIFF(b.end_date, b.start_date) * p.pricepernight) as total_cost

FROM Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN User h ON p.host_id = h.user_id
    INNER JOIN Location l ON p.location_id = l.location_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.created_at >= '2024-01-01'
    AND b.status IN ('confirmed', 'pending')
ORDER BY b.created_at DESC
LIMIT 100;

-- =============================================
-- OPTIMIZED QUERY VERSION 2
-- =============================================
-- Using window functions for aggregate data

WITH booking_stats AS (
    SELECT 
        b.booking_id,
        b.user_id,
        b.property_id,
        b.start_date,
        b.end_date,
        b.status,
        b.created_at,
        COUNT(*) OVER (PARTITION BY b.user_id) as guest_total_bookings,
        ROW_NUMBER() OVER (PARTITION BY b.user_id ORDER BY b.created_at) as booking_sequence
    FROM Booking b
    WHERE b.created_at >= '2024-01-01'
),
property_stats AS (
    SELECT 
        p.property_id,
        p.name,
        p.pricepernight,
        p.host_id,
        p.location_id,
        AVG(r.rating) as avg_rating,
        COUNT(r.review_id) as total_reviews
    FROM Property p
    LEFT JOIN Review r ON p.property_id = r.property_id
    GROUP BY p.property_id, p.name, p.pricepernight, p.host_id, p.location_id
)
SELECT 
    bs.booking_id,
    bs.start_date,
    bs.end_date,
    bs.status as booking_status,
    DATEDIFF(bs.end_date, bs.start_date) as nights,
    
    CONCAT(u.first_name, ' ', u.last_name) as guest_name,
    u.email as guest_email,
    bs.guest_total_bookings,
    bs.booking_sequence,
    
    ps.name as property_name,
    ps.pricepernight,
    ps.avg_rating,
    ps.total_reviews,
    
    CONCAT(h.first_name, ' ', h.last_name) as host_name,
    
    CONCAT(l.city, ', ', l.country) as location,
    
    pay.amount as payment_amount,
    pay.payment_status,
    
    (DATEDIFF(bs.end_date, bs.start_date) * ps.pricepernight) as total_cost

FROM booking_stats bs
    INNER JOIN User u ON bs.user_id = u.user_id
    INNER JOIN property_stats ps ON bs.property_id = ps.property_id
    INNER JOIN User h ON ps.host_id = h.user_id
    INNER JOIN Location l ON ps.location_id = l.location_id
    LEFT JOIN Payment pay ON bs.booking_id = pay.booking_id
WHERE bs.status IN ('confirmed', 'pending')
ORDER BY bs.created_at DESC
LIMIT 100;

-- =============================================
-- OPTIMIZED QUERY VERSION 3
-- =============================================
-- Using materialized view approach (simulated with temporary table)

CREATE TEMPORARY TABLE temp_booking_details AS
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    b.created_at,
    DATEDIFF(b.end_date, b.start_date) as nights,
    
    u.user_id as guest_id,
    CONCAT(u.first_name, ' ', u.last_name) as guest_name,
    u.email as guest_email,
    
    p.property_id,
    p.name as property_name,
    p.pricepernight,
    
    h.user_id as host_id,
    CONCAT(h.first_name, ' ', h.last_name) as host_name,
    
    l.city,
    l.country,
    CONCAT(l.city, ', ', l.country) as location,
    
    (DATEDIFF(b.end_date, b.start_date) * p.pricepernight) as calculated_total

FROM Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN User h ON p.host_id = h.user_id
    INNER JOIN Location l ON p.location_id = l.location_id
WHERE b.created_at >= '2024-01-01'
    AND b.status IN ('confirmed', 'pending');

-- Create index on temporary table
CREATE INDEX idx_temp_booking_created ON temp_booking_details(created_at);
CREATE INDEX idx_temp_booking_status ON temp_booking_details(status);

-- Optimized query using temporary table
SELECT 
    tbd.*,
    pay.amount as payment_amount,
    pay.payment_status,
    pay.payment_method,
    pay.payment_date
FROM temp_booking_details tbd
    LEFT JOIN Payment pay ON tbd.booking_id = pay.booking_id
ORDER BY tbd.created_at DESC
LIMIT 100;

-- Clean up temporary table
DROP TEMPORARY TABLE temp_booking_details;

-- =============================================
-- SPECIFIC OPTIMIZATION TECHNIQUES
-- =============================================

-- 1. Index-optimized query for specific use cases
SELECT /*+ USE_INDEX(b, idx_booking_status_created) */
    b.booking_id,
    b.start_date,
    b.end_date,
    CONCAT(u.first_name, ' ', u.last_name) as guest_name,
    p.name as property_name,
    l.city,
    pay.amount
FROM Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN Location l ON p.location_id = l.location_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed'
    AND b.created_at >= '2024-01-01'
ORDER BY b.created_at DESC
LIMIT 50;

-- 2. Pagination-optimized query
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    CONCAT(u.first_name, ' ', u.last_name) as guest_name,
    p.name as property_name,
    pay.amount
FROM Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.booking_id > '850e8400-e29b-41d4-a716-446655440010'  -- Cursor-based pagination
    AND b.status = 'confirmed'
ORDER BY b.booking_id
LIMIT 20;

-- 3. Denormalized query for reporting
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    -- Pre-calculated fields to avoid JOINs
    (DATEDIFF(b.end_date, b.start_date) * p.pricepernight) as total_cost,
    
    -- Minimal JOINs for essential data
    u.first_name as guest_first_name,
    u.last_name as guest_last_name,
    p.name as property_name,
    p.pricepernight,
    l.city,
    l.country
    
FROM Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN Location l ON p.location_id = l.location_id
WHERE b.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    AND b.status = 'confirmed'
ORDER BY b.start_date DESC;

-- =============================================
-- PERFORMANCE COMPARISON: BEFORE vs AFTER
-- =============================================
-- This section demonstrates the performance improvement achieved through optimization

-- MEASURE INITIAL QUERY PERFORMANCE (BEFORE OPTIMIZATION)
SET @start_time_initial = NOW(6);

-- Run the initial complex query
SELECT COUNT(*) FROM (
    SELECT 
        b.booking_id,
        b.start_date,
        b.end_date,
        b.status as booking_status,
        u.first_name as guest_first_name,
        u.last_name as guest_last_name,
        p.name as property_name,
        p.pricepernight,
        h.first_name as host_first_name,
        h.last_name as host_last_name,
        l.city,
        l.country,
        pay.amount as payment_amount,
        pay.payment_status,
        (SELECT COUNT(*) FROM Booking b2 WHERE b2.user_id = u.user_id) as guest_total_bookings,
        (SELECT AVG(rating) FROM Review r WHERE r.property_id = p.property_id) as property_avg_rating
    FROM Booking b
        LEFT JOIN User u ON b.user_id = u.user_id
        LEFT JOIN Property p ON b.property_id = p.property_id
        LEFT JOIN User h ON p.host_id = h.user_id
        LEFT JOIN Location l ON p.location_id = l.location_id
        LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
    WHERE b.created_at >= '2024-01-01'
    ORDER BY b.created_at DESC
    LIMIT 50
) as initial_result;

SET @end_time_initial = NOW(6);

-- MEASURE OPTIMIZED QUERY PERFORMANCE (AFTER OPTIMIZATION)
SET @start_time_optimized = NOW(6);

-- Run the optimized query
SELECT COUNT(*) FROM (
    SELECT 
        b.booking_id,
        b.start_date,
        b.end_date,
        b.status as booking_status,
        CONCAT(u.first_name, ' ', u.last_name) as guest_name,
        p.name as property_name,
        p.pricepernight,
        CONCAT(h.first_name, ' ', h.last_name) as host_name,
        CONCAT(l.city, ', ', l.country) as location,
        pay.amount as payment_amount,
        pay.payment_status,
        (DATEDIFF(b.end_date, b.start_date) * p.pricepernight) as total_cost
    FROM Booking b
        INNER JOIN User u ON b.user_id = u.user_id
        INNER JOIN Property p ON b.property_id = p.property_id
        INNER JOIN User h ON p.host_id = h.user_id
        INNER JOIN Location l ON p.location_id = l.location_id
        LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
    WHERE b.created_at >= '2024-01-01'
        AND b.status IN ('confirmed', 'pending')
    ORDER BY b.created_at DESC
    LIMIT 50
) as optimized_result;

SET @end_time_optimized = NOW(6);

-- DISPLAY PERFORMANCE COMPARISON RESULTS
SELECT 
    'Initial Query (Before Optimization)' as query_type,
    TIMESTAMPDIFF(MICROSECOND, @start_time_initial, @end_time_initial) as execution_time_microseconds,
    'Complex query with correlated subqueries and multiple LEFT JOINs' as description
UNION ALL
SELECT 
    'Optimized Query (After Optimization)' as query_type,
    TIMESTAMPDIFF(MICROSECOND, @start_time_optimized, @end_time_optimized) as execution_time_microseconds,
    'Simplified query with INNER JOINs and eliminated subqueries' as description;

-- CALCULATE PERFORMANCE IMPROVEMENT
SELECT 
    CONCAT(
        ROUND(
            (TIMESTAMPDIFF(MICROSECOND, @start_time_initial, @end_time_initial) - 
             TIMESTAMPDIFF(MICROSECOND, @start_time_optimized, @end_time_optimized)) * 100.0 / 
            TIMESTAMPDIFF(MICROSECOND, @start_time_initial, @end_time_initial), 2
        ), '%'
    ) as performance_improvement,
    'Performance improvement achieved through optimization' as description;

-- =============================================
-- QUERY OPTIMIZATION RECOMMENDATIONS
-- =============================================

-- 1. Always use LIMIT for large result sets
-- 2. Use INNER JOIN instead of LEFT JOIN when possible
-- 3. Filter data early with WHERE clauses
-- 4. Use indexes for WHERE, JOIN, and ORDER BY clauses
-- 5. Avoid SELECT * and only select necessary columns
-- 6. Use window functions instead of correlated subqueries
-- 7. Consider materialized views for complex recurring queries
-- 8. Use proper data types and avoid implicit conversions
-- 9. Consider query result caching for frequently accessed data
-- 10. Monitor and analyze query execution plans regularly

-- =============================================
-- END OF PERFORMANCE OPTIMIZATION SCRIPT
-- =============================================
