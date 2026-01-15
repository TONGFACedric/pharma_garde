# PharmaGarde

## Professional Description

PharmaGarde is a mobile application designed to help users in Cameroon quickly locate pharmacies that are on duty (pharmacies de garde) outside of regular business hours. The app provides real-time access to pharmacy information across all regions of Cameroon, ensuring that users can find essential healthcare services when they need them most, especially during evenings, nights, weekends, and holidays.

The application addresses a critical need in Cameroon's healthcare system by providing an easy-to-use interface for finding on-duty pharmacies, complete with contact information, addresses, and schedules. This helps prevent medical emergencies from becoming worse due to inability to access medications or basic healthcare services.

## Technology Used

### Core Framework
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language used for Flutter development

### Key Dependencies
- **http**: For making HTTP requests to fetch pharmacy data
- **html**: For parsing HTML content from web sources
- **shared_preferences**: For local data persistence and caching
- **google_fonts**: For custom typography (Inter font)
- **url_launcher**: For opening phone calls and maps
- **workmanager**: For background task scheduling
- **share_plus**: For sharing pharmacy information
- **package_info_plus**: For app version information

### Architecture Patterns
- **Repository Pattern**: For data management and caching
- **MVVM (Model-View-ViewModel)**: For clean separation of concerns
- **Service Layer**: For API communication and data processing

## Purpose

The primary purpose of PharmaGarde is to:
1. **Improve Healthcare Access**: Make it easier for Cameroonians to find pharmacies during off-hours
2. **Provide Real-time Information**: Ensure users have up-to-date pharmacy schedules and contact details
3. **Enhance Emergency Response**: Help in medical emergencies by providing quick access to healthcare facilities
4. **Promote Digital Healthcare**: Contribute to the digitization of healthcare services in Cameroon

## How to Operate the App

### Prerequisites
- Android or iOS device
- Internet connection for initial data loading
- Location services (optional, for map integration)

### Installation
1. Download the app from the Google Play Store or Apple App Store
2. Grant necessary permissions (location, phone calls)
3. The app will automatically load pharmacy data on first launch

### Basic Usage
1. **Launch the App**: Open PharmaGarde to see the splash screen
2. **Select Region**: Choose your region from the grid of Cameroonian regions
3. **Choose City**: Select your city from the list of available cities in that region
4. **View Pharmacies**: Browse the list of on-duty pharmacies with their details
5. **Contact Pharmacy**: Tap phone numbers to call or use map buttons to navigate
6. **Share Information**: Use the share button to send pharmacy details to others
7. **Refresh Data**: Pull down or use the refresh button to update pharmacy information

### Advanced Features
- **Theme Switching**: Toggle between light, dark, and system themes
- **Background Updates**: The app automatically refreshes data in the background
- **Offline Access**: Cached data remains available when offline
- **Search Functionality**: Search for specific cities within regions

## Role of Each Function in the Code (For Beginners)

### 1. main.dart - Application Entry Point
This is where the app starts. It initializes essential services like SharedPreferences and Workmanager for background tasks. It sets up the main MaterialApp with theme configuration and handles theme switching logic. Think of it as the "front door" of your app - everything begins here.

### 2. splash_screen.dart - Welcome Screen
Creates an animated splash screen that shows when the app first opens. It displays the app logo, name, and a loading indicator while preparing the app. This gives users a professional first impression and time for the app to load necessary data.

### 3. home.dart - Main Home Page
Displays a grid of all Cameroonian regions. Users select their region here to proceed. It handles loading states, error handling, and navigation to the cities page. This is like the main menu of the app.

### 4. cities_page.dart - Cities Selection Page
Shows all cities within a selected region. Includes a search bar to filter cities. When a city is selected, it navigates to the pharmacies page. This acts as an intermediate step between region and pharmacy selection.

### 5. pharmacies_page.dart - Pharmacy Display Page
The core page showing all on-duty pharmacies for a selected city. Displays pharmacy cards with all relevant information. Includes interactive buttons for calling, mapping, and sharing. This is where users get the information they need.

### 6. pharmacy_model.dart - Data Structure
Defines what a pharmacy looks like in code. Contains properties like name, address, phone, and schedule. Includes methods to convert pharmacy data to/from JSON format. Think of this as a blueprint for pharmacy information.

### 7. pharmacy_service.dart - Data Fetching Service
Handles all communication with external data sources. Scrapes pharmacy information from websites and processes the raw data into usable format. Manages network requests and error handling for data retrieval.

### 8. pharmacy_repository.dart - Data Management Layer
Acts as a middleman between the UI and data services. Implements caching to store pharmacy data locally. Manages data freshness and provides offline access. This layer ensures efficient data handling and persistence.

### 9. theme.dart - Visual Styling
Contains all the visual design elements of the app. Defines color schemes for light and dark themes. Provides reusable styles for cards, buttons, and other UI components. This file controls how the app looks and feels.

## Background Processing

The app uses Workmanager to perform background tasks:
- Automatically refreshes pharmacy data at scheduled times (9 AM, 6 PM, and next day)
- Ensures users always have up-to-date information
- Works even when the app is not actively open

## Caching Strategy

- **24-hour cache validity**: Pharmacy data is stored locally for 24 hours
- **Offline access**: Users can view cached data without internet
- **Automatic refresh**: Background tasks update data regularly
- **Fallback mechanism**: If network fails, app uses stale cache rather than showing errors

## Contributing

To contribute to PharmaGarde:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For support or questions:
- Check the app's help section
- Contact the development team
- Report issues through the app store

## License

This project is licensed under the MIT License - see the LICENSE file for details.
