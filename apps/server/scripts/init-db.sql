-- FlutterDemo Database Initialization Script
-- Usage: mysql -u root -p < scripts/init-db.sql

-- Create database
CREATE DATABASE IF NOT EXISTS flutter_demo
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- Use the database
USE flutter_demo;

-- Grant privileges (optional, for non-root user)
-- CREATE USER IF NOT EXISTS 'flutter_user'@'localhost' IDENTIFIED BY 'your_password';
-- GRANT ALL PRIVILEGES ON flutter_demo.* TO 'flutter_user'@'localhost';
-- FLUSH PRIVILEGES;

SELECT 'Database flutter_demo initialized successfully!' AS status;
