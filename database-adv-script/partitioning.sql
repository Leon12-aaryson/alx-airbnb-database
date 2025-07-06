-- =============================================
-- Table Partitioning Implementation for Large Datasets
-- =============================================
-- This script implements partitioning on the Booking table to optimize
-- queries on large datasets, particularly for date-based queries.

USE airbnb_db;

-- =============================================
-- PARTITIONING ANALYSIS AND STRATEGY
-- =============================================

-- Before implementing partitioning, let's analyze the current table structure
-- and query patterns to determine the optimal partitioning strategy

-- Check current table size and distribution
SELECT 
    COUNT(*) as total_bookings,
    MIN(start_date) as earliest_booking,
    MAX(start_date) as latest_booking,
    YEAR(MIN(start_date)) as earliest_year,
    YEAR(MAX(start_date)) as latest_year
FROM Booking;

-- Analyze booking distribution by month
SELECT 
    YEAR(start_date) as booking_year,
    MONTH(start_date) as booking_month,
    COUNT(*) as bookings_count,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Booking) as percentage
FROM Booking
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY booking_year, booking_month;

-- Analyze query patterns that would benefit from partitioning
-- Most common queries on Booking table:
-- 1. Date range queries (start_date, end_date)
-- 2. Status filtering with date ranges
-- 3. User booking history with date ranges
-- 4. Property booking history with date ranges

-- =============================================
-- BACKUP CURRENT TABLE STRUCTURE
-- =============================================

-- Create backup of current Booking table
CREATE TABLE Booking_backup AS
SELECT * FROM Booking;

-- Verify backup
SELECT COUNT(*) as backup_count FROM Booking_backup;

-- =============================================
-- PARTITION STRATEGY IMPLEMENTATION
-- =============================================

-- Strategy: RANGE partitioning by start_date
-- Benefits:
-- 1. Improved query performance for date-based queries
-- 2. Better maintenance operations (archiving old data)
-- 3. Parallel processing capabilities
-- 4. Reduced index maintenance overhead

-- Drop existing foreign key constraints temporarily
ALTER TABLE Payment DROP FOREIGN KEY fk_payment_booking;
ALTER TABLE Review DROP FOREIGN KEY fk_review_property;

-- Create new partitioned Booking table
DROP TABLE IF EXISTS Booking_partitioned;

CREATE TABLE Booking_partitioned (
    booking_id CHAR(36) NOT NULL,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (booking_id, start_date),
    KEY idx_property_id (property_id),
    KEY idx_user_id (user_id),
    KEY idx_status (status),
    KEY idx_created_at (created_at),
    KEY idx_date_range (start_date, end_date),
    
    -- Constraints (adapted for partitioning)
    CONSTRAINT chk_date_range_part CHECK (end_date > start_date),
    CONSTRAINT chk_future_booking_part CHECK (start_date >= '2024-01-01'),
    CONSTRAINT chk_max_duration_part CHECK (DATEDIFF(end_date, start_date) <= 365)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
PARTITION BY RANGE (YEAR(start_date) * 100 + MONTH(start_date)) (
    PARTITION p202401 VALUES LESS THAN (202402),
    PARTITION p202402 VALUES LESS THAN (202403),
    PARTITION p202403 VALUES LESS THAN (202404),
    PARTITION p202404 VALUES LESS THAN (202405),
    PARTITION p202405 VALUES LESS THAN (202406),
    PARTITION p202406 VALUES LESS THAN (202407),
    PARTITION p202407 VALUES LESS THAN (202408),
    PARTITION p202408 VALUES LESS THAN (202409),
    PARTITION p202409 VALUES LESS THAN (202410),
    PARTITION p202410 VALUES LESS THAN (202411),
    PARTITION p202411 VALUES LESS THAN (202412),
    PARTITION p202412 VALUES LESS THAN (202501),
    PARTITION p202501 VALUES LESS THAN (202502),
    PARTITION p202502 VALUES LESS THAN (202503),
    PARTITION p202503 VALUES LESS THAN (202504),
    PARTITION p202504 VALUES LESS THAN (202505),
    PARTITION p202505 VALUES LESS THAN (202506),
    PARTITION p202506 VALUES LESS THAN (202507),
    PARTITION p202507 VALUES LESS THAN (202508),
    PARTITION p202508 VALUES LESS THAN (202509),
    PARTITION p202509 VALUES LESS THAN (202510),
    PARTITION p202510 VALUES LESS THAN (202511),
    PARTITION p202511 VALUES LESS THAN (202512),
    PARTITION p202512 VALUES LESS THAN (202601),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- =============================================
-- DATA MIGRATION TO PARTITIONED TABLE
-- =============================================

-- Insert data from original table to partitioned table
INSERT INTO Booking_partitioned 
SELECT * FROM Booking;

-- Verify data migration
SELECT COUNT(*) as original_count FROM Booking;
SELECT COUNT(*) as partitioned_count FROM Booking_partitioned;

-- Check partition distribution
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH,
    DATA_FREE
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_SCHEMA = 'airbnb_db' 
    AND TABLE_NAME = 'Booking_partitioned'
    AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_NAME;

-- =============================================
-- PERFORMANCE TESTING - BEFORE PARTITIONING
-- =============================================

-- Test 1: Date range query on original table
SET @start_time = NOW(6);

SELECT COUNT(*) as booking_count
FROM Booking
WHERE start_date >= '2024-06-01' 
    AND start_date < '2024-09-01';

SET @end_time = NOW(6);
SELECT 'Original Table - Date Range Query' as query_type,
       TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;

-- Test 2: Complex query with date filtering on original table
SET @start_time = NOW(6);

SELECT 
    b.status,
    COUNT(*) as booking_count,
    AVG(DATEDIFF(b.end_date, b.start_date)) as avg_nights
FROM Booking b
WHERE b.start_date >= '2024-05-01' 
    AND b.start_date < '2024-08-01'
GROUP BY b.status;

SET @end_time = NOW(6);
SELECT 'Original Table - Complex Query' as query_type,
       TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;

-- =============================================
-- PERFORMANCE TESTING - AFTER PARTITIONING
-- =============================================

-- Test 1: Date range query on partitioned table
SET @start_time = NOW(6);

SELECT COUNT(*) as booking_count
FROM Booking_partitioned
WHERE start_date >= '2024-06-01' 
    AND start_date < '2024-09-01';

SET @end_time = NOW(6);
SELECT 'Partitioned Table - Date Range Query' as query_type,
       TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;

-- Test 2: Complex query with date filtering on partitioned table
SET @start_time = NOW(6);

SELECT 
    b.status,
    COUNT(*) as booking_count,
    AVG(DATEDIFF(b.end_date, b.start_date)) as avg_nights
FROM Booking_partitioned b
WHERE b.start_date >= '2024-05-01' 
    AND b.start_date < '2024-08-01'
GROUP BY b.status;

SET @end_time = NOW(6);
SELECT 'Partitioned Table - Complex Query' as query_type,
       TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;

-- Test 3: Query execution plan comparison
EXPLAIN PARTITIONS 
SELECT * FROM Booking_partitioned
WHERE start_date >= '2024-07-01' 
    AND start_date < '2024-08-01'
ORDER BY start_date;

-- =============================================
-- PARTITION PRUNING DEMONSTRATION
-- =============================================

-- Show how partition pruning works
EXPLAIN PARTITIONS 
SELECT COUNT(*) 
FROM Booking_partitioned 
WHERE start_date = '2024-07-15';

-- Query that spans multiple partitions
EXPLAIN PARTITIONS 
SELECT COUNT(*) 
FROM Booking_partitioned 
WHERE start_date >= '2024-06-15' 
    AND start_date <= '2024-08-15';

-- Query without partition key (no pruning)
EXPLAIN PARTITIONS 
SELECT COUNT(*) 
FROM Booking_partitioned 
WHERE status = 'confirmed';

-- =============================================
-- PARTITION MAINTENANCE OPERATIONS
-- =============================================

-- Add new partition for future dates
ALTER TABLE Booking_partitioned 
ADD PARTITION (
    PARTITION p202601 VALUES LESS THAN (202602),
    PARTITION p202602 VALUES LESS THAN (202603)
);

-- Drop old partition (example - be careful with this in production)
-- ALTER TABLE Booking_partitioned DROP PARTITION p202401;

-- Reorganize partitions if needed
-- ALTER TABLE Booking_partitioned REORGANIZE PARTITION p_future INTO (
--     PARTITION p202603 VALUES LESS THAN (202604),
--     PARTITION p_future VALUES LESS THAN MAXVALUE
-- );

-- Check partition information after modifications
SELECT 
    PARTITION_NAME,
    PARTITION_DESCRIPTION,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_SCHEMA = 'airbnb_db' 
    AND TABLE_NAME = 'Booking_partitioned'
    AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_ORDINAL_POSITION;

-- =============================================
-- OPTIMIZED QUERIES FOR PARTITIONED TABLE
-- =============================================

-- Query 1: Monthly booking analysis (leverages partitioning)
SELECT 
    YEAR(start_date) as booking_year,
    MONTH(start_date) as booking_month,
    COUNT(*) as total_bookings,
    COUNT(CASE WHEN status = 'confirmed' THEN 1 END) as confirmed_bookings,
    AVG(DATEDIFF(end_date, start_date)) as avg_nights
FROM Booking_partitioned
WHERE start_date >= '2024-01-01' 
    AND start_date < '2025-01-01'
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY booking_year, booking_month;

-- Query 2: User booking history (partition-aware)
SELECT 
    bp.user_id,
    COUNT(*) as total_bookings,
    MIN(bp.start_date) as first_booking,
    MAX(bp.start_date) as last_booking,
    SUM(DATEDIFF(bp.end_date, bp.start_date)) as total_nights
FROM Booking_partitioned bp
WHERE bp.start_date >= '2024-01-01'
    AND bp.user_id IN (
        SELECT user_id FROM User WHERE role = 'guest'
    )
GROUP BY bp.user_id
HAVING COUNT(*) > 1
ORDER BY total_bookings DESC;

-- Query 3: Property performance by quarter (partition-efficient)
SELECT 
    property_id,
    QUARTER(start_date) as booking_quarter,
    COUNT(*) as bookings,
    COUNT(CASE WHEN status = 'confirmed' THEN 1 END) as confirmed_bookings,
    ROUND(COUNT(CASE WHEN status = 'confirmed' THEN 1 END) * 100.0 / COUNT(*), 2) as confirmation_rate
FROM Booking_partitioned
WHERE start_date >= '2024-01-01' 
    AND start_date < '2025-01-01'
GROUP BY property_id, QUARTER(start_date)
HAVING COUNT(*) > 0
ORDER BY property_id, booking_quarter;

-- =============================================
-- ALTERNATIVE PARTITIONING STRATEGIES
-- =============================================

-- Strategy 2: Hash partitioning by user_id (for user-based queries)
-- This would be useful if most queries are user-specific rather than date-based

/*
CREATE TABLE Booking_hash_partitioned (
    -- same structure as above
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
PARTITION BY HASH(CRC32(user_id))
PARTITIONS 8;
*/

-- Strategy 3: Range partitioning by booking_id (for general distribution)
-- This could be useful for general performance improvement

/*
CREATE TABLE Booking_range_partitioned (
    -- same structure as above
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
PARTITION BY RANGE (CRC32(booking_id)) (
    PARTITION p1 VALUES LESS THAN (1000000000),
    PARTITION p2 VALUES LESS THAN (2000000000),
    PARTITION p3 VALUES LESS THAN (3000000000),
    PARTITION p4 VALUES LESS THAN MAXVALUE
);
*/

-- =============================================
-- MONITORING AND MAINTENANCE SCRIPTS
-- =============================================

-- Monitor partition sizes and growth
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    ROUND(DATA_LENGTH / 1024 / 1024, 2) as data_size_mb,
    ROUND(INDEX_LENGTH / 1024 / 1024, 2) as index_size_mb,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) as total_size_mb,
    PARTITION_DESCRIPTION
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_SCHEMA = 'airbnb_db' 
    AND TABLE_NAME = 'Booking_partitioned'
    AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_ORDINAL_POSITION;

-- Check for partition pruning in queries
SELECT 
    'Partition Pruning Status' as info,
    'Use EXPLAIN PARTITIONS to check if queries use partition pruning' as instruction;

-- Performance monitoring query
SELECT 
    'Performance Monitoring' as info,
    'Compare execution times of similar queries on partitioned vs non-partitioned tables' as instruction;

-- =============================================
-- CLEANUP AND RESTORATION OPTIONS
-- =============================================

-- If you need to restore the original table structure:
/*
-- Restore original table
DROP TABLE Booking;
CREATE TABLE Booking AS SELECT * FROM Booking_backup;

-- Restore foreign key constraints
ALTER TABLE Payment ADD CONSTRAINT fk_payment_booking 
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Clean up backup and test tables
DROP TABLE Booking_backup;
DROP TABLE Booking_partitioned;
*/

-- =============================================
-- PARTITION PERFORMANCE ANALYSIS
-- =============================================

-- Summary query to show partition effectiveness
SELECT 
    'Partitioning Summary' as analysis_type,
    COUNT(DISTINCT PARTITION_NAME) as partition_count,
    SUM(TABLE_ROWS) as total_rows,
    AVG(TABLE_ROWS) as avg_rows_per_partition,
    MIN(TABLE_ROWS) as min_rows_per_partition,
    MAX(TABLE_ROWS) as max_rows_per_partition,
    ROUND(SUM(DATA_LENGTH) / 1024 / 1024, 2) as total_data_mb,
    ROUND(SUM(INDEX_LENGTH) / 1024 / 1024, 2) as total_index_mb
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_SCHEMA = 'airbnb_db' 
    AND TABLE_NAME = 'Booking_partitioned'
    AND PARTITION_NAME IS NOT NULL;

-- =============================================
-- END OF PARTITIONING SCRIPT
-- =============================================
