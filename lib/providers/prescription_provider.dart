import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

/// Prescription Provider for managing prescription state
class PrescriptionProvider extends ChangeNotifier {
  final PrescriptionService _prescriptionService = PrescriptionService();

  List<PrescriptionModel> _prescriptions = [];
  PrescriptionModel? _selectedPrescription;
  bool _isLoading = false;
  String? _errorMessage;

  List<PrescriptionModel> get prescriptions => _prescriptions;
  PrescriptionModel? get selectedPrescription => _selectedPrescription;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load prescriptions for a patient
  Future<void> loadPrescriptions(String patientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _prescriptions = await _prescriptionService.getPatientPrescriptions(
        patientId,
      );
    } catch (e) {
      _errorMessage = 'Failed to load prescriptions';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create prescription
  Future<PrescriptionModel?> createPrescription(
    PrescriptionModel prescription,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newPrescription = await _prescriptionService.createPrescription(
        prescription,
      );
      if (newPrescription != null) {
        _prescriptions.insert(0, newPrescription);
      }
      _isLoading = false;
      notifyListeners();
      return newPrescription;
    } catch (e) {
      _errorMessage = 'Failed to create prescription';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update prescription
  Future<bool> updatePrescription(PrescriptionModel prescription) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _prescriptionService.updatePrescription(
        prescription,
      );
      if (success) {
        final index = _prescriptions.indexWhere((p) => p.id == prescription.id);
        if (index != -1) {
          _prescriptions[index] = prescription;
        }
        if (_selectedPrescription?.id == prescription.id) {
          _selectedPrescription = prescription;
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update prescription';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete prescription
  Future<bool> deletePrescription(String prescriptionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _prescriptionService.deletePrescription(
        prescriptionId,
      );
      if (success) {
        _prescriptions.removeWhere((p) => p.id == prescriptionId);
        if (_selectedPrescription?.id == prescriptionId) {
          _selectedPrescription = null;
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete prescription';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Select prescription
  Future<void> selectPrescription(String prescriptionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedPrescription = await _prescriptionService.getPrescriptionById(
        prescriptionId,
      );
    } catch (e) {
      _errorMessage = 'Failed to load prescription details';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get prescriptions for a visit
  Future<List<PrescriptionModel>> getVisitPrescriptions(String visitId) async {
    try {
      return await _prescriptionService.getVisitPrescriptions(visitId);
    } catch (e) {
      return [];
    }
  }

  /// Get prescriptions by date range
  Future<List<PrescriptionModel>> getPrescriptionsByDateRange(
    String patientId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _prescriptionService.getPrescriptionsByDateRange(
        patientId,
        startDate,
        endDate,
      );
    } catch (e) {
      return [];
    }
  }

  /// Clear prescriptions
  void clearPrescriptions() {
    _prescriptions = [];
    _selectedPrescription = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
