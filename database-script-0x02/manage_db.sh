#!/bin/bash

# =============================================
# AirBnB Database Reset and Seed Script
# =============================================
# This script provides easy database management for development

set -e  # Exit on any error

# Configuration
DB_NAME="airbnb_db"
DB_USER="${DB_USER:-root}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA_DIR="$(dirname "$SCRIPT_DIR")/database-script-0x01"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Help function
show_help() {
    echo "AirBnB Database Management Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  --seed-only     Run only the seed script (requires existing schema)"
    echo "  --schema-only   Run only the schema script (drops and recreates tables)"
    echo "  --full-reset    Drop database, recreate schema, and populate with seed data"
    echo "  --verify        Verify the database contents after seeding"
    echo "  --help          Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  DB_USER         MySQL username (default: root)"
    echo "  DB_PASSWORD     MySQL password (will prompt if not set)"
    echo ""
    echo "Examples:"
    echo "  $0 --full-reset                 # Complete database reset"
    echo "  $0 --seed-only                  # Just populate with sample data"
    echo "  DB_USER=myuser $0 --full-reset  # Use custom username"
}

# Check if MySQL is accessible
check_mysql() {
    print_status "Checking MySQL connection..."
    
    if ! command -v mysql &> /dev/null; then
        print_error "MySQL client not found. Please install MySQL client."
        exit 1
    fi
    
    # Test connection
    if ! mysql -u "$DB_USER" -p -e "SELECT 1;" &> /dev/null; then
        print_error "Cannot connect to MySQL. Please check your credentials."
        exit 1
    fi
    
    print_success "MySQL connection verified"
}

# Create database if it doesn't exist
create_database() {
    print_status "Creating database if it doesn't exist..."
    mysql -u "$DB_USER" -p -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
    print_success "Database $DB_NAME ready"
}

# Run schema script
run_schema() {
    print_status "Running schema script..."
    
    if [ ! -f "$SCHEMA_DIR/schema.sql" ]; then
        print_error "Schema file not found at $SCHEMA_DIR/schema.sql"
        exit 1
    fi
    
    mysql -u "$DB_USER" -p "$DB_NAME" < "$SCHEMA_DIR/schema.sql"
    print_success "Schema created successfully"
}

# Run seed script
run_seed() {
    print_status "Running seed script..."
    
    if [ ! -f "$SCRIPT_DIR/seed.sql" ]; then
        print_error "Seed file not found at $SCRIPT_DIR/seed.sql"
        exit 1
    fi
    
    mysql -u "$DB_USER" -p "$DB_NAME" < "$SCRIPT_DIR/seed.sql"
    print_success "Sample data inserted successfully"
}

# Verify database contents
verify_database() {
    print_status "Verifying database contents..."
    
    echo ""
    echo "Database Summary:"
    echo "=================="
    
    mysql -u "$DB_USER" -p "$DB_NAME" -e "
    SELECT 'Users' as Entity, COUNT(*) as Count FROM User
    UNION ALL
    SELECT 'Locations' as Entity, COUNT(*) as Count FROM Location
    UNION ALL
    SELECT 'Properties' as Entity, COUNT(*) as Count FROM Property
    UNION ALL
    SELECT 'Bookings' as Entity, COUNT(*) as Count FROM Booking
    UNION ALL
    SELECT 'Payments' as Entity, COUNT(*) as Count FROM Payment
    UNION ALL
    SELECT 'Reviews' as Entity, COUNT(*) as Count FROM Review
    UNION ALL
    SELECT 'Messages' as Entity, COUNT(*) as Count FROM Message;
    " 2>/dev/null
    
    print_success "Database verification completed"
}

# Drop database
drop_database() {
    print_warning "This will permanently delete all data in $DB_NAME"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Dropping database $DB_NAME..."
        mysql -u "$DB_USER" -p -e "DROP DATABASE IF EXISTS $DB_NAME;"
        print_success "Database dropped"
    else
        print_status "Operation cancelled"
        exit 0
    fi
}

# Main script logic
main() {
    case "${1:-}" in
        --help)
            show_help
            exit 0
            ;;
        --seed-only)
            check_mysql
            run_seed
            verify_database
            ;;
        --schema-only)
            check_mysql
            create_database
            run_schema
            ;;
        --full-reset)
            check_mysql
            drop_database
            create_database
            run_schema
            run_seed
            verify_database
            ;;
        --verify)
            check_mysql
            verify_database
            ;;
        "")
            print_error "No option specified. Use --help for usage information."
            exit 1
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
    
    print_success "Operation completed successfully!"
}

# Run main function with all arguments
main "$@"
