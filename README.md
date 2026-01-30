# 🏥 HomeoCare - Homeopathic Clinic Management App

A comprehensive Flutter mobile application for managing homeopathic clinic operations, including patient management, visit tracking, prescription generation, and document storage.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)

## ✨ Features

### 📱 Mobile App (Flutter)
- **Welcome & Onboarding**: Beautiful animated welcome screens with feature highlights
- **Authentication**: Email/password login and signup with Firebase Auth
- **Dashboard**: 
  - Today's appointments view
  - All patients list with search and filters
  - Quick patient access
- **Patient Management**:
  - Add new patients with comprehensive details
  - Record vitals (height, weight, BP, temperature, heart rate)
  - Upload and manage medical documents
  - View patient history
- **Visit Tracking**:
  - Record visit details with symptoms and examination notes
  - Prescribe homeopathic medicines with potency and dosage
  - Set follow-up appointments
  - Track vitals during visits
- **Prescription Management**:
  - Digital prescription generation
  - Print to PDF functionality
  - Medicine history tracking
- **Profile Management**:
  - Update personal and clinic information
  - Change password
  - Dark mode support

### 🖥️ Backend (Node.js)
- RESTful API with Express.js
- MongoDB database with Mongoose ODM
- JWT authentication with refresh tokens
- Firebase Admin SDK integration
- Rate limiting and security middleware
- Input validation with express-validator

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: >= 3.10.0
- **Dart SDK**: >= 3.0.0
- **Node.js**: >= 18.0.0
- **MongoDB**: Local installation or MongoDB Atlas account
- **Firebase Project**: With Authentication and Storage enabled

### 📥 Installation

#### 1. Clone the Repository
```bash
git clone <repository-url>
cd homeocare
```

#### 2. Flutter App Setup

```bash
# Install Flutter dependencies
flutter pub get

# Configure Firebase (requires FlutterFire CLI)
# Install FlutterFire CLI if not installed
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure

# This will generate lib/firebase_options.dart with your project configuration
```

#### 3. Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing
3. Enable the following services:
   - **Authentication**: Enable Email/Password sign-in
   - **Cloud Firestore**: Create database in production mode
   - **Storage**: Create storage bucket

4. Set up Firestore Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /patients/{patientId} {
      allow read, write: if request.auth != null && 
        resource.data.doctorId == request.auth.uid;
      allow create: if request.auth != null;
    }
    match /visits/{visitId} {
      allow read, write: if request.auth != null;
    }
    match /prescriptions/{prescriptionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

5. Set up Storage Security Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /patients/{patientId}/documents/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### 4. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Copy environment template
cp .env.example .env

# Edit .env with your configuration
```

Edit the `.env` file with your values:
```env
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://localhost:27017/homeocare
JWT_SECRET=your_super_secret_key_here
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
```

To get Firebase Admin SDK credentials:
1. Go to Firebase Console > Project Settings > Service Accounts
2. Click "Generate New Private Key"
3. Copy the values to your .env file

#### 5. Start the Backend Server

```bash
# Development mode with hot reload
npm run dev

# Production mode
npm start
```

#### 6. Run the Flutter App

```bash
# Run on connected device or emulator
flutter run

# Run on specific device
flutter run -d <device_id>

# Run in release mode
flutter run --release
```

## 📂 Project Structure

```
homeocare/
├── lib/
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart          # App configuration constants
│   │   ├── theme/
│   │   │   ├── app_colors.dart          # Color palette
│   │   │   ├── app_text_styles.dart     # Typography
│   │   │   └── app_theme.dart           # Theme configuration
│   │   └── utils/
│   │       └── helpers.dart             # Utility functions
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart          # User data model
│   │   │   ├── patient_model.dart       # Patient data model
│   │   │   ├── visit_model.dart         # Visit data model
│   │   │   └── prescription_model.dart  # Prescription data model
│   │   └── services/
│   │       ├── auth_service.dart        # Firebase Auth service
│   │       ├── patient_service.dart     # Patient CRUD operations
│   │       ├── visit_service.dart       # Visit CRUD operations
│   │       ├── prescription_service.dart# Prescription operations
│   │       └── storage_service.dart     # Firebase Storage service
│   ├── providers/
│   │   ├── auth_provider.dart           # Authentication state
│   │   ├── patient_provider.dart        # Patient state management
│   │   ├── visit_provider.dart          # Visit state management
│   │   └── prescription_provider.dart   # Prescription state management
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── welcome_screen.dart      # Welcome/splash screen
│   │   │   ├── get_started_screen.dart  # Onboarding screens
│   │   │   ├── auth/
│   │   │   │   └── login_screen.dart    # Login/Signup screen
│   │   │   ├── dashboard/
│   │   │   │   └── dashboard_screen.dart# Main dashboard
│   │   │   ├── patient/
│   │   │   │   ├── new_patient_screen.dart
│   │   │   │   ├── patient_details_screen.dart
│   │   │   │   └── tabs/                # Patient detail tabs
│   │   │   ├── visit/
│   │   │   │   ├── new_visit_screen.dart
│   │   │   │   └── visit_details_screen.dart
│   │   │   └── profile/
│   │   │       └── profile_screen.dart
│   │   └── widgets/
│   │       ├── common_widgets.dart      # Reusable UI components
│   │       └── patient_card.dart        # Patient list card
│   ├── firebase_options.dart            # Firebase configuration
│   └── main.dart                        # App entry point
├── backend/
│   ├── src/
│   │   ├── config/
│   │   │   └── firebase.js              # Firebase Admin config
│   │   ├── middleware/
│   │   │   ├── auth.js                  # JWT/Firebase auth middleware
│   │   │   └── errorHandler.js          # Global error handler
│   │   ├── models/
│   │   │   ├── User.js                  # User MongoDB model
│   │   │   ├── Patient.js               # Patient MongoDB model
│   │   │   ├── Visit.js                 # Visit MongoDB model
│   │   │   └── Prescription.js          # Prescription MongoDB model
│   │   ├── routes/
│   │   │   ├── auth.routes.js           # Authentication endpoints
│   │   │   ├── patient.routes.js        # Patient CRUD endpoints
│   │   │   ├── visit.routes.js          # Visit CRUD endpoints
│   │   │   ├── prescription.routes.js   # Prescription endpoints
│   │   │   └── user.routes.js           # User profile endpoints
│   │   └── server.js                    # Express server entry
│   ├── package.json
│   └── .env.example
├── pubspec.yaml
└── README.md
```

## 🔌 API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/signup` | Register new user |
| POST | `/api/auth/signin` | Login user |
| POST | `/api/auth/refresh` | Refresh access token |
| POST | `/api/auth/signout` | Logout user |
| GET | `/api/auth/me` | Get current user |
| POST | `/api/auth/forgot-password` | Request password reset |

### Patients
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/patients` | Get all patients |
| GET | `/api/patients/today` | Get today's appointments |
| GET | `/api/patients/:id` | Get single patient |
| POST | `/api/patients` | Create new patient |
| PUT | `/api/patients/:id` | Update patient |
| DELETE | `/api/patients/:id` | Delete patient |
| POST | `/api/patients/:id/documents` | Add document |
| DELETE | `/api/patients/:id/documents` | Remove document |

### Visits
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/visits` | Get all visits |
| GET | `/api/visits/:id` | Get single visit |
| POST | `/api/visits` | Create new visit |
| PUT | `/api/visits/:id` | Update visit |
| DELETE | `/api/visits/:id` | Delete visit |

### Prescriptions
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/prescriptions` | Get all prescriptions |
| GET | `/api/prescriptions/:id` | Get single prescription |
| POST | `/api/prescriptions` | Create prescription |
| PUT | `/api/prescriptions/:id` | Update prescription |
| DELETE | `/api/prescriptions/:id` | Delete prescription |

### Users
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users/profile` | Get user profile |
| PUT | `/api/users/profile` | Update profile |
| PUT | `/api/users/change-password` | Change password |
| DELETE | `/api/users/account` | Deactivate account |

## 📦 Dependencies

### Flutter
- **provider**: State management
- **firebase_core, firebase_auth, cloud_firestore, firebase_storage**: Firebase services
- **dio, http**: HTTP client
- **pdf, printing**: PDF generation and printing
- **file_picker, image_picker**: File selection
- **flutter_animate**: Smooth animations
- **google_fonts**: Custom typography
- **fluttertoast**: Toast notifications
- **url_launcher**: Open URLs and make calls
- **intl**: Date formatting
- **connectivity_plus**: Network status

### Backend
- **express**: Web framework
- **mongoose**: MongoDB ODM
- **jsonwebtoken**: JWT authentication
- **bcryptjs**: Password hashing
- **firebase-admin**: Firebase Admin SDK
- **helmet, cors**: Security middleware
- **express-validator**: Input validation
- **morgan**: HTTP logging

## 🔧 Configuration

### App Configuration (`lib/core/config/app_config.dart`)
- API base URL
- Firebase collection names
- Validation patterns
- File size limits
- Supported file types

### Theme Configuration
- Primary color: Medical Blue (#2563EB)
- Secondary color: Medical Green (#10B981)
- Accent color: Purple (#8B5CF6)
- Material Design 3 support
- Light and dark themes

## 📝 License

This project is licensed under the MIT License.

## 👥 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For support, email support@homeocare.app or open an issue in the repository.

---

Made with ❤️ for Homeopathic Practitioners
