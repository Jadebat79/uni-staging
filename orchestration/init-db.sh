#!/bin/bash
set -e

# Helper function
create_db() {
    local db=$1
    local user=$2
    local pass=$3
    echo "Creating user $user and database $db"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE USER $user WITH PASSWORD '$pass';
        CREATE DATABASE $db;
        GRANT ALL PRIVILEGES ON DATABASE $db TO $user;
EOSQL
}

# Create Logic
# In a real setup, consider fetching these passwords safely or setting defaults
create_db "app1_db" "app1_user" "pass123"
create_db "app2_db" "app2_user" "pass123"