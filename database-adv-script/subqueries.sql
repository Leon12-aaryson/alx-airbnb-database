-- =============================================
-- Practice Subqueries
-- =============================================
-- This script demonstrates both correlated and non-correlated subqueries
-- for advanced data analysis in the AirBnB database.

USE airbnb_db;

-- =============================================
-- 1. NON-CORRELATED SUBQUERY
-- =============================================
-- Find all properties where the average rating is greater than 4.0

SELECT 
    p.property_id,
    p.name as property_name,
    p.description,
    p.pricepernight,
    CONCAT(h.first_name, ' ', h.last_name) as host_name,
    l.city,
    l.country,
    -- Calculate average rating for this property
    (SELECT AVG(rating) 
     FROM Review r 
     WHERE r.property_id = p.property_id) as average_rating,
    -- Count total reviews for this property
    (SELECT COUNT(*) 
     FROM Review r 
     WHERE r.property_id = p.property_id) as total_reviews
FROM Property p
INNER JOIN User h ON p.host_id = h.user_id
INNER JOIN Location l ON p.location_id = l.location_id
WHERE p.property_id IN (
    -- Subquery to find properties with average rating > 4.0
    SELECT r.property_id
    FROM Review r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY average_rating DESC, total_reviews DESC;

-- Alternative approach using EXISTS
SELECT 
    p.property_id,
    p.name as property_name,
    p.pricepernight,
    CONCAT(h.first_name, ' ', h.last_name) as host_name,
    l.city,
    l.country
FROM Property p
INNER JOIN User h ON p.host_id = h.user_id
INNER JOIN Location l ON p.location_id = l.location_id
WHERE EXISTS (
    SELECT 1
    FROM Review r
    WHERE r.property_id = p.property_id
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY p.name;

-- =============================================
-- 2. CORRELATED SUBQUERY
-- =============================================
-- Find users who have made more than 3 bookings

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    u.created_at,
    -- Count bookings for each user using correlated subquery
    (SELECT COUNT(*)
     FROM Booking b
     WHERE b.user_id = u.user_id) as total_bookings,
    -- Count confirmed bookings
    (SELECT COUNT(*)
     FROM Booking b
     WHERE b.user_id = u.user_id AND b.status = 'confirmed') as confirmed_bookings,
    -- Total amount spent
    (SELECT COALESCE(SUM(pay.amount), 0)
     FROM Booking b
     INNER JOIN Payment pay ON b.booking_id = pay.booking_id
     WHERE b.user_id = u.user_id AND pay.payment_status = 'completed') as total_spent
FROM User u
WHERE (
    -- Correlated subquery to filter users with more than 3 bookings
    SELECT COUNT(*)
    FROM Booking b
    WHERE b.user_id = u.user_id
) > 3
ORDER BY total_bookings DESC, total_spent DESC;

-- Alternative approach using window function
SELECT 
    user_id,
    first_name,
    last_name,
    email,
    role,
    total_bookings,
    confirmed_bookings,
    total_spent
FROM (
    SELECT 
        u.user_id,
        u.first_name,
        u.last_name,
        u.email,
        u.role,
        COUNT(b.booking_id) as total_bookings,
        COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) as confirmed_bookings,
        COALESCE(SUM(pay.amount), 0) as total_spent
    FROM User u
    LEFT JOIN Booking b ON u.user_id = b.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id AND pay.payment_status = 'completed'
    GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.role
) as user_stats
WHERE total_bookings > 3
ORDER BY total_bookings DESC;

-- =============================================
-- ADDITIONAL ADVANCED SUBQUERY EXAMPLES
-- =============================================

-- 3. Find properties that have never been booked
SELECT 
    p.property_id,
    p.name as property_name,
    p.pricepernight,
    CONCAT(h.first_name, ' ', h.last_name) as host_name,
    l.city,
    l.country,
    p.created_at
FROM Property p
INNER JOIN User h ON p.host_id = h.user_id
INNER JOIN Location l ON p.location_id = l.location_id
WHERE NOT EXISTS (
    SELECT 1
    FROM Booking b
    WHERE b.property_id = p.property_id
)
ORDER BY p.created_at DESC;

-- 4. Find users who have both made bookings and left reviews
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) as total_bookings,
    (SELECT COUNT(*) FROM Review r WHERE r.user_id = u.user_id) as total_reviews
FROM User u
WHERE EXISTS (
    SELECT 1 FROM Booking b WHERE b.user_id = u.user_id
)
AND EXISTS (
    SELECT 1 FROM Review r WHERE r.user_id = u.user_id
)
ORDER BY total_bookings DESC, total_reviews DESC;

-- 5. Find properties with above-average pricing in their city
SELECT 
    p.property_id,
    p.name as property_name,
    p.pricepernight,
    l.city,
    l.country,
    -- Calculate average price for the city
    (SELECT AVG(p2.pricepernight)
     FROM Property p2
     INNER JOIN Location l2 ON p2.location_id = l2.location_id
     WHERE l2.city = l.city) as city_avg_price,
    -- Calculate price difference from city average
    p.pricepernight - (SELECT AVG(p2.pricepernight)
                       FROM Property p2
                       INNER JOIN Location l2 ON p2.location_id = l2.location_id
                       WHERE l2.city = l.city) as price_diff
FROM Property p
INNER JOIN Location l ON p.location_id = l.location_id
WHERE p.pricepernight > (
    -- Subquery to find average price in the same city
    SELECT AVG(p2.pricepernight)
    FROM Property p2
    INNER JOIN Location l2 ON p2.location_id = l2.location_id
    WHERE l2.city = l.city
)
ORDER BY price_diff DESC;

-- 6. Find the most expensive property in each city
SELECT 
    l.city,
    l.country,
    p.property_id,
    p.name as property_name,
    p.pricepernight,
    CONCAT(h.first_name, ' ', h.last_name) as host_name
FROM Property p
INNER JOIN Location l ON p.location_id = l.location_id
INNER JOIN User h ON p.host_id = h.user_id
WHERE p.pricepernight = (
    -- Correlated subquery to find max price in each city
    SELECT MAX(p2.pricepernight)
    FROM Property p2
    INNER JOIN Location l2 ON p2.location_id = l2.location_id
    WHERE l2.city = l.city
)
ORDER BY l.city, p.pricepernight DESC;

-- 7. Find users with booking patterns (frequent vs occasional bookers)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) as total_bookings,
    (SELECT MIN(b.start_date) FROM Booking b WHERE b.user_id = u.user_id) as first_booking_date,
    (SELECT MAX(b.start_date) FROM Booking b WHERE b.user_id = u.user_id) as last_booking_date,
    CASE 
        WHEN (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) >= 5 THEN 'Frequent'
        WHEN (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) >= 2 THEN 'Regular'
        WHEN (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) >= 1 THEN 'Occasional'
        ELSE 'No Bookings'
    END as booking_pattern
FROM User u
WHERE u.role = 'guest'
ORDER BY total_bookings DESC;

-- 8. Find properties with higher than average ratings but lower than average price
SELECT 
    p.property_id,
    p.name as property_name,
    p.pricepernight,
    l.city,
    l.country,
    (SELECT AVG(r.rating) FROM Review r WHERE r.property_id = p.property_id) as avg_rating,
    (SELECT AVG(pricepernight) FROM Property) as overall_avg_price,
    (SELECT AVG(r.rating) FROM Review r) as overall_avg_rating
FROM Property p
INNER JOIN Location l ON p.location_id = l.location_id
WHERE p.pricepernight < (SELECT AVG(pricepernight) FROM Property)
AND EXISTS (
    SELECT 1 
    FROM Review r 
    WHERE r.property_id = p.property_id
    GROUP BY r.property_id
    HAVING AVG(r.rating) > (SELECT AVG(rating) FROM Review)
)
ORDER BY avg_rating DESC, p.pricepernight ASC;

-- =============================================
-- PERFORMANCE ANALYSIS FOR SUBQUERIES
-- =============================================

-- Analyze performance of correlated vs non-correlated subqueries
EXPLAIN SELECT 
    p.property_id,
    p.name,
    (SELECT AVG(rating) FROM Review r WHERE r.property_id = p.property_id) as avg_rating
FROM Property p
WHERE p.property_id IN (
    SELECT r.property_id
    FROM Review r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
);

-- =============================================
-- END OF SUBQUERIES SCRIPT
-- =============================================
