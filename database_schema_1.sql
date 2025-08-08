-- 3rd Logistics Database Schema
-- Production-ready database design for logistics management system
-- Created: 2025
-- Author: Manus AI

-- =====================================================
-- DATABASE CREATION AND CONFIGURATION
-- =====================================================

-- Create database (MySQL/MariaDB)
CREATE DATABASE IF NOT EXISTS third_logistics_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE third_logistics_db;

-- =====================================================
-- USER MANAGEMENT TABLES
-- =====================================================

-- Users table for authentication and authorization
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    role ENUM('admin', 'manager', 'dispatcher', 'driver', 'client') NOT NULL DEFAULT 'client',
    status ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_username (username),
    INDEX idx_role (role),
    INDEX idx_status (status)
);

-- User sessions for security
CREATE TABLE user_sessions (
    session_id VARCHAR(128) PRIMARY KEY,
    user_id INT NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_expires_at (expires_at)
);

-- =====================================================
-- COMPANY AND CLIENT MANAGEMENT
-- =====================================================

-- Companies/Clients table
CREATE TABLE companies (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(200) NOT NULL,
    registration_number VARCHAR(50),
    tax_id VARCHAR(50),
    company_type ENUM('transporter', 'shipper', 'both') NOT NULL,
    industry VARCHAR(100),
    address_line1 VARCHAR(200),
    address_line2 VARCHAR(200),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Tanzania',
    primary_contact_name VARCHAR(100),
    primary_contact_phone VARCHAR(20),
    primary_contact_email VARCHAR(100),
    website VARCHAR(200),
    status ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
    credit_limit DECIMAL(15,2) DEFAULT 0.00,
    payment_terms INT DEFAULT 30, -- days
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_company_name (company_name),
    INDEX idx_company_type (company_type),
    INDEX idx_status (status),
    INDEX idx_country (country)
);

-- Company contacts (multiple contacts per company)
CREATE TABLE company_contacts (
    contact_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    contact_name VARCHAR(100) NOT NULL,
    position VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE,
    INDEX idx_company_id (company_id),
    INDEX idx_email (email)
);

-- =====================================================
-- FLEET MANAGEMENT
-- =====================================================

-- Vehicle types
CREATE TABLE vehicle_types (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    max_weight_kg DECIMAL(10,2),
    max_volume_m3 DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vehicles/Fleet
CREATE TABLE vehicles (
    vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
    vehicle_number VARCHAR(50) UNIQUE NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    type_id INT NOT NULL,
    make VARCHAR(50),
    model VARCHAR(50),
    year_manufactured YEAR,
    engine_number VARCHAR(100),
    chassis_number VARCHAR(100),
    fuel_type ENUM('diesel', 'petrol', 'electric', 'hybrid') DEFAULT 'diesel',
    fuel_capacity_liters DECIMAL(8,2),
    max_load_weight_kg DECIMAL(10,2),
    max_volume_m3 DECIMAL(10,2),
    current_mileage_km DECIMAL(12,2) DEFAULT 0,
    status ENUM('available', 'in_transit', 'maintenance', 'out_of_service') DEFAULT 'available',
    owner_type ENUM('owned', 'leased', 'partner') DEFAULT 'owned',
    insurance_policy_number VARCHAR(100),
    insurance_expiry_date DATE,
    registration_expiry_date DATE,
    last_service_date DATE,
    next_service_due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (type_id) REFERENCES vehicle_types(type_id),
    INDEX idx_vehicle_number (vehicle_number),
    INDEX idx_license_plate (license_plate),
    INDEX idx_status (status),
    INDEX idx_type_id (type_id)
);

-- Vehicle maintenance records
CREATE TABLE vehicle_maintenance (
    maintenance_id INT PRIMARY KEY AUTO_INCREMENT,
    vehicle_id INT NOT NULL,
    maintenance_type ENUM('routine', 'repair', 'inspection', 'emergency') NOT NULL,
    description TEXT NOT NULL,
    cost DECIMAL(10,2),
    service_provider VARCHAR(200),
    start_date DATE NOT NULL,
    completion_date DATE,
    mileage_at_service DECIMAL(12,2),
    next_service_mileage DECIMAL(12,2),
    status ENUM('scheduled', 'in_progress', 'completed', 'cancelled') DEFAULT 'scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_maintenance_type (maintenance_type),
    INDEX idx_status (status)
);

-- =====================================================
-- DRIVER MANAGEMENT
-- =====================================================

-- Drivers
CREATE TABLE drivers (
    driver_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE,
    driver_license_number VARCHAR(50) UNIQUE NOT NULL,
    license_class VARCHAR(20),
    license_expiry_date DATE NOT NULL,
    medical_certificate_expiry DATE,
    experience_years INT DEFAULT 0,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    current_status ENUM('available', 'on_trip', 'off_duty', 'on_leave') DEFAULT 'available',
    rating DECIMAL(3,2) DEFAULT 5.00, -- out of 5
    total_trips INT DEFAULT 0,
    total_distance_km DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_license_number (driver_license_number),
    INDEX idx_current_status (current_status),
    INDEX idx_user_id (user_id)
);

-- Driver vehicle assignments
CREATE TABLE driver_vehicle_assignments (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    driver_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    assigned_date DATE NOT NULL,
    unassigned_date DATE,
    is_primary BOOLEAN DEFAULT FALSE,
    status ENUM('active', 'inactive') DEFAULT 'active',
    
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    INDEX idx_driver_id (driver_id),
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_status (status)
);

-- =====================================================
-- LOCATION AND ROUTE MANAGEMENT
-- =====================================================

-- Countries
CREATE TABLE countries (
    country_id INT PRIMARY KEY AUTO_INCREMENT,
    country_code VARCHAR(3) UNIQUE NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    currency_code VARCHAR(3),
    is_active BOOLEAN DEFAULT TRUE
);

-- Cities/Locations
CREATE TABLE locations (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    location_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    state_province VARCHAR(100),
    country_id INT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_border_point BOOLEAN DEFAULT FALSE,
    customs_office BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (country_id) REFERENCES countries(country_id),
    INDEX idx_location_name (location_name),
    INDEX idx_country_id (country_id),
    INDEX idx_coordinates (latitude, longitude)
);

-- Routes
CREATE TABLE routes (
    route_id INT PRIMARY KEY AUTO_INCREMENT,
    route_name VARCHAR(200) NOT NULL,
    origin_location_id INT NOT NULL,
    destination_location_id INT NOT NULL,
    distance_km DECIMAL(10,2),
    estimated_duration_hours DECIMAL(5,2),
    route_type ENUM('local', 'cross_border', 'international') NOT NULL,
    toll_cost DECIMAL(10,2) DEFAULT 0,
    fuel_cost_estimate DECIMAL(10,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (origin_location_id) REFERENCES locations(location_id),
    FOREIGN KEY (destination_location_id) REFERENCES locations(location_id),
    INDEX idx_origin (origin_location_id),
    INDEX idx_destination (destination_location_id),
    INDEX idx_route_type (route_type)
);

-- Route waypoints
CREATE TABLE route_waypoints (
    waypoint_id INT PRIMARY KEY AUTO_INCREMENT,
    route_id INT NOT NULL,
    location_id INT NOT NULL,
    sequence_order INT NOT NULL,
    estimated_arrival_hours DECIMAL(5,2),
    waypoint_type ENUM('stop', 'checkpoint', 'border', 'fuel', 'rest') DEFAULT 'stop',
    
    FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES locations(location_id),
    INDEX idx_route_id (route_id),
    INDEX idx_sequence (route_id, sequence_order)
);

-- =====================================================
-- CARGO AND SHIPMENT MANAGEMENT
-- =====================================================

-- Cargo types
CREATE TABLE cargo_types (
    cargo_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(100) NOT NULL,
    description TEXT,
    requires_special_handling BOOLEAN DEFAULT FALSE,
    hazardous BOOLEAN DEFAULT FALSE,
    temperature_controlled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shipments
CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY AUTO_INCREMENT,
    shipment_number VARCHAR(50) UNIQUE NOT NULL,
    client_company_id INT NOT NULL,
    cargo_type_id INT NOT NULL,
    origin_location_id INT NOT NULL,
    destination_location_id INT NOT NULL,
    pickup_address TEXT,
    delivery_address TEXT,
    cargo_description TEXT NOT NULL,
    weight_kg DECIMAL(10,2) NOT NULL,
    volume_m3 DECIMAL(10,2),
    quantity INT DEFAULT 1,
    unit_type VARCHAR(50), -- pieces, pallets, containers, etc.
    declared_value DECIMAL(15,2),
    currency VARCHAR(3) DEFAULT 'TZS',
    special_instructions TEXT,
    pickup_date_requested DATE,
    delivery_date_requested DATE,
    pickup_time_window_start TIME,
    pickup_time_window_end TIME,
    delivery_time_window_start TIME,
    delivery_time_window_end TIME,
    status ENUM('pending', 'confirmed', 'assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled') DEFAULT 'pending',
    priority ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
    requires_insurance BOOLEAN DEFAULT FALSE,
    insurance_amount DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (client_company_id) REFERENCES companies(company_id),
    FOREIGN KEY (cargo_type_id) REFERENCES cargo_types(cargo_type_id),
    FOREIGN KEY (origin_location_id) REFERENCES locations(location_id),
    FOREIGN KEY (destination_location_id) REFERENCES locations(location_id),
    INDEX idx_shipment_number (shipment_number),
    INDEX idx_client_company (client_company_id),
    INDEX idx_status (status),
    INDEX idx_pickup_date (pickup_date_requested),
    INDEX idx_delivery_date (delivery_date_requested)
);

-- Trips (vehicle assignments to shipments)
CREATE TABLE trips (
    trip_id INT PRIMARY KEY AUTO_INCREMENT,
    trip_number VARCHAR(50) UNIQUE NOT NULL,
    vehicle_id INT NOT NULL,
    driver_id INT NOT NULL,
    route_id INT,
    trip_type ENUM('pickup', 'delivery', 'pickup_delivery', 'empty_return') DEFAULT 'pickup_delivery',
    planned_start_date DATE NOT NULL,
    planned_end_date DATE,
    actual_start_datetime TIMESTAMP NULL,
    actual_end_datetime TIMESTAMP NULL,
    status ENUM('planned', 'in_progress', 'completed', 'cancelled', 'delayed') DEFAULT 'planned',
    total_distance_km DECIMAL(10,2),
    fuel_consumed_liters DECIMAL(8,2),
    fuel_cost DECIMAL(10,2),
    toll_cost DECIMAL(10,2),
    other_expenses DECIMAL(10,2),
    driver_allowance DECIMAL(10,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    FOREIGN KEY (route_id) REFERENCES routes(route_id),
    INDEX idx_trip_number (trip_number),
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_driver_id (driver_id),
    INDEX idx_status (status),
    INDEX idx_planned_start_date (planned_start_date)
);

-- Trip shipments (many-to-many relationship)
CREATE TABLE trip_shipments (
    trip_shipment_id INT PRIMARY KEY AUTO_INCREMENT,
    trip_id INT NOT NULL,
    shipment_id INT NOT NULL,
    pickup_order INT,
    delivery_order INT,
    pickup_datetime TIMESTAMP NULL,
    delivery_datetime TIMESTAMP NULL,
    pickup_signature TEXT,
    delivery_signature TEXT,
    pickup_notes TEXT,
    delivery_notes TEXT,
    
    FOREIGN KEY (trip_id) REFERENCES trips(trip_id) ON DELETE CASCADE,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    UNIQUE KEY unique_trip_shipment (trip_id, shipment_id),
    INDEX idx_trip_id (trip_id),
    INDEX idx_shipment_id (shipment_id)
);

-- =====================================================
-- TRACKING AND MONITORING
-- =====================================================

-- GPS tracking data
CREATE TABLE gps_tracking (
    tracking_id INT PRIMARY KEY AUTO_INCREMENT,
    vehicle_id INT NOT NULL,
    trip_id INT,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    speed_kmh DECIMAL(5,2),
    heading_degrees DECIMAL(5,2),
    altitude_meters DECIMAL(8,2),
    accuracy_meters DECIMAL(6,2),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    FOREIGN KEY (trip_id) REFERENCES trips(trip_id) ON DELETE SET NULL,
    INDEX idx_vehicle_timestamp (vehicle_id, timestamp),
    INDEX idx_trip_id (trip_id),
    INDEX idx_timestamp (timestamp)
);

-- Shipment status history
CREATE TABLE shipment_status_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    shipment_id INT NOT NULL,
    status ENUM('pending', 'confirmed', 'assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled') NOT NULL,
    location_id INT,
    notes TEXT,
    updated_by_user_id INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES locations(location_id),
    FOREIGN KEY (updated_by_user_id) REFERENCES users(user_id),
    INDEX idx_shipment_id (shipment_id),
    INDEX idx_timestamp (timestamp)
);

-- =====================================================
-- FINANCIAL MANAGEMENT
-- =====================================================

-- Pricing rules
CREATE TABLE pricing_rules (
    rule_id INT PRIMARY KEY AUTO_INCREMENT,
    rule_name VARCHAR(200) NOT NULL,
    route_id INT,
    cargo_type_id INT,
    vehicle_type_id INT,
    base_rate DECIMAL(10,2) NOT NULL,
    rate_per_km DECIMAL(8,4),
    rate_per_kg DECIMAL(8,4),
    rate_per_m3 DECIMAL(8,4),
    minimum_charge DECIMAL(10,2),
    fuel_surcharge_percentage DECIMAL(5,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    effective_from DATE NOT NULL,
    effective_to DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (route_id) REFERENCES routes(route_id),
    FOREIGN KEY (cargo_type_id) REFERENCES cargo_types(cargo_type_id),
    FOREIGN KEY (vehicle_type_id) REFERENCES vehicle_types(type_id),
    INDEX idx_route_cargo_vehicle (route_id, cargo_type_id, vehicle_type_id),
    INDEX idx_effective_dates (effective_from, effective_to)
);

-- Quotes
CREATE TABLE quotes (
    quote_id INT PRIMARY KEY AUTO_INCREMENT,
    quote_number VARCHAR(50) UNIQUE NOT NULL,
    client_company_id INT NOT NULL,
    shipment_id INT,
    origin_location_id INT NOT NULL,
    destination_location_id INT NOT NULL,
    cargo_type_id INT NOT NULL,
    weight_kg DECIMAL(10,2) NOT NULL,
    volume_m3 DECIMAL(10,2),
    distance_km DECIMAL(10,2),
    base_amount DECIMAL(12,2) NOT NULL,
    fuel_surcharge DECIMAL(10,2) DEFAULT 0,
    insurance_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'TZS',
    valid_until DATE NOT NULL,
    status ENUM('draft', 'sent', 'accepted', 'rejected', 'expired') DEFAULT 'draft',
    notes TEXT,
    created_by_user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (client_company_id) REFERENCES companies(company_id),
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id),
    FOREIGN KEY (origin_location_id) REFERENCES locations(location_id),
    FOREIGN KEY (destination_location_id) REFERENCES locations(location_id),
    FOREIGN KEY (cargo_type_id) REFERENCES cargo_types(cargo_type_id),
    FOREIGN KEY (created_by_user_id) REFERENCES users(user_id),
    INDEX idx_quote_number (quote_number),
    INDEX idx_client_company (client_company_id),
    INDEX idx_status (status),
    INDEX idx_valid_until (valid_until)
);

-- Invoices
CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    client_company_id INT NOT NULL,
    quote_id INT,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 18.00, -- VAT rate
    tax_amount DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'TZS',
    status ENUM('draft', 'sent', 'paid', 'overdue', 'cancelled') DEFAULT 'draft',
    payment_terms VARCHAR(200),
    notes TEXT,
    created_by_user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (client_company_id) REFERENCES companies(company_id),
    FOREIGN KEY (quote_id) REFERENCES quotes(quote_id),
    FOREIGN KEY (created_by_user_id) REFERENCES users(user_id),
    INDEX idx_invoice_number (invoice_number),
    INDEX idx_client_company (client_company_id),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date)
);

-- Invoice line items
CREATE TABLE invoice_line_items (
    line_item_id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    shipment_id INT,
    description TEXT NOT NULL,
    quantity DECIMAL(10,2) DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    line_total DECIMAL(12,2) NOT NULL,
    
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id),
    INDEX idx_invoice_id (invoice_id)
);

-- Payments
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    payment_reference VARCHAR(100),
    payment_method ENUM('cash', 'bank_transfer', 'mobile_money', 'cheque', 'credit_card') NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'TZS',
    payment_date DATE NOT NULL,
    bank_reference VARCHAR(100),
    notes TEXT,
    created_by_user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    FOREIGN KEY (created_by_user_id) REFERENCES users(user_id),
    INDEX idx_invoice_id (invoice_id),
    INDEX idx_payment_date (payment_date),
    INDEX idx_payment_reference (payment_reference)
);

-- =====================================================
-- COMMUNICATION AND NOTIFICATIONS
-- =====================================================

-- Messages/Communications
CREATE TABLE messages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_user_id INT NOT NULL,
    recipient_user_id INT,
    recipient_company_id INT,
    subject VARCHAR(200),
    message_body TEXT NOT NULL,
    message_type ENUM('email', 'sms', 'system', 'notification') DEFAULT 'system',
    priority ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
    status ENUM('draft', 'sent', 'delivered', 'read', 'failed') DEFAULT 'draft',
    related_shipment_id INT,
    related_trip_id INT,
    sent_at TIMESTAMP NULL,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (sender_user_id) REFERENCES users(user_id),
    FOREIGN KEY (recipient_user_id) REFERENCES users(user_id),
    FOREIGN KEY (recipient_company_id) REFERENCES companies(company_id),
    FOREIGN KEY (related_shipment_id) REFERENCES shipments(shipment_id),
    FOREIGN KEY (related_trip_id) REFERENCES trips(trip_id),
    INDEX idx_sender (sender_user_id),
    INDEX idx_recipient_user (recipient_user_id),
    INDEX idx_recipient_company (recipient_company_id),
    INDEX idx_status (status),
    INDEX idx_sent_at (sent_at)
);

-- Notifications
CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    notification_type ENUM('info', 'warning', 'error', 'success') DEFAULT 'info',
    related_entity_type ENUM('shipment', 'trip', 'vehicle', 'driver', 'invoice', 'payment'),
    related_entity_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- SYSTEM CONFIGURATION AND LOGS
-- =====================================================

-- System settings
CREATE TABLE system_settings (
    setting_id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    updated_by_user_id INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (updated_by_user_id) REFERENCES users(user_id),
    INDEX idx_setting_key (setting_key)
);

-- Audit logs
CREATE TABLE audit_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_table_name (table_name),
    INDEX idx_timestamp (timestamp)
);

-- File uploads
CREATE TABLE file_uploads (
    file_id INT PRIMARY KEY AUTO_INCREMENT,
    original_filename VARCHAR(255) NOT NULL,
    stored_filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    mime_type VARCHAR(100),
    file_category ENUM('document', 'image', 'signature', 'invoice', 'other') DEFAULT 'document',
    related_entity_type ENUM('shipment', 'trip', 'vehicle', 'driver', 'company', 'invoice'),
    related_entity_id INT,
    uploaded_by_user_id INT NOT NULL,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (uploaded_by_user_id) REFERENCES users(user_id),
    INDEX idx_related_entity (related_entity_type, related_entity_id),
    INDEX idx_uploaded_by (uploaded_by_user_id),
    INDEX idx_file_category (file_category)
);

-- =====================================================
-- INITIAL DATA INSERTION
-- =====================================================

-- Insert default countries
INSERT INTO countries (country_code, country_name, currency_code) VALUES
('TZA', 'Tanzania', 'TZS'),
('KEN', 'Kenya', 'KES'),
('UGA', 'Uganda', 'UGX'),
('RWA', 'Rwanda', 'RWF'),
('BDI', 'Burundi', 'BIF'),
('COD', 'Democratic Republic of Congo', 'CDF');

-- Insert default vehicle types
INSERT INTO vehicle_types (type_name, description, max_weight_kg, max_volume_m3) VALUES
('Small Truck', 'Light commercial vehicle for local deliveries', 3500.00, 15.00),
('Medium Truck', 'Medium-duty truck for regional transport', 7500.00, 35.00),
('Heavy Truck', 'Heavy-duty truck for long-haul transport', 25000.00, 80.00),
('Trailer', 'Semi-trailer for bulk cargo', 40000.00, 120.00),
('Tanker', 'Specialized tanker for liquid cargo', 30000.00, 50.00);

-- Insert default cargo types
INSERT INTO cargo_types (type_name, description, requires_special_handling, hazardous, temperature_controlled) VALUES
('General Cargo', 'Standard dry goods and merchandise', FALSE, FALSE, FALSE),
('Food Products', 'Packaged food items and beverages', FALSE, FALSE, FALSE),
('Agricultural Products', 'Grains, seeds, and farm produce', FALSE, FALSE, FALSE),
('Construction Materials', 'Cement, steel, building supplies', TRUE, FALSE, FALSE),
('Chemicals', 'Industrial chemicals and compounds', TRUE, TRUE, FALSE),
('Perishables', 'Fresh produce and temperature-sensitive goods', TRUE, FALSE, TRUE),
('Fuel/Oil', 'Petroleum products and fuel', TRUE, TRUE, FALSE),
('Electronics', 'Electronic equipment and devices', TRUE, FALSE, FALSE);

-- Insert default system settings
INSERT INTO system_settings (setting_key, setting_value, setting_type, description, is_public) VALUES
('company_name', '3rd Logistics', 'string', 'Company name', TRUE),
('company_email', 'info@3rdlogistics.co.tz', 'string', 'Company email address', TRUE),
('company_phone', '+255 656 730 595', 'string', 'Company phone number', TRUE),
('company_website', 'www.3rdlogistics.co.tz', 'string', 'Company website', TRUE),
('default_currency', 'TZS', 'string', 'Default currency code', TRUE),
('default_tax_rate', '18.00', 'number', 'Default VAT rate percentage', FALSE),
('fuel_price_per_liter', '2800.00', 'number', 'Current fuel price per liter in TZS', FALSE),
('max_file_upload_size', '10485760', 'number', 'Maximum file upload size in bytes (10MB)', FALSE);

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- Active shipments view
CREATE VIEW active_shipments AS
SELECT 
    s.shipment_id,
    s.shipment_number,
    c.company_name as client_name,
    s.cargo_description,
    s.weight_kg,
    ol.location_name as origin,
    dl.location_name as destination,
    s.status,
    s.pickup_date_requested,
    s.delivery_date_requested,
    s.created_at
FROM shipments s
JOIN companies c ON s.client_company_id = c.company_id
JOIN locations ol ON s.origin_location_id = ol.location_id
JOIN locations dl ON s.destination_location_id = dl.location_id
WHERE s.status NOT IN ('delivered', 'cancelled');

-- Fleet status view
CREATE VIEW fleet_status AS
SELECT 
    v.vehicle_id,
    v.vehicle_number,
    v.license_plate,
    vt.type_name,
    v.status,
    d.first_name as driver_first_name,
    d.last_name as driver_last_name,
    t.trip_number as current_trip,
    v.current_mileage_km,
    v.next_service_due_date
FROM vehicles v
LEFT JOIN vehicle_types vt ON v.type_id = vt.type_id
LEFT JOIN driver_vehicle_assignments dva ON v.vehicle_id = dva.vehicle_id AND dva.status = 'active'
LEFT JOIN drivers dr ON dva.driver_id = dr.driver_id
LEFT JOIN users d ON dr.user_id = d.user_id
LEFT JOIN trips t ON v.vehicle_id = t.vehicle_id AND t.status = 'in_progress';

-- Financial summary view
CREATE VIEW financial_summary AS
SELECT 
    DATE(i.invoice_date) as invoice_date,
    COUNT(i.invoice_id) as total_invoices,
    SUM(i.total_amount) as total_invoiced,
    SUM(CASE WHEN i.status = 'paid' THEN i.total_amount ELSE 0 END) as total_paid,
    SUM(CASE WHEN i.status = 'overdue' THEN i.total_amount ELSE 0 END) as total_overdue,
    i.currency
FROM invoices i
GROUP BY DATE(i.invoice_date), i.currency;

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

DELIMITER //

-- Procedure to calculate shipment cost
CREATE PROCEDURE CalculateShipmentCost(
    IN p_origin_location_id INT,
    IN p_destination_location_id INT,
    IN p_cargo_type_id INT,
    IN p_vehicle_type_id INT,
    IN p_weight_kg DECIMAL(10,2),
    IN p_volume_m3 DECIMAL(10,2),
    OUT p_total_cost DECIMAL(12,2)
)
BEGIN
    DECLARE v_route_id INT;
    DECLARE v_distance_km DECIMAL(10,2);
    DECLARE v_base_rate DECIMAL(10,2);
    DECLARE v_rate_per_km DECIMAL(8,4);
    DECLARE v_rate_per_kg DECIMAL(8,4);
    DECLARE v_rate_per_m3 DECIMAL(8,4);
    DECLARE v_minimum_charge DECIMAL(10,2);
    DECLARE v_fuel_surcharge_percentage DECIMAL(5,2);
    DECLARE v_calculated_cost DECIMAL(12,2);
    
    -- Find route
    SELECT route_id, distance_km INTO v_route_id, v_distance_km
    FROM routes 
    WHERE origin_location_id = p_origin_location_id 
    AND destination_location_id = p_destination_location_id
    AND is_active = TRUE
    LIMIT 1;
    
    -- Find pricing rule
    SELECT base_rate, rate_per_km, rate_per_kg, rate_per_m3, minimum_charge, fuel_surcharge_percentage
    INTO v_base_rate, v_rate_per_km, v_rate_per_kg, v_rate_per_m3, v_minimum_charge, v_fuel_surcharge_percentage
    FROM pricing_rules
    WHERE (route_id = v_route_id OR route_id IS NULL)
    AND (cargo_type_id = p_cargo_type_id OR cargo_type_id IS NULL)
    AND (vehicle_type_id = p_vehicle_type_id OR vehicle_type_id IS NULL)
    AND is_active = TRUE
    AND CURDATE() BETWEEN effective_from AND COALESCE(effective_to, CURDATE())
    ORDER BY route_id DESC, cargo_type_id DESC, vehicle_type_id DESC
    LIMIT 1;
    
    -- Calculate cost
    SET v_calculated_cost = COALESCE(v_base_rate, 0) + 
                           (COALESCE(v_rate_per_km, 0) * COALESCE(v_distance_km, 0)) +
                           (COALESCE(v_rate_per_kg, 0) * p_weight_kg) +
                           (COALESCE(v_rate_per_m3, 0) * COALESCE(p_volume_m3, 0));
    
    -- Apply fuel surcharge
    SET v_calculated_cost = v_calculated_cost * (1 + COALESCE(v_fuel_surcharge_percentage, 0) / 100);
    
    -- Apply minimum charge
    SET p_total_cost = GREATEST(v_calculated_cost, COALESCE(v_minimum_charge, 0));
    
END //

-- Procedure to update shipment status
CREATE PROCEDURE UpdateShipmentStatus(
    IN p_shipment_id INT,
    IN p_new_status ENUM('pending', 'confirmed', 'assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled'),
    IN p_location_id INT,
    IN p_notes TEXT,
    IN p_user_id INT
)
BEGIN
    -- Update shipment status
    UPDATE shipments 
    SET status = p_new_status, updated_at = CURRENT_TIMESTAMP
    WHERE shipment_id = p_shipment_id;
    
    -- Insert status history
    INSERT INTO shipment_status_history (shipment_id, status, location_id, notes, updated_by_user_id)
    VALUES (p_shipment_id, p_new_status, p_location_id, p_notes, p_user_id);
    
END //

DELIMITER ;

-- =====================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- =====================================================

-- Additional composite indexes for common queries
CREATE INDEX idx_shipments_client_status_date ON shipments(client_company_id, status, pickup_date_requested);
CREATE INDEX idx_trips_vehicle_status_date ON trips(vehicle_id, status, planned_start_date);
CREATE INDEX idx_gps_vehicle_time ON gps_tracking(vehicle_id, timestamp DESC);
CREATE INDEX idx_invoices_client_status_date ON invoices(client_company_id, status, due_date);
CREATE INDEX idx_messages_recipient_status ON messages(recipient_user_id, status, sent_at DESC);

-- =====================================================
-- TRIGGERS FOR DATA INTEGRITY
-- =====================================================

DELIMITER //

-- Trigger to update vehicle mileage from GPS data
CREATE TRIGGER update_vehicle_mileage
AFTER INSERT ON gps_tracking
FOR EACH ROW
BEGIN
    DECLARE prev_lat, prev_lng DECIMAL(10,8);
    DECLARE distance_km DECIMAL(10,4);
    
    -- Get previous GPS point
    SELECT latitude, longitude INTO prev_lat, prev_lng
    FROM gps_tracking 
    WHERE vehicle_id = NEW.vehicle_id 
    AND tracking_id < NEW.tracking_id
    ORDER BY timestamp DESC 
    LIMIT 1;
    
    -- Calculate distance (simplified - in production use proper geospatial functions)
    IF prev_lat IS NOT NULL AND prev_lng IS NOT NULL THEN
        SET distance_km = SQRT(POW(NEW.latitude - prev_lat, 2) + POW(NEW.longitude - prev_lng, 2)) * 111.32; -- Approximate km per degree
        
        -- Update vehicle mileage
        UPDATE vehicles 
        SET current_mileage_km = current_mileage_km + distance_km
        WHERE vehicle_id = NEW.vehicle_id;
    END IF;
END //

-- Trigger to create notification for overdue invoices
CREATE TRIGGER check_overdue_invoices
AFTER UPDATE ON invoices
FOR EACH ROW
BEGIN
    IF NEW.due_date < CURDATE() AND NEW.status = 'sent' AND OLD.status != 'overdue' THEN
        UPDATE invoices SET status = 'overdue' WHERE invoice_id = NEW.invoice_id;
        
        INSERT INTO notifications (user_id, title, message, notification_type, related_entity_type, related_entity_id)
        SELECT u.user_id, 
               CONCAT('Invoice ', NEW.invoice_number, ' is overdue'),
               CONCAT('Invoice ', NEW.invoice_number, ' for ', c.company_name, ' is now overdue. Amount: ', NEW.total_amount, ' ', NEW.currency),
               'warning',
               'invoice',
               NEW.invoice_id
        FROM users u
        JOIN companies c ON NEW.client_company_id = c.company_id
        WHERE u.role IN ('admin', 'manager');
    END IF;
END //

DELIMITER ;

-- =====================================================
-- SAMPLE DATA FOR TESTING
-- =====================================================

-- Insert sample admin user (password should be hashed in production)
INSERT INTO users (username, email, password_hash, first_name, last_name, phone, role, email_verified) VALUES
('admin', 'admin@3rdlogistics.co.tz', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'System', 'Administrator', '+255656730595', 'admin', TRUE);

-- Insert sample locations
INSERT INTO locations (location_name, city, state_province, country_id, latitude, longitude) VALUES
('Dar es Salaam Port', 'Dar es Salaam', 'Dar es Salaam', 1, -6.7924, 39.2083),
('Mombasa Port', 'Mombasa', 'Mombasa', 2, -4.0435, 39.6682),
('Kampala Central', 'Kampala', 'Central', 3, 0.3476, 32.5825),
('Kigali City', 'Kigali', 'Kigali', 4, -1.9441, 30.0619);

-- This completes the comprehensive database schema for 3rd Logistics
-- The schema includes all necessary tables, relationships, indexes, views, 
-- stored procedures, and triggers for a production-ready logistics management system.

