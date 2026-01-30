import 'package:cloud_firestore/cloud_firestore.dart';
import 'visit_model.dart';

/// Prescription model for patient medications
class PrescriptionModel {
  final String id;
  final String patientId;
  final String visitId;
  final DateTime prescriptionDate;
  final String? diagnosis;
  final List<Medicine> medicines;
  final String? notes;
  final DateTime createdAt;

  PrescriptionModel({
    required this.id,
    required this.patientId,
    required this.visitId,
    required this.prescriptionDate,
    this.diagnosis,
    required this.medicines,
    this.notes,
    required this.createdAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      visitId: json['visitId'] as String,
      prescriptionDate: json['prescriptionDate'] is Timestamp
          ? (json['prescriptionDate'] as Timestamp).toDate()
          : DateTime.parse(json['prescriptionDate'] as String),
      diagnosis: json['diagnosis'] as String?,
      medicines:
          (json['medicines'] as List<dynamic>?)
              ?.map((e) => Medicine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'visitId': visitId,
      'prescriptionDate': Timestamp.fromDate(prescriptionDate),
      'diagnosis': diagnosis,
      'medicines': medicines.map((e) => e.toJson()).toList(),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PrescriptionModel copyWith({
    String? id,
    String? patientId,
    String? visitId,
    DateTime? prescriptionDate,
    String? diagnosis,
    List<Medicine>? medicines,
    String? notes,
    DateTime? createdAt,
  }) {
    return PrescriptionModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      visitId: visitId ?? this.visitId,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
      diagnosis: diagnosis ?? this.diagnosis,
      medicines: medicines ?? this.medicines,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
