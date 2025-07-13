-- =============================================
-- Database Performance Monitoring and Refinement
-- =============================================
-- This script implements comprehensive database performance monitoring
-- using SHOW PROFILE, EXPLAIN ANALYZE, and other MySQL monitoring tools
-- to identify bottlenecks and suggest schema improvements.

USE airbnb_db;

-- =============================================
-- PERFORMANCE MONITORING SETUP
-- =============================================

-- Enable profiling for detailed query analysis
SET profiling = 1;

-- Enable performance schema for detailed monitoring
UPDATE performance_schema.setup_instruments 
SET ENABLED = 'YES', TIMED = 'YES' 
WHERE NAME LIKE '%statement/%';

UPDATE performance_schema.setup_consumers 
SET ENABLED = 'YES' 
WHERE NAME LIKE '%events_statements_%';

-- =============================================
-- FREQUENTLY USED QUERIES FOR MONITORING
-- =============================================
-- These are the most commonly executed queries that need performance monitoring

-- Query 1: Comprehensive Booking Details (Complex Join Query)
-- This query retrieves all bookings with user, property, and payment details
-- It's frequently used for booking management and reporting

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status as booking_status,
    b.created_at as booking_created,
    
    -- User details
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    
    -- Property details
    p.name as property_name,
    p.pricepernight,
    
    -- Host details
    h.first_name as host_first_name,
    h.last_name as host_last_name,
    
    -- Location details
    l.city,
    l.country,
    
    -- Payment details
    pay.amount as payment_amount,
    pay.payment_status
    
FROM Booking b
LEFT JOIN User u ON b.user_id = u.user_id
LEFT JOIN Property p ON b.property_id = p.property_id
LEFT JOIN User h ON p.host_id = h.user_id
LEFT JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC
LIMIT 50;

-- Query 2: Property Search with Location Filtering
-- This query is used for property search functionality

SELECT 
    p.property_id, 
    p.name, 
    p.pricepernight, 
    l.city, 
    l.country,
    COUNT(b.booking_id) as total_bookings,
    AVG(r.rating) as avg_rating
FROM Property p
JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
WHERE l.city = 'San Francisco' 
    AND p.pricepernight BETWEEN 100 AND 300
GROUP BY p.property_id, p.name, p.pricepernight, l.city, l.country
ORDER BY p.pricepernight;

-- Query 3: User Booking History
-- This query retrieves booking history for a specific user

SELECT 
    b.booking_id, 
    b.start_date, 
    b.end_date, 
    b.status, 
    p.name as property_name,
    pay.amount,
    pay.payment_status
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.user_id = '550e8400-e29b-41d4-a716-446655440007'
ORDER BY b.start_date DESC;

-- Query 4: Monthly Revenue Report
-- This query generates revenue reports by date

SELECT 
    DATE(payment_date) as payment_day,
    SUM(amount) as daily_revenue,
    COUNT(*) as transaction_count,
    AVG(amount) as avg_transaction
FROM Payment
WHERE payment_status = 'completed'
    AND payment_date >= '2024-01-01'
GROUP BY DATE(payment_date)
ORDER BY payment_day;

-- Query 5: Property Performance Analytics
-- This query analyzes property performance metrics

SELECT 
    p.property_id,
    p.name,
    p.pricepernight,
    COUNT(b.booking_id) as total_bookings,
    COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) as confirmed_bookings,
    AVG(r.rating) as avg_rating,
    COUNT(r.review_id) as total_reviews,
    SUM(CASE WHEN pay.payment_status = 'completed' THEN pay.amount ELSE 0 END) as total_revenue
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
GROUP BY p.property_id, p.name, p.pricepernight
HAVING total_bookings > 0
ORDER BY total_revenue DESC;

-- =============================================
-- PERFORMANCE ANALYSIS USING EXPLAIN ANALYZE
-- =============================================

-- Analyze Query 1: Comprehensive Booking Details
EXPLAIN ANALYZE SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status as booking_status,
    u.first_name,
    u.last_name,
    u.email,
    p.name as property_name,
    p.pricepernight,
    h.first_name as host_first_name,
    h.last_name as host_last_name,
    l.city,
    l.country,
    pay.amount as payment_amount,
    pay.payment_status
FROM Booking b
LEFT JOIN User u ON b.user_id = u.user_id
LEFT JOIN Property p ON b.property_id = p.property_id
LEFT JOIN User h ON p.host_id = h.user_id
LEFT JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC
LIMIT 50;

-- Analyze Query 2: Property Search
EXPLAIN ANALYZE SELECT 
    p.property_id, 
    p.name, 
    p.pricepernight, 
    l.city, 
    l.country,
    COUNT(b.booking_id) as total_bookings,
    AVG(r.rating) as avg_rating
FROM Property p
JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
WHERE l.city = 'San Francisco' 
    AND p.pricepernight BETWEEN 100 AND 300
GROUP BY p.property_id, p.name, p.pricepernight, l.city, l.country
ORDER BY p.pricepernight;

-- Analyze Query 3: User Booking History
EXPLAIN ANALYZE SELECT 
    b.booking_id, 
    b.start_date, 
    b.end_date, 
    b.status, 
    p.name as property_name,
    pay.amount,
    pay.payment_status
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.user_id = '550e8400-e29b-41d4-a716-446655440007'
ORDER BY b.start_date DESC;

-- =============================================
-- PERFORMANCE ANALYSIS USING SHOW PROFILE
-- =============================================

-- Show profile for the last executed queries
SHOW PROFILES;

-- Show detailed profile for the most recent query
SHOW PROFILE FOR QUERY 1;

-- Show profile with specific details
SHOW PROFILE CPU, BLOCK IO, CONTEXT SWITCHES FOR QUERY 1;

-- =============================================
-- BOTTLENECK IDENTIFICATION
-- =============================================

-- 1. Check for slow queries
SELECT 
    sql_text,
    exec_count,
    avg_timer_wait/1000000000 as avg_time_seconds,
    sum_timer_wait/1000000000 as total_time_seconds,
    max_timer_wait/1000000000 as max_time_seconds
FROM performance_schema.events_statements_summary_by_digest 
WHERE schema_name = 'airbnb_db'
    AND avg_timer_wait > 1000000000  -- Queries taking more than 1 second
ORDER BY avg_timer_wait DESC
LIMIT 10;

-- 2. Check index usage statistics
SELECT 
    table_name,
    index_name,
    cardinality,
    sub_part,
    packed,
    null,
    index_type,
    comment
FROM information_schema.statistics 
WHERE table_schema = 'airbnb_db'
    AND table_name IN ('Booking', 'Property', 'User', 'Payment', 'Review')
ORDER BY table_name, index_name;

-- 3. Check table sizes and row counts
SELECT 
    table_name,
    table_rows,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) as size_mb,
    ROUND((data_length / 1024 / 1024), 2) as data_mb,
    ROUND((index_length / 1024 / 1024), 2) as index_mb
FROM information_schema.tables 
WHERE table_schema = 'airbnb_db'
    AND table_name IN ('Booking', 'Property', 'User', 'Payment', 'Review')
ORDER BY size_mb DESC;

-- 4. Check for table scans
SELECT 
    object_schema,
    object_name,
    index_name,
    count_read,
    count_write,
    count_fetch,
    count_insert,
    count_update,
    count_delete
FROM performance_schema.table_io_waits_summary_by_index_usage 
WHERE object_schema = 'airbnb_db'
    AND index_name IS NULL  -- Full table scans
ORDER BY count_read DESC;

-- =============================================
-- SCHEMA ADJUSTMENT RECOMMENDATIONS
-- =============================================

-- Based on the analysis above, here are the recommended schema adjustments:

-- 1. Create missing indexes for frequently used queries
-- Index for booking queries with date ordering
CREATE INDEX IF NOT EXISTS idx_booking_created_at 
ON Booking(created_at DESC);

-- Composite index for user booking history
CREATE INDEX IF NOT EXISTS idx_booking_user_date 
ON Booking(user_id, start_date DESC, property_id);

-- Covering index for property search
CREATE INDEX IF NOT EXISTS idx_property_location_price_covering 
ON Property(location_id, pricepernight, property_id, name);

-- Index for payment date queries
CREATE INDEX IF NOT EXISTS idx_payment_date_status 
ON Payment(payment_date, payment_status, amount);

-- 2. Add generated columns for function-based queries
-- Add date-only column for payment queries
ALTER TABLE Payment 
ADD COLUMN IF NOT EXISTS payment_date_only DATE 
GENERATED ALWAYS AS (DATE(payment_date)) STORED;

-- Create index on generated column
CREATE INDEX IF NOT EXISTS idx_payment_date_only_status 
ON Payment(payment_date_only, payment_status, amount);

-- 3. Optimize existing indexes
-- Analyze and update table statistics
ANALYZE TABLE Booking, Property, User, Payment, Review;

-- =============================================
-- PERFORMANCE IMPROVEMENT TESTING
-- =============================================

-- Test the optimized queries after schema adjustments

-- Test 1: Optimized booking query
SET @start_time = NOW(6);
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status as booking_status,
    u.first_name,
    u.last_name,
    p.name as property_name,
    l.city,
    pay.amount
FROM Booking b
LEFT JOIN User u ON b.user_id = u.user_id
LEFT JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC
LIMIT 50;
SET @end_time = NOW(6);
SELECT 'Optimized Booking Query' as query_type,
       TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;

-- Test 2: Optimized property search
SET @start_time = NOW(6);
SELECT 
    p.property_id, 
    p.name, 
    p.pricepernight, 
    l.city, 
    l.country
FROM Property p
JOIN Location l ON p.location_id = l.location_id
WHERE l.city = 'San Francisco' 
    AND p.pricepernight BETWEEN 100 AND 300
ORDER BY p.pricepernight;
SET @end_time = NOW(6);
SELECT 'Optimized Property Search' as query_type,
       TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;

-- Test 3: Optimized user booking history
SET @start_time = NOW(6);
SELECT 
    b.booking_id, 
    b.start_date, 
    b.end_date, 
    b.status, 
    p.name as property_name
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
WHERE b.user_id = '550e8400-e29b-41d4-a716-446655440007'
ORDER BY b.start_date DESC;
SET @end_time = NOW(6);
SELECT 'Optimized User History' as query_type,
       TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;

-- =============================================
-- ONGOING MONITORING QUERIES
-- =============================================

-- Monitor query performance over time
SELECT 
    'Query Performance Summary' as metric,
    COUNT(*) as total_queries,
    ROUND(AVG(avg_timer_wait/1000000000), 3) as avg_time_seconds,
    ROUND(MAX(avg_timer_wait/1000000000), 3) as max_time_seconds,
    ROUND(SUM(sum_timer_wait/1000000000), 3) as total_time_seconds
FROM performance_schema.events_statements_summary_by_digest 
WHERE schema_name = 'airbnb_db';

-- Monitor index usage
SELECT 
    table_name,
    COUNT(*) as index_count,
    SUM(CASE WHEN cardinality > 0 THEN 1 ELSE 0 END) as used_indexes,
    SUM(CASE WHEN cardinality = 0 THEN 1 ELSE 0 END) as unused_indexes
FROM information_schema.statistics 
WHERE table_schema = 'airbnb_db'
    AND table_name IN ('Booking', 'Property', 'User', 'Payment', 'Review')
GROUP BY table_name;

-- Monitor table growth
SELECT 
    table_name,
    table_rows,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) as total_size_mb,
    ROUND((data_length / 1024 / 1024), 2) as data_size_mb,
    ROUND((index_length / 1024 / 1024), 2) as index_size_mb
FROM information_schema.tables 
WHERE table_schema = 'airbnb_db'
    AND table_name IN ('Booking', 'Property', 'User', 'Payment', 'Review')
ORDER BY total_size_mb DESC;

-- =============================================
-- PERFORMANCE ALERTS AND THRESHOLDS
-- =============================================

-- Check for queries exceeding performance thresholds
SELECT 
    'Slow Query Alert' as alert_type,
    sql_text,
    exec_count,
    ROUND(avg_timer_wait/1000000000, 3) as avg_time_seconds
FROM performance_schema.events_statements_summary_by_digest 
WHERE schema_name = 'airbnb_db'
    AND avg_timer_wait > 5000000000  -- Queries taking more than 5 seconds
ORDER BY avg_timer_wait DESC;

-- Check for tables with high scan rates
SELECT 
    'High Table Scan Alert' as alert_type,
    object_name as table_name,
    count_read as scan_count
FROM performance_schema.table_io_waits_summary_by_index_usage 
WHERE object_schema = 'airbnb_db'
    AND index_name IS NULL  -- Full table scans
    AND count_read > 1000   -- More than 1000 scans
ORDER BY count_read DESC;

-- Check for index fragmentation
SELECT 
    'Index Fragmentation Alert' as alert_type,
    table_name,
    index_name,
    cardinality,
    CASE 
        WHEN cardinality = 0 THEN 'Unused Index'
        WHEN cardinality < 10 THEN 'Low Selectivity'
        ELSE 'OK'
    END as status
FROM information_schema.statistics 
WHERE table_schema = 'airbnb_db'
    AND table_name IN ('Booking', 'Property', 'User', 'Payment', 'Review')
    AND (cardinality = 0 OR cardinality < 10)
ORDER BY table_name, index_name;

-- =============================================
-- CLEANUP AND MAINTENANCE
-- =============================================

-- Disable profiling after monitoring
SET profiling = 0;

-- Clean up performance schema data (optional)
-- TRUNCATE TABLE performance_schema.events_statements_summary_by_digest;

-- =============================================
-- MONITORING SUMMARY REPORT
-- =============================================

-- Generate a comprehensive monitoring report
SELECT 
    'Database Performance Monitoring Summary' as report_title,
    NOW() as report_date;

-- Overall performance metrics
SELECT 
    'Overall Performance' as metric_category,
    COUNT(*) as total_queries,
    ROUND(AVG(avg_timer_wait/1000000000), 3) as avg_query_time_seconds,
    ROUND(MAX(avg_timer_wait/1000000000), 3) as slowest_query_seconds,
    SUM(exec_count) as total_executions
FROM performance_schema.events_statements_summary_by_digest 
WHERE schema_name = 'airbnb_db';

-- Index effectiveness summary
SELECT 
    'Index Effectiveness' as metric_category,
    COUNT(*) as total_indexes,
    SUM(CASE WHEN cardinality > 0 THEN 1 ELSE 0 END) as used_indexes,
    SUM(CASE WHEN cardinality = 0 THEN 1 ELSE 0 END) as unused_indexes,
    ROUND(SUM(CASE WHEN cardinality > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as usage_percentage
FROM information_schema.statistics 
WHERE table_schema = 'airbnb_db'
    AND table_name IN ('Booking', 'Property', 'User', 'Payment', 'Review');

-- Storage utilization summary
SELECT 
    'Storage Utilization' as metric_category,
    ROUND(SUM((data_length + index_length) / 1024 / 1024), 2) as total_size_mb,
    ROUND(SUM(data_length / 1024 / 1024), 2) as data_size_mb,
    ROUND(SUM(index_length / 1024 / 1024), 2) as index_size_mb,
    ROUND(SUM(index_length) * 100.0 / SUM(data_length + index_length), 2) as index_overhead_percentage
FROM information_schema.tables 
WHERE table_schema = 'airbnb_db'
    AND table_name IN ('Booking', 'Property', 'User', 'Payment', 'Review');

-- =============================================
-- END OF PERFORMANCE MONITORING SCRIPT
-- ============================================= 