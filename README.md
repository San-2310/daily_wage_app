# Daily Wage App

A Flutter application designed to connect employers with daily wage workers, providing a simple and efficient platform for job posting and worker-employer interaction.

## Features

### User Authentication
- Dual role system (Employer/Worker)
- Email/password-based authentication using Firebase
- Profile management with location, contact details, and phone number

### For Employers
- Create and manage job listings with detailed information:
  - Job title and description
  - Location (manual entry or geolocation)
  - Number of workers required
  - Daily wage
  - Job duration
  - Job category (Cleaning, Construction, Delivery, etc.)
- Review worker applications
- Rate workers after job completion
- Manage active job listings (edit/delete)

### For Workers
- Browse available jobs based on location
- Filter jobs by:
  - Wage (high to low)
  - Duration
- Simple one-click job application
- Rate employers after job completion
- View job application status

### Additional Features
- Multilingual support (English and Hindi)
- Local notifications for:
  - New job postings
  - Application status updates
  - New applications (for employers)
- Pagination for efficient job listing display
- Responsive design for various screen sizes
- 5-star rating system for both workers and employers

## Technical Details

### Architecture
The project has the following structure:
```
lib/
├── configs/      # Configuration files
├── models/       # Data models
├── pages/        # UI screens
├── providers/    # State management
├── services/     # Business logic
├── widgets/      # Reusable UI components
└── localization/ # Language support
```

### Dependencies
- **State Management**: Provider
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Location Services**: Geolocator
- **Notifications**: Flutter Local Notifications
- **Localization**: Flutter Localization
- **UI**: Material Design

### Key Packages
```yaml
provider: ^6.1.2
geolocator: ^13.0.2
firebase_auth: ^5.3.4
cloud_firestore: ^5.6.0
flutter_local_notifications: ^18.0.1
shared_preferences: ^2.3.5
intl: ^0.19.0
```

## Getting Started

### Prerequisites
- Flutter SDK (^3.5.3)
- Firebase account
- Android Studio / VS Code

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/San-2310/daily_wage_app.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android/iOS apps in Firebase console
   - Download and add configuration files
   - Enable Email/Password authentication

4. Run the app:
   ```bash
   flutter run
   ```

### Configuration
- Update `firebase_options.dart` with your Firebase credentials
- Configure supported languages in `localization/`
- Set up local notification channels in `services/notification_service.dart`

## UI/UX Considerations
- Simple and intuitive interface for users with limited education
- Clear navigation structure
- Easy-to-read typography using Poppins font family
- Responsive design for all screen sizes
- Language switcher easily accessible from all screens

## Future Improvements
- Advanced job matching algorithm
- In-app messaging between workers and employers
- Job history tracking
- Enhanced location-based job suggestions
