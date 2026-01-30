// File: lib/screens/main_dashboard_screen.dart
import 'package:flutter/material.dart';

import 'appointments_screen.dart';
import 'patient_description_screen.dart';
import 'patient_registration_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _navIndex = 1; // Patients tab selected by default (matches your concept)
  final _searchCtrl = TextEditingController();

  final List<_PatientLite> _patients = [
    _PatientLite(
      name: 'Rahul Sharma',
      age: 34,
      gender: 'Male',
      initials: 'RS',
      phone: '+91 98765 43210',
    ),
    _PatientLite(
      name: 'Anita Desai',
      age: 29,
      gender: 'Female',
      initials: 'AD',
      phone: '+91 99887 77665',
    ),
    _PatientLite(
      name: 'Vikram Singh',
      age: 41,
      gender: 'Male',
      initials: 'VS',
      phone: '+91 90000 11223',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13EC80);
    const bgLight = Color(0xFFF6F8F7);
    const bgDark = Color(0xFF102219);
    const surfaceDark = Color(0xFF1A2C23);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _patients.where((p) {
      final q = _searchCtrl.text.trim().toLowerCase();
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.phone.toLowerCase().contains(q);
    }).toList();

    Widget bodyForIndex() {
      switch (_navIndex) {
        case 0:
          return _HomePlaceholder(primary: primary);
        case 1:
          return _PatientsList(
            primary: primary,
            isDark: isDark,
            surfaceDark: surfaceDark,
            bgLight: bgLight,
            bgDark: bgDark,
            searchCtrl: _searchCtrl,
            patients: filtered,
            onTapPatient: (p) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PatientDescriptionScreen(
                    name: p.name,
                    initials: p.initials,
                    age: p.age,
                    gender: p.gender,
                    phone: p.phone,
                  ),
                ),
              );
            },
            onAddPatient: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PatientRegistrationScreen(),
                ),
              );
            },
          );
        case 2:
          return const AppointmentsScreen();
        case 3:
          return _ProfilePlaceholder(primary: primary);
        default:
          return const SizedBox.shrink();
      }
    }

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? bgDark : bgLight,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        title: Text(
          _navIndex == 1
              ? 'Patients'
              : _navIndex == 2
              ? 'Appointments'
              : _navIndex == 0
              ? 'Home'
              : 'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0D1B14),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _navIndex == 1 ? Icons.search : Icons.notifications_none,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(child: bodyForIndex()),
      bottomNavigationBar: _BottomPillNav(
        primary: primary,
        isDark: isDark,
        index: _navIndex,
        onChanged: (i) => setState(() => _navIndex = i),
      ),
      floatingActionButton: _navIndex == 2
          ? FloatingActionButton(
              backgroundColor: primary,
              foregroundColor: const Color(0xFF00391D),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add appointment (UI only).')),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _PatientsList extends StatelessWidget {
  const _PatientsList({
    required this.primary,
    required this.isDark,
    required this.surfaceDark,
    required this.bgLight,
    required this.bgDark,
    required this.searchCtrl,
    required this.patients,
    required this.onTapPatient,
    required this.onAddPatient,
  });

  final Color primary;
  final bool isDark;
  final Color surfaceDark;
  final Color bgLight;
  final Color bgDark;
  final TextEditingController searchCtrl;
  final List<_PatientLite> patients;
  final void Function(_PatientLite) onTapPatient;
  final VoidCallback onAddPatient;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? surfaceDark : Colors.white;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: TextField(
            controller: searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search patients',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : const Color(0xFFE0E9E4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primary, width: 1.4),
              ),
            ),
          ),
        ),
        Expanded(
          child: patients.isEmpty
              ? _EmptyPatients(
                  primary: primary,
                  isDark: isDark,
                  onAdd: onAddPatient,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
                  itemBuilder: (_, i) {
                    final p = patients[i];
                    return InkWell(
                      onTap: () => onTapPatient(p),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFEAF1ED),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(
                                  isDark ? 0.14 : 0.18,
                                ),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                p.initials,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? primary
                                      : const Color(0xFF0D1B14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0D1B14),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${p.age} yrs • ${p.gender} • ${p.phone}',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: isDark ? Colors.white54 : Colors.black38,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: patients.length,
                ),
        ),
        // Bottom "+ New Patient" action (button island)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: const Color(0xFF0D1B14),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              onPressed: onAddPatient,
              icon: const Icon(Icons.add),
              label: const Text(
                'New Patient',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyPatients extends StatelessWidget {
  const _EmptyPatients({
    required this.primary,
    required this.isDark,
    required this.onAdd,
  });

  final Color primary;
  final bool isDark;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: primary.withOpacity(isDark ? 0.08 : 0.10),
              ),
              child: const Icon(
                Icons.folder_open,
                size: 64,
                color: Color(0xFF13EC80),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No patients found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0D1B14),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Start by adding your first patient to the clinic registry.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onAdd,
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Add Patient',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPillNav extends StatelessWidget {
  const _BottomPillNav({
    required this.primary,
    required this.isDark,
    required this.index,
    required this.onChanged,
  });

  final Color primary;
  final bool isDark;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A2C23) : Colors.white;
    final border = isDark ? Colors.white12 : const Color(0xFFE7F3ED);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          _navItem(Icons.home_outlined, 'Home', 0),
          _navItem(Icons.group, 'Patients', 1, activePill: true),
          _navItem(Icons.calendar_month, 'Schedule', 2),
          _navItem(Icons.person_outline, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    int i, {
    bool activePill = false,
  }) {
    final active = index == i;
    final textColor = active
        ? (isDark ? Colors.white : const Color(0xFF0D1B14))
        : (isDark ? Colors.white54 : Colors.black45);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onChanged(i),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (active && activePill)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(isDark ? 0.20 : 0.22),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Icon(icon, size: 24, color: textColor),
                )
              else
                Icon(icon, size: 24, color: textColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Home (placeholder)',
        style: TextStyle(fontWeight: FontWeight.w900, color: primary),
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile (placeholder)',
        style: TextStyle(fontWeight: FontWeight.w900, color: primary),
      ),
    );
  }
}

class _PatientLite {
  _PatientLite({
    required this.name,
    required this.age,
    required this.gender,
    required this.initials,
    required this.phone,
  });

  final String name;
  final int age;
  final String gender;
  final String initials;
  final String phone;
}
