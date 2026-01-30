import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

/// Patient Provider for managing patient state
class PatientProvider extends ChangeNotifier {
  final PatientService _patientService = PatientService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  List<PatientModel> _patients = [];
  List<PatientModel> _filteredPatients = [];
  List<PatientModel> _todayAppointments = [];
  PatientModel? _selectedPatient;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<PatientModel> get patients =>
      _filteredPatients.isEmpty && _searchQuery.isEmpty
      ? _patients
      : _filteredPatients;
  List<PatientModel> get filteredPatients =>
      _searchQuery.isEmpty ? _patients : _filteredPatients;
  List<PatientModel> get todayPatients => _todayAppointments;
  List<PatientModel> get todayAppointments => _todayAppointments;
  PatientModel? get selectedPatient => _selectedPatient;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage; // Alias for errorMessage
  String get searchQuery => _searchQuery;

  /// Load all patients
  Future<void> loadPatients([String? userId]) async {
    final uid = userId ?? _userId;
    if (uid == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _patients = await _patientService.getAllPatients(uid);
      _filteredPatients = [];
      _searchQuery = '';
    } catch (e) {
      _errorMessage = 'Failed to load patients';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load today's appointments
  Future<void> loadTodayAppointments([String? userId]) async {
    final uid = userId ?? _userId;
    if (uid == null) return;

    try {
      _todayAppointments = await _patientService.getTodayAppointments(uid);
      notifyListeners();
    } catch (e) {
      // Silently fail
    }
  }

  /// Search patients
  Future<void> searchPatients(String query, [String? userId]) async {
    final uid = userId ?? _userId;
    if (uid == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _searchQuery = query;

    if (query.isEmpty) {
      _filteredPatients = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _filteredPatients = await _patientService.searchPatients(uid, query);
    } catch (e) {
      _errorMessage = 'Search failed';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create patient
  Future<PatientModel?> createPatient(PatientModel patient) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newPatient = await _patientService.createPatient(patient);
      if (newPatient != null) {
        _patients.insert(0, newPatient);
      }
      _isLoading = false;
      notifyListeners();
      return newPatient;
    } catch (e) {
      _errorMessage = 'Failed to create patient';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update patient
  Future<bool> updatePatient(PatientModel patient) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _patientService.updatePatient(patient);
      if (success) {
        final index = _patients.indexWhere((p) => p.id == patient.id);
        if (index != -1) {
          _patients[index] = patient;
        }
        if (_selectedPatient?.id == patient.id) {
          _selectedPatient = patient;
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update patient';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete patient
  Future<bool> deletePatient(String patientId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _patientService.deletePatient(patientId);
      if (success) {
        _patients.removeWhere((p) => p.id == patientId);
        if (_selectedPatient?.id == patientId) {
          _selectedPatient = null;
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete patient';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Select patient
  Future<void> selectPatient(String patientId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedPatient = await _patientService.getPatientById(patientId);
    } catch (e) {
      _errorMessage = 'Failed to load patient details';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear selected patient
  void clearSelectedPatient() {
    _selectedPatient = null;
    notifyListeners();
  }

  /// Upload document for patient
  Future<PatientDocument?> uploadDocument({
    required String patientId,
    required File file,
    required String fileName,
  }) async {
    try {
      final document = await _storageService.uploadFile(
        patientId: patientId,
        file: file,
        fileName: fileName,
      );

      if (document != null) {
        await _patientService.addPatientDocument(patientId, document);

        // Update local state
        if (_selectedPatient?.id == patientId) {
          final updatedDocs = [..._selectedPatient!.documents, document];
          _selectedPatient = _selectedPatient!.copyWith(documents: updatedDocs);
          notifyListeners();
        }
      }

      return document;
    } catch (e) {
      return null;
    }
  }

  /// Delete document
  Future<bool> deleteDocument({
    required String patientId,
    required PatientDocument document,
  }) async {
    try {
      await _storageService.deleteFile(document.fileUrl);
      await _patientService.removePatientDocument(patientId, document);

      // Update local state
      if (_selectedPatient?.id == patientId) {
        final updatedDocs = _selectedPatient!.documents
            .where((d) => d.id != document.id)
            .toList();
        _selectedPatient = _selectedPatient!.copyWith(documents: updatedDocs);
        notifyListeners();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sort patients
  void sortPatients(String sortBy, bool ascending) {
    final listToSort = _searchQuery.isEmpty ? _patients : _filteredPatients;

    listToSort.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'name':
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 'lastVisit':
          final aDate = a.lastVisitDate ?? DateTime(1970);
          final bDate = b.lastVisitDate ?? DateTime(1970);
          comparison = aDate.compareTo(bDate);
          break;
        case 'createdAt':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
      }
      return ascending ? comparison : -comparison;
    });

    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredPatients = [];
    notifyListeners();
  }
}
