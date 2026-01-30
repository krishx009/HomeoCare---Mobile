import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Patient Firestore Service
class PatientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference
  CollectionReference<Map<String, dynamic>> get _patientsCollection =>
      _firestore.collection('patients');

  /// Create a new patient
  Future<PatientModel?> createPatient(PatientModel patient) async {
    try {
      final docRef = _patientsCollection.doc();
      final newPatient = patient.copyWith(id: docRef.id);
      await docRef.set(newPatient.toJson());
      return newPatient;
    } catch (e) {
      return null;
    }
  }

  /// Get all patients for a user
  Future<List<PatientModel>> getAllPatients(String userId) async {
    try {
      final querySnapshot = await _patientsCollection
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PatientModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get patients stream
  Stream<List<PatientModel>> getPatientsStream(String userId) {
    return _patientsCollection
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PatientModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  /// Get patient by ID
  Future<PatientModel?> getPatientById(String patientId) async {
    try {
      final doc = await _patientsCollection.doc(patientId).get();
      if (doc.exists) {
        return PatientModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update patient
  Future<bool> updatePatient(PatientModel patient) async {
    try {
      await _patientsCollection.doc(patient.id).update({
        ...patient.toJson(),
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete patient
  Future<bool> deletePatient(String patientId) async {
    try {
      await _patientsCollection.doc(patientId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Search patients by name or phone
  Future<List<PatientModel>> searchPatients(String userId, String query) async {
    try {
      if (query.isEmpty) return getAllPatients(userId);

      final queryLower = query.toLowerCase();

      // Get all patients and filter locally (Firestore doesn't support full-text search)
      final allPatients = await getAllPatients(userId);

      return allPatients.where((patient) {
        return patient.name.toLowerCase().contains(queryLower) ||
            patient.contactNumber1.contains(query) ||
            (patient.contactNumber2?.contains(query) ?? false);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get patients with appointments today
  Future<List<PatientModel>> getTodayAppointments(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get visits for today
      final visitsSnapshot = await _firestore
          .collection('visits')
          .where(
            'visitDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('visitDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      // Get unique patient IDs
      final patientIds = visitsSnapshot.docs
          .map((doc) => doc.data()['patientId'] as String)
          .toSet();

      if (patientIds.isEmpty) return [];

      // Fetch patient details
      final patients = <PatientModel>[];
      for (final patientId in patientIds) {
        final patient = await getPatientById(patientId);
        if (patient != null && patient.createdBy == userId) {
          patients.add(patient);
        }
      }

      return patients;
    } catch (e) {
      return [];
    }
  }

  /// Add document to patient
  Future<bool> addPatientDocument(
    String patientId,
    PatientDocument document,
  ) async {
    try {
      await _patientsCollection.doc(patientId).update({
        'documents': FieldValue.arrayUnion([document.toJson()]),
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove document from patient
  Future<bool> removePatientDocument(
    String patientId,
    PatientDocument document,
  ) async {
    try {
      await _patientsCollection.doc(patientId).update({
        'documents': FieldValue.arrayRemove([document.toJson()]),
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
