// File: lib/presentation/screens/patient/tabs/visits_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/models/models.dart';
import '../../../../providers/providers.dart';
import '../../../widgets/ui_components.dart';
import '../../visit/visit_details_screen.dart';
import '../../visit/new_visit_screen.dart';

/// Visits Tab for Patient Details with Material Design 3
class VisitsTab extends StatelessWidget {
  final String patientId;

  const VisitsTab({super.key, required this.patientId});

  void _viewVisitDetails(BuildContext context, VisitModel visit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VisitDetailsScreen(visitId: visit.id),
      ),
    );
  }

  void _addNewVisit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewVisitScreen(patientId: patientId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VisitProvider>(
      builder: (context, visitProvider, child) {
        if (visitProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final visits = visitProvider.visits;

        if (visits.isEmpty) {
          return _buildEmptyState(context);
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => visitProvider.loadVisits(patientId),
              color: AppTheme.primary,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: visits.length,
                itemBuilder: (context, index) {
                  final visit = visits[index];
                  return _buildVisitCard(context, visit, index)
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 50 * index))
                      .slideY(begin: 0.05);
                },
              ),
            ),
            // FAB
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                heroTag: 'add_visit',
                onPressed: () => _addNewVisit(context),
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.textPrimaryLight,
                icon: const Icon(Icons.add),
                label: const Text(
                  'New Visit',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyState(
      icon: Icons.calendar_today_outlined,
      title: 'No visits recorded',
      description: 'Add a new visit to start tracking consultations.',
      actionLabel: 'Add First Visit',
      onAction: () => _addNewVisit(context),
    );
  }

  Widget _buildVisitCard(BuildContext context, VisitModel visit, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => _viewVisitDetails(context, visit),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_month,
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
                        'Visit #${visits.length - index}',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppDateUtils.formatDateTime(visit.visitDate),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.textTertiary),
              ],
            ),

            if (visit.chiefComplaint != null &&
                visit.chiefComplaint!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: context.borderColor),
              const SizedBox(height: 12),
              // Chief Complaint
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.medical_information_outlined,
                    size: 18,
                    color: context.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chief Complaint',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          visit.chiefComplaint!,
                          style: context.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // Medicine count
            if (visit.medicines.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 16,
                      color: AppTheme.primaryDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${visit.medicines.length} medicine${visit.medicines.length > 1 ? 's' : ''} prescribed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<VisitModel> get visits => [];
}
