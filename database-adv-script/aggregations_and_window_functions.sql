-- =============================================
-- Aggregations and Window Functions
-- =============================================
-- This script demonstrates SQL aggregation functions and window functions
-- for advanced data analysis in the AirBnB database.

USE airbnb_db;

-- =============================================
-- 1. BASIC AGGREGATIONS WITH GROUP BY
-- =============================================
-- Find the total number of bookings made by each user

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    COUNT(b.booking_id) as total_bookings,
    COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) as confirmed_bookings,
    COUNT(CASE WHEN b.status = 'pending' THEN 1 END) as pending_bookings,
    COUNT(CASE WHEN b.status = 'canceled' THEN 1 END) as canceled_bookings,
    MIN(b.start_date) as first_booking_date,
    MAX(b.start_date) as last_booking_date,
    SUM(DATEDIFF(b.end_date, b.start_date)) as total_nights_booked
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.role
HAVING COUNT(b.booking_id) > 0
ORDER BY total_bookings DESC, confirmed_bookings DESC;

-- =============================================
-- 2. WINDOW FUNCTIONS - RANKING PROPERTIES
-- =============================================
-- Rank properties based on the total number of bookings they have received

SELECT 
    p.property_id,
    p.name as property_name,
    p.pricepernight,
    l.city,
    l.country,
    CONCAT(h.first_name, ' ', h.last_name) as host_name,
    COUNT(b.booking_id) as total_bookings,
    AVG(r.rating) as average_rating,
    COUNT(r.review_id) as total_reviews,
    
    -- Window functions for ranking
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) as booking_rank,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) as booking_rank_with_ties,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) as booking_dense_rank,
    
    -- Ranking by price within each city
    ROW_NUMBER() OVER (PARTITION BY l.city ORDER BY p.pricepernight DESC) as price_rank_in_city,
    
    -- Ranking by average rating
    ROW_NUMBER() OVER (ORDER BY AVG(r.rating) DESC) as rating_rank,
    
    -- Percentile ranking
    PERCENT_RANK() OVER (ORDER BY COUNT(b.booking_id)) as booking_percentile,
    
    -- Calculate running totals and moving averages
    SUM(COUNT(b.booking_id)) OVER (ORDER BY COUNT(b.booking_id) DESC 
                                   ROWS UNBOUNDED PRECEDING) as running_booking_total,
    AVG(COUNT(b.booking_id)) OVER (ORDER BY COUNT(b.booking_id) DESC 
                                   ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as moving_avg_bookings

FROM Property p
INNER JOIN User h ON p.host_id = h.user_id
INNER JOIN Location l ON p.location_id = l.location_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name, p.pricepernight, l.city, l.country, h.first_name, h.last_name
ORDER BY total_bookings DESC, average_rating DESC;

-- =============================================
-- 3. ADVANCED AGGREGATIONS BY LOCATION
-- =============================================
-- Analyze booking patterns and revenue by location

SELECT 
    l.city,
    l.country,
    COUNT(DISTINCT p.property_id) as total_properties,
    COUNT(b.booking_id) as total_bookings,
    COUNT(DISTINCT b.user_id) as unique_guests,
    
    -- Revenue calculations
    SUM(CASE WHEN pay.payment_status = 'completed' THEN pay.amount ELSE 0 END) as total_revenue,
    AVG(CASE WHEN pay.payment_status = 'completed' THEN pay.amount ELSE NULL END) as avg_booking_value,
    
    -- Booking status distribution
    SUM(CASE WHEN b.status = 'confirmed' THEN 1 ELSE 0 END) as confirmed_bookings,
    SUM(CASE WHEN b.status = 'pending' THEN 1 ELSE 0 END) as pending_bookings,
    SUM(CASE WHEN b.status = 'canceled' THEN 1 ELSE 0 END) as canceled_bookings,
    
    -- Property pricing statistics
    MIN(p.pricepernight) as min_price,
    MAX(p.pricepernight) as max_price,
    AVG(p.pricepernight) as avg_price,
    STDDEV(p.pricepernight) as price_std_dev,
    
    -- Rating statistics
    AVG(r.rating) as avg_rating,
    COUNT(r.review_id) as total_reviews,
    
    -- Occupancy rate (simplified calculation)
    ROUND(
        COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(DISTINCT p.property_id), 0), 2
    ) as occupancy_rate_estimate

FROM Location l
INNER JOIN Property p ON l.location_id = p.location_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY l.city, l.country
ORDER BY total_revenue DESC, total_bookings DESC;

-- =============================================
-- 4. WINDOW FUNCTIONS - TEMPORAL ANALYSIS
-- =============================================
-- Analyze booking trends over time with window functions

SELECT 
    DATE_FORMAT(b.created_at, '%Y-%m') as booking_month,
    COUNT(b.booking_id) as monthly_bookings,
    SUM(pay.amount) as monthly_revenue,
    
    -- Window functions for trend analysis
    LAG(COUNT(b.booking_id), 1) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m')) as prev_month_bookings,
    LEAD(COUNT(b.booking_id), 1) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m')) as next_month_bookings,
    
    -- Calculate month-over-month growth
    ROUND(
        (COUNT(b.booking_id) - LAG(COUNT(b.booking_id), 1) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m'))) * 100.0 / 
        NULLIF(LAG(COUNT(b.booking_id), 1) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m')), 0), 2
    ) as mom_growth_rate,
    
    -- Running totals
    SUM(COUNT(b.booking_id)) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m') 
                                   ROWS UNBOUNDED PRECEDING) as cumulative_bookings,
    SUM(SUM(pay.amount)) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m') 
                               ROWS UNBOUNDED PRECEDING) as cumulative_revenue,
    
    -- Moving averages (3-month)
    AVG(COUNT(b.booking_id)) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m') 
                                   ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as three_month_avg_bookings,
    AVG(SUM(pay.amount)) OVER (ORDER BY DATE_FORMAT(b.created_at, '%Y-%m') 
                               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as three_month_avg_revenue

FROM Booking b
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id AND pay.payment_status = 'completed'
GROUP BY DATE_FORMAT(b.created_at, '%Y-%m')
ORDER BY booking_month;

-- =============================================
-- 5. HOST PERFORMANCE ANALYSIS
-- =============================================
-- Analyze host performance using aggregations and window functions

SELECT 
    h.user_id as host_id,
    CONCAT(h.first_name, ' ', h.last_name) as host_name,
    h.email as host_email,
    COUNT(DISTINCT p.property_id) as total_properties,
    COUNT(b.booking_id) as total_bookings,
    
    -- Revenue metrics
    SUM(CASE WHEN pay.payment_status = 'completed' THEN pay.amount ELSE 0 END) as total_revenue,
    AVG(CASE WHEN pay.payment_status = 'completed' THEN pay.amount ELSE NULL END) as avg_booking_value,
    
    -- Rating metrics
    AVG(r.rating) as avg_rating,
    COUNT(r.review_id) as total_reviews,
    
    -- Booking success rate
    ROUND(
        COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(b.booking_id), 0), 2
    ) as booking_success_rate,
    
    -- Window functions for host ranking
    ROW_NUMBER() OVER (ORDER BY SUM(CASE WHEN pay.payment_status = 'completed' THEN pay.amount ELSE 0 END) DESC) as revenue_rank,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) as booking_rank,
    ROW_NUMBER() OVER (ORDER BY AVG(r.rating) DESC) as rating_rank,
    
    -- Percentile rankings
    PERCENT_RANK() OVER (ORDER BY SUM(CASE WHEN pay.payment_status = 'completed' THEN pay.amount ELSE 0 END)) as revenue_percentile,
    PERCENT_RANK() OVER (ORDER BY AVG(r.rating)) as rating_percentile,
    
    -- Calculate average metrics across all hosts
    AVG(SUM(CASE WHEN pay.payment_status = 'completed' THEN pay.amount ELSE 0 END)) OVER () as avg_host_revenue,
    AVG(COUNT(b.booking_id)) OVER () as avg_host_bookings,
    
    -- Performance vs average
    ROUND(
        SUM(CASE WHEN pay.payment_status = 'completed' THEN pay.amount ELSE 0 END) / 
        NULLIF(AVG(SUM(CASE WHEN pay.payment_status = 'completed' THEN pay.amount ELSE 0 END)) OVER (), 0), 2
    ) as revenue_vs_avg_ratio

FROM User h
INNER JOIN Property p ON h.user_id = p.host_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
LEFT JOIN Review r ON p.property_id = r.property_id
WHERE h.role = 'host'
GROUP BY h.user_id, h.first_name, h.last_name, h.email
HAVING COUNT(b.booking_id) > 0
ORDER BY total_revenue DESC, total_bookings DESC;

-- =============================================
-- 6. ADVANCED WINDOW FUNCTIONS - COHORT ANALYSIS
-- =============================================
-- Analyze user behavior patterns using window functions

WITH user_first_booking AS (
    SELECT 
        u.user_id,
        u.first_name,
        u.last_name,
        u.email,
        u.created_at as user_signup_date,
        MIN(b.created_at) as first_booking_date,
        DATE_FORMAT(MIN(b.created_at), '%Y-%m') as first_booking_month
    FROM User u
    INNER JOIN Booking b ON u.user_id = b.user_id
    GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.created_at
),
user_booking_activity AS (
    SELECT 
        ufb.user_id,
        ufb.first_name,
        ufb.last_name,
        ufb.email,
        ufb.first_booking_month,
        COUNT(b.booking_id) as total_bookings,
        SUM(pay.amount) as total_spent,
        AVG(pay.amount) as avg_booking_value,
        MAX(b.created_at) as last_booking_date,
        DATEDIFF(MAX(b.created_at), MIN(b.created_at)) as days_active
    FROM user_first_booking ufb
    LEFT JOIN Booking b ON ufb.user_id = b.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id AND pay.payment_status = 'completed'
    GROUP BY ufb.user_id, ufb.first_name, ufb.last_name, ufb.email, ufb.first_booking_month
)
SELECT 
    first_booking_month,
    COUNT(user_id) as cohort_size,
    AVG(total_bookings) as avg_bookings_per_user,
    AVG(total_spent) as avg_spending_per_user,
    AVG(avg_booking_value) as avg_booking_value,
    AVG(days_active) as avg_days_active,
    
    -- Window functions for cohort analysis
    SUM(COUNT(user_id)) OVER (ORDER BY first_booking_month ROWS UNBOUNDED PRECEDING) as cumulative_users,
    AVG(AVG(total_bookings)) OVER (ORDER BY first_booking_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as rolling_avg_bookings,
    
    -- Calculate retention proxy (users who made multiple bookings)
    ROUND(
        SUM(CASE WHEN total_bookings > 1 THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(COUNT(user_id), 0), 2
    ) as repeat_user_rate

FROM user_booking_activity
GROUP BY first_booking_month
ORDER BY first_booking_month;

-- =============================================
-- 7. PROPERTY PERFORMANCE QUARTILES
-- =============================================
-- Categorize properties into performance quartiles

SELECT 
    property_id,
    property_name,
    city,
    country,
    total_bookings,
    total_revenue,
    avg_rating,
    pricepernight,
    
    -- Quartile analysis using window functions
    NTILE(4) OVER (ORDER BY total_bookings) as booking_quartile,
    NTILE(4) OVER (ORDER BY total_revenue) as revenue_quartile,
    NTILE(4) OVER (ORDER BY avg_rating) as rating_quartile,
    NTILE(4) OVER (ORDER BY pricepernight) as price_quartile,
    
    -- Performance category based on bookings
    CASE 
        WHEN NTILE(4) OVER (ORDER BY total_bookings) = 4 THEN 'Top Performer'
        WHEN NTILE(4) OVER (ORDER BY total_bookings) = 3 THEN 'High Performer'
        WHEN NTILE(4) OVER (ORDER BY total_bookings) = 2 THEN 'Average Performer'
        ELSE 'Low Performer'
    END as performance_category

FROM (
    SELECT 
        p.property_id,
        p.name as property_name,
        l.city,
        l.country,
        p.pricepernight,
        COUNT(b.booking_id) as total_bookings,
        SUM(CASE WHEN pay.payment_status = 'completed' THEN pay.amount ELSE 0 END) as total_revenue,
        AVG(r.rating) as avg_rating
    FROM Property p
    INNER JOIN Location l ON p.location_id = l.location_id
    LEFT JOIN Booking b ON p.property_id = b.property_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
    LEFT JOIN Review r ON p.property_id = r.property_id
    GROUP BY p.property_id, p.name, l.city, l.country, p.pricepernight
) as property_stats
ORDER BY total_bookings DESC, total_revenue DESC;

-- =============================================
-- PERFORMANCE ANALYSIS
-- =============================================

-- Analyze query performance for window functions
EXPLAIN SELECT 
    property_id,
    COUNT(booking_id) as total_bookings,
    ROW_NUMBER() OVER (ORDER BY COUNT(booking_id) DESC) as booking_rank,
    PERCENT_RANK() OVER (ORDER BY COUNT(booking_id)) as booking_percentile
FROM (
    SELECT p.property_id, b.booking_id
    FROM Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
) as property_bookings
GROUP BY property_id
ORDER BY total_bookings DESC;

-- =============================================
-- END OF AGGREGATIONS AND WINDOW FUNCTIONS
-- =============================================
