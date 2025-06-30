# Database Specification - AirBnB

## Entities and Attributes

### User

    user_id: Primary Key, UUID, Indexed
    first_name: VARCHAR, NOT NULL
    last_name: VARCHAR, NOT NULL
    email: VARCHAR, UNIQUE, NOT NULL
    password_hash: VARCHAR, NOT NULL
    phone_number: VARCHAR, NULL
    role: ENUM (guest, host, admin), NOT NULL
    created_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

Property

    property_id: Primary Key, UUID, Indexed
    host_id: Foreign Key, references User(user_id)
    name: VARCHAR, NOT NULL
    description: TEXT, NOT NULL
    location: VARCHAR, NOT NULL
    pricepernight: DECIMAL, NOT NULL
    created_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
    updated_at: TIMESTAMP, ON UPDATE CURRENT_TIMESTAMP

Booking

    booking_id: Primary Key, UUID, Indexed
    property_id: Foreign Key, references Property(property_id)
    user_id: Foreign Key, references User(user_id)
    start_date: DATE, NOT NULL
    end_date: DATE, NOT NULL
    total_price: DECIMAL, NOT NULL
    status: ENUM (pending, confirmed, canceled), NOT NULL
    created_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

Payment

    payment_id: Primary Key, UUID, Indexed
    booking_id: Foreign Key, references Booking(booking_id)
    amount: DECIMAL, NOT NULL
    payment_date: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
    payment_method: ENUM (credit_card, paypal, stripe), NOT NULL

Review

    review_id: Primary Key, UUID, Indexed
    property_id: Foreign Key, references Property(property_id)
    user_id: Foreign Key, references User(user_id)
    rating: INTEGER, CHECK: rating >= 1 AND rating <= 5, NOT NULL
    comment: TEXT, NOT NULL
    created_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

Message

    message_id: Primary Key, UUID, Indexed
    sender_id: Foreign Key, references User(user_id)
    recipient_id: Foreign Key, references User(user_id)
    message_body: TEXT, NOT NULL
    sent_at: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

Constraints
User Table

    Unique constraint on email.
    Non-null constraints on required fields.

Property Table

    Foreign key constraint on host_id.
    Non-null constraints on essential attributes.

Booking Table

    Foreign key constraints on property_id and user_id.
    status must be one of pending, confirmed, or canceled.

Payment Table

    Foreign key constraint on booking_id, ensuring payment is linked to valid bookings.

Review Table

    Constraints on rating values (1-5).
    Foreign key constraints on property_id and user_id.

Message Table

    Foreign key constraints on sender_id and recipient_id.

Indexing

    Primary Keys: Indexed automatically.
    Additional Indexes:
        email in the User table.
        property_id in the Property and Booking tables.
        booking_id in the Booking and Payment tables.

## Entity-Relationship (ER) Diagram Description

### Overview

This section provides a comprehensive definition of the Entity-Relationship diagram for the AirBnB database system, detailing all entities, their attributes, and the relationships between them.

### Entities Summary

The database consists of **6 main entities**:

1. **User** - Central entity representing all system users (guests, hosts, admins)
2. **Property** - Rental properties listed by hosts
3. **Booking** - Reservation records linking users to properties
4. **Payment** - Payment transactions for bookings
5. **Review** - User reviews and ratings for properties
6. **Message** - Communication system between users

### Relationship Definitions

#### 1. User ↔ Property (Host Relationship)

- **Type**: One-to-Many (1:M)
- **Description**: A User can host multiple Properties
- **Foreign Key**: Property.host_id → User.user_id
- **Business Rule**: One User (with host role) can own/manage many Properties, but each Property has exactly one host

#### 2. User ↔ Booking (Guest Relationship)

- **Type**: One-to-Many (1:M)
- **Description**: A User can make multiple Bookings
- **Foreign Key**: Booking.user_id → User.user_id
- **Business Rule**: One User (guest) can have many Bookings, but each Booking belongs to exactly one User

#### 3. Property ↔ Booking

- **Type**: One-to-Many (1:M)
- **Description**: A Property can have multiple Bookings
- **Foreign Key**: Booking.property_id → Property.property_id
- **Business Rule**: One Property can have many Bookings over time, but each Booking is for exactly one Property

#### 4. Booking ↔ Payment

- **Type**: One-to-One (1:1)
- **Description**: Each Booking has exactly one Payment
- **Foreign Key**: Payment.booking_id → Booking.booking_id
- **Business Rule**: One Booking requires exactly one Payment transaction, ensuring financial integrity

#### 5. User ↔ Review (Reviewer Relationship)

- **Type**: One-to-Many (1:M)
- **Description**: A User can write multiple Reviews
- **Foreign Key**: Review.user_id → User.user_id
- **Business Rule**: One User can write many Reviews, but each Review is authored by exactly one User

#### 6. Property ↔ Review

- **Type**: One-to-Many (1:M)
- **Description**: A Property can receive multiple Reviews
- **Foreign Key**: Review.property_id → Property.property_id
- **Business Rule**: One Property can have many Reviews from different users, but each Review is for exactly one Property

#### 7. User ↔ Message (Sender Relationship)

- **Type**: One-to-Many (1:M)
- **Description**: A User can send multiple Messages
- **Foreign Key**: Message.sender_id → User.user_id
- **Business Rule**: One User can send many Messages, but each Message has exactly one sender

#### 8. User ↔ Message (Recipient Relationship)

- **Type**: One-to-Many (1:M)
- **Description**: A User can receive multiple Messages
- **Foreign Key**: Message.recipient_id → User.user_id
- **Business Rule**: One User can receive many Messages, but each Message has exactly one recipient

### Key Business Rules Captured

1. **Multi-Role Users**: The User entity supports multiple roles (guest, host, admin) through the role enum, allowing users to act in different capacities
2. **Property Ownership**: Each property must have exactly one host, ensuring clear ownership and responsibility
3. **Booking Integrity**: Every booking must reference both a valid property and a valid user, maintaining referential integrity
4. **Payment Assurance**: The 1:1 relationship between Booking and Payment ensures every booking has associated payment information
5. **Review Authenticity**: Reviews are linked to both users and properties, enabling verification of review authenticity
6. **Communication Flow**: The message system supports bidirectional communication between any users in the system

### Data Integrity Features

- **Referential Integrity**: All foreign key relationships maintain data consistency
- **Unique Constraints**: Email addresses are unique across all users
- **Check Constraints**: Rating values are constrained to 1-5 range
- **Enumerated Values**: Role, status, and payment method fields use controlled vocabularies
- **Timestamp Tracking**: Automatic creation and update timestamps for audit trails

### Indexing Strategy

- **Primary Keys**: All entities use UUID primary keys with automatic indexing
- **Foreign Keys**: Strategic indexing on frequently joined columns
- **Unique Fields**: Email field indexed for fast user lookup
- **Query Optimization**: Additional indexes on property_id and booking_id for performance

This ER diagram design provides a robust foundation for implementing a comprehensive AirBnB-style rental platform with complete data integrity and efficient query performance.
