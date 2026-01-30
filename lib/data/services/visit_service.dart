import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Visit Firestore Service
class VisitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference
  CollectionReference<Map<String, dynamic>> get _visitsCollection =>
      _firestore.collection('visits');

  /// Create a new visit
  Future<VisitModel?> createVisit(VisitModel visit) async {
    try {
      final docRef = _visitsCollection.doc();
      final newVisit = visit.copyWith(id: docRef.id);
      await docRef.set(newVisit.toJson());

      // Update patient's last visit date and total visits
      await _firestore.collection('patients').doc(visit.patientId).update({
        'lastVisitDate': Timestamp.fromDate(visit.visitDate),
        'totalVisits': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });

      return newVisit;
    } catch (e) {
      return null;
    }
  }

  /// Get all visits for a patient
  Future<List<VisitModel>> getPatientVisits(String patientId) async {
    try {
      final querySnapshot = await _visitsCollection
          .where('patientId', isEqualTo: patientId)
          .orderBy('visitDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => VisitModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get visits stream for a patient
  Stream<List<VisitModel>> getPatientVisitsStream(String patientId) {
    return _visitsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('visitDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VisitModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  /// Get visit by ID
  Future<VisitModel?> getVisitById(String visitId) async {
    try {
      final doc = await _visitsCollection.doc(visitId).get();
      if (doc.exists) {
        return VisitModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update visit
  Future<bool> updateVisit(VisitModel visit) async {
    try {
      await _visitsCollection.doc(visit.id).update({
        ...visit.toJson(),
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete visit
  Future<bool> deleteVisit(String visitId, String patientId) async {
    try {
      await _visitsCollection.doc(visitId).delete();

      // Update patient's total visits
      await _firestore.collection('patients').doc(patientId).update({
        'totalVisits': FieldValue.increment(-1),
        'updatedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get visits by date range
  Future<List<VisitModel>> getVisitsByDateRange(
    String patientId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _visitsCollection
          .where('patientId', isEqualTo: patientId)
          .where(
            'visitDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('visitDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('visitDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => VisitModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add prescription to visit
  Future<bool> addPrescriptionToVisit(String visitId, Medicine medicine) async {
    try {
      await _visitsCollection.doc(visitId).update({
        'prescriptions': FieldValue.arrayUnion([medicine.toJson()]),
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
