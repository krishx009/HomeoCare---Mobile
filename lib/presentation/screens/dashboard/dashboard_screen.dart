// File: lib/presentation/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/patient_model.dart';
import '../../../providers/patient_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/ui_components.dart';

/// Main dashboard with bottom navigation
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 1; // Patients tab selected by default
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load patients on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().loadPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: PillBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          PillNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            activeIcon: Icons.home,
          ),
          PillNavItem(
            icon: Icons.group_outlined,
            label: 'Patients',
            activeIcon: Icons.group,
          ),
          PillNavItem(
            icon: Icons.calendar_month_outlined,
            label: 'Schedule',
            activeIcon: Icons.calendar_month,
          ),
          PillNavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            activeIcon: Icons.person,
          ),
        ],
      ),
      floatingActionButton: _navIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed('/new-patient'),
              icon: const Icon(Icons.add),
              label: const Text('New Patient'),
            )
          : _navIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Add appointment
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add appointment coming soon')),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final titles = ['Home', 'Patients', 'Appointments', 'Profile'];

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          // TODO: Open drawer
        },
      ),
      title: Text(titles[_navIndex]),
      actions: [
        if (_navIndex == 1)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search is handled in the body
            },
          )
        else
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Notifications
            },
          ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildPatientsTab();
      case 2:
        return _buildAppointmentsTab();
      case 3:
        return _buildProfileTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HOME TAB
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHomeTab() {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, _) {
        final todayCount = patientProvider.todayPatients.length;
        final totalPatients = patientProvider.patients.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary,
                      AppTheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.spa,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateTime.now().hour < 12
                              ? 'Good Morning'
                              : DateTime.now().hour < 17
                              ? 'Good Afternoon'
                              : 'Good Evening',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return Text(
                          auth.currentUser?.name ?? 'Doctor',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$todayCount appointments today',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      icon: Icons.people,
                      title: 'Total Patients',
                      value: '$totalPatients',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      icon: Icons.calendar_today,
                      title: 'Today',
                      value: '$todayCount',
                      iconColor: AppTheme.info,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Quick actions
              SectionHeader(title: 'Quick Actions', icon: Icons.flash_on),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.person_add,
                      label: 'Add Patient',
                      onTap: () =>
                          Navigator.of(context).pushNamed('/new-patient'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.event,
                      label: 'Schedule',
                      onTap: () => setState(() => _navIndex = 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.search,
                      label: 'Search',
                      onTap: () => setState(() => _navIndex = 1),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Recent patients
              SectionHeader(
                title: 'Recent Patients',
                actionLabel: 'View All',
                onAction: () => setState(() => _navIndex = 1),
              ),

              const SizedBox(height: 12),

              if (patientProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (patientProvider.patients.isEmpty)
                EmptyState(
                  icon: Icons.folder_open,
                  title: 'No patients yet',
                  description: 'Start by adding your first patient',
                  actionLabel: 'Add Patient',
                  onAction: () =>
                      Navigator.of(context).pushNamed('/new-patient'),
                )
              else
                ...patientProvider.patients
                    .take(3)
                    .map((patient) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PatientCard(
                          patient: patient,
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed('/patient-details', arguments: patient),
                        ),
                      );
                    })
                    .toList()
                    .animate(interval: 50.ms)
                    .fadeIn()
                    .slideX(begin: 0.1, end: 0),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PATIENTS TAB
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPatientsTab() {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, _) {
        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  patientProvider.searchPatients(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search patients',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            patientProvider.searchPatients('');
                          },
                        )
                      : null,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),

            // Patient list
            Expanded(child: _buildPatientList(patientProvider)),
          ],
        );
      },
    );
  }

  Widget _buildPatientList(PatientProvider patientProvider) {
    if (patientProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (patientProvider.error != null) {
      return ErrorState(
        message: patientProvider.error!,
        onRetry: () => patientProvider.loadPatients(),
      );
    }

    final patients = patientProvider.filteredPatients;

    if (patients.isEmpty) {
      return EmptyState(
        icon: Icons.folder_open,
        title: _searchController.text.isNotEmpty
            ? 'No results found'
            : 'No patients found',
        description: _searchController.text.isNotEmpty
            ? 'Try a different search term'
            : 'Start by adding your first patient to the clinic registry.',
        actionLabel: _searchController.text.isEmpty ? 'Add Patient' : null,
        onAction: _searchController.text.isEmpty
            ? () => Navigator.of(context).pushNamed('/new-patient')
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => patientProvider.loadPatients(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
        itemCount: patients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final patient = patients[index];
          return _PatientCard(
                patient: patient,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed('/patient-details', arguments: patient),
              )
              .animate(delay: (50 * index).ms)
              .fadeIn()
              .slideX(begin: 0.05, end: 0);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // APPOINTMENTS TAB
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAppointmentsTab() {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, _) {
        final todayPatients = patientProvider.todayPatients;

        return Column(
          children: [
            // Date chips (today + next 6 days)
            SizedBox(
              height: 92,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final date = DateTime.now().add(Duration(days: i));
                  final days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  final dayName = days[date.weekday - 1];

                  return DateChip(
                    day: dayName,
                    date: date.day,
                    isActive: i == 0,
                    onTap: () {
                      // TODO: Filter by date
                    },
                  );
                },
              ),
            ).animate().fadeIn(duration: 300.ms),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Today, ${_formatDate(DateTime.now())}',
                      style: context.textTheme.labelMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${todayPatients.length} Scheduled',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: context.isDark
                            ? AppTheme.primary
                            : AppTheme.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Appointments list
            Expanded(
              child: patientProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : todayPatients.isEmpty
                  ? EmptyState(
                      icon: Icons.calendar_today,
                      title: 'No appointments today',
                      description: 'Schedule a new appointment to get started',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      itemCount: todayPatients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final patient = todayPatients[index];
                        return _AppointmentCard(
                          patient: patient,
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed('/patient-details', arguments: patient),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE TAB
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.borderColor),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withOpacity(0.15),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          user?.name.isNotEmpty == true
                              ? user!.name
                                    .split(' ')
                                    .map((e) => e[0])
                                    .take(2)
                                    .join()
                                    .toUpperCase()
                              : 'DR',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Doctor',
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // Menu items
              _ProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () => Navigator.of(context).pushNamed('/profile'),
              ),
              _ProfileMenuItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {
                  // TODO: Change password
                },
              ),
              _ProfileMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  // TODO: Notifications settings
                },
              ),
              _ProfileMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  // TODO: Help
                },
              ),
              _ProfileMenuItem(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  // TODO: About
                },
              ),

              const SizedBox(height: 24),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<AuthProvider>().signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.error),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: AppTheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: context.textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.onTap});

  final PatientModel patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            InitialsAvatar(name: patient.name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.name, style: context.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    '${patient.age} yrs • ${patient.gender.name} • ${patient.phone}',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.patient, required this.onTap});

  final PatientModel patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            // Status strip
            Container(
              width: 6,
              height: 92,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(22),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                child: Row(
                  children: [
                    InitialsAvatar(name: patient.name),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: context.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: context.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${patient.age} yrs, ${patient.gender.name}',
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: context.textTertiary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: context.textSecondary),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: context.textTheme.bodyLarge)),
              Icon(Icons.chevron_right, color: context.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
