import 'package:cloud_firestore/cloud_firestore.dart';

/// Gender enum for patient
enum Gender { male, female, other }

/// Extension to convert Gender to/from string
extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  static Gender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.other;
    }
  }
}

/// Vitals model for patient health measurements
class Vitals {
  final double? height; // in cm
  final double? weight; // in kg
  final double? temperature; // in Celsius
  final int? systolicBP;
  final int? diastolicBP;
  final int? heartRate; // BPM

  Vitals({
    this.height,
    this.weight,
    this.temperature,
    this.systolicBP,
    this.diastolicBP,
    this.heartRate,
  });

  factory Vitals.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Vitals();
    return Vitals(
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      systolicBP: json['systolicBP'] as int?,
      diastolicBP: json['diastolicBP'] as int?,
      heartRate: json['heartRate'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'temperature': temperature,
      'systolicBP': systolicBP,
      'diastolicBP': diastolicBP,
      'heartRate': heartRate,
    };
  }

  // BMI Calculation
  double? get bmi {
    if (height != null && weight != null && height! > 0) {
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  String get bloodPressure {
    if (systolicBP != null && diastolicBP != null) {
      return '$systolicBP/$diastolicBP mmHg';
    }
    return 'N/A';
  }

  /// Check if any vitals are recorded
  bool get hasAnyVitals {
    return height != null ||
        weight != null ||
        temperature != null ||
        systolicBP != null ||
        diastolicBP != null ||
        heartRate != null;
  }

  Vitals copyWith({
    double? height,
    double? weight,
    double? temperature,
    int? systolicBP,
    int? diastolicBP,
    int? heartRate,
  }) {
    return Vitals(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      temperature: temperature ?? this.temperature,
      systolicBP: systolicBP ?? this.systolicBP,
      diastolicBP: diastolicBP ?? this.diastolicBP,
      heartRate: heartRate ?? this.heartRate,
    );
  }
}

/// Document model for patient files
class PatientDocument {
  final String id;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize; // in bytes
  final DateTime uploadedAt;

  PatientDocument({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
  });

  factory PatientDocument.fromJson(Map<String, dynamic> json) {
    return PatientDocument(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
      uploadedAt: json['uploadedAt'] is Timestamp
          ? (json['uploadedAt'] as Timestamp).toDate()
          : DateTime.parse(json['uploadedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Alias for fileName (used by UI)
  String get name => fileName;

  /// Alias for fileUrl (used by UI)
  String get url => fileUrl;
}

/// Patient model
class PatientModel {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final Gender gender;
  final String contactNumber1;
  final String? contactNumber2;
  final String? medicalHistory;
  final String? chiefComplaint;
  final Vitals vitals;
  final List<PatientDocument> documents;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastVisitDate;
  final DateTime? nextAppointment;
  final int totalVisits;

  PatientModel({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.contactNumber1,
    this.contactNumber2,
    this.medicalHistory,
    this.chiefComplaint,
    required this.vitals,
    this.documents = const [],
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.lastVisitDate,
    this.nextAppointment,
    this.totalVisits = 0,
  });

  /// Calculate age from date of birth
  int get age {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      years--;
    }
    return years;
  }

  /// Get primary phone (alias for contactNumber1)
  String get phone => contactNumber1;

  /// Get age in years and months format
  String get ageFormatted {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    int months = now.month - dateOfBirth.month;

    if (now.day < dateOfBirth.day) {
      months--;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) {
      return months > 0 ? '$years yrs $months mo' : '$years yrs';
    } else {
      return '$months mo';
    }
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] is Timestamp
          ? (json['dateOfBirth'] as Timestamp).toDate()
          : DateTime.parse(json['dateOfBirth'] as String),
      gender: GenderExtension.fromString(json['gender'] as String),
      contactNumber1: json['contactNumber1'] as String,
      contactNumber2: json['contactNumber2'] as String?,
      medicalHistory: json['medicalHistory'] as String?,
      chiefComplaint: json['chiefComplaint'] as String?,
      vitals: Vitals.fromJson(json['vitals'] as Map<String, dynamic>?),
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((e) => PatientDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdBy: json['createdBy'] as String,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp
                ? (json['updatedAt'] as Timestamp).toDate()
                : DateTime.parse(json['updatedAt'] as String))
          : null,
      lastVisitDate: json['lastVisitDate'] != null
          ? (json['lastVisitDate'] is Timestamp
                ? (json['lastVisitDate'] as Timestamp).toDate()
                : DateTime.parse(json['lastVisitDate'] as String))
          : null,
      nextAppointment: json['nextAppointment'] != null
          ? (json['nextAppointment'] is Timestamp
                ? (json['nextAppointment'] as Timestamp).toDate()
                : DateTime.parse(json['nextAppointment'] as String))
          : null,
      totalVisits: json['totalVisits'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender.displayName.toLowerCase(),
      'contactNumber1': contactNumber1,
      'contactNumber2': contactNumber2,
      'medicalHistory': medicalHistory,
      'chiefComplaint': chiefComplaint,
      'vitals': vitals.toJson(),
      'documents': documents.map((e) => e.toJson()).toList(),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastVisitDate': lastVisitDate != null
          ? Timestamp.fromDate(lastVisitDate!)
          : null,
      'nextAppointment': nextAppointment != null
          ? Timestamp.fromDate(nextAppointment!)
          : null,
      'totalVisits': totalVisits,
    };
  }

  PatientModel copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    Gender? gender,
    String? contactNumber1,
    String? contactNumber2,
    String? medicalHistory,
    String? chiefComplaint,
    Vitals? vitals,
    List<PatientDocument>? documents,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastVisitDate,
    DateTime? nextAppointment,
    int? totalVisits,
  }) {
    return PatientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      contactNumber1: contactNumber1 ?? this.contactNumber1,
      contactNumber2: contactNumber2 ?? this.contactNumber2,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      vitals: vitals ?? this.vitals,
      documents: documents ?? this.documents,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      nextAppointment: nextAppointment ?? this.nextAppointment,
      totalVisits: totalVisits ?? this.totalVisits,
    );
  }
}
