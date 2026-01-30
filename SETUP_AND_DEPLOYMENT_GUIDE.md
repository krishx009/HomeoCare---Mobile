# HomeoCare - Setup and Deployment Guide

This guide provides step-by-step instructions for setting up the development environment, building, and deploying the HomeoCare Flutter application.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Development Environment Setup](#development-environment-setup)
3. [Project Setup](#project-setup)
4. [Firebase Configuration](#firebase-configuration)
5. [Running the App](#running-the-app)
6. [Building for Production](#building-for-production)
7. [Deployment](#deployment)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

| Software | Minimum Version | Recommended Version |
|----------|-----------------|---------------------|
| Flutter SDK | 3.16.0 | 3.24.0+ |
| Dart SDK | 3.2.0 | 3.5.0+ |
| Android Studio | Hedgehog+ | Latest |
| Xcode (macOS only) | 14.0+ | 15.0+ |
| VS Code | 1.80+ | Latest |
| Git | 2.30+ | Latest |

### System Requirements

**Windows:**
- Windows 10 or later (64-bit)
- 8 GB RAM minimum (16 GB recommended)
- 10 GB free disk space

**macOS:**
- macOS 10.15 (Catalina) or later
- 8 GB RAM minimum (16 GB recommended)
- 10 GB free disk space
- Xcode Command Line Tools

---

## Development Environment Setup

### 1. Install Flutter SDK

**Windows:**
```powershell
# Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
# Extract to C:\flutter

# Add to PATH
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", "User")
```

**macOS:**
```bash
# Using Homebrew
brew install flutter

# Or download from https://docs.flutter.dev/get-started/install/macos
# Extract and add to PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. Verify Installation

```bash
flutter doctor -v
```

Ensure all checks pass. Address any issues reported.

### 3. Install IDE Extensions

**VS Code Extensions:**
- Flutter (dart-code.flutter)
- Dart (dart-code.dart-code)
- Flutter Widget Snippets
- Error Lens

**Android Studio Plugins:**
- Flutter Plugin
- Dart Plugin

### 4. Setup Android Development

1. Install Android Studio
2. Open Android Studio → SDK Manager
3. Install:
   - Android SDK Platform 34 (Android 14)
   - Android SDK Build-Tools 34
   - Android SDK Command-line Tools
   - Android Emulator
4. Create an Android Virtual Device (AVD)

### 5. Setup iOS Development (macOS only)

```bash
# Install Xcode from App Store

# Install CocoaPods
sudo gem install cocoapods

# Accept Xcode license
sudo xcodebuild -license accept
```

---

## Project Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd homeocare
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Required Files

```bash
# Generate launcher icons (if applicable)
flutter pub run flutter_launcher_icons

# Generate splash screen (if applicable)
flutter pub run flutter_native_splash:create
```

---

## Firebase Configuration

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project"
3. Enter project name: "HomeoCare"
4. Enable Google Analytics (optional)
5. Create project

### 2. Add Android App

1. In Firebase Console, click "Add App" → Android
2. Enter package name: `com.example.homeocare`
3. Download `google-services.json`
4. Place in `android/app/google-services.json`

### 3. Add iOS App (macOS only)

1. In Firebase Console, click "Add App" → iOS
2. Enter bundle ID: `com.example.homeocare`
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into Runner folder

### 4. Enable Firebase Services

In Firebase Console, enable:
- **Authentication** → Email/Password provider
- **Cloud Firestore** → Create database in production mode
- **Storage** → Initialize with default rules

### 5. Configure FlutterFire

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=your-project-id
```

This generates `lib/firebase_options.dart`.

### 6. Firestore Security Rules

In Firebase Console → Firestore → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /doctors/{doctorId} {
      allow read, write: if request.auth != null && request.auth.uid == doctorId;
      
      match /patients/{patientId} {
        allow read, write: if request.auth != null;
        
        match /visits/{visitId} {
          allow read, write: if request.auth != null;
        }
      }
    }
  }
}
```

---

## Running the App

### Run on Android Emulator

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode (default)
flutter run

# Run in release mode
flutter run --release
```

### Run on iOS Simulator (macOS only)

```bash
# Open iOS folder first time
cd ios && pod install && cd ..

# Run on iOS Simulator
flutter run -d "iPhone 15 Pro"
```

### Run on Chrome (Web)

```bash
flutter run -d chrome
```

### Hot Reload & Hot Restart

- **Hot Reload:** Press `r` in terminal (preserves state)
- **Hot Restart:** Press `R` in terminal (resets state)

---

## Building for Production

### Android APK

```bash
# Build APK
flutter build apk --release

# Build Split APKs (smaller size)
flutter build apk --split-per-abi --release

# Output: build/app/outputs/flutter-apk/
```

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS App (macOS only)

```bash
# Build IPA
flutter build ipa --release

# Output: build/ios/ipa/
```

### Web Build

```bash
flutter build web --release

# Output: build/web/
```

---

## Deployment

### Android - Google Play Store

1. **Create Keystore:**
   ```bash
   keytool -genkey -v -keystore ~/homeocare-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias homeocare
   ```

2. **Configure Signing:**
   Create `android/key.properties`:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=homeocare
   storeFile=<path-to-keystore>/homeocare-keystore.jks
   ```

3. **Update build.gradle:**
   In `android/app/build.gradle`, the signing config should reference key.properties.

4. **Build App Bundle:**
   ```bash
   flutter build appbundle --release
   ```

5. **Upload to Play Console:**
   - Go to [Google Play Console](https://play.google.com/console)
   - Create app → Upload `.aab` file
   - Complete store listing

### iOS - App Store

1. **Configure Xcode:**
   - Open `ios/Runner.xcworkspace`
   - Select Runner → Signing & Capabilities
   - Select your Team
   - Update Bundle Identifier if needed

2. **Build Archive:**
   ```bash
   flutter build ipa --release
   ```

3. **Upload via Xcode:**
   - Open Xcode → Product → Archive
   - Distribute App → App Store Connect

4. **Submit in App Store Connect:**
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Complete app information
   - Submit for review

### Web - Firebase Hosting

1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **Initialize Hosting:**
   ```bash
   firebase init hosting
   # Select: build/web as public directory
   # Configure as single-page app: Yes
   ```

3. **Deploy:**
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

---

## Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues

```bash
# Accept Android licenses
flutter doctor --android-licenses

# Update Flutter
flutter upgrade

# Clean and rebuild
flutter clean
flutter pub get
```

#### 2. Gradle Build Failures

```bash
# Clear Gradle cache
cd android
./gradlew clean
cd ..

# Invalidate caches in Android Studio
File → Invalidate Caches → Invalidate and Restart
```

#### 3. iOS CocoaPods Issues

```bash
cd ios
pod deintegrate
pod cache clean --all
pod install --repo-update
cd ..
```

#### 4. Firebase Connection Issues

- Verify `google-services.json` is in correct location
- Check Firebase project configuration
- Ensure internet connectivity
- Check Firestore rules allow access

#### 5. Build Errors

```bash
# Full clean rebuild
flutter clean
flutter pub cache repair
flutter pub get
flutter run
```

### Performance Tips

1. **Use Release Mode for Testing:**
   ```bash
   flutter run --release
   ```

2. **Profile Mode for Debugging:**
   ```bash
   flutter run --profile
   ```

3. **Analyze Bundle Size:**
   ```bash
   flutter build apk --analyze-size
   ```

---

## Environment Variables

For different environments, create configuration files:

**lib/config/env_config.dart:**
```dart
class EnvConfig {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.homeocare.dev',
  );
}
```

**Run with environment:**
```bash
flutter run --dart-define=PRODUCTION=true --dart-define=API_URL=https://api.homeocare.com
```

---

## Support

For issues or questions:
- Create an issue in the repository
- Check Flutter documentation: https://docs.flutter.dev
- Firebase documentation: https://firebase.google.com/docs

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run in debug mode |
| `flutter run --release` | Run in release mode |
| `flutter build apk` | Build Android APK |
| `flutter build appbundle` | Build Android App Bundle |
| `flutter build ipa` | Build iOS IPA |
| `flutter build web` | Build web app |
| `flutter clean` | Clean build files |
| `flutter doctor` | Check environment |
| `flutter analyze` | Analyze code |
| `flutter test` | Run tests |

---

*Last updated: Phase 2 Completion*
