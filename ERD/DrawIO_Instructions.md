# AirBnB Database ER Diagram - Draw.io Instructions

## Visual ER Diagram Creation Guide

### Step-by-Step Instructions for Draw.io

1. **Open Draw.io** (<https://app.diagrams.net/>)
2. **Create New Diagram** → Choose "Entity Relation" template
3. **Add Entities** using rectangles from the shape library

## Entity Boxes Layout

### User Entity (Central Position)

```text
┌─────────────────────────┐
│         USER            │
├─────────────────────────┤
│ PK: user_id (UUID)      │
│     first_name          │
│     last_name           │
│     email (UNIQUE)      │
│     password_hash       │
│     phone_number        │
│     role (ENUM)         │
│     created_at          │
└─────────────────────────┘
```

### Property Entity (Top Right)

```text
┌─────────────────────────┐
│       PROPERTY          │
├─────────────────────────┤
│ PK: property_id (UUID)  │
│ FK: host_id             │
│     name                │
│     description         │
│     location            │
│     pricepernight       │
│     created_at          │
│     updated_at          │
└─────────────────────────┘
```

### Booking Entity (Bottom Center)

```text
┌─────────────────────────┐
│        BOOKING          │
├─────────────────────────┤
│ PK: booking_id (UUID)   │
│ FK: property_id         │
│ FK: user_id             │
│     start_date          │
│     end_date            │
│     total_price         │
│     status (ENUM)       │
│     created_at          │
└─────────────────────────┘
```

### Payment Entity (Bottom Right)

```text
┌─────────────────────────┐
│        PAYMENT          │
├─────────────────────────┤
│ PK: payment_id (UUID)   │
│ FK: booking_id          │
│     amount              │
│     payment_date        │
│     payment_method      │
└─────────────────────────┘
```

### Review Entity (Top Left)

```text
┌─────────────────────────┐
│        REVIEW           │
├─────────────────────────┤
│ PK: review_id (UUID)    │
│ FK: property_id         │
│ FK: user_id             │
│     rating (1-5)        │
│     comment             │
│     created_at          │
└─────────────────────────┘
```

### Message Entity (Left)

```text
┌─────────────────────────┐
│        MESSAGE          │
├─────────────────────────┤
│ PK: message_id (UUID)   │
│ FK: sender_id           │
│ FK: recipient_id        │
│     message_body        │
│     sent_at             │
└─────────────────────────┘
```

## Relationship Connections

### 1. User → Property (HOSTS)

- **Connection**: User.user_id ← Property.host_id
- **Cardinality**: 1:M (One user can host many properties)
- **Line Style**: Solid line with crow's foot on Property side

### 2. User → Booking (MAKES)

- **Connection**: User.user_id ← Booking.user_id
- **Cardinality**: 1:M (One user can make many bookings)
- **Line Style**: Solid line with crow's foot on Booking side

### 3. Property → Booking (HAS)

- **Connection**: Property.property_id ← Booking.property_id
- **Cardinality**: 1:M (One property can have many bookings)
- **Line Style**: Solid line with crow's foot on Booking side

### 4. Booking → Payment (HAS)

- **Connection**: Booking.booking_id ← Payment.booking_id
- **Cardinality**: 1:1 (Each booking has exactly one payment)
- **Line Style**: Solid line with single line on both sides

### 5. User → Review (WRITES)

- **Connection**: User.user_id ← Review.user_id
- **Cardinality**: 1:M (One user can write many reviews)
- **Line Style**: Solid line with crow's foot on Review side

### 6. Property → Review (RECEIVES)

- **Connection**: Property.property_id ← Review.property_id
- **Cardinality**: 1:M (One property can have many reviews)
- **Line Style**: Solid line with crow's foot on Review side

### 7. User → Message (SENDS)

- **Connection**: User.user_id ← Message.sender_id
- **Cardinality**: 1:M (One user can send many messages)
- **Line Style**: Solid line with crow's foot on Message side

### 8. User → Message (RECEIVES)

- **Connection**: User.user_id ← Message.recipient_id
- **Cardinality**: 1:M (One user can receive many messages)
- **Line Style**: Solid line with crow's foot on Message side

## Draw.io Formatting Guidelines

### Entity Styling

- **Rectangle Shape**: Use rounded rectangles for entities
- **Header Color**: Light blue (#E1F5FE) for entity names
- **Border**: Black, 2px width
- **Font**: Arial, 12pt for entity names (bold), 10pt for attributes
- **Primary Keys**: Underlined text
- **Foreign Keys**: Italicized text with "FK:" prefix

### Relationship Styling

- **Relationship Lines**: Black, 2px width
- **Cardinality Notation**: Use crow's foot notation
- **Relationship Labels**: Place verb phrases on relationship lines
- **Colors**: Use different colors for different relationship types
  - Host relationships: Green
  - Booking relationships: Blue
  - Review relationships: Orange
  - Message relationships: Purple

### Layout Suggestions

1. **Center**: User entity (as it's connected to all others)
2. **Top**: Property and Review entities
3. **Bottom**: Booking and Payment entities
4. **Left**: Message entity
5. **Spacing**: Maintain consistent spacing between entities
6. **Alignment**: Align entities in a logical grid pattern

## ASCII Art Representation

```text
    REVIEW ────────┐           PROPERTY
      │            │              │
      │            │              │
      │         ┌──USER──┐         │
      │         │       │         │
      │         │       │         │
    MESSAGE     │       │      BOOKING
                │       │         │
                │       │         │
                │       │      PAYMENT
                └───────┘
```

## Relationship Matrix

| Entity    | User | Property | Booking | Payment | Review | Message |
|-----------|------|----------|---------|---------|--------|---------|
| User      | -    | 1:M(H)   | 1:M(G)  | -       | 1:M(W) | M:M(S/R)|
| Property  | M:1  | -        | 1:M     | -       | 1:M    | -       |
| Booking   | M:1  | M:1      | -       | 1:1     | -      | -       |
| Payment   | -    | -        | 1:1     | -       | -      | -       |
| Review    | M:1  | M:1      | -       | -       | -      | -       |
| Message   | M:1  | -        | -       | -       | -      | -       |

**Legend:**

- H = Host relationship
- G = Guest relationship  
- W = Writer relationship
- S = Sender relationship
- R = Recipient relationship

This comprehensive guide provides all the information needed to create a professional ER diagram using Draw.io or any other diagramming tool.
