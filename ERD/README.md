# AirBnB Database ER Diagram Summary

## Overview

This document provides a quick reference for the Entity-Relationship diagram for the AirBnB database system. For detailed specifications and ER diagram descriptions, see `requirements.md`.

## Quick Reference

### Entities (6 Total)

1. **User** - System users (guests, hosts, admins)
2. **Property** - Rental properties listed by hosts
3. **Booking** - Reservation records
4. **Payment** - Payment transactions
5. **Review** - Property reviews by users
6. **Message** - User-to-user communications

### Key Relationships

| From Entity | To Entity | Relationship Type | Description |
|-------------|-----------|-------------------|-------------|
| User | Property | 1:M | User hosts multiple properties |
| User | Booking | 1:M | User makes multiple bookings |
| Property | Booking | 1:M | Property has multiple bookings |
| Booking | Payment | 1:1 | Each booking has one payment |
| User | Review | 1:M | User writes multiple reviews |
| Property | Review | 1:M | Property receives multiple reviews |
| User | Message | 1:M | User sends/receives multiple messages |

## File Structure

```text
ERD/
├── requirements.md              # Database specification with detailed ER diagram description
├── DrawIO_Instructions.md       # Visual diagram creation guide
└── README.md                   # This summary file
```

## Next Steps

1. **Review Specifications**: Read the detailed ER diagram description in `requirements.md`
2. **Create Visual Diagram**: Use the instructions in `DrawIO_Instructions.md` to create the actual ER diagram using Draw.io
3. **Review Relationships**: Ensure all foreign key relationships are properly represented
4. **Validate Design**: Check that the diagram supports all business requirements

## Business Logic Captured

- **Multi-role Users**: Users can be guests, hosts, or admins
- **Property Management**: Hosts can manage multiple properties
- **Booking System**: Complete reservation workflow with payments
- **Review System**: Users can review properties they've experienced
- **Communication**: Direct messaging between users
- **Data Integrity**: Proper foreign key constraints and business rules

## Technical Specifications

- **Primary Keys**: All entities use UUID primary keys
- **Indexing**: Strategic indexing on primary keys and frequently queried fields
- **Constraints**: Proper data validation and referential integrity
- **Timestamps**: Audit trail with creation and update timestamps
- **Enums**: Controlled vocabulary for status fields and roles

This ER diagram provides a solid foundation for implementing a complete AirBnB-style rental platform database.
