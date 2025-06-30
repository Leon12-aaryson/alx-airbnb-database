# Database Sample Data - Seed Script

This directory contains the sample data and seed scripts for the AirBnB database. The seed script populates the database with realistic test data for development, testing, and demonstration purposes.

## Files Overview

- `seed.sql` - Main seed script with comprehensive sample data for all database entities
- `test_queries.sql` - Validation and test queries for database verification
- `manage_db.sh` - Automated database management script for easy setup and reset
- `README.md` - This documentation file

## Seed Script Features

### Data Coverage

The `seed.sql` script provides sample data for all major entities:

- **Users**: 16 users including admins, hosts, and guests with diverse profiles
- **Locations**: 15 global locations across major cities and countries
- **Properties**: 15 properties with varying price ranges and property types
- **Bookings**: 18 bookings with different statuses (confirmed, pending, canceled)
- **Payments**: 15 payments with various payment methods and statuses
- **Reviews**: 12 reviews with realistic ratings and feedback
- **Messages**: 10 message exchanges between users

### Data Quality Features

- **Realistic Data**: All sample data uses realistic names, addresses, prices, and descriptions
- **Referential Integrity**: All foreign key relationships are properly maintained
- **Data Variety**: Includes diverse scenarios for comprehensive testing
- **Geographic Distribution**: Properties span multiple countries and continents
- **Temporal Distribution**: Bookings and payments span past, present, and future dates

### Business Logic Compliance

- **Price Calculations**: Payment amounts correctly reflect property prices and booking durations
- **Status Consistency**: Booking and payment statuses are logically consistent
- **Date Validation**: All date ranges are realistic and properly sequenced
- **Role-based Data**: Users have appropriate data based on their roles (admin, host, guest)

## Usage Instructions

### Prerequisites

Before running the seed script, ensure:

1. The database schema is already created (run `database-script-0x01/schema.sql` first)
2. You have appropriate MySQL permissions
3. The target database `airbnb_db` exists

### Running the Seed Script

#### Option 1: Using the Management Script (Recommended)

The `manage_db.sh` script provides an easy way to manage your database:

```bash
# Make the script executable (first time only)
chmod +x manage_db.sh

# Full database reset (drops, recreates, and populates)
./manage_db.sh --full-reset

# Only populate with sample data (requires existing schema)
./manage_db.sh --seed-only

# Only create schema (no sample data)
./manage_db.sh --schema-only

# Verify database contents
./manage_db.sh --verify

# Show help
./manage_db.sh --help
```

#### Option 2: Manual MySQL Commands

```bash
# Connect to MySQL
mysql -u your_username -p

# Run the seed script
source /path/to/seed.sql

# Or use mysql command directly
mysql -u your_username -p airbnb_db < seed.sql
```

### Verification and Testing

Use the provided test queries to validate your database:

```bash
# Run comprehensive validation
mysql -u your_username -p airbnb_db < test_queries.sql
```

The test script includes:

- Record count verification
- Referential integrity checks
- Data consistency validation
- Business logic verification
- Sample business queries
- Performance test queries

## Sample Data Overview

### User Distribution

- **1 Admin**: Platform administrator
- **5 Hosts**: Property owners with listings
- **10 Guests**: Users who book properties

### Geographic Coverage

Properties are distributed across:

- **United States**: San Francisco, Los Angeles, New York, Miami
- **Europe**: Paris, London, Berlin, Rome, Barcelona
- **Asia**: Tokyo, Bangkok
- **Other**: Toronto, Sydney, Rio de Janeiro

### Price Range

Properties range from budget-friendly ($25/night) to luxury ($580/night):

- **Budget**: $25-65/night (hostels, capsule hotels)
- **Mid-range**: $85-175/night (apartments, standard properties)
- **Premium**: $200-580/night (luxury properties, prime locations)

### Booking Scenarios

- **Confirmed Bookings**: 12 confirmed reservations (past and future)
- **Pending Bookings**: 3 awaiting confirmation
- **Canceled Bookings**: 3 canceled reservations

## Data Relationships

The seed data maintains proper relationships between entities:

1. **Users → Properties**: Hosts own multiple properties
2. **Properties → Locations**: Each property has a specific location
3. **Bookings → Users/Properties**: Guests book host properties
4. **Payments → Bookings**: Each confirmed booking has corresponding payments
5. **Reviews → Bookings**: Completed stays generate reviews
6. **Messages → Users**: Communication between hosts and guests

## Testing Scenarios

The sample data supports testing of:

- **Search and Filtering**: Properties across different locations and price ranges
- **Booking Management**: Various booking statuses and workflows
- **Payment Processing**: Different payment methods and statuses
- **Review System**: Rating distribution and feedback analysis
- **Messaging**: Host-guest communication patterns
- **Geographic Queries**: Location-based property searches
- **Financial Reporting**: Revenue and payment analytics

## Customization

To modify the sample data:

1. **Adding More Data**: Follow the existing UUID patterns and maintain referential integrity
2. **Different Scenarios**: Modify dates, statuses, or amounts to test specific cases
3. **Scaling**: Increase the number of records while maintaining data relationships

## Maintenance

- **Regular Updates**: Update dates periodically to keep data current
- **Data Refresh**: Re-run the script to reset to known sample state
- **Backup**: Consider backing up custom modifications before refresh

## Notes

- The script uses `SET FOREIGN_KEY_CHECKS = 0` temporarily for easier insertion
- All UUIDs follow the pattern `XY0e8400-e29b-41d4-a716-4466554400NN` where XY indicates entity type
- Passwords are hashed using bcrypt with salt rounds of 12
- All timestamps use realistic dates and times
- The script includes a COMMIT at the end to ensure data persistence

For questions or issues with the seed data, refer to the main project documentation or the schema documentation in `database-script-0x01/README.md`.
