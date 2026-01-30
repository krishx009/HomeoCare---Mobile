// File: lib/screens/patient_list_empty_screen.dart
import 'package:flutter/material.dart';

import 'patient_registration_screen.dart';

class PatientListEmptyScreen extends StatelessWidget {
  const PatientListEmptyScreen({super.key});

  static const routeName = '/patients-empty';

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13EC80);
    const bgLight = Color(0xFFF6F8F7);
    const bgDark = Color(0xFF102219);
    const surfaceLight = Colors.white;
    const surfaceDark = Color(0xFF1A2C23);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? bgDark : bgLight,
        elevation: 0,
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        title: Text(
          'Patients',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0D1B14),
          ),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: primary.withOpacity(isDark ? 0.08 : 0.10),
                        ),
                        child: const Icon(
                          Icons.folder_copy_outlined,
                          size: 72,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'No patients found',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0D1B14),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start by adding your first patient to the clinic registry.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PatientRegistrationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'New Patient',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
            // Bottom nav (static, Patients selected)
            Container(
              decoration: BoxDecoration(
                color: isDark ? surfaceDark : surfaceLight,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white12 : const Color(0xFFE7F3ED),
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Row(
                children: [
                  _navItem(
                    isDark,
                    icon: Icons.home_outlined,
                    label: 'Home',
                    active: false,
                  ),
                  _navItem(
                    isDark,
                    icon: Icons.group,
                    label: 'Patients',
                    active: true,
                    primary: primary,
                  ),
                  _navItem(
                    isDark,
                    icon: Icons.calendar_month,
                    label: 'Schedule',
                    active: false,
                  ),
                  _navItem(
                    isDark,
                    icon: Icons.person_outline,
                    label: 'Profile',
                    active: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _navItem(
    bool isDark, {
    required IconData icon,
    required String label,
    required bool active,
    Color primary = const Color(0xFF13EC80),
  }) {
    final textColor = active
        ? (isDark ? Colors.white : const Color(0xFF0D1B14))
        : (isDark ? Colors.white54 : Colors.black45);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(isDark ? 0.20 : 0.22),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Icon(icon, color: textColor),
              )
            else
              Icon(icon, color: textColor),
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
    );
  }
}
