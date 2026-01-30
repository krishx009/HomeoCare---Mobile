/// Application configuration constants
class AppConfig {
  // App Info
  static const String appName = 'Homeocare';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Trusted Homeopathic Care Partner';

  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String patientsCollection = 'patients';
  static const String visitsCollection = 'visits';
  static const String prescriptionsCollection = 'prescriptions';

  // Firebase Storage Paths
  static const String patientDocumentsPath = 'patients';

  // Supported Document Types
  static const List<String> supportedDocumentExtensions = [
    'pdf',
    'doc',
    'docx',
    'jpg',
    'jpeg',
    'png',
    'dcm', // DICOM
    'xml',
  ];

  // File Size Limits (in bytes)
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB

  // Pagination
  static const int defaultPageSize = 20;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 24);

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Validation Patterns
  static final RegExp emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phonePattern = RegExp(r'^\+?[1-9]\d{9,14}$');
  static final RegExp namePattern = RegExp(r'^[a-zA-Z\s]{2,50}$');
}
