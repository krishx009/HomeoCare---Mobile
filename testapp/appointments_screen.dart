// File: lib/screens/appointments_screen.dart
import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  static const routeName = '/appointments';

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int _selectedDayIndex = 0;

  final List<_DayChip> _days = const [
    _DayChip('Mon', 24, active: true),
    _DayChip('Tue', 25),
    _DayChip('Wed', 26),
    _DayChip('Thu', 27),
    _DayChip('Fri', 28),
    _DayChip('Sat', 29),
  ];

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13EC80);
    const bgLight = Color(0xFFF6F8F7);
    const bgDark = Color(0xFF102219);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? bgDark : bgLight,
        elevation: 0,
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        title: Text(
          'Appointments',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0D1B14),
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.calendar_month)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Date strip
            SizedBox(
              height: 92,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final d = _days[i];
                  final active = i == _selectedDayIndex;
                  return _DateChip(
                    day: d.day,
                    date: d.date,
                    active: active,
                    primary: primary,
                    onTap: () => setState(() => _selectedDayIndex = i),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Today, Oct ${_days[_selectedDayIndex].date}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.7,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(isDark ? 0.16 : 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '4 Pending',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isDark ? primary : const Color(0xFF0D1B14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                children: const [
                  _ApptCard(
                    name: 'Anita Desai',
                    time: '10:30 AM',
                    type: 'Initial Consultation',
                    status: _ApptStatus.pending,
                  ),
                  SizedBox(height: 12),
                  _ApptCard(
                    name: 'Vikram Singh',
                    time: '11:15 AM',
                    type: 'Follow-up',
                    status: _ApptStatus.confirmed,
                  ),
                  SizedBox(height: 12),
                  _ApptCard(
                    name: 'Rahul Mehta',
                    time: '02:00 PM',
                    type: 'Acute Care - Cancelled',
                    status: _ApptStatus.cancelled,
                  ),
                  SizedBox(height: 12),
                  _ApptCard(
                    name: 'Sarah Jenkins',
                    time: '03:45 PM',
                    type: 'Consultation',
                    status: _ApptStatus.pending,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        foregroundColor: const Color(0xFF00391D),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add appointment (UI only).')),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2C23) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white12 : const Color(0xFFE7F3ED),
            ),
          ),
        ),
        child: Row(
          children: const [
            _NavStub(
              icon: Icons.calendar_today,
              label: 'Schedule',
              active: true,
            ),
            _NavStub(icon: Icons.group, label: 'Patients', active: false),
            _NavStub(icon: Icons.notifications, label: 'Alerts', active: false),
          ],
        ),
      ),
    );
  }
}

class _DayChip {
  const _DayChip(this.day, this.date, {this.active = false});
  final String day;
  final int date;
  final bool active;
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.day,
    required this.date,
    required this.active,
    required this.primary,
    required this.onTap,
  });

  final String day;
  final int date;
  final bool active;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: active
              ? primary
              : (isDark ? const Color(0xFF1A2C23) : Colors.white),
          border: Border.all(
            color: active
                ? Colors.transparent
                : (isDark ? Colors.white12 : const Color(0xFFDDE6E1)),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: active
                    ? const Color(0xFF00391D)
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$date',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: active
                    ? const Color(0xFF00391D)
                    : (isDark ? Colors.white : const Color(0xFF0D1B14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ApptStatus { pending, confirmed, cancelled }

class _ApptCard extends StatelessWidget {
  const _ApptCard({
    required this.name,
    required this.time,
    required this.type,
    required this.status,
  });

  final String name;
  final String time;
  final String type;
  final _ApptStatus status;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13EC80);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = isDark ? const Color(0xFF1A2C23) : Colors.white;
    final border = isDark ? Colors.white12 : const Color(0xFFEAF1ED);

    Color strip;
    switch (status) {
      case _ApptStatus.pending:
        strip = Colors.amber;
        break;
      case _ApptStatus.confirmed:
        strip = primary;
        break;
      case _ApptStatus.cancelled:
        strip = isDark ? Colors.white24 : Colors.black26;
        break;
    }

    final disabled = status == _ApptStatus.cancelled;

    return Opacity(
      opacity: disabled ? 0.60 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 92,
                  decoration: BoxDecoration(
                    color: strip,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(22),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 8, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary.withOpacity(isDark ? 0.16 : 0.18),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : const Color(0xFFEAF1ED),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            name
                                .split(' ')
                                .map((e) => e.isNotEmpty ? e[0] : '')
                                .take(2)
                                .join(),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: isDark ? primary : const Color(0xFF0D1B14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0D1B14),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                type,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.more_vert,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!disabled)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: const BorderSide(color: primary),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Reschedule',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: status == _ApptStatus.confirmed
                            ? null
                            : () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: const Color(0xFF00391D),
                          disabledBackgroundColor: (isDark
                              ? Colors.white12
                              : const Color(0xFFE9EFEC)),
                          disabledForegroundColor: (isDark
                              ? Colors.white54
                              : Colors.black45),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: Text(
                          status == _ApptStatus.confirmed
                              ? 'Confirmed'
                              : 'Confirm',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavStub extends StatelessWidget {
  const _NavStub({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13EC80);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = active
        ? (isDark ? Colors.white : const Color(0xFF0D1B14))
        : (isDark ? Colors.white54 : Colors.black45);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withOpacity(isDark ? 0.20 : 0.22),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Icon(icon, color: fg),
            )
          else
            Icon(icon, color: fg),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w900 : FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
