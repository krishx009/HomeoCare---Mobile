import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

/// Visit Provider for managing visit state
class VisitProvider extends ChangeNotifier {
  final VisitService _visitService = VisitService();

  List<VisitModel> _visits = [];
  VisitModel? _selectedVisit;
  bool _isLoading = false;
  String? _errorMessage;

  List<VisitModel> get visits => _visits;
  VisitModel? get selectedVisit => _selectedVisit;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load visits for a patient
  Future<void> loadVisits(String patientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _visits = await _visitService.getPatientVisits(patientId);
    } catch (e) {
      _errorMessage = 'Failed to load visits';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create visit
  Future<VisitModel?> createVisit(VisitModel visit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newVisit = await _visitService.createVisit(visit);
      if (newVisit != null) {
        _visits.insert(0, newVisit);
      }
      _isLoading = false;
      notifyListeners();
      return newVisit;
    } catch (e) {
      _errorMessage = 'Failed to create visit';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update visit
  Future<bool> updateVisit(VisitModel visit) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _visitService.updateVisit(visit);
      if (success) {
        final index = _visits.indexWhere((v) => v.id == visit.id);
        if (index != -1) {
          _visits[index] = visit;
        }
        if (_selectedVisit?.id == visit.id) {
          _selectedVisit = visit;
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update visit';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete visit
  Future<bool> deleteVisit(String visitId, String patientId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _visitService.deleteVisit(visitId, patientId);
      if (success) {
        _visits.removeWhere((v) => v.id == visitId);
        if (_selectedVisit?.id == visitId) {
          _selectedVisit = null;
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete visit';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Select visit
  Future<void> selectVisit(String visitId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedVisit = await _visitService.getVisitById(visitId);
    } catch (e) {
      _errorMessage = 'Failed to load visit details';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear selected visit
  void clearSelectedVisit() {
    _selectedVisit = null;
    notifyListeners();
  }

  /// Add prescription to visit
  Future<bool> addPrescription(String visitId, Medicine medicine) async {
    try {
      final success = await _visitService.addPrescriptionToVisit(
        visitId,
        medicine,
      );
      if (success) {
        // Reload the visit
        await selectVisit(visitId);
      }
      return success;
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
      return await _visitService.getVisitsByDateRange(
        patientId,
        startDate,
        endDate,
      );
    } catch (e) {
      return [];
    }
  }

  /// Clear visits
  void clearVisits() {
    _visits = [];
    _selectedVisit = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
