#!/bin/bash

# FlutterDemo Database Initialization Script
# This script creates the flutter_demo database

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"

# Load environment variables if .env exists
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_NAME="${DB_NAME:-flutter_demo}"

echo "=== FlutterDemo Database Initialization ==="
echo "Host: $DB_HOST:$DB_PORT"
echo "User: $DB_USER"
echo "Database: $DB_NAME"
echo ""

# Check if mysql client is available
if ! command -v mysql &> /dev/null; then
  echo "Error: mysql client not found. Please install mysql-client."
  exit 1
fi

# Try different connection methods
connect_and_run() {
  local sql="$1"

  # Method 1: Use password from env if available
  if [ -n "$DB_PASSWORD" ]; then
    echo "Connecting with password from .env..."
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "$sql" 2>/dev/null && return 0
  fi

  # Method 2: Try sudo mysql (for auth_socket)
  echo "Trying sudo mysql..."
  sudo mysql -e "$sql" 2>/dev/null && return 0

  # Method 3: Interactive password prompt
  echo "Please enter MySQL root password:"
  mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p -e "$sql" && return 0

  return 1
}

SQL="
CREATE DATABASE IF NOT EXISTS $DB_NAME
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
SELECT 'Database $DB_NAME created successfully!' AS status;
"

if connect_and_run "$SQL"; then
  echo ""
  echo "=== Initialization Complete ==="
  echo "You can now run: npm run dev"
else
  echo ""
  echo "=== Initialization Failed ==="
  echo "Please create the database manually:"
  echo "  mysql -u root -p -e \"CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\""
  exit 1
fi
