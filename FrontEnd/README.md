# Snuggy Canteen Management System - Frontend

## Overview

Snuggy is a comprehensive canteen management system designed for educational institutions. The frontend is built with Flutter, providing a cross-platform mobile application for both users and administrators.

## Features

### User Features
- User authentication (login/register)
- Browse menu items
- Add items to cart
- Place and track orders
- View order history
- Make payments
- Profile management

### Admin Features
- Admin dashboard with key metrics
- NFC scanning for order retrieval
- Order management (view, update status)
- Inventory management (add, update, delete items)
- Daily usage reports with analytics

### NFC Integration
The application includes NFC scanning capabilities to:
- Register users with their NFC cards
- Retrieve user orders by scanning their NFC card UUID
- Streamline the order pickup process

## Project Structure

```
frontend/
├── lib/
│   ├── admin/                  # Admin screens
│   │   ├── admin_dashboard.dart
│   │   ├── daily_report_screen.dart
│   │   ├── inventory_screen.dart
│   │   ├── order_management_screen.dart
│   │   └── nfc_scanner_screen.dart
│   ├── models/                 # Data models
│   │   ├── cart_model.dart
│   │   ├── daily_report.dart
│   │   ├── inventory_item.dart
│   │   ├── menu_item.dart
│   │   └── order_model.dart
│   ├── screens/                # User screens
│   │   ├── cart_screen.dart
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   ├── menu_screen.dart
│   │   ├── orders_screen.dart
│   │   ├── payment_screen.dart
│   │   ├── profile_screen.dart
│   │   └── register_screen.dart
│   ├── services/               # API and other services
│   │   ├── api_service.dart
│   │   └── nfc_service.dart
│   ├── widgets/                # Reusable widgets
│   │   └── custom_bottom_nav_bar.dart
│   └── main.dart               # App entry point
└── assets/
    ├── images/                 # Image assets
    └── fonts/                  # Font assets
```

## NFC Implementation

The NFC functionality is implemented through the `NfcService` class, which provides:

1. **Scanning Interface**: Methods to start and stop NFC scanning
2. **Status Tracking**: Real-time status updates through streams
3. **UUID Handling**: Captured NFC tag UUIDs are broadcast to listeners
4. **Hardware Abstraction**: Integration with actual NFC hardware through platform channels

For development purposes, the service includes a simulation mode that generates mock UUIDs.

### Integration with Admin Module

The NFC scanner is integrated with the admin module to:

1. Scan customer NFC cards
2. Retrieve their pending orders via UUID
3. Allow admins to mark orders as dispatched
4. Provide visual feedback during the scanning process

## Setup and Installation

1. Ensure Flutter is installed on your development machine
2. Clone the repository
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run
   ```

## Backend Integration

The frontend communicates with a Node.js backend through RESTful API endpoints. The `ApiService` class handles all API communication, including:

- Authentication
- Menu retrieval
- Order management
- Payment processing
- Inventory management
- Reporting

## Future Enhancements

- Biometric authentication
- Push notifications for order updates
- QR code generation for order pickup
- Offline mode support
- Analytics dashboard enhancements 