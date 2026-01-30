// File: lib/presentation/screens/patient/new_patient_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/models.dart';
import '../../../providers/providers.dart';
import '../../widgets/ui_components.dart';

/// Multi-step Patient Registration Screen with Material Design 3
class NewPatientScreen extends StatefulWidget {
  final PatientModel? patient;

  const NewPatientScreen({super.key, this.patient});

  @override
  State<NewPatientScreen> createState() => _NewPatientScreenState();
}

class _NewPatientScreenState extends State<NewPatientScreen> {
  final _pageController = PageController();

  // Current step (0-indexed)
  int _currentStep = 0;
  static const int _totalSteps = 5;

  // Form controllers - Step 1: Basic Details
  final _nameController = TextEditingController();
  final _contact1Controller = TextEditingController();
  final _contact2Controller = TextEditingController();

  // Step 2: Medical History
  final _medicalHistoryController = TextEditingController();
  final _chiefComplaintController = TextEditingController();

  // Step 3: Vitals
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _systolicBPController = TextEditingController();
  final _diastolicBPController = TextEditingController();
  final _heartRateController = TextEditingController();

  // State
  DateTime? _selectedDOB;
  Gender _selectedGender = Gender.male;
  List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;

  bool get isEditing => widget.patient != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final patient = widget.patient!;
    _nameController.text = patient.name;
    _selectedDOB = patient.dateOfBirth;
    _selectedGender = patient.gender;
    _contact1Controller.text = patient.contactNumber1;
    _contact2Controller.text = patient.contactNumber2 ?? '';
    _medicalHistoryController.text = patient.medicalHistory ?? '';
    _chiefComplaintController.text = patient.chiefComplaint ?? '';

    if (patient.vitals.height != null) {
      _heightController.text = patient.vitals.height.toString();
    }
    if (patient.vitals.weight != null) {
      _weightController.text = patient.vitals.weight.toString();
    }
    if (patient.vitals.temperature != null) {
      _temperatureController.text = patient.vitals.temperature.toString();
    }
    if (patient.vitals.systolicBP != null) {
      _systolicBPController.text = patient.vitals.systolicBP.toString();
    }
    if (patient.vitals.diastolicBP != null) {
      _diastolicBPController.text = patient.vitals.diastolicBP.toString();
    }
    if (patient.vitals.heartRate != null) {
      _heartRateController.text = patient.vitals.heartRate.toString();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _contact1Controller.dispose();
    _contact2Controller.dispose();
    _medicalHistoryController.dispose();
    _chiefComplaintController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }

  String get _ageDisplay {
    if (_selectedDOB == null) return '';
    final age = AppDateUtils.calculateAge(_selectedDOB!);
    if (age['years']! > 0) {
      return '${age['years']} years ${age['months']} months';
    }
    return '${age['months']} months ${age['days']} days';
  }

  String get _stepTitle {
    switch (_currentStep) {
      case 0:
        return 'Basic Details';
      case 1:
        return 'Medical History';
      case 2:
        return 'Body Metrics';
      case 3:
        return 'Documents';
      case 4:
        return 'Review & Submit';
      default:
        return '';
    }
  }

  String get _stepDescription {
    switch (_currentStep) {
      case 0:
        return "Please enter the patient's personal information.";
      case 1:
        return "Enter medical history and current complaints.";
      case 2:
        return "Record the patient's vital measurements.";
      case 3:
        return "Upload relevant medical documents.";
      case 4:
        return "Review all information before saving.";
      default:
        return '';
    }
  }

  Future<void> _selectDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDOB ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDOB = picked);
    }
  }

  Future<void> _pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: AppConfig.supportedDocumentExtensions,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to pick files');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_nameController.text.trim().isEmpty) {
          Fluttertoast.showToast(msg: 'Please enter patient name');
          return false;
        }
        if (_selectedDOB == null) {
          Fluttertoast.showToast(msg: 'Please select date of birth');
          return false;
        }
        if (_contact1Controller.text.trim().isEmpty) {
          Fluttertoast.showToast(msg: 'Please enter contact number');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _savePatient() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final patientProvider = context.read<PatientProvider>();

      final vitals = Vitals(
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        temperature: double.tryParse(_temperatureController.text),
        systolicBP: int.tryParse(_systolicBPController.text),
        diastolicBP: int.tryParse(_diastolicBPController.text),
        heartRate: int.tryParse(_heartRateController.text),
      );

      final patient = PatientModel(
        id: isEditing ? widget.patient!.id : '',
        name: _nameController.text.trim(),
        dateOfBirth: _selectedDOB!,
        gender: _selectedGender,
        contactNumber1: _contact1Controller.text.trim(),
        contactNumber2: _contact2Controller.text.trim().isNotEmpty
            ? _contact2Controller.text.trim()
            : null,
        medicalHistory: _medicalHistoryController.text.trim().isNotEmpty
            ? _medicalHistoryController.text.trim()
            : null,
        chiefComplaint: _chiefComplaintController.text.trim().isNotEmpty
            ? _chiefComplaintController.text.trim()
            : null,
        vitals: vitals,
        documents: isEditing ? widget.patient!.documents : [],
        createdBy: authProvider.user!.id,
        createdAt: isEditing ? widget.patient!.createdAt : DateTime.now(),
        updatedAt: isEditing ? DateTime.now() : null,
      );

      PatientModel? savedPatient;
      if (isEditing) {
        final success = await patientProvider.updatePatient(patient);
        if (success) savedPatient = patient;
      } else {
        savedPatient = await patientProvider.createPatient(patient);
      }

      if (savedPatient != null) {
        for (final file in _selectedFiles) {
          if (file.path != null) {
            await patientProvider.uploadDocument(
              patientId: savedPatient.id,
              file: File(file.path!),
              fileName: file.name,
            );
          }
        }

        if (mounted) {
          Fluttertoast.showToast(
            msg: isEditing
                ? 'Patient updated successfully!'
                : 'Patient registered successfully!',
            backgroundColor: AppTheme.success,
          );
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Failed to save patient');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to save patient: ${e.toString()}',
        backgroundColor: AppTheme.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('Are you sure you want to discard the changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _showCancelConfirmation,
        ),
        title: Text(isEditing ? 'Edit Patient' : 'New Patient'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Saving patient...',
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Column(
                  children: [
                    StepProgressIndicator(
                      totalSteps: _totalSteps,
                      currentStep: _currentStep,
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _stepTitle,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _stepDescription,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 18),

              // Form pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildBasicDetailsStep(),
                    _buildMedicalHistoryStep(),
                    _buildVitalsStep(),
                    _buildDocumentsStep(),
                    _buildReviewStep(),
                  ],
                ),
              ),

              // Bottom action bar
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: context.surfaceColor.withOpacity(0.96),
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.textPrimary,
                    side: BorderSide(color: context.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          if (!isFirstStep) const SizedBox(width: 12),
          Expanded(
            flex: isFirstStep ? 1 : 2,
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: isLastStep ? _savePatient : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.textPrimaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastStep
                          ? (isEditing ? 'Update Patient' : 'Save Patient')
                          : 'Next',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    if (!isLastStep) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 1: BASIC DETAILS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBasicDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label: 'Full Name', required: true),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nameController,
            hint: 'Enter full name',
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 16),
          FieldLabel(label: 'Date of Birth', required: true),
          const SizedBox(height: 8),
          _buildDateField(),

          if (_selectedDOB != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cake, size: 16, color: AppTheme.info),
                  const SizedBox(width: 8),
                  Text(
                    'Age: $_ageDisplay',
                    style: TextStyle(
                      color: AppTheme.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          FieldLabel(label: 'Gender', required: true),
          const SizedBox(height: 8),
          GenderSelector(
            selectedGender: _selectedGender.displayName,
            onChanged: (value) {
              setState(() {
                _selectedGender = Gender.values.firstWhere(
                  (g) => g.displayName == value,
                  orElse: () => Gender.male,
                );
              });
            },
          ),

          const SizedBox(height: 16),
          FieldLabel(label: 'Phone Number', required: true),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _contact1Controller,
            hint: '(555) 000-0000',
            keyboardType: TextInputType.phone,
            suffixIcon: Icons.call,
          ),

          const SizedBox(height: 16),
          FieldLabel(label: 'Emergency Contact'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _contact2Controller,
            hint: '(555) 000-0000',
            keyboardType: TextInputType.phone,
            suffixIcon: Icons.emergency,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 2: MEDICAL HISTORY
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMedicalHistoryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label: 'Medical History'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _medicalHistoryController,
            hint: 'Enter medical history, allergies, previous treatments...',
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
          ),

          const SizedBox(height: 16),
          FieldLabel(label: 'Chief Complaint'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _chiefComplaintController,
            hint: 'Enter the main reason for visit...',
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 3: VITALS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildVitalsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: 'Height (cm)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _heightController,
                      hint: '175',
                      keyboardType: TextInputType.number,
                      suffixIcon: Icons.height,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: 'Weight (kg)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _weightController,
                      hint: '70',
                      keyboardType: TextInputType.number,
                      suffixIcon: Icons.monitor_weight,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          FieldLabel(label: 'Temperature (°C)'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _temperatureController,
            hint: '36.5',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixIcon: Icons.thermostat,
          ),

          const SizedBox(height: 16),
          FieldLabel(label: 'Blood Pressure'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _systolicBPController,
                  hint: '120',
                  keyboardType: TextInputType.number,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('/', style: context.textTheme.headlineSmall),
              ),
              Expanded(
                child: _buildTextField(
                  controller: _diastolicBPController,
                  hint: '80',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Text('mmHg', style: context.textTheme.labelMedium),
            ],
          ),

          const SizedBox(height: 16),
          FieldLabel(label: 'Heart Rate (BPM)'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _heartRateController,
            hint: '72',
            keyboardType: TextInputType.number,
            suffixIcon: Icons.favorite,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 4: DOCUMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload button
          InkWell(
            onTap: _pickDocuments,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to upload documents',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PDF, DOC, Images, DICOM',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_selectedFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '${_selectedFiles.length} file${_selectedFiles.length > 1 ? 's' : ''} selected',
              style: context.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            ...List.generate(_selectedFiles.length, (index) {
              final file = _selectedFiles[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getFileIcon(file.extension ?? ''),
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _formatFileSize(file.size),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeFile(index),
                      icon: Icon(Icons.close, color: AppTheme.error),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 5: REVIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewSection(
            title: 'Basic Details',
            icon: Icons.person,
            items: [
              _ReviewItem('Name', _nameController.text),
              _ReviewItem(
                'Date of Birth',
                _selectedDOB != null
                    ? DateFormat('MMM dd, yyyy').format(_selectedDOB!)
                    : 'Not set',
              ),
              _ReviewItem(
                'Age',
                _ageDisplay.isNotEmpty ? _ageDisplay : 'Not set',
              ),
              _ReviewItem('Gender', _selectedGender.displayName),
              _ReviewItem('Phone', _contact1Controller.text),
              if (_contact2Controller.text.isNotEmpty)
                _ReviewItem('Emergency', _contact2Controller.text),
            ],
          ),

          const SizedBox(height: 16),
          _buildReviewSection(
            title: 'Medical Information',
            icon: Icons.medical_information,
            items: [
              _ReviewItem(
                'Medical History',
                _medicalHistoryController.text.isNotEmpty
                    ? _medicalHistoryController.text
                    : 'Not provided',
              ),
              _ReviewItem(
                'Chief Complaint',
                _chiefComplaintController.text.isNotEmpty
                    ? _chiefComplaintController.text
                    : 'Not provided',
              ),
            ],
          ),

          const SizedBox(height: 16),
          _buildReviewSection(
            title: 'Vitals',
            icon: Icons.monitor_heart,
            items: [
              if (_heightController.text.isNotEmpty)
                _ReviewItem('Height', '${_heightController.text} cm'),
              if (_weightController.text.isNotEmpty)
                _ReviewItem('Weight', '${_weightController.text} kg'),
              if (_temperatureController.text.isNotEmpty)
                _ReviewItem('Temperature', '${_temperatureController.text} °C'),
              if (_systolicBPController.text.isNotEmpty &&
                  _diastolicBPController.text.isNotEmpty)
                _ReviewItem(
                  'Blood Pressure',
                  '${_systolicBPController.text}/${_diastolicBPController.text} mmHg',
                ),
              if (_heartRateController.text.isNotEmpty)
                _ReviewItem('Heart Rate', '${_heartRateController.text} BPM'),
            ],
          ),

          if (_selectedFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildReviewSection(
              title: 'Documents',
              icon: Icons.folder,
              items: _selectedFiles
                  .map((f) => _ReviewItem('File', f.name))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewSection({
    required String title,
    required IconData icon,
    required List<_ReviewItem> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      item.label,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: context.cardColor,
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: context.textSecondary)
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDOB,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedDOB != null
                    ? DateFormat('dd/MM/yyyy').format(_selectedDOB!)
                    : 'DD/MM/YYYY',
                style: TextStyle(
                  color: _selectedDOB != null
                      ? context.textPrimary
                      : context.textTertiary,
                ),
              ),
            ),
            Icon(Icons.calendar_month, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ReviewItem {
  final String label;
  final String value;
  const _ReviewItem(this.label, this.value);
}
