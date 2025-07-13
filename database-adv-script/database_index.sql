-- =============================================
-- Database Index Implementation for Performance Optimization
-- =============================================
-- This script creates strategic indexes to improve query performance
-- for the most frequently used queries in the AirBnB database.

USE airbnb_db;

-- =============================================
-- INDEX ANALYSIS AND STRATEGY
-- =============================================

-- IMPORTANT: PERFORMANCE MEASUREMENT INSTRUCTIONS
-- =============================================
-- To properly measure query performance before and after adding indexes:
--
-- 1. FIRST: Run the "BASELINE PERFORMANCE MEASUREMENT" queries (lines ~150-200)
--    These use EXPLAIN ANALYZE to measure performance BEFORE indexes
--
-- 2. THEN: Create all the indexes in this script
--
-- 3. FINALLY: Run the "PERFORMANCE MEASUREMENT AFTER INDEX CREATION" queries (lines ~200-250)
--    These use EXPLAIN ANALYZE to measure performance AFTER indexes
--
-- 4. COMPARE: The results will show execution time, rows examined, and other metrics
--    to demonstrate the performance improvement from indexing
--
-- Note: EXPLAIN ANALYZE actually executes the query and provides real performance metrics,
-- while EXPLAIN only shows the execution plan without running the query.

-- Before creating indexes, let's analyze current query performance
-- and identify high-usage columns

-- 1. Show current indexes on all tables
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    NON_UNIQUE,
    INDEX_TYPE
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'airbnb_db'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- =============================================
-- HIGH-USAGE COLUMN IDENTIFICATION
-- =============================================
-- Based on common query patterns, these columns are frequently used:

-- User table: email (login), role (filtering), created_at (sorting)
-- Property table: host_id (joins), location_id (joins), pricepernight (filtering/sorting)
-- Booking table: user_id (joins), property_id (joins), start_date/end_date (filtering), status (filtering)
-- Payment table: booking_id (joins), payment_status (filtering), payment_date (sorting)
-- Review table: property_id (joins), user_id (joins), rating (filtering/sorting)
-- Location table: city (filtering), country (filtering), coordinates (geo queries)
-- Message table: sender_id/recipient_id (joins), sent_at (sorting)

-- =============================================
-- STRATEGIC INDEX CREATION
-- =============================================

-- User table indexes (in addition to existing ones)
CREATE INDEX idx_user_role_created ON User(role, created_at);
CREATE INDEX idx_user_email_role ON User(email, role);

-- Property table indexes (in addition to existing ones)
CREATE INDEX idx_property_price_range ON Property(pricepernight, created_at);
CREATE INDEX idx_property_host_location ON Property(host_id, location_id);
CREATE INDEX idx_property_location_price ON Property(location_id, pricepernight);

-- Booking table indexes (in addition to existing ones)
CREATE INDEX idx_booking_date_range ON Booking(start_date, end_date, status);
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);
CREATE INDEX idx_booking_property_status ON Booking(property_id, status);
CREATE INDEX idx_booking_status_created ON Booking(status, created_at);
CREATE INDEX idx_booking_user_dates ON Booking(user_id, start_date, end_date);

-- Payment table indexes (in addition to existing ones)
CREATE INDEX idx_payment_status_date ON Payment(payment_status, payment_date);
CREATE INDEX idx_payment_method_status ON Payment(payment_method, payment_status);
CREATE INDEX idx_payment_date_amount ON Payment(payment_date, amount);

-- Review table indexes (in addition to existing ones)
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);
CREATE INDEX idx_review_user_created ON Review(user_id, created_at);
CREATE INDEX idx_review_rating_created ON Review(rating, created_at);

-- Location table indexes (in addition to existing ones)
CREATE INDEX idx_location_city_country ON Location(city, country);
CREATE INDEX idx_location_country_city ON Location(country, city);
CREATE INDEX idx_location_full_address ON Location(country, state_province, city);

-- Message table indexes (in addition to existing ones)
CREATE INDEX idx_message_recipient_read ON Message(recipient_id, read_at);
CREATE INDEX idx_message_sender_sent ON Message(sender_id, sent_at);
CREATE INDEX idx_message_type_sent ON Message(message_type, sent_at);

-- =============================================
-- COMPOSITE INDEXES FOR COMPLEX QUERIES
-- =============================================

-- Index for property search with location and price filtering
CREATE INDEX idx_property_search_composite ON Property(location_id, pricepernight, created_at);

-- Index for booking analytics queries
CREATE INDEX idx_booking_analytics ON Booking(status, start_date, end_date, created_at);

-- Index for payment reporting
CREATE INDEX idx_payment_reporting ON Payment(payment_status, payment_date, amount, payment_method);

-- Index for review analytics
CREATE INDEX idx_review_analytics ON Review(property_id, rating, created_at);

-- Index for user activity tracking
CREATE INDEX idx_user_activity ON User(role, created_at);

-- =============================================
-- COVERING INDEXES FOR FREQUENT QUERIES
-- =============================================

-- Covering index for booking list queries
CREATE INDEX idx_booking_list_covering ON Booking(user_id, status, start_date, end_date, property_id, created_at);

-- Covering index for property listing queries
CREATE INDEX idx_property_listing_covering ON Property(location_id, pricepernight, host_id, name, created_at);

-- Covering index for payment summary queries
CREATE INDEX idx_payment_summary_covering ON Payment(booking_id, payment_status, amount, payment_method, payment_date);

-- =============================================
-- PARTIAL INDEXES FOR SPECIFIC CONDITIONS
-- =============================================

-- Index only for confirmed bookings (most common queries)
CREATE INDEX idx_booking_confirmed ON Booking(property_id, start_date, end_date) WHERE status = 'confirmed';

-- Index only for completed payments
CREATE INDEX idx_payment_completed ON Payment(booking_id, amount, payment_date) WHERE payment_status = 'completed';

-- Index only for unread messages
CREATE INDEX idx_message_unread ON Message(recipient_id, sent_at) WHERE read_at IS NULL;

-- =============================================
-- FULL-TEXT SEARCH INDEXES
-- =============================================

-- Full-text search for property names and descriptions
CREATE FULLTEXT INDEX idx_property_search ON Property(name, description);

-- Full-text search for review comments
CREATE FULLTEXT INDEX idx_review_search ON Review(comment);

-- =============================================
-- SPECIALIZED INDEXES FOR ANALYTICS
-- =============================================

-- Index for temporal analysis queries
CREATE INDEX idx_booking_temporal ON Booking(DATE(created_at), status);
CREATE INDEX idx_payment_temporal ON Payment(DATE(payment_date), payment_status);

-- Index for geographic analysis
CREATE INDEX idx_location_geo ON Location(latitude, longitude);

-- Index for user segmentation
CREATE INDEX idx_user_segmentation ON User(created_at, role);

-- =============================================
-- PERFORMANCE TESTING QUERIES
-- =============================================

-- Test index performance for common query patterns
-- Note: Run these queries BEFORE creating indexes to establish baseline performance

-- =============================================
-- BASELINE PERFORMANCE MEASUREMENT (BEFORE INDEXES)
-- =============================================

-- 1. Property search by location and price range
EXPLAIN ANALYZE SELECT p.property_id, p.name, p.pricepernight, l.city, l.country
FROM Property p
JOIN Location l ON p.location_id = l.location_id
WHERE l.city = 'San Francisco' 
AND p.pricepernight BETWEEN 100 AND 300
ORDER BY p.pricepernight;

-- 2. User booking history
EXPLAIN ANALYZE SELECT b.booking_id, b.start_date, b.end_date, b.status, p.name
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
WHERE b.user_id = '550e8400-e29b-41d4-a716-446655440007'
ORDER BY b.start_date DESC;

-- 3. Property performance analytics
EXPLAIN ANALYZE SELECT p.property_id, p.name, COUNT(b.booking_id) as bookings, AVG(r.rating) as avg_rating
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id AND b.status = 'confirmed'
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name
ORDER BY bookings DESC;

-- 4. Payment reporting
EXPLAIN ANALYZE SELECT DATE(payment_date) as payment_day, 
       SUM(amount) as daily_revenue,
       COUNT(*) as transaction_count
FROM Payment
WHERE payment_status = 'completed'
AND payment_date >= '2024-01-01'
GROUP BY DATE(payment_date)
ORDER BY payment_day;

-- 5. Host performance query
EXPLAIN ANALYZE SELECT h.user_id, h.first_name, h.last_name,
       COUNT(DISTINCT p.property_id) as properties,
       COUNT(b.booking_id) as bookings,
       SUM(pay.amount) as revenue
FROM User h
JOIN Property p ON h.user_id = p.host_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id AND pay.payment_status = 'completed'
WHERE h.role = 'host'
GROUP BY h.user_id, h.first_name, h.last_name
ORDER BY revenue DESC;

-- =============================================
-- PERFORMANCE MEASUREMENT AFTER INDEX CREATION
-- =============================================
-- Note: Run these queries AFTER creating all indexes to measure improvement

-- 1. Property search by location and price range (AFTER INDEXES)
EXPLAIN ANALYZE SELECT p.property_id, p.name, p.pricepernight, l.city, l.country
FROM Property p
JOIN Location l ON p.location_id = l.location_id
WHERE l.city = 'San Francisco' 
AND p.pricepernight BETWEEN 100 AND 300
ORDER BY p.pricepernight;

-- 2. User booking history (AFTER INDEXES)
EXPLAIN ANALYZE SELECT b.booking_id, b.start_date, b.end_date, b.status, p.name
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
WHERE b.user_id = '550e8400-e29b-41d4-a716-446655440007'
ORDER BY b.start_date DESC;

-- 3. Property performance analytics (AFTER INDEXES)
EXPLAIN ANALYZE SELECT p.property_id, p.name, COUNT(b.booking_id) as bookings, AVG(r.rating) as avg_rating
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id AND b.status = 'confirmed'
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name
ORDER BY bookings DESC;

-- 4. Payment reporting (AFTER INDEXES)
EXPLAIN ANALYZE SELECT DATE(payment_date) as payment_day, 
       SUM(amount) as daily_revenue,
       COUNT(*) as transaction_count
FROM Payment
WHERE payment_status = 'completed'
AND payment_date >= '2024-01-01'
GROUP BY DATE(payment_date)
ORDER BY payment_day;

-- 5. Host performance query (AFTER INDEXES)
EXPLAIN ANALYZE SELECT h.user_id, h.first_name, h.last_name,
       COUNT(DISTINCT p.property_id) as properties,
       COUNT(b.booking_id) as bookings,
       SUM(pay.amount) as revenue
FROM User h
JOIN Property p ON h.user_id = p.host_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id AND pay.payment_status = 'completed'
WHERE h.role = 'host'
GROUP BY h.user_id, h.first_name, h.last_name
ORDER BY revenue DESC;

-- =============================================
-- INDEX MONITORING QUERIES
-- =============================================

-- Monitor index usage statistics
SELECT 
    s.TABLE_NAME,
    s.INDEX_NAME,
    s.CARDINALITY,
    s.SUB_PART,
    s.PACKED,
    s.NULLABLE,
    s.INDEX_TYPE,
    s.COMMENT
FROM INFORMATION_SCHEMA.STATISTICS s
WHERE s.TABLE_SCHEMA = 'airbnb_db'
AND s.INDEX_NAME != 'PRIMARY'
ORDER BY s.TABLE_NAME, s.INDEX_NAME;

-- Check index sizes
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    ROUND(
        SUM(stat_value * @@innodb_page_size) / 1024 / 1024, 2
    ) as index_size_mb
FROM mysql.innodb_index_stats
WHERE database_name = 'airbnb_db'
AND stat_name = 'size'
GROUP BY TABLE_NAME, INDEX_NAME
ORDER BY index_size_mb DESC;

-- =============================================
-- INDEX MAINTENANCE RECOMMENDATIONS
-- =============================================

-- Check for unused indexes (requires query log analysis)
-- This query shows all indexes - unused ones should be considered for removal

SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COUNT(COLUMN_NAME) as column_count,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) as columns
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'airbnb_db'
AND INDEX_NAME != 'PRIMARY'
GROUP BY TABLE_NAME, INDEX_NAME
ORDER BY TABLE_NAME, INDEX_NAME;

-- =============================================
-- QUERY OPTIMIZATION HINTS
-- =============================================

-- Examples of how to use indexes effectively:

-- 1. Force index usage when needed
SELECT /*+ USE_INDEX(Property, idx_property_search_composite) */ 
    p.property_id, p.name, p.pricepernight
FROM Property p
JOIN Location l ON p.location_id = l.location_id
WHERE l.city = 'New York'
ORDER BY p.pricepernight;

-- 2. Avoid index usage when it's not beneficial
SELECT /*+ IGNORE_INDEX(Booking, idx_booking_created_at) */
    COUNT(*) as total_bookings
FROM Booking;

-- =============================================
-- ADDITIONAL PERFORMANCE MEASUREMENT QUERIES
-- =============================================
-- Focused on User, Booking, and Property tables as specified in requirements

-- =============================================
-- USER TABLE PERFORMANCE TESTS
-- =============================================

-- Test 1: User lookup by email (common authentication query)
EXPLAIN ANALYZE SELECT user_id, first_name, last_name, role, created_at
FROM User 
WHERE email = 'john.doe@example.com';

-- Test 2: Users by role with date filtering
EXPLAIN ANALYZE SELECT user_id, first_name, last_name, email, created_at
FROM User 
WHERE role = 'host' 
AND created_at >= '2023-01-01'
ORDER BY created_at DESC;

-- Test 3: User activity analysis
EXPLAIN ANALYZE SELECT u.user_id, u.first_name, u.last_name, u.role,
       COUNT(b.booking_id) as total_bookings,
       MAX(b.created_at) as last_booking_date
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.role
ORDER BY total_bookings DESC;

-- =============================================
-- BOOKING TABLE PERFORMANCE TESTS
-- =============================================

-- Test 4: Booking search by date range and status
EXPLAIN ANALYZE SELECT booking_id, user_id, property_id, start_date, end_date, status
FROM Booking 
WHERE start_date >= '2024-01-01' 
AND end_date <= '2024-12-31'
AND status = 'confirmed'
ORDER BY start_date;

-- Test 5: User's booking history with property details
EXPLAIN ANALYZE SELECT b.booking_id, b.start_date, b.end_date, b.status,
       p.name as property_name, p.pricepernight
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
WHERE b.user_id = '550e8400-e29b-41d4-a716-446655440007'
ORDER BY b.start_date DESC;

-- Test 6: Property booking statistics
EXPLAIN ANALYZE SELECT p.property_id, p.name,
       COUNT(b.booking_id) as total_bookings,
       COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) as confirmed_bookings,
       AVG(DATEDIFF(b.end_date, b.start_date)) as avg_stay_duration
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name
ORDER BY total_bookings DESC;

-- =============================================
-- PROPERTY TABLE PERFORMANCE TESTS
-- =============================================

-- Test 7: Property search by price range and location
EXPLAIN ANALYZE SELECT p.property_id, p.name, p.pricepernight, l.city, l.country
FROM Property p
JOIN Location l ON p.location_id = l.location_id
WHERE p.pricepernight BETWEEN 100 AND 300
AND l.city = 'New York'
ORDER BY p.pricepernight;

-- Test 8: Host's property portfolio
EXPLAIN ANALYZE SELECT p.property_id, p.name, p.pricepernight, l.city,
       COUNT(b.booking_id) as total_bookings,
       AVG(r.rating) as avg_rating
FROM Property p
JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
WHERE p.host_id = '550e8400-e29b-41d4-a716-446655440008'
GROUP BY p.property_id, p.name, p.pricepernight, l.city
ORDER BY total_bookings DESC;

-- Test 9: Property availability check
EXPLAIN ANALYZE SELECT p.property_id, p.name, p.pricepernight
FROM Property p
WHERE p.property_id NOT IN (
    SELECT DISTINCT property_id 
    FROM Booking 
    WHERE status = 'confirmed'
    AND start_date <= '2024-06-15'
    AND end_date >= '2024-06-10'
)
AND p.pricepernight <= 200
ORDER BY p.pricepernight;

-- =============================================
-- COMPLEX JOIN PERFORMANCE TESTS
-- =============================================

-- Test 10: Complete booking information with all related data
EXPLAIN ANALYZE SELECT 
    b.booking_id,
    u.first_name as guest_name,
    u.email as guest_email,
    p.name as property_name,
    h.first_name as host_name,
    l.city, l.country,
    b.start_date, b.end_date,
    b.status,
    pay.amount,
    pay.payment_status
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User h ON p.host_id = h.user_id
JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed'
ORDER BY b.start_date DESC;

-- =============================================
-- BENCHMARK QUERIES FOR PERFORMANCE TESTING
-- =============================================

-- Before and after index performance comparison
SET @start_time = NOW(6);

-- Complex query that should benefit from indexes
SELECT 
    l.city,
    l.country,
    COUNT(DISTINCT p.property_id) as properties,
    COUNT(b.booking_id) as bookings,
    AVG(p.pricepernight) as avg_price,
    SUM(CASE WHEN pay.payment_status = 'completed' THEN pay.amount ELSE 0 END) as revenue
FROM Location l
JOIN Property p ON l.location_id = p.location_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE l.country IN ('United States', 'France', 'Japan')
AND p.pricepernight BETWEEN 50 AND 500
AND (b.status = 'confirmed' OR b.status IS NULL)
GROUP BY l.city, l.country
HAVING COUNT(DISTINCT p.property_id) > 0
ORDER BY revenue DESC, bookings DESC;

SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;

-- =============================================
-- END OF INDEX IMPLEMENTATION
-- =============================================
