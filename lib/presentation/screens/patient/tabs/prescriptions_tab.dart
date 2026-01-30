// File: lib/presentation/screens/patient/tabs/prescriptions_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/models/models.dart';
import '../../../../providers/providers.dart';
import '../../../widgets/ui_components.dart';

/// Prescriptions Tab for Patient Details with Material Design 3
class PrescriptionsTab extends StatelessWidget {
  final String patientId;

  const PrescriptionsTab({super.key, required this.patientId});

  Future<void> _printPrescription(
    BuildContext context,
    PrescriptionModel prescription,
  ) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Text(
                    'PRESCRIPTION',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Date: ${AppDateUtils.formatDate(prescription.prescriptionDate)}',
                ),
                pw.SizedBox(height: 10),
                if (prescription.diagnosis != null)
                  pw.Text('Diagnosis: ${prescription.diagnosis}'),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Medicines:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                ...prescription.medicines.map((medicine) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 12),
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          medicine.name,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('Dosage: ${medicine.dosage}'),
                        pw.Text('Frequency: ${medicine.frequency}'),
                        pw.Text('Duration: ${medicine.duration}'),
                        if (medicine.instructions != null)
                          pw.Text('Instructions: ${medicine.instructions}'),
                      ],
                    ),
                  );
                }),
                if (prescription.notes != null) ...[
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Notes:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(prescription.notes!),
                ],
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name:
            'prescription_${AppDateUtils.formatDate(prescription.prescriptionDate)}.pdf',
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to print prescription',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionProvider>(
      builder: (context, prescriptionProvider, child) {
        if (prescriptionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final prescriptions = prescriptionProvider.prescriptions;

        if (prescriptions.isEmpty) {
          return const EmptyState(
            icon: Icons.description_outlined,
            title: 'No prescriptions yet',
            description: 'Prescriptions will appear after visits are recorded.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => prescriptionProvider.loadPrescriptions(patientId),
          color: AppTheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              return _buildPrescriptionCard(context, prescription, index)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 50 * index))
                  .slideY(begin: 0.05);
            },
          ),
        );
      },
    );
  }

  Widget _buildPrescriptionCard(
    BuildContext context,
    PrescriptionModel prescription,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: AppTheme.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prescription #${index + 1}',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppDateUtils.formatDate(prescription.prescriptionDate),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _printPrescription(context, prescription),
                  icon: Icon(Icons.print, color: AppTheme.primary),
                  tooltip: 'Print Prescription',
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: context.borderColor),
            const SizedBox(height: 12),

            // Diagnosis
            if (prescription.diagnosis != null &&
                prescription.diagnosis!.isNotEmpty) ...[
              _buildInfoSection(
                context,
                icon: Icons.medical_information_outlined,
                label: 'Diagnosis',
                value: prescription.diagnosis!,
              ),
              const SizedBox(height: 12),
            ],

            // Medicines
            Text(
              'Medicines',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...prescription.medicines.map(
              (medicine) => _buildMedicineRow(context, medicine),
            ),

            // Notes
            if (prescription.notes != null &&
                prescription.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoSection(
                context,
                icon: Icons.notes_outlined,
                label: 'Notes',
                value: prescription.notes!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: context.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineRow(BuildContext context, Medicine medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medication, size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  medicine.name,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildMedicineChip(context, medicine.dosage),
              _buildMedicineChip(context, medicine.frequency),
              _buildMedicineChip(context, medicine.duration),
            ],
          ),
          if (medicine.instructions != null) ...[
            const SizedBox(height: 6),
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

  Widget _buildMedicineChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryDark,
        ),
      ),
    );
  }
}
