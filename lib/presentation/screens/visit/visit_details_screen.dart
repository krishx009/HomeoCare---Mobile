// File: lib/presentation/screens/visit/visit_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/models.dart';
import '../../../providers/providers.dart';
import '../../widgets/ui_components.dart';
import 'new_visit_screen.dart';

/// Visit Details Screen with Material Design 3
class VisitDetailsScreen extends StatefulWidget {
  final String visitId;

  const VisitDetailsScreen({super.key, required this.visitId});

  @override
  State<VisitDetailsScreen> createState() => _VisitDetailsScreenState();
}

class _VisitDetailsScreenState extends State<VisitDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadVisit();
  }

  Future<void> _loadVisit() async {
    await context.read<VisitProvider>().selectVisit(widget.visitId);
  }

  void _editVisit(VisitModel visit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            NewVisitScreen(patientId: visit.patientId, visit: visit),
      ),
    );
  }

  Future<void> _printPrescription(VisitModel visit) async {
    final patient = context.read<PatientProvider>().selectedPatient;
    if (patient == null) return;

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'HomeoCare Clinic',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Homeopathic Medicine',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),

                // Patient Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Patient: ${patient.name}'),
                        pw.Text('Age: ${patient.ageFormatted}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Date: ${AppDateUtils.formatDate(visit.visitDate)}',
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Chief Complaint
                pw.Text(
                  'Chief Complaint: ${visit.chiefComplaint}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),

                if (visit.diagnosis != null && visit.diagnosis!.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Diagnosis: ${visit.diagnosis}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],

                pw.SizedBox(height: 16),

                // Rx Symbol
                pw.Text(
                  'Rx',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.SizedBox(height: 8),

                // Medicines
                ...visit.medicines.asMap().entries.map((entry) {
                  final index = entry.key;
                  final medicine = entry.value;
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('${index + 1}. '),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                '${medicine.name}${medicine.potency != null ? ' ${medicine.potency}' : ''}',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text('Dosage: ${medicine.dosage}'),
                              pw.Text('Duration: ${medicine.duration}'),
                              if (medicine.instructions != null)
                                pw.Text(
                                  medicine.instructions!,
                                  style: const pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                if (visit.followUpDate != null) ...[
                  pw.SizedBox(height: 16),
                  pw.Text(
                    'Follow-up: ${AppDateUtils.formatDate(visit.followUpDate!)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],

                if (visit.notes != null && visit.notes!.isNotEmpty) ...[
                  pw.SizedBox(height: 16),
                  pw.Text(
                    'Notes:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(visit.notes!),
                ],

                pw.Spacer(),

                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Get well soon!',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      "Doctor's Signature",
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name:
            '${patient.name}_prescription_${AppDateUtils.formatDate(visit.visitDate)}.pdf',
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to print prescription',
        backgroundColor: AppTheme.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VisitProvider>(
      builder: (context, visitProvider, child) {
        final visit = visitProvider.selectedVisit;

        if (visitProvider.isLoading || visit == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Visit Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Visit Details'),
            actions: [
              IconButton(
                onPressed: () => _editVisit(visit),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Visit',
              ),
              IconButton(
                onPressed: () => _printPrescription(visit),
                icon: const Icon(Icons.print_outlined),
                tooltip: 'Print Prescription',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visit Date Card
                _buildDateCard(
                  visit,
                ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.05),

                const SizedBox(height: 16),

                // Consultation Details
                _buildSection(
                  title: 'Consultation',
                  icon: Icons.medical_information,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (visit.chiefComplaint != null)
                        _buildInfoRow('Chief Complaint', visit.chiefComplaint!),
                      if (visit.symptoms != null && visit.symptoms!.isNotEmpty)
                        _buildInfoRow('Symptoms', visit.symptoms!),
                      if (visit.examination != null &&
                          visit.examination!.isNotEmpty)
                        _buildInfoRow('Examination', visit.examination!),
                      if (visit.diagnosis != null &&
                          visit.diagnosis!.isNotEmpty)
                        _buildInfoRow('Diagnosis', visit.diagnosis!),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),

                const SizedBox(height: 16),

                // Vitals (if recorded)
                if (visit.vitals.hasAnyVitals)
                  _buildSection(
                    title: 'Vitals',
                    icon: Icons.monitor_heart,
                    child: _buildVitalsGrid(visit.vitals),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05),

                if (visit.vitals.hasAnyVitals) const SizedBox(height: 16),

                // Medicines
                _buildSection(
                  title: 'Medicines (${visit.medicines.length})',
                  icon: Icons.medication,
                  child: Column(
                    children: visit.medicines
                        .map((m) => _buildMedicineCard(m))
                        .toList(),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),

                const SizedBox(height: 16),

                // Follow-up & Notes
                if (visit.followUpDate != null ||
                    (visit.notes != null && visit.notes!.isNotEmpty))
                  _buildSection(
                    title: 'Additional Information',
                    icon: Icons.info_outline,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (visit.followUpDate != null)
                          _buildInfoRow(
                            'Follow-up',
                            AppDateUtils.formatDate(visit.followUpDate!),
                          ),
                        if (visit.notes != null && visit.notes!.isNotEmpty)
                          _buildInfoRow('Notes', visit.notes!),
                      ],
                    ),
                  ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateCard(VisitModel visit) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_month,
              color: AppTheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppDateUtils.formatDate(visit.visitDate),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'at ${AppDateUtils.formatTime(visit.visitDate)}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsGrid(Vitals vitals) {
    final items = <Widget>[];

    if (vitals.height != null) {
      items.add(_buildVitalItem('Height', '${vitals.height} cm', Icons.height));
    }
    if (vitals.weight != null) {
      items.add(
        _buildVitalItem('Weight', '${vitals.weight} kg', Icons.monitor_weight),
      );
    }
    if (vitals.temperature != null) {
      items.add(
        _buildVitalItem('Temp', '${vitals.temperature} °C', Icons.thermostat),
      );
    }
    if (vitals.heartRate != null) {
      items.add(
        _buildVitalItem(
          'Heart Rate',
          '${vitals.heartRate} bpm',
          Icons.favorite,
        ),
      );
    }
    if (vitals.systolicBP != null && vitals.diastolicBP != null) {
      items.add(
        _buildVitalItem(
          'BP',
          '${vitals.systolicBP}/${vitals.diastolicBP}',
          Icons.monitor_heart,
        ),
      );
    }

    return Wrap(spacing: 12, runSpacing: 12, children: items);
  }

  Widget _buildVitalItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.textTertiary,
                ),
              ),
              Text(
                value,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medication, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${medicine.name} ${medicine.potency}',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMedicineChip(medicine.dosage),
              _buildMedicineChip(medicine.frequency),
              _buildMedicineChip(medicine.duration),
            ],
          ),
          if (medicine.instructions != null) ...[
            const SizedBox(height: 8),
            Text(
              medicine.instructions!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicineChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryDark,
        ),
      ),
    );
  }
}
