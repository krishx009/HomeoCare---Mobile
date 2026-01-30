// File: lib/presentation/screens/patient/tabs/overview_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/models/models.dart';
import '../../../widgets/ui_components.dart';

/// Overview Tab for Patient Details with Material Design 3
class OverviewTab extends StatelessWidget {
  final PatientModel patient;

  const OverviewTab({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Profile Summary Card
        _buildSectionCard(
          context,
          titleIcon: Icons.person_pin,
          title: 'Profile Summary',
          child: Text(
            patient.chiefComplaint ?? 'No chief complaint recorded.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textTertiary,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ).animate().fadeIn(delay: 50.ms).slideX(begin: -0.05),

        const SizedBox(height: 12),

        // Height & Weight
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Height',
                value: patient.vitals.height?.toString() ?? '--',
                unit: 'cm',
                icon: Icons.height,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Weight',
                value: patient.vitals.weight?.toString() ?? '--',
                unit: 'kg',
                icon: Icons.monitor_weight,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.05),

        const SizedBox(height: 12),

        // Vitals Card
        _buildVitalsCard(
          context,
        ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.05),

        const SizedBox(height: 12),

        // Medical History
        if (patient.medicalHistory != null &&
            patient.medicalHistory!.isNotEmpty)
          _buildSectionCard(
            context,
            titleIcon: Icons.history,
            title: 'Medical History',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: patient.medicalHistory!.split('\n').map((line) {
                if (line.trim().isEmpty) return const SizedBox.shrink();
                return _buildBullet(context, line.trim());
              }).toList(),
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05),

        if (patient.medicalHistory != null &&
            patient.medicalHistory!.isNotEmpty)
          const SizedBox(height: 12),

        // Visit Statistics
        _buildSectionCard(
          context,
          titleIcon: Icons.calendar_month,
          title: 'Visit Statistics',
          child: Column(
            children: [
              _buildInfoRow(
                context,
                'Total Visits',
                patient.totalVisits.toString(),
              ),
              _buildInfoRow(
                context,
                'First Visit',
                AppDateUtils.formatDate(patient.createdAt),
              ),
              if (patient.lastVisitDate != null)
                _buildInfoRow(
                  context,
                  'Last Visit',
                  AppDateUtils.formatDate(patient.lastVisitDate!),
                ),
              if (patient.nextAppointment != null)
                _buildInfoRow(
                  context,
                  'Next Appointment',
                  AppDateUtils.formatDateTime(patient.nextAppointment!),
                  valueColor: AppTheme.primary,
                ),
            ],
          ),
        ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.05),

        const SizedBox(height: 12),

        // Contact Information
        _buildSectionCard(
          context,
          titleIcon: Icons.phone,
          title: 'Contact Information',
          child: Column(
            children: [
              _buildInfoRow(context, 'Primary Contact', patient.contactNumber1),
              if (patient.contactNumber2 != null)
                _buildInfoRow(
                  context,
                  'Secondary Contact',
                  patient.contactNumber2!,
                ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.05),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData titleIcon,
    required String title,
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
                child: Icon(titleIcon, color: AppTheme.primary, size: 20),
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

  Widget _buildVitalsCard(BuildContext context) {
    final vitals = patient.vitals;

    return AppCard(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: context.isDark
                  ? Colors.white.withOpacity(0.06)
                  : const Color(0xFFF4F7F5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.monitor_heart, color: AppTheme.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Last Recorded Vitals',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? Colors.white.withOpacity(0.08)
                        : const Color(0xFFE9EFEC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    patient.updatedAt != null
                        ? AppDateUtils.formatDate(patient.updatedAt!)
                        : 'Today',
                    style: context.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Vitals grid
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
            child: Row(
              children: [
                Expanded(
                  child: _VitalItem(
                    icon: Icons.favorite,
                    label: 'BP',
                    value:
                        vitals.systolicBP != null && vitals.diastolicBP != null
                        ? '${vitals.systolicBP}/${vitals.diastolicBP}'
                        : '--',
                  ),
                ),
                _buildDivider(context),
                Expanded(
                  child: _VitalItem(
                    icon: Icons.monitor_heart,
                    label: 'Heart Rate',
                    value: vitals.heartRate != null
                        ? '${vitals.heartRate} bpm'
                        : '--',
                  ),
                ),
                _buildDivider(context),
                Expanded(
                  child: _VitalItem(
                    icon: Icons.thermostat,
                    label: 'Temp',
                    value: vitals.temperature != null
                        ? '${vitals.temperature} °C'
                        : '--',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 60,
      color: context.isDark ? Colors.white10 : const Color(0xFFEAF1ED),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.textTertiary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: valueColor ?? context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7, right: 10),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTertiary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VitalItem extends StatelessWidget {
  const _VitalItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 22),
        const SizedBox(height: 8),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
