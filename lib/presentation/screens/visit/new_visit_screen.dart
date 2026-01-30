// File: lib/presentation/screens/visit/new_visit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/models.dart';
import '../../../providers/providers.dart';
import '../../widgets/ui_components.dart';

/// New Visit Screen with Material Design 3
class NewVisitScreen extends StatefulWidget {
  final String patientId;
  final VisitModel? visit;

  const NewVisitScreen({super.key, required this.patientId, this.visit});

  @override
  State<NewVisitScreen> createState() => _NewVisitScreenState();
}

class _NewVisitScreenState extends State<NewVisitScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _chiefComplaintController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _examinationController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  // Vitals controllers
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _systolicBPController = TextEditingController();
  final _diastolicBPController = TextEditingController();
  final _heartRateController = TextEditingController();

  // State
  DateTime _visitDate = DateTime.now();
  DateTime? _followUpDate;
  List<Medicine> _medicines = [];
  bool _isLoading = false;

  bool get _isEditing => widget.visit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final visit = widget.visit!;
    _chiefComplaintController.text = visit.chiefComplaint ?? '';
    _symptomsController.text = visit.symptoms ?? '';
    _examinationController.text = visit.examination ?? '';
    _diagnosisController.text = visit.diagnosis ?? '';
    _notesController.text = visit.notes ?? '';
    _visitDate = visit.visitDate;
    _followUpDate = visit.followUpDate;
    _medicines = List.from(visit.medicines);

    final vitals = visit.vitals;
    _heightController.text = vitals.height?.toString() ?? '';
    _weightController.text = vitals.weight?.toString() ?? '';
    _temperatureController.text = vitals.temperature?.toString() ?? '';
    _systolicBPController.text = vitals.systolicBP?.toString() ?? '';
    _diastolicBPController.text = vitals.diastolicBP?.toString() ?? '';
    _heartRateController.text = vitals.heartRate?.toString() ?? '';
  }

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _symptomsController.dispose();
    _examinationController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }

  Future<void> _selectVisitDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_visitDate),
      );
      if (time != null) {
        setState(() {
          _visitDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectFollowUpDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() => _followUpDate = date);
    }
  }

  void _addMedicine() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MedicineFormSheet(
        onSave: (medicine) {
          setState(() => _medicines.add(medicine));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editMedicine(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MedicineFormSheet(
        medicine: _medicines[index],
        onSave: (medicine) {
          setState(() => _medicines[index] = medicine);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _removeMedicine(int index) {
    setState(() => _medicines.removeAt(index));
  }

  Future<void> _saveVisit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_medicines.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please add at least one medicine',
        backgroundColor: AppTheme.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final visitProvider = context.read<VisitProvider>();

      final vitals = Vitals(
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        temperature: double.tryParse(_temperatureController.text),
        systolicBP: int.tryParse(_systolicBPController.text),
        diastolicBP: int.tryParse(_diastolicBPController.text),
        heartRate: int.tryParse(_heartRateController.text),
      );

      if (_isEditing) {
        final updatedVisit = widget.visit!.copyWith(
          chiefComplaint: _chiefComplaintController.text.trim(),
          symptoms: _symptomsController.text.trim().isNotEmpty
              ? _symptomsController.text.trim()
              : null,
          examinationNotes: _examinationController.text.trim().isNotEmpty
              ? _examinationController.text.trim()
              : null,
          diagnosis: _diagnosisController.text.trim().isNotEmpty
              ? _diagnosisController.text.trim()
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          visitDate: _visitDate,
          followUpDate: _followUpDate,
          prescriptions: _medicines,
          vitals: vitals,
        );
        await visitProvider.updateVisit(updatedVisit);
      } else {
        final visit = VisitModel(
          id: '',
          patientId: widget.patientId,
          visitDate: _visitDate,
          chiefComplaint: _chiefComplaintController.text.trim(),
          symptoms: _symptomsController.text.trim().isNotEmpty
              ? _symptomsController.text.trim()
              : null,
          examinationNotes: _examinationController.text.trim().isNotEmpty
              ? _examinationController.text.trim()
              : null,
          diagnosis: _diagnosisController.text.trim().isNotEmpty
              ? _diagnosisController.text.trim()
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          prescriptions: _medicines,
          vitals: vitals,
          followUpDate: _followUpDate,
          createdAt: DateTime.now(),
        );
        await visitProvider.createVisit(visit);
      }

      // Reload patient data to reflect the updated visit info
      await context.read<PatientProvider>().selectPatient(widget.patientId);

      Fluttertoast.showToast(
        msg: _isEditing
            ? 'Visit updated successfully'
            : 'Visit added successfully',
        backgroundColor: AppTheme.success,
      );
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to save visit',
        backgroundColor: AppTheme.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Visit' : 'New Visit')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Saving visit...',
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visit Date
                _buildSectionTitle('Visit Information', Icons.event),
                const SizedBox(height: 12),
                _buildDateSelector(),

                const SizedBox(height: 24),

                // Consultation Details
                _buildSectionTitle(
                  'Consultation Details',
                  Icons.medical_information,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _chiefComplaintController,
                  label: 'Chief Complaint *',
                  hint: 'Main reason for visit',
                  maxLines: 3,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _symptomsController,
                  label: 'Symptoms',
                  hint: 'Describe symptoms in detail',
                  maxLines: 4,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _examinationController,
                  label: 'Examination Findings',
                  hint: 'Physical examination notes',
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _diagnosisController,
                  label: 'Diagnosis',
                  hint: 'Provisional diagnosis',
                  maxLines: 2,
                ),

                const SizedBox(height: 24),

                // Vitals
                _buildSectionTitle('Vitals (Optional)', Icons.monitor_heart),
                const SizedBox(height: 12),
                _buildVitalsSection(),

                const SizedBox(height: 24),

                // Medicines
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('Medicines', Icons.medication),
                    TextButton.icon(
                      onPressed: _addMedicine,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(
                        'Add',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMedicinesSection(),

                const SizedBox(height: 24),

                // Follow-up & Notes
                _buildSectionTitle('Follow-up', Icons.calendar_month),
                const SizedBox(height: 12),
                _buildFollowUpSelector(),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _notesController,
                  label: 'Additional Notes',
                  hint: 'Any additional notes for this visit',
                  maxLines: 3,
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveVisit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.textPrimaryLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Update Visit' : 'Save Visit',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectVisitDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
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
                Icons.calendar_today,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visit Date & Time',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDateUtils.formatDateTime(_visitDate),
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.textTertiary),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 50.ms);
  }

  Widget _buildFollowUpSelector() {
    return InkWell(
      onTap: _selectFollowUpDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.event_available,
                color: AppTheme.info,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Follow-up Date',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _followUpDate != null
                        ? AppDateUtils.formatDate(_followUpDate!)
                        : 'Tap to set',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _followUpDate != null
                          ? context.textPrimary
                          : context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (_followUpDate != null)
              IconButton(
                onPressed: () => setState(() => _followUpDate = null),
                icon: Icon(Icons.close, color: context.textTertiary, size: 20),
              )
            else
              Icon(Icons.chevron_right, color: context.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _heightController,
                label: 'Height (cm)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildTextField(
                controller: _weightController,
                label: 'Weight (kg)',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _temperatureController,
                label: 'Temp (°C)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildTextField(
                controller: _heartRateController,
                label: 'Heart Rate',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _systolicBPController,
                label: 'Systolic BP',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildTextField(
                controller: _diastolicBPController,
                label: 'Diastolic BP',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicinesSection() {
    if (_medicines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          children: [
            Icon(
              Icons.medication_outlined,
              size: 48,
              color: context.textTertiary,
            ),
            const SizedBox(height: 8),
            Text(
              'No medicines added',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _addMedicine,
              child: const Text(
                'Add Medicine',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(_medicines.length, (index) {
        final medicine = _medicines[index];
        return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                onTap: () => _editMedicine(index),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.medication_liquid,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${medicine.name}${medicine.potency != null ? ' ${medicine.potency}' : ''}',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${medicine.dosage} • ${medicine.frequency}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeMedicine(index),
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppTheme.error,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 50 * index))
            .slideX(begin: 0.05);
      }),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: context.cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.error),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MEDICINE FORM BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _MedicineFormSheet extends StatefulWidget {
  final Medicine? medicine;
  final Function(Medicine) onSave;

  const _MedicineFormSheet({this.medicine, required this.onSave});

  @override
  State<_MedicineFormSheet> createState() => _MedicineFormSheetState();
}

class _MedicineFormSheetState extends State<_MedicineFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _potencyController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _nameController.text = widget.medicine!.name;
      _potencyController.text = widget.medicine!.potency ?? '';
      _dosageController.text = widget.medicine!.dosage;
      _frequencyController.text = widget.medicine!.frequency;
      _durationController.text = widget.medicine!.duration;
      _instructionsController.text = widget.medicine!.instructions ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _potencyController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final medicine = Medicine(
      name: _nameController.text.trim(),
      potency: _potencyController.text.trim().isNotEmpty
          ? _potencyController.text.trim()
          : null,
      dosage: _dosageController.text.trim(),
      frequency: _frequencyController.text.trim(),
      duration: _durationController.text.trim(),
      instructions: _instructionsController.text.trim().isNotEmpty
          ? _instructionsController.text.trim()
          : null,
    );

    widget.onSave(medicine);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        18,
        18,
        MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.medication, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    widget.medicine != null ? 'Edit Medicine' : 'Add Medicine',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSheetField(
                controller: _nameController,
                label: 'Medicine Name *',
                hint: 'e.g., Arnica Montana',
                required: true,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildSheetField(
                      controller: _potencyController,
                      label: 'Potency *',
                      hint: 'e.g., 30C',
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildSheetField(
                      controller: _dosageController,
                      label: 'Dosage *',
                      hint: 'e.g., 4 pills',
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildSheetField(
                      controller: _frequencyController,
                      label: 'Frequency',
                      hint: 'e.g., 3x daily',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildSheetField(
                      controller: _durationController,
                      label: 'Duration',
                      hint: 'e.g., 7 days',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _buildSheetField(
                controller: _instructionsController,
                label: 'Instructions',
                hint: 'Special instructions...',
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.textPrimaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    widget.medicine != null
                        ? 'Update Medicine'
                        : 'Add Medicine',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: required
              ? (v) => v?.isEmpty == true ? 'Required' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: context.cardColor,
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
        ),
      ],
    );
  }
}
