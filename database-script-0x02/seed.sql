-- =============================================
-- AirBnB Database Sample Data - Seed Script
-- =============================================
-- This script populates the database with realistic sample data
-- for testing and demonstration purposes.

USE airbnb_db;

-- Disable foreign key checks temporarily for easier data insertion
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================
-- 1. SAMPLE USERS
-- =============================================
-- Insert diverse users representing guests, hosts, and admins

INSERT INTO User (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) VALUES
-- Admins
('550e8400-e29b-41d4-a716-446655440001', 'Alice', 'Admin', 'alice.admin@airbnb.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0001', 'admin', '2023-01-15 10:00:00'),

-- Hosts
('550e8400-e29b-41d4-a716-446655440002', 'John', 'Smith', 'john.smith@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0002', 'host', '2023-02-01 09:30:00'),
('550e8400-e29b-41d4-a716-446655440003', 'Maria', 'Garcia', 'maria.garcia@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0003', 'host', '2023-02-15 14:20:00'),
('550e8400-e29b-41d4-a716-446655440004', 'David', 'Johnson', 'david.johnson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0004', 'host', '2023-03-01 11:15:00'),
('550e8400-e29b-41d4-a716-446655440005', 'Sophie', 'Chen', 'sophie.chen@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0005', 'host', '2023-03-15 16:45:00'),
('550e8400-e29b-41d4-a716-446655440006', 'Ahmed', 'Hassan', 'ahmed.hassan@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0006', 'host', '2023-04-01 08:30:00'),

-- Guests (some will become hosts later)
('550e8400-e29b-41d4-a716-446655440007', 'Emma', 'Wilson', 'emma.wilson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0007', 'guest', '2023-04-15 12:00:00'),
('550e8400-e29b-41d4-a716-446655440008', 'Michael', 'Brown', 'michael.brown@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0008', 'guest', '2023-05-01 15:30:00'),
('550e8400-e29b-41d4-a716-446655440009', 'Lisa', 'Anderson', 'lisa.anderson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0009', 'guest', '2023-05-15 10:45:00'),
('550e8400-e29b-41d4-a716-446655440010', 'Robert', 'Taylor', 'robert.taylor@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0010', 'guest', '2023-06-01 13:20:00'),
('550e8400-e29b-41d4-a716-446655440011', 'Sarah', 'Davis', 'sarah.davis@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0011', 'guest', '2023-06-15 17:10:00'),
('550e8400-e29b-41d4-a716-446655440012', 'James', 'Miller', 'james.miller@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0012', 'guest', '2023-07-01 09:15:00'),
('550e8400-e29b-41d4-a716-446655440013', 'Anna', 'Martinez', 'anna.martinez@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0013', 'guest', '2023-07-15 14:40:00'),
('550e8400-e29b-41d4-a716-446655440014', 'Kevin', 'Lee', 'kevin.lee@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0014', 'guest', '2023-08-01 11:25:00'),
('550e8400-e29b-41d4-a716-446655440015', 'Rachel', 'Thompson', 'rachel.thompson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0015', 'guest', '2023-08-15 16:00:00'),
('550e8400-e29b-41d4-a716-446655440016', 'Daniel', 'White', 'daniel.white@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKzWKAKfN8L1nce', '+1-555-0016', 'guest', '2023-09-01 12:35:00');

-- =============================================
-- 2. SAMPLE LOCATIONS
-- =============================================
-- Insert diverse locations across different countries and cities

INSERT INTO Location (location_id, country, state_province, city, address, postal_code, latitude, longitude, created_at) VALUES
-- United States Locations
('650e8400-e29b-41d4-a716-446655440001', 'United States', 'California', 'San Francisco', '123 Market Street', '94102', 37.7749, -122.4194, '2023-01-20 10:00:00'),
('650e8400-e29b-41d4-a716-446655440002', 'United States', 'California', 'Los Angeles', '456 Hollywood Blvd', '90028', 34.0522, -118.2437, '2023-01-21 11:00:00'),
('650e8400-e29b-41d4-a716-446655440003', 'United States', 'New York', 'New York City', '789 Broadway', '10003', 40.7128, -74.0060, '2023-01-22 12:00:00'),
('650e8400-e29b-41d4-a716-446655440004', 'United States', 'Florida', 'Miami', '321 Ocean Drive', '33139', 25.7617, -80.1918, '2023-01-23 13:00:00'),
('650e8400-e29b-41d4-a716-446655440005', 'United States', 'Texas', 'Austin', '654 South Lamar', '78704', 30.2672, -97.7431, '2023-01-24 14:00:00'),

-- International Locations
('650e8400-e29b-41d4-a716-446655440006', 'France', 'Île-de-France', 'Paris', '12 Rue de la Paix', '75001', 48.8566, 2.3522, '2023-01-25 15:00:00'),
('650e8400-e29b-41d4-a716-446655440007', 'United Kingdom', 'England', 'London', '45 Baker Street', 'NW1 6XE', 51.5074, -0.1278, '2023-01-26 16:00:00'),
('650e8400-e29b-41d4-a716-446655440008', 'Japan', 'Tokyo', 'Tokyo', '78 Shibuya Crossing', '150-0043', 35.6762, 139.6503, '2023-01-27 17:00:00'),
('650e8400-e29b-41d4-a716-446655440009', 'Italy', 'Lazio', 'Rome', '23 Via del Corso', '00186', 41.9028, 12.4964, '2023-01-28 18:00:00'),
('650e8400-e29b-41d4-a716-446655440010', 'Spain', 'Catalonia', 'Barcelona', '67 Las Ramblas', '08002', 41.3851, 2.1734, '2023-01-29 19:00:00'),
('650e8400-e29b-41d4-a716-446655440011', 'Germany', 'Berlin', 'Berlin', '89 Unter den Linden', '10117', 52.5200, 13.4050, '2023-01-30 20:00:00'),
('650e8400-e29b-41d4-a716-446655440012', 'Canada', 'Ontario', 'Toronto', '34 King Street West', 'M5H 1A1', 43.6532, -79.3832, '2023-02-01 09:00:00'),
('650e8400-e29b-41d4-a716-446655440013', 'Australia', 'New South Wales', 'Sydney', '56 George Street', '2000', -33.8688, 151.2093, '2023-02-02 10:00:00'),
('650e8400-e29b-41d4-a716-446655440014', 'Brazil', 'Rio de Janeiro', 'Rio de Janeiro', '12 Copacabana Beach', '22070-011', -22.9068, -43.1729, '2023-02-03 11:00:00'),
('650e8400-e29b-41d4-a716-446655440015', 'Thailand', 'Bangkok', 'Bangkok', '89 Khao San Road', '10200', 13.7563, 100.5018, '2023-02-04 12:00:00');

-- =============================================
-- 3. SAMPLE PROPERTIES
-- =============================================
-- Insert diverse properties with different price ranges and features

INSERT INTO Property (property_id, host_id, location_id, name, description, pricepernight, created_at) VALUES
-- Premium Properties
('750e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440001', 'Luxury Downtown Loft', 'Stunning modern loft in the heart of San Francisco with panoramic city views, high-end appliances, and walking distance to major attractions.', 295.00, '2023-02-10 10:00:00'),
('750e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440002', 'Hollywood Hills Villa', 'Exclusive villa with pool and city views. Perfect for celebrities and luxury travelers. Features home theater, gym, and chef kitchen.', 450.00, '2023-02-11 11:00:00'),
('750e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440003', 'Manhattan Penthouse', 'Breathtaking penthouse apartment with Central Park views. Luxurious furnishings and premium amenities in prime NYC location.', 580.00, '2023-02-12 12:00:00'),

-- Mid-range Properties
('750e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440004', 'Miami Beach Condo', 'Beautiful beachfront condo with ocean views. Modern amenities, beach access, and close to South Beach nightlife and restaurants.', 185.00, '2023-02-13 13:00:00'),
('750e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440005', 'Austin Music District Apartment', 'Trendy apartment in the heart of Austin music scene. Walking distance to live venues, restaurants, and vibrant nightlife.', 125.00, '2023-02-14 14:00:00'),
('750e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440006', 'Parisian Charm Studio', 'Cozy studio apartment near the Louvre with authentic Parisian charm. Perfect for couples exploring the City of Light.', 95.00, '2023-02-15 15:00:00'),
('750e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440007', 'London Victorian Townhouse', 'Historic Victorian townhouse in central London. Traditional British charm with modern conveniences and garden access.', 220.00, '2023-02-16 16:00:00'),

-- Budget-friendly Properties
('750e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440008', 'Tokyo Capsule Experience', 'Modern capsule hotel experience in Shibuya. Compact but efficient design with all necessary amenities for budget travelers.', 65.00, '2023-02-17 17:00:00'),
('750e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440009', 'Rome Historic Apartment', 'Charming apartment near the Colosseum. Traditional Italian architecture with modern updates and easy access to historic sites.', 110.00, '2023-02-18 18:00:00'),
('750e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440010', 'Barcelona Beach Hostel', 'Friendly hostel near Barcelona beaches. Great for backpackers and budget travelers. Includes breakfast and communal kitchen.', 35.00, '2023-02-19 19:00:00'),

-- Additional Properties for variety
('750e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440011', 'Berlin Art District Loft', 'Creative loft in Berlin art district. Exposed brick, high ceilings, and surrounded by galleries, cafes, and cultural venues.', 85.00, '2023-02-20 20:00:00'),
('750e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440012', 'Toronto Downtown Suite', 'Modern suite in downtown Toronto. Business traveler friendly with workspace, high-speed internet, and transit access.', 140.00, '2023-02-21 21:00:00'),
('750e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440013', 'Sydney Harbor View', 'Stunning apartment with Sydney Harbor views. Perfect location for exploring Opera House, Harbour Bridge, and The Rocks.', 175.00, '2023-02-22 22:00:00'),
('750e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440014', 'Rio Beach House', 'Colorful beach house near Copacabana. Brazilian charm with beach access, outdoor space, and local cultural immersion.', 120.00, '2023-02-23 23:00:00'),
('750e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440015', 'Bangkok Backpacker Hub', 'Budget-friendly accommodation in Khao San Road area. Perfect for backpackers with shared facilities and travel information.', 25.00, '2023-02-24 08:00:00');

-- =============================================
-- 4. SAMPLE BOOKINGS
-- =============================================
-- Insert bookings with various statuses and date ranges

INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, status, created_at) VALUES
-- Confirmed Bookings (Past and Future)
('850e8400-e29b-41d4-a716-446655440001', '750e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440007', '2024-08-15', '2024-08-20', 'confirmed', '2024-07-01 10:00:00'),
('850e8400-e29b-41d4-a716-446655440002', '750e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440008', '2024-09-01', '2024-09-07', 'confirmed', '2024-07-15 14:30:00'),
('850e8400-e29b-41d4-a716-446655440003', '750e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440009', '2024-08-25', '2024-08-30', 'confirmed', '2024-07-20 16:45:00'),
('850e8400-e29b-41d4-a716-446655440004', '750e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440010', '2024-09-10', '2024-09-15', 'confirmed', '2024-08-01 09:15:00'),
('850e8400-e29b-41d4-a716-446655440005', '750e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440011', '2024-08-30', '2024-09-05', 'confirmed', '2024-08-05 11:20:00'),
('850e8400-e29b-41d4-a716-446655440006', '750e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440012', '2024-09-20', '2024-09-25', 'confirmed', '2024-08-10 13:40:00'),
('850e8400-e29b-41d4-a716-446655440007', '750e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440013', '2024-10-01', '2024-10-06', 'confirmed', '2024-08-15 15:55:00'),

-- Pending Bookings
('850e8400-e29b-41d4-a716-446655440008', '750e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440014', '2024-10-15', '2024-10-20', 'pending', '2024-08-20 10:30:00'),
('850e8400-e29b-41d4-a716-446655440009', '750e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440015', '2024-10-25', '2024-10-30', 'pending', '2024-08-22 12:15:00'),
('850e8400-e29b-41d4-a716-446655440010', '750e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440016', '2024-11-01', '2024-11-05', 'pending', '2024-08-25 14:20:00'),

-- Canceled Bookings
('850e8400-e29b-41d4-a716-446655440011', '750e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440007', '2024-09-15', '2024-09-20', 'canceled', '2024-08-01 16:00:00'),
('850e8400-e29b-41d4-a716-446655440012', '750e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440008', '2024-10-05', '2024-10-10', 'canceled', '2024-08-05 18:30:00'),

-- Additional bookings for data variety
('850e8400-e29b-41d4-a716-446655440013', '750e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440009', '2024-11-10', '2024-11-15', 'confirmed', '2024-08-28 10:45:00'),
('850e8400-e29b-41d4-a716-446655440014', '750e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440010', '2024-11-20', '2024-11-25', 'confirmed', '2024-08-30 13:10:00'),
('850e8400-e29b-41d4-a716-446655440015', '750e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440011', '2024-12-01', '2024-12-10', 'pending', '2024-09-01 15:25:00'),

-- Past bookings for historical data
('850e8400-e29b-41d4-a716-446655440016', '750e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', '2024-06-01', '2024-06-05', 'confirmed', '2024-05-01 09:00:00'),
('850e8400-e29b-41d4-a716-446655440017', '750e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440013', '2024-06-15', '2024-06-20', 'confirmed', '2024-05-15 11:30:00'),
('850e8400-e29b-41d4-a716-446655440018', '750e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440014', '2024-07-01', '2024-07-07', 'confirmed', '2024-06-01 14:15:00');

-- =============================================
-- 5. SAMPLE PAYMENTS
-- =============================================
-- Insert payments for confirmed bookings with various statuses

INSERT INTO Payment (payment_id, booking_id, amount, payment_date, payment_method, payment_status, transaction_id, created_at) VALUES
-- Completed Payments
('950e8400-e29b-41d4-a716-446655440001', '850e8400-e29b-41d4-a716-446655440001', 1475.00, '2024-07-01 10:05:00', 'credit_card', 'completed', 'TXN_CC_001_2024070110', '2024-07-01 10:05:00'),
('950e8400-e29b-41d4-a716-446655440002', '850e8400-e29b-41d4-a716-446655440002', 3150.00, '2024-07-15 14:35:00', 'stripe', 'completed', 'TXN_ST_002_2024071514', '2024-07-15 14:35:00'),
('950e8400-e29b-41d4-a716-446655440003', '850e8400-e29b-41d4-a716-446655440003', 2900.00, '2024-07-20 16:50:00', 'paypal', 'completed', 'TXN_PP_003_2024072016', '2024-07-20 16:50:00'),
('950e8400-e29b-41d4-a716-446655440004', '850e8400-e29b-41d4-a716-446655440004', 925.00, '2024-08-01 09:20:00', 'credit_card', 'completed', 'TXN_CC_004_2024080109', '2024-08-01 09:20:00'),
('950e8400-e29b-41d4-a716-446655440005', '850e8400-e29b-41d4-a716-446655440005', 750.00, '2024-08-05 11:25:00', 'bank_transfer', 'completed', 'TXN_BT_005_2024080511', '2024-08-05 11:25:00'),
('950e8400-e29b-41d4-a716-446655440006', '850e8400-e29b-41d4-a716-446655440006', 475.00, '2024-08-10 13:45:00', 'stripe', 'completed', 'TXN_ST_006_2024081013', '2024-08-10 13:45:00'),
('950e8400-e29b-41d4-a716-446655440007', '850e8400-e29b-41d4-a716-446655440007', 1100.00, '2024-08-15 16:00:00', 'credit_card', 'completed', 'TXN_CC_007_2024081516', '2024-08-15 16:00:00'),

-- Pending Payments
('950e8400-e29b-41d4-a716-446655440008', '850e8400-e29b-41d4-a716-446655440008', 325.00, '2024-08-20 10:35:00', 'paypal', 'pending', NULL, '2024-08-20 10:35:00'),
('950e8400-e29b-41d4-a716-446655440009', '850e8400-e29b-41d4-a716-446655440009', 550.00, '2024-08-22 12:20:00', 'credit_card', 'pending', NULL, '2024-08-22 12:20:00'),
('950e8400-e29b-41d4-a716-446655440010', '850e8400-e29b-41d4-a716-446655440010', 175.00, '2024-08-25 14:25:00', 'stripe', 'pending', NULL, '2024-08-25 14:25:00'),

-- Failed and Refunded Payments
('950e8400-e29b-41d4-a716-446655440011', '850e8400-e29b-41d4-a716-446655440011', 425.00, '2024-08-01 16:05:00', 'credit_card', 'refunded', 'TXN_CC_011_2024080116_REF', '2024-08-01 16:05:00'),
('950e8400-e29b-41d4-a716-446655440012', '850e8400-e29b-41d4-a716-446655440012', 700.00, '2024-08-05 18:35:00', 'paypal', 'refunded', 'TXN_PP_012_2024080518_REF', '2024-08-05 18:35:00'),

-- Additional completed payments
('950e8400-e29b-41d4-a716-446655440013', '850e8400-e29b-41d4-a716-446655440013', 875.00, '2024-08-28 10:50:00', 'stripe', 'completed', 'TXN_ST_013_2024082810', '2024-08-28 10:50:00'),
('950e8400-e29b-41d4-a716-446655440014', '850e8400-e29b-41d4-a716-446655440014', 600.00, '2024-08-30 13:15:00', 'credit_card', 'completed', 'TXN_CC_014_2024083013', '2024-08-30 13:15:00'),

-- Historical payments
('950e8400-e29b-41d4-a716-446655440016', '850e8400-e29b-41d4-a716-446655440016', 1475.00, '2024-05-01 09:05:00', 'credit_card', 'completed', 'TXN_CC_016_2024050109', '2024-05-01 09:05:00'),
('950e8400-e29b-41d4-a716-446655440017', '850e8400-e29b-41d4-a716-446655440017', 2250.00, '2024-05-15 11:35:00', 'paypal', 'completed', 'TXN_PP_017_2024051511', '2024-05-15 11:35:00'),
('950e8400-e29b-41d4-a716-446655440018', '850e8400-e29b-41d4-a716-446655440018', 4060.00, '2024-06-01 14:20:00', 'stripe', 'completed', 'TXN_ST_018_2024060114', '2024-06-01 14:20:00');

-- =============================================
-- 6. SAMPLE REVIEWS
-- =============================================
-- Insert reviews for completed bookings

INSERT INTO Review (review_id, property_id, user_id, rating, comment, created_at) VALUES
-- 5-star reviews
('a50e8400-e29b-41d4-a716-446655440001', '750e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', 5, 'Absolutely stunning property! The views of San Francisco were breathtaking and the location couldn''t be better. John was an excellent host, very responsive and helpful. The loft was exactly as described and even better in person. Highly recommend!', '2024-06-07 10:00:00'),
('a50e8400-e29b-41d4-a716-446655440002', '750e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440013', 5, 'This villa exceeded all expectations! The pool area was perfect for relaxing and the views of LA were incredible. Maria was fantastic - she provided great local recommendations and the house was spotless. Perfect for a luxury getaway!', '2024-06-22 15:30:00'),
('a50e8400-e29b-41d4-a716-446655440003', '750e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440014', 5, 'Manhattan penthouse of dreams! Central Park views were magical, especially during sunset. David thought of everything - from welcome snacks to detailed neighborhood guides. The apartment was luxurious and comfortable. Will definitely return!', '2024-07-09 18:45:00'),

-- 4-star reviews
('a50e8400-e29b-41d4-a716-446655440004', '750e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440007', 4, 'Great beachfront location with easy access to South Beach. The condo was clean and well-equipped. Sophie was helpful with check-in instructions. Only minor issue was the wifi was a bit slow, but overall a wonderful stay for our Miami vacation.', '2024-08-22 12:15:00'),
('a50e8400-e29b-41d4-a716-446655440005', '750e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440008', 4, 'Perfect location in Austin! Walking distance to all the best music venues and restaurants. Ahmed was quick to respond to questions. The apartment was comfortable and well-decorated. Street noise was minimal considering the central location.', '2024-09-07 16:20:00'),
('a50e8400-e29b-41d4-a716-446655440006', '750e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440009', 4, 'Charming Parisian studio with authentic character. John provided excellent local tips and restaurant recommendations. The location near the Louvre was unbeatable. Space was cozy but well-designed. Minor issue with hot water but quickly resolved.', '2024-09-27 09:30:00'),

-- 3-star reviews
('a50e8400-e29b-41d4-a716-446655440007', '750e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440010', 3, 'Decent stay in London. The Victorian house has character and the location is convenient for sightseeing. Maria was responsive to messages. However, the heating system was temperamental and some furnishings could use updating. Fair value for the location.', '2024-10-08 14:45:00'),
('a50e8400-e29b-41d4-a716-446655440008', '750e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440011', 3, 'Interesting capsule experience in Tokyo. David was helpful with directions and local information. The space is exactly as advertised - very small but functional. Good for budget travelers who don''t mind tight quarters. Cleanliness was acceptable.', '2024-10-22 11:20:00'),

-- 2-star reviews
('a50e8400-e29b-41d4-a716-446655440009', '750e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440015', 2, 'The location near the Colosseum was great, but the apartment had several issues. Sophie took a while to respond to our concerns about the broken air conditioning. The WiFi was unreliable and the neighborhood was quite noisy at night. Disappointing for the price.', '2024-10-31 19:15:00'),

-- Additional reviews
('a50e8400-e29b-41d4-a716-446655440010', '750e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440016', 4, 'Fantastic Sydney Harbor views and great location! David was welcoming and provided useful city maps. The apartment was clean and comfortable. Only downside was construction noise during morning hours, but the views made up for it. Would recommend!', '2024-11-17 13:40:00');

-- =============================================
-- 7. SAMPLE MESSAGES
-- =============================================
-- Insert messages between users for various purposes

INSERT INTO Message (message_id, sender_id, recipient_id, message_body, message_type, sent_at, read_at) VALUES
-- Booking inquiries
('b50e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440002', 'Hi John! I''m interested in booking your San Francisco loft for August 15-20. Are those dates available? Also, is parking included?', 'inquiry', '2024-06-25 14:30:00', '2024-06-25 15:45:00'),
('b50e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440007', 'Hello Emma! Yes, those dates are available and parking is included in the building garage. The loft has amazing city views and is perfect for exploring SF. Would you like to proceed with the booking?', 'inquiry', '2024-06-25 15:45:00', '2024-06-25 16:20:00'),
('b50e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440002', 'Perfect! Yes, I''d like to book those dates. This will be my first time in San Francisco, so any local recommendations would be appreciated!', 'booking', '2024-06-25 16:20:00', '2024-06-25 17:00:00'),

-- Host-guest communication during stay
('b50e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440003', 'Hi Maria! We''ve arrived at the Hollywood villa and it''s absolutely stunning! Thank you for the welcome basket. Quick question - how do we adjust the pool temperature?', 'general', '2024-09-01 18:30:00', '2024-09-01 19:15:00'),
('b50e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440008', 'Welcome to LA, Michael! So glad you like the place. For the pool, there''s a control panel in the outdoor kitchen area - just press the blue button to adjust temperature. Let me know if you need anything else!', 'general', '2024-09-01 19:15:00', '2024-09-01 20:00:00'),

-- Support messages
('b50e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440001', 'Hi Alice, I''m having trouble with a payment for my upcoming booking in Manhattan. The payment keeps failing even though my card is valid. Can you help?', 'support', '2024-07-18 10:45:00', '2024-07-18 11:30:00'),
('b50e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440009', 'Hello Lisa! I''d be happy to help with your payment issue. I''ve checked your account and see the failed attempts. Let me transfer you to our payments team who can resolve this quickly. You should receive an email within the hour.', 'support', '2024-07-18 11:30:00', '2024-07-18 12:00:00'),

-- General communication
('b50e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440005', 'Hi Sophie! Just wanted to thank you again for the amazing stay in Miami. The location and amenities were perfect. We''re already planning our next trip and would love to stay again!', 'general', '2024-09-17 16:20:00', '2024-09-17 17:45:00'),
('b50e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440010', 'Robert! It was wonderful hosting you and your family. You were fantastic guests and took great care of the property. You''re welcome back anytime! I''ll keep you updated on any special offers.', 'general', '2024-09-17 17:45:00', '2024-09-17 18:30:00'),

-- Booking follow-up messages
('b50e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440011', 'Hi Sarah! I see you''ve booked the Austin apartment for August 30th. I''ve sent check-in instructions to your email. The area has incredible live music - I''ve included a list of my favorite venues. Safe travels!', 'booking', '2024-08-06 09:15:00', '2024-08-06 10:30:00'),
('b50e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440006', 'Ahmed, thank you so much for the venue recommendations! I''m a huge music fan, so this is perfect. Looking forward to the stay and exploring Austin''s music scene.', 'booking', '2024-08-06 10:30:00', '2024-08-06 11:15:00'),

-- Unread messages
('b50e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440003', 'Hi Maria! I''m interested in your Barcelona hostel for November. Do you offer any discounts for longer stays? I''m planning to stay for about 2 weeks.', 'inquiry', '2024-08-28 14:20:00', NULL),
('b50e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440004', 'David, quick question about the Tokyo capsule booking - is there a luggage storage area? We''ll have large backpacks.', 'inquiry', '2024-08-29 16:45:00', NULL),
('b50e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440005', 'Sophie, we had an amazing time in Rome! The apartment was perfect and the location couldn''t be better. Thank you for being such a wonderful host!', 'general', '2024-08-30 20:30:00', NULL),
('b50e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440001', 'Hi Alice, I need help canceling a booking due to a family emergency. Can you assist with the cancellation policy?', 'support', '2024-09-01 11:00:00', NULL);

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- DATA VALIDATION QUERIES
-- =============================================
-- Verify the inserted data

-- Check user distribution by role
SELECT role, COUNT(*) as count 
FROM User 
GROUP BY role 
ORDER BY count DESC;

-- Check property distribution by price range
SELECT 
    CASE 
        WHEN pricepernight < 50 THEN 'Budget (< $50)'
        WHEN pricepernight BETWEEN 50 AND 150 THEN 'Mid-range ($50-$150)'
        WHEN pricepernight BETWEEN 150 AND 300 THEN 'Premium ($150-$300)'
        ELSE 'Luxury (> $300)'
    END as price_category,
    COUNT(*) as count,
    AVG(pricepernight) as avg_price
FROM Property 
GROUP BY price_category 
ORDER BY avg_price;

-- Check booking status distribution
SELECT status, COUNT(*) as count 
FROM Booking 
GROUP BY status 
ORDER BY count DESC;

-- Check payment status distribution
SELECT payment_status, COUNT(*) as count, SUM(amount) as total_amount 
FROM Payment 
GROUP BY payment_status 
ORDER BY total_amount DESC;

-- Check review rating distribution
SELECT rating, COUNT(*) as count 
FROM Review 
GROUP BY rating 
ORDER BY rating DESC;

-- Check message type distribution
SELECT message_type, COUNT(*) as count 
FROM Message 
GROUP BY message_type 
ORDER BY count DESC;

-- Check geographic distribution of properties
SELECT l.country, l.city, COUNT(p.property_id) as property_count
FROM Location l
LEFT JOIN Property p ON l.location_id = p.location_id
GROUP BY l.country, l.city
ORDER BY property_count DESC;

-- =============================================
-- SUMMARY STATISTICS
-- =============================================

-- Total records summary
SELECT 
    'Users' as entity, COUNT(*) as total_records FROM User
UNION ALL
SELECT 'Locations' as entity, COUNT(*) as total_records FROM Location
UNION ALL
SELECT 'Properties' as entity, COUNT(*) as total_records FROM Property
UNION ALL
SELECT 'Bookings' as entity, COUNT(*) as total_records FROM Booking
UNION ALL
SELECT 'Payments' as entity, COUNT(*) as total_records FROM Payment
UNION ALL
SELECT 'Reviews' as entity, COUNT(*) as total_records FROM Review
UNION ALL
SELECT 'Messages' as entity, COUNT(*) as total_records FROM Message
ORDER BY total_records DESC;

-- =============================================
-- END OF SEED SCRIPT
-- =============================================

COMMIT;
