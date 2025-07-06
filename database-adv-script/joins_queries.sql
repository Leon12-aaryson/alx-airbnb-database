-- =============================================
-- Complex Queries with Joins
-- =============================================
-- This script demonstrates advanced SQL join techniques
-- for retrieving data from multiple related tables.

USE airbnb_db;

-- =============================================
-- 1. INNER JOIN - Bookings with User Details
-- =============================================
-- Retrieve all bookings along with the user information
-- for users who made those bookings

SELECT 
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.status,
    b.created_at as booking_created_at,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    DATEDIFF(b.end_date, b.start_date) as nights_booked
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
ORDER BY b.created_at DESC;

-- =============================================
-- 2. LEFT JOIN - Properties with Reviews
-- =============================================
-- Retrieve all properties along with their reviews,
-- including properties that have no reviews

SELECT 
    p.property_id,
    p.name as property_name,
    p.description,
    p.pricepernight,
    p.created_at as property_created_at,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at as review_created_at,
    CONCAT(u.first_name, ' ', u.last_name) as reviewer_name
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
LEFT JOIN User u ON r.user_id = u.user_id
ORDER BY p.property_id, r.created_at DESC;

-- =============================================
-- 3. FULL OUTER JOIN - Users and Bookings
-- =============================================
-- Retrieve all users and all bookings, even if the user has no booking
-- or a booking is not linked to a user (MySQL doesn't support FULL OUTER JOIN
-- natively, so we use UNION to simulate it)

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.status,
    'User with booking' as relationship_type
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id

UNION

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.status,
    'Booking without user' as relationship_type
FROM User u
RIGHT JOIN Booking b ON u.user_id = b.user_id
WHERE u.user_id IS NULL

ORDER BY user_id, booking_id;

-- =============================================
-- ADDITIONAL COMPLEX JOIN EXAMPLES
-- =============================================

-- 4. Multi-table join with property location and host information
SELECT 
    p.property_id,
    p.name as property_name,
    p.pricepernight,
    CONCAT(h.first_name, ' ', h.last_name) as host_name,
    h.email as host_email,
    l.city,
    l.state_province,
    l.country,
    l.address,
    COUNT(b.booking_id) as total_bookings,
    AVG(r.rating) as average_rating
FROM Property p
INNER JOIN User h ON p.host_id = h.user_id
INNER JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name, p.pricepernight, h.first_name, h.last_name, 
         h.email, l.city, l.state_province, l.country, l.address
ORDER BY total_bookings DESC, average_rating DESC;

-- 5. Complex join with payment information
SELECT 
    b.booking_id,
    CONCAT(g.first_name, ' ', g.last_name) as guest_name,
    g.email as guest_email,
    p.name as property_name,
    CONCAT(h.first_name, ' ', h.last_name) as host_name,
    l.city,
    l.country,
    b.start_date,
    b.end_date,
    b.status as booking_status,
    pay.amount as payment_amount,
    pay.payment_method,
    pay.payment_status,
    pay.payment_date
FROM Booking b
INNER JOIN User g ON b.user_id = g.user_id  -- Guest information
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User h ON p.host_id = h.user_id  -- Host information
INNER JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed'
ORDER BY b.created_at DESC;

-- 6. Self-join example - Find users who have both hosted and booked properties
SELECT DISTINCT
    u1.user_id,
    CONCAT(u1.first_name, ' ', u1.last_name) as user_name,
    u1.email,
    u1.role,
    'Both host and guest' as user_type
FROM User u1
INNER JOIN Property p ON u1.user_id = p.host_id  -- User as host
INNER JOIN Booking b ON u1.user_id = b.user_id   -- Same user as guest
WHERE u1.role = 'host'
ORDER BY u1.first_name, u1.last_name;

-- =============================================
-- PERFORMANCE ANALYSIS QUERIES
-- =============================================

-- Query to analyze join performance
EXPLAIN SELECT 
    b.booking_id,
    u.first_name,
    u.last_name,
    p.name as property_name,
    l.city
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN Location l ON p.location_id = l.location_id
WHERE b.status = 'confirmed'
AND b.start_date >= '2024-01-01'
ORDER BY b.start_date;

-- =============================================
-- END OF JOINS QUERIES
-- =============================================
