// File: lib/presentation/screens/patient/patient_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/models.dart';
import '../../../providers/providers.dart';
import 'new_patient_screen.dart';
import 'tabs/overview_tab.dart';
import 'tabs/visits_tab.dart';
import 'tabs/prescriptions_tab.dart';
import 'tabs/documents_tab.dart';

/// Patient Details Screen with Material Design 3
class PatientDetailsScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPatientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    await context.read<PatientProvider>().selectPatient(widget.patientId);
    await context.read<VisitProvider>().loadVisits(widget.patientId);
    await context.read<PrescriptionProvider>().loadPrescriptions(
      widget.patientId,
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Fluttertoast.showToast(msg: 'Could not launch dialer');
    }
  }

  void _editPatient(PatientModel patient) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewPatientScreen(patient: patient),
      ),
    );
  }

  Future<void> _exportToPDF(PatientModel patient) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Patient Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildPdfSection('Personal Information', [
              _buildPdfRow('Name', patient.name),
              _buildPdfRow(
                'Date of Birth',
                AppDateUtils.formatDate(patient.dateOfBirth),
              ),
              _buildPdfRow('Age', patient.ageFormatted),
              _buildPdfRow('Gender', patient.gender.displayName),
              _buildPdfRow('Contact 1', patient.contactNumber1),
              if (patient.contactNumber2 != null)
                _buildPdfRow('Contact 2', patient.contactNumber2!),
            ]),
            if (patient.medicalHistory != null &&
                patient.medicalHistory!.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              _buildPdfSection('Medical History', [
                pw.Text(patient.medicalHistory!),
              ]),
            ],
            pw.SizedBox(height: 16),
            _buildPdfSection('Vitals', [
              if (patient.vitals.height != null)
                _buildPdfRow('Height', '${patient.vitals.height} cm'),
              if (patient.vitals.weight != null)
                _buildPdfRow('Weight', '${patient.vitals.weight} kg'),
              if (patient.vitals.temperature != null)
                _buildPdfRow('Temperature', '${patient.vitals.temperature}°C'),
              if (patient.vitals.systolicBP != null &&
                  patient.vitals.diastolicBP != null)
                _buildPdfRow('Blood Pressure', patient.vitals.bloodPressure),
              if (patient.vitals.heartRate != null)
                _buildPdfRow('Heart Rate', '${patient.vitals.heartRate} BPM'),
            ]),
            pw.SizedBox(height: 16),
            _buildPdfSection('Visit Statistics', [
              _buildPdfRow('Total Visits', patient.totalVisits.toString()),
              _buildPdfRow(
                'First Visit',
                AppDateUtils.formatDate(patient.createdAt),
              ),
              if (patient.lastVisitDate != null)
                _buildPdfRow(
                  'Last Visit',
                  AppDateUtils.formatDate(patient.lastVisitDate!),
                ),
            ]),
            pw.SizedBox(height: 32),
            pw.Center(
              child: pw.Text(
                'Generated on ${AppDateUtils.formatDateTime(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: '${patient.name}_report.pdf',
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to generate PDF',
        backgroundColor: Colors.red,
      );
    }
  }

  pw.Widget _buildPdfSection(String title, List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              label,
              style: const pw.TextStyle(color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(flex: 3, child: pw.Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, child) {
        final patient = patientProvider.selectedPatient;

        if (patientProvider.isLoading || patient == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Patient Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(patient),

                // Tabs
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: context.borderColor),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: AppTheme.primary,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: context.textTertiary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                    tabs: const [
                      Tab(text: 'Details'),
                      Tab(text: 'Visits'),
                      Tab(text: 'Prescriptions'),
                      Tab(text: 'Documents'),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      OverviewTab(patient: patient),
                      VisitsTab(patientId: patient.id),
                      PrescriptionsTab(patientId: patient.id),
                      DocumentsTab(patient: patient),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(PatientModel patient) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: Column(
        children: [
          // Top bar
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              Expanded(
                child: Text(
                  'Patient Details',
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _editPatient(patient),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Profile avatar
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.cardColor,
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.25),
                    width: 2,
                  ),
                  boxShadow: context.isDark
                      ? []
                      : [
                          BoxShadow(
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                            color: Colors.black.withOpacity(0.08),
                          ),
                        ],
                ),
                alignment: Alignment.center,
                child: Text(
                  patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.cardColor,
                    border: Border.all(color: context.borderColor),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            duration: 300.ms,
            curve: Curves.easeOut,
          ),

          const SizedBox(height: 10),

          // Name
          Text(
            patient.name,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 4),

          // Age and gender
          Text(
            '${patient.ageFormatted} • ${patient.gender.displayName}',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textTertiary,
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.call,
                  label: 'Call',
                  onTap: () => _makePhoneCall(patient.contactNumber1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.picture_as_pdf,
                  label: 'Export PDF',
                  onTap: () => _exportToPDF(patient),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
