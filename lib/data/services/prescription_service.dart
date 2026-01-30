import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Prescription Firestore Service
class PrescriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference
  CollectionReference<Map<String, dynamic>> get _prescriptionsCollection =>
      _firestore.collection('prescriptions');

  /// Create a new prescription
  Future<PrescriptionModel?> createPrescription(
    PrescriptionModel prescription,
  ) async {
    try {
      final docRef = _prescriptionsCollection.doc();
      final newPrescription = prescription.copyWith(id: docRef.id);
      await docRef.set(newPrescription.toJson());
      return newPrescription;
    } catch (e) {
      return null;
    }
  }

  /// Get all prescriptions for a patient
  Future<List<PrescriptionModel>> getPatientPrescriptions(
    String patientId,
  ) async {
    try {
      final querySnapshot = await _prescriptionsCollection
          .where('patientId', isEqualTo: patientId)
          .orderBy('prescriptionDate', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => PrescriptionModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get prescriptions stream for a patient
  Stream<List<PrescriptionModel>> getPatientPrescriptionsStream(
    String patientId,
  ) {
    return _prescriptionsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('prescriptionDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    PrescriptionModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  /// Get prescription by ID
  Future<PrescriptionModel?> getPrescriptionById(String prescriptionId) async {
    try {
      final doc = await _prescriptionsCollection.doc(prescriptionId).get();
      if (doc.exists) {
        return PrescriptionModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get prescriptions for a specific visit
  Future<List<PrescriptionModel>> getVisitPrescriptions(String visitId) async {
    try {
      final querySnapshot = await _prescriptionsCollection
          .where('visitId', isEqualTo: visitId)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => PrescriptionModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Update prescription
  Future<bool> updatePrescription(PrescriptionModel prescription) async {
    try {
      await _prescriptionsCollection.doc(prescription.id).update({
        ...prescription.toJson(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete prescription
  Future<bool> deletePrescription(String prescriptionId) async {
    try {
      await _prescriptionsCollection.doc(prescriptionId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get prescriptions by date range
  Future<List<PrescriptionModel>> getPrescriptionsByDateRange(
    String patientId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _prescriptionsCollection
          .where('patientId', isEqualTo: patientId)
          .where(
            'prescriptionDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where(
            'prescriptionDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate),
          )
          .orderBy('prescriptionDate', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => PrescriptionModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }
}
