-- =============================================
-- AirBnB Database Validation and Test Queries
-- =============================================
-- This script contains useful queries for validating and testing
-- the database after seeding with sample data.

USE airbnb_db;

-- =============================================
-- BASIC DATA VALIDATION
-- =============================================

-- Check record counts for all tables
SELECT 'RECORD COUNTS' as section;
SELECT '==============' as section;

SELECT 
    'Users' as table_name, COUNT(*) as record_count FROM User
UNION ALL
SELECT 'Locations' as table_name, COUNT(*) as record_count FROM Location
UNION ALL
SELECT 'Properties' as table_name, COUNT(*) as record_count FROM Property
UNION ALL
SELECT 'Bookings' as table_name, COUNT(*) as record_count FROM Booking
UNION ALL
SELECT 'Payments' as table_name, COUNT(*) as record_count FROM Payment
UNION ALL
SELECT 'Reviews' as table_name, COUNT(*) as record_count FROM Review
UNION ALL
SELECT 'Messages' as table_name, COUNT(*) as record_count FROM Message
ORDER BY record_count DESC;

-- =============================================
-- REFERENTIAL INTEGRITY CHECKS
-- =============================================

SELECT '' as section;
SELECT 'REFERENTIAL INTEGRITY CHECKS' as section;
SELECT '============================' as section;

-- Check for orphaned properties (properties without valid hosts)
SELECT 'Orphaned Properties' as check_type, COUNT(*) as count
FROM Property p
LEFT JOIN User h ON p.host_id = h.user_id AND h.role = 'host'
WHERE h.user_id IS NULL;

-- Check for orphaned bookings (bookings without valid properties or users)
SELECT 'Orphaned Bookings' as check_type, COUNT(*) as count
FROM Booking b
LEFT JOIN Property p ON b.property_id = p.property_id
LEFT JOIN User u ON b.user_id = u.user_id
WHERE p.property_id IS NULL OR u.user_id IS NULL;

-- Check for payments without bookings
SELECT 'Orphaned Payments' as check_type, COUNT(*) as count
FROM Payment pay
LEFT JOIN Booking b ON pay.booking_id = b.booking_id
WHERE b.booking_id IS NULL;

-- =============================================
-- DATA CONSISTENCY CHECKS
-- =============================================

SELECT '' as section;
SELECT 'DATA CONSISTENCY CHECKS' as section;
SELECT '========================' as section;

-- Check for bookings with end_date before start_date
SELECT 'Invalid Date Ranges' as check_type, COUNT(*) as count
FROM Booking
WHERE end_date <= start_date;

-- Check for negative payment amounts
SELECT 'Negative Payments' as check_type, COUNT(*) as count
FROM Payment
WHERE amount < 0;

-- Check for negative property prices
SELECT 'Negative Prices' as check_type, COUNT(*) as count
FROM Property
WHERE pricepernight < 0;

-- =============================================
-- BUSINESS LOGIC VALIDATION
-- =============================================

SELECT '' as section;
SELECT 'BUSINESS LOGIC VALIDATION' as section;
SELECT '==========================' as section;

-- Check booking status distribution
SELECT booking_status, COUNT(*) as count, 
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Booking), 2) as percentage
FROM (
    SELECT status as booking_status FROM Booking
) as booking_stats
GROUP BY booking_status
ORDER BY count DESC;

-- Check payment method distribution
SELECT payment_method, COUNT(*) as count,
       ROUND(SUM(amount), 2) as total_amount
FROM Payment
GROUP BY payment_method
ORDER BY total_amount DESC;

-- Check average property prices by location
SELECT l.city, l.country, 
       COUNT(p.property_id) as property_count,
       ROUND(AVG(p.pricepernight), 2) as avg_price_per_night,
       ROUND(MIN(p.pricepernight), 2) as min_price,
       ROUND(MAX(p.pricepernight), 2) as max_price
FROM Location l
JOIN Property p ON l.location_id = p.location_id
GROUP BY l.city, l.country
ORDER BY avg_price_per_night DESC;

-- =============================================
-- SAMPLE BUSINESS QUERIES
-- =============================================

SELECT '' as section;
SELECT 'SAMPLE BUSINESS QUERIES' as section;
SELECT '=======================' as section;

-- Top rated properties
SELECT p.name, l.city, l.country,
       ROUND(AVG(r.rating), 2) as avg_rating,
       COUNT(r.review_id) as review_count,
       p.pricepernight
FROM Property p
JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name, l.city, l.country, p.pricepernight
HAVING review_count > 0
ORDER BY avg_rating DESC, review_count DESC
LIMIT 5;

-- Most active hosts (by booking count)
SELECT u.first_name, u.last_name, u.email,
       COUNT(DISTINCT p.property_id) as properties_owned,
       COUNT(b.booking_id) as total_bookings,
       ROUND(SUM(pay.amount), 2) as total_revenue
FROM User u
JOIN Property p ON u.user_id = p.host_id
LEFT JOIN Booking b ON p.property_id = b.property_id AND b.status = 'confirmed'
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id AND pay.payment_status = 'completed'
WHERE u.role = 'host'
GROUP BY u.user_id, u.first_name, u.last_name, u.email
ORDER BY total_revenue DESC;

-- Guest booking history
SELECT u.first_name, u.last_name,
       COUNT(b.booking_id) as total_bookings,
       COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) as confirmed_bookings,
       COUNT(CASE WHEN b.status = 'canceled' THEN 1 END) as canceled_bookings,
       ROUND(SUM(CASE WHEN pay.payment_status = 'completed' THEN pay.amount ELSE 0 END), 2) as total_spent
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE u.role = 'guest'
GROUP BY u.user_id, u.first_name, u.last_name
HAVING total_bookings > 0
ORDER BY total_spent DESC;

-- =============================================
-- PERFORMANCE TEST QUERIES
-- =============================================

SELECT '' as section;
SELECT 'PERFORMANCE TEST QUERIES' as section;
SELECT '========================' as section;

-- Test index usage for property search by location
EXPLAIN SELECT p.name, p.pricepernight, l.city, l.country
FROM Property p
JOIN Location l ON p.location_id = l.location_id
WHERE l.city = 'San Francisco'
ORDER BY p.pricepernight;

-- Test index usage for booking search by date range
EXPLAIN SELECT b.booking_id, p.name, b.start_date, b.end_date
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
WHERE b.start_date >= '2024-08-01' AND b.end_date <= '2024-12-31'
ORDER BY b.start_date;

-- =============================================
-- DATA EXPORT SAMPLE
-- =============================================

SELECT '' as section;
SELECT 'PROPERTY LISTING EXPORT SAMPLE' as section;
SELECT '===============================' as section;

SELECT p.property_id,
       p.name as property_name,
       p.description,
       p.pricepernight,
       l.address,
       l.city,
       l.state_province,
       l.country,
       l.postal_code,
       CONCAT(h.first_name, ' ', h.last_name) as host_name,
       h.email as host_email,
       COUNT(b.booking_id) as total_bookings,
       COUNT(r.review_id) as total_reviews,
       ROUND(AVG(r.rating), 2) as avg_rating,
       p.created_at
FROM Property p
JOIN Location l ON p.location_id = l.location_id
JOIN User h ON p.host_id = h.user_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name, p.description, p.pricepernight,
         l.address, l.city, l.state_province, l.country, l.postal_code,
         h.first_name, h.last_name, h.email, p.created_at
ORDER BY p.created_at DESC;

SELECT '' as section;
SELECT 'VALIDATION COMPLETE' as section;
SELECT '==================' as section;
