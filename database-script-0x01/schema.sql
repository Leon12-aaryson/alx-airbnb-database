-- =============================================
-- AirBnB Database Schema - Third Normal Form (3NF)
-- =============================================
-- This script creates the complete database schema for the AirBnB platform
-- following normalization principles and best practices.

-- Set SQL mode for strict data validation
SET SQL_MODE = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS airbnb_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE airbnb_db;

-- =============================================
-- 1. USER TABLE
-- =============================================
-- Stores all platform users (guests, hosts, admins)
CREATE TABLE User (
    user_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NULL,
    role ENUM('guest', 'host', 'admin') NOT NULL DEFAULT 'guest',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_phone_format CHECK (phone_number IS NULL OR phone_number REGEXP '^[+]?[0-9\s\-\(\)]{10,20}$'),
    CONSTRAINT chk_name_length CHECK (CHAR_LENGTH(first_name) >= 1 AND CHAR_LENGTH(last_name) >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- 2. LOCATION TABLE (Normalized)
-- =============================================
-- Stores location information to eliminate redundancy
CREATE TABLE Location (
    location_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    country VARCHAR(100) NOT NULL,
    state_province VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20) NULL,
    latitude DECIMAL(10,8) NULL,
    longitude DECIMAL(11,8) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_latitude CHECK (latitude IS NULL OR (latitude >= -90 AND latitude <= 90)),
    CONSTRAINT chk_longitude CHECK (longitude IS NULL OR (longitude >= -180 AND longitude <= 180)),
    CONSTRAINT chk_address_length CHECK (CHAR_LENGTH(address) >= 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- 3. PROPERTY TABLE
-- =============================================
-- Stores rental properties with normalized location reference
CREATE TABLE Property (
    property_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    host_id CHAR(36) NOT NULL,
    location_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    pricepernight DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_property_host 
        FOREIGN KEY (host_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    CONSTRAINT fk_property_location
        FOREIGN KEY (location_id) REFERENCES Location(location_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Data Constraints
    CONSTRAINT chk_price_positive CHECK (pricepernight > 0),
    CONSTRAINT chk_name_length CHECK (CHAR_LENGTH(name) >= 3),
    CONSTRAINT chk_description_length CHECK (CHAR_LENGTH(description) >= 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- 4. BOOKING TABLE (Normalized - removed calculated total_price)
-- =============================================
-- Stores booking information without redundant calculated fields
CREATE TABLE Booking (
    booking_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_booking_property 
        FOREIGN KEY (property_id) REFERENCES Property(property_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    CONSTRAINT fk_booking_user 
        FOREIGN KEY (user_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Data Constraints
    CONSTRAINT chk_date_range CHECK (end_date > start_date),
    CONSTRAINT chk_future_booking CHECK (start_date >= CURDATE()),
    CONSTRAINT chk_max_duration CHECK (DATEDIFF(end_date, start_date) <= 365)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- 5. PAYMENT TABLE
-- =============================================
-- Stores payment information for bookings
CREATE TABLE Payment (
    payment_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    booking_id CHAR(36) NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'paypal', 'stripe', 'bank_transfer') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    transaction_id VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_payment_booking 
        FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Data Constraints
    CONSTRAINT chk_payment_amount CHECK (amount > 0),
    CONSTRAINT chk_transaction_id CHECK (
        payment_status = 'pending' OR 
        (payment_status != 'pending' AND transaction_id IS NOT NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- 6. REVIEW TABLE
-- =============================================
-- Stores user reviews for properties
CREATE TABLE Review (
    review_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_review_property 
        FOREIGN KEY (property_id) REFERENCES Property(property_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    CONSTRAINT fk_review_user 
        FOREIGN KEY (user_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Data Constraints
    CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT chk_comment_length CHECK (CHAR_LENGTH(comment) >= 10),
    
    -- Unique constraint to prevent duplicate reviews
    CONSTRAINT uk_user_property_review UNIQUE (user_id, property_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- 7. MESSAGE TABLE
-- =============================================
-- Stores messages between users
CREATE TABLE Message (
    message_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    sender_id CHAR(36) NOT NULL,
    recipient_id CHAR(36) NOT NULL,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    message_type ENUM('inquiry', 'booking', 'general', 'support') NOT NULL DEFAULT 'general',
    
    -- Foreign Key Constraints
    CONSTRAINT fk_message_sender 
        FOREIGN KEY (sender_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    CONSTRAINT fk_message_recipient 
        FOREIGN KEY (recipient_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Data Constraints
    CONSTRAINT chk_different_users CHECK (sender_id != recipient_id),
    CONSTRAINT chk_message_length CHECK (CHAR_LENGTH(message_body) >= 1),
    CONSTRAINT chk_read_after_sent CHECK (read_at IS NULL OR read_at >= sent_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- INDEXES FOR OPTIMAL PERFORMANCE
-- =============================================

-- User table indexes
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_user_role ON User(role);
CREATE INDEX idx_user_created_at ON User(created_at);

-- Location table indexes
CREATE INDEX idx_location_city ON Location(city);
CREATE INDEX idx_location_country ON Location(country);
CREATE INDEX idx_location_coordinates ON Location(latitude, longitude);
CREATE INDEX idx_location_postal ON Location(postal_code);

-- Property table indexes
CREATE INDEX idx_property_host ON Property(host_id);
CREATE INDEX idx_property_location ON Property(location_id);
CREATE INDEX idx_property_price ON Property(pricepernight);
CREATE INDEX idx_property_created_at ON Property(created_at);

-- Booking table indexes
CREATE INDEX idx_booking_property ON Booking(property_id);
CREATE INDEX idx_booking_user ON Booking(user_id);
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_created_at ON Booking(created_at);

-- Payment table indexes
CREATE INDEX idx_payment_booking ON Payment(booking_id);
CREATE INDEX idx_payment_status ON Payment(payment_status);
CREATE INDEX idx_payment_method ON Payment(payment_method);
CREATE INDEX idx_payment_date ON Payment(payment_date);

-- Review table indexes
CREATE INDEX idx_review_property ON Review(property_id);
CREATE INDEX idx_review_user ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);
CREATE INDEX idx_review_created_at ON Review(created_at);

-- Message table indexes
CREATE INDEX idx_message_sender ON Message(sender_id);
CREATE INDEX idx_message_recipient ON Message(recipient_id);
CREATE INDEX idx_message_sent_at ON Message(sent_at);
CREATE INDEX idx_message_type ON Message(message_type);
CREATE INDEX idx_message_unread ON Message(recipient_id, read_at);

-- =============================================
-- VIEWS FOR COMMON QUERIES
-- =============================================

-- View to get booking details with calculated total price
CREATE VIEW BookingDetails AS
SELECT 
    b.booking_id,
    b.property_id,
    b.user_id,
    b.start_date,
    b.end_date,
    b.status,
    b.created_at,
    DATEDIFF(b.end_date, b.start_date) as nights,
    p.pricepernight,
    (DATEDIFF(b.end_date, b.start_date) * p.pricepernight) as total_price
FROM Booking b
JOIN Property p ON b.property_id = p.property_id;

-- View to get property details with location
CREATE VIEW PropertyWithLocation AS
SELECT 
    p.property_id,
    p.host_id,
    p.name,
    p.description,
    p.pricepernight,
    l.country,
    l.state_province,
    l.city,
    l.address,
    l.postal_code,
    l.latitude,
    l.longitude,
    p.created_at,
    p.updated_at
FROM Property p
JOIN Location l ON p.location_id = l.location_id;

-- View to get user statistics
CREATE VIEW UserStats AS
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    COUNT(DISTINCT CASE WHEN u.role IN ('host', 'admin') THEN p.property_id END) as properties_owned,
    COUNT(DISTINCT b.booking_id) as total_bookings,
    COUNT(DISTINCT r.review_id) as reviews_written,
    u.created_at
FROM User u
LEFT JOIN Property p ON u.user_id = p.host_id
LEFT JOIN Booking b ON u.user_id = b.user_id
LEFT JOIN Review r ON u.user_id = r.user_id
GROUP BY u.user_id;

-- =============================================
-- TRIGGERS FOR DATA INTEGRITY
-- =============================================

-- Trigger to update user role to host when they create a property
DELIMITER //
CREATE TRIGGER tr_update_user_to_host
AFTER INSERT ON Property
FOR EACH ROW
BEGIN
    UPDATE User 
    SET role = CASE 
        WHEN role = 'guest' THEN 'host'
        ELSE role 
    END
    WHERE user_id = NEW.host_id;
END//
DELIMITER ;

-- Trigger to prevent booking overlaps
DELIMITER //
CREATE TRIGGER tr_prevent_booking_overlap
BEFORE INSERT ON Booking
FOR EACH ROW
BEGIN
    DECLARE overlap_count INT DEFAULT 0;
    
    SELECT COUNT(*) INTO overlap_count
    FROM Booking
    WHERE property_id = NEW.property_id
      AND status IN ('confirmed', 'pending')
      AND (
          (NEW.start_date BETWEEN start_date AND end_date) OR
          (NEW.end_date BETWEEN start_date AND end_date) OR
          (start_date BETWEEN NEW.start_date AND NEW.end_date) OR
          (end_date BETWEEN NEW.start_date AND NEW.end_date)
      );
    
    IF overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Booking dates overlap with existing booking';
    END IF;
END//
DELIMITER ;

-- =============================================
-- INITIAL DATA SETUP (Optional)
-- =============================================

-- Insert default admin user
INSERT INTO User (user_id, first_name, last_name, email, password_hash, role) 
VALUES (
    UUID(),
    'Admin',
    'User',
    'admin@airbnb.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', -- hashed 'admin123'
    'admin'
);

-- =============================================
-- SCHEMA VALIDATION QUERIES
-- =============================================

-- Query to verify all tables are created
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    CREATE_TIME
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'airbnb_db'
ORDER BY TABLE_NAME;

-- Query to verify all foreign key constraints
SELECT 
    TABLE_NAME,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_SCHEMA = 'airbnb_db' 
    AND CONSTRAINT_TYPE = 'FOREIGN KEY'
ORDER BY TABLE_NAME;

-- Query to verify all indexes
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'airbnb_db'
    AND INDEX_NAME != 'PRIMARY'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- =============================================
-- END OF SCHEMA SCRIPT
-- =============================================
