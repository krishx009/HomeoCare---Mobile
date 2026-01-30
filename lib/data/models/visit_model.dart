import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_model.dart';

/// Medicine model for prescriptions
class Medicine {
  final String name;
  final String? potency; // For homeopathic medicines (e.g., 30C, 200CH)
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;

  Medicine({
    required this.name,
    this.potency,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] as String,
      potency: json['potency'] as String?,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'potency': potency,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }

  Medicine copyWith({
    String? name,
    String? potency,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
  }) {
    return Medicine(
      name: name ?? this.name,
      potency: potency ?? this.potency,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }
}

/// Visit model for patient visits
class VisitModel {
  final String id;
  final String patientId;
  final DateTime visitDate;
  final String? chiefComplaint;
  final String? symptoms;
  final String? examinationNotes;
  final String? diagnosis;
  final String? treatment;
  final String? notes;
  final DateTime? followUpDate;
  final Vitals vitals;
  final List<Medicine> prescriptions;
  final List<PatientDocument> documents;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VisitModel({
    required this.id,
    required this.patientId,
    required this.visitDate,
    this.chiefComplaint,
    this.symptoms,
    this.examinationNotes,
    this.diagnosis,
    this.treatment,
    this.notes,
    this.followUpDate,
    required this.vitals,
    this.prescriptions = const [],
    this.documents = const [],
    required this.createdAt,
    this.updatedAt,
  });

  /// Alias for prescriptions (used by UI)
  List<Medicine> get medicines => prescriptions;

  /// Alias for examinationNotes (used by UI)
  String? get examination => examinationNotes;

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      visitDate: json['visitDate'] is Timestamp
          ? (json['visitDate'] as Timestamp).toDate()
          : DateTime.parse(json['visitDate'] as String),
      chiefComplaint: json['chiefComplaint'] as String?,
      symptoms: json['symptoms'] as String?,
      examinationNotes: json['examinationNotes'] as String?,
      diagnosis: json['diagnosis'] as String?,
      treatment: json['treatment'] as String?,
      notes: json['notes'] as String?,
      followUpDate: json['followUpDate'] != null
          ? (json['followUpDate'] is Timestamp
                ? (json['followUpDate'] as Timestamp).toDate()
                : DateTime.parse(json['followUpDate'] as String))
          : null,
      vitals: Vitals.fromJson(json['vitals'] as Map<String, dynamic>?),
      prescriptions:
          (json['prescriptions'] as List<dynamic>?)
              ?.map((e) => Medicine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((e) => PatientDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp
                ? (json['updatedAt'] as Timestamp).toDate()
                : DateTime.parse(json['updatedAt'] as String))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'visitDate': Timestamp.fromDate(visitDate),
      'chiefComplaint': chiefComplaint,
      'symptoms': symptoms,
      'examinationNotes': examinationNotes,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'notes': notes,
      'followUpDate': followUpDate != null
          ? Timestamp.fromDate(followUpDate!)
          : null,
      'vitals': vitals.toJson(),
      'prescriptions': prescriptions.map((e) => e.toJson()).toList(),
      'documents': documents.map((e) => e.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  VisitModel copyWith({
    String? id,
    String? patientId,
    DateTime? visitDate,
    String? chiefComplaint,
    String? symptoms,
    String? examinationNotes,
    String? diagnosis,
    String? treatment,
    String? notes,
    DateTime? followUpDate,
    Vitals? vitals,
    List<Medicine>? prescriptions,
    List<PatientDocument>? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VisitModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      visitDate: visitDate ?? this.visitDate,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      symptoms: symptoms ?? this.symptoms,
      examinationNotes: examinationNotes ?? this.examinationNotes,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      notes: notes ?? this.notes,
      followUpDate: followUpDate ?? this.followUpDate,
      vitals: vitals ?? this.vitals,
      prescriptions: prescriptions ?? this.prescriptions,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
