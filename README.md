# Pharmacy Chain Management System

## Overview
A comprehensive pharmacy chain management system built with a **Flutter frontend** and **Java backend**, designed to manage multiple pharmacy locations with centralized control. This system handles inventory management, point-of-sale operations, customer records, and manager oversight across the entire pharmacy chain.

## System Architecture

### Frontend (Dart/Flutter)
- **Technology**: Flutter (Dart)
- **File**: `pharmacy_flutter_fixed_v16_pos_stock_customer.zip`
- Modern, responsive UI for pharmacy operations
- Cross-platform support (iOS, Android, Web)

### Backend (Java)
- **Technology**: Java
- **File**: `pharmacy_backend_fixed_logic_v12.zip`
- RESTful API for pharmacy operations
- Business logic and data processing

### Database (SQL)
- **Technology**: SQL Database
- **File**: `pharmacy_sql_manager_logic_fixed_v4_manager_add_fix (1).sql`
- Centralized database for all pharmacy chain data
- Manager and staff role management

---

## Installation & Setup

### Prerequisites
- **Java 8+** (for backend)
- **Flutter SDK** (for frontend)
- **SQL Database Server** (MySQL/PostgreSQL recommended)
- **Git** (for version control)

### Step 1: Backend Setup (Java)
1. Extract `pharmacy_backend_fixed_logic_v12.zip`
2. Navigate to the backend directory:
   ```bash
   cd pharmacy_backend_fixed_logic_v12
   ```
3. Install dependencies and build:
   ```bash
   mvn clean install
   ```
4. Configure database connection in `application.properties`
5. Run the backend server:
   ```bash
   mvn spring-boot:run
   ```
   - Default server runs on: `http://localhost:8080`

### Step 2: Database Setup (SQL)
1. Access your SQL database server (MySQL, PostgreSQL, etc.)
2. Import the SQL script:
   ```bash
   mysql -u root -p pharmacy_db < pharmacy_sql_manager_logic_fixed_v4_manager_add_fix.sql
   ```
3. Verify tables and data are created successfully

### Step 3: Frontend Setup (Flutter)
1. Extract `pharmacy_flutter_fixed_v16_pos_stock_customer.zip`
2. Navigate to the frontend directory:
   ```bash
   cd pharmacy_flutter_fixed_v16_pos_stock_customer
   ```
3. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```
4. Update API endpoint in configuration (point to your backend server):
   ```dart
   const String API_BASE_URL = 'http://localhost:8080';
   ```
5. Run the Flutter application:
   ```bash
   flutter run
   ```

---

## Features

### For Pharmacy Staff
- **Point of Sale (POS)**
  - Process customer purchases
  - Generate receipts
  - Payment processing  

- **Stock Management**
  - View current inventory levels
  - Track product availability
  - Low stock alerts

### For Customers
- **Customer Portal**
  - Browse available medicines
  - View prescription history
  - Track orders

### For Managers
- **Chain-wide Management**
  - Manage multiple pharmacy locations
  - Staff management and access control
  - Generate reports and analytics
  - Monitor inventory across locations
  - View sales data and trends

---

## User Roles

1. **Manager**
   - Full system access
   - Manage staff accounts
   - View chain-wide analytics
   - Configure system settings

2. **Pharmacy Staff**
   - POS operations
   - Inventory management
   - Customer service
   - Stock adjustments

3. **Customer**
   - Browse products
   - View purchase history
   - Track orders

---

## How to Use

### For Managers
1. Log in with manager credentials
2. Access the management dashboard
3. Add/remove pharmacy locations
4. Manage staff accounts and permissions
5. View sales reports and inventory analytics

### For Pharmacy Staff
1. Log in with staff credentials
2. Access the POS interface
3. Process customer transactions
4. Check stock levels
5. Generate daily reports

### For Customers
1. Create a customer account or log in
2. Browse available medicines
3. View prescription history
4. Complete purchases through POS

---

## Database Schema Overview

The system includes the following main tables:
- **Pharmacies**: Store location information
- **Products**: Medication and product inventory
- **Inventory**: Stock levels by location
- **Users**: Staff and manager accounts
- **Transactions**: Sales and purchase records
- **Customers**: Customer information and history

---

## Troubleshooting

### Backend Connection Issues
- Ensure Java is properly installed
- Check if port 8080 is available
- Verify database connection settings
- Review backend logs for errors

### Frontend Connection Issues
- Verify backend server is running
- Check API endpoint configuration
- Ensure network connectivity
- Clear Flutter build cache: `flutter clean`

### Database Issues
- Confirm SQL server is running
- Verify database credentials
- Check SQL file was imported correctly
- Review database logs

---

## Support & Contribution

**Note**: This is a final project for IT1K65 Java Programming Course by Group 1. 

For inquiries or references, please contact the author. **Any copying actions will be reported.**

---

## Project Information

- **Course**: Java Programming Course IT1K65
- **Group**: Group 1
- **Type**: Final Project
- **Languages**: Dart (86.9%), C++ (6.6%), CMake (5.1%), Swift (0.6%), HTML (0.4%), C (0.4%)

---

## License

This project is proprietary and intended for educational purposes only.