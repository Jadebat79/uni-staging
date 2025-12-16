#!/bin/bash
set -e

# Helper function
create_db() {
    local db=$1
    local user=$2
    local pass=$3
    
    echo "Creating user $user and database $db..."
    
    # 1. Create User and Database
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE USER $user WITH PASSWORD '$pass';
        CREATE DATABASE $db;
        GRANT ALL PRIVILEGES ON DATABASE $db TO $user;
        -- Set ownership so the user has full control (Crucial for Postgres 15+)
        ALTER DATABASE $db OWNER TO $user;
EOSQL

    # 2. Grant Schema Permissions (Required for Postgres 15+)
    # We must connect TO the new database to grant schema permissions on it
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$db" <<-EOSQL
        GRANT ALL ON SCHEMA public TO $user;
EOSQL
}

# --- DEFINE YOUR DATABASES HERE ---
# We read the passwords from environment variables passed by Docker
# Format: create_db "DB_NAME" "DB_USER" "DB_PASSWORD"

if [ -n "$HIKEGH_DB_PASS" ]; then
    create_db "hikegh_db" "hikegh_user" "$HIKEGH_DB_PASS"
fi

# Example for a future second app
# if [ -n "$PAYMENT_DB_PASS" ]; then
#    create_db "payment_db" "payment_user" "$PAYMENT_DB_PASS"
# fi