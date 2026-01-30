// File: lib/screens/patient_description_screen.dart
import 'package:flutter/material.dart';

class PatientDescriptionScreen extends StatefulWidget {
  const PatientDescriptionScreen({
    super.key,
    required this.name,
    required this.initials,
    required this.age,
    required this.gender,
    required this.phone,
  });

  static const routeName = '/patient-details';

  final String name;
  final String initials;
  final int age;
  final String gender;
  final String phone;

  @override
  State<PatientDescriptionScreen> createState() =>
      _PatientDescriptionScreenState();
}

class _PatientDescriptionScreenState extends State<PatientDescriptionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13EC80);
    const bgLight = Color(0xFFF6F8F7);
    const bgDark = Color(0xFF102219);
    const surfaceDark = Color(0xFF162D23);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? bgDark : bgLight,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Patient Details',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0D1B14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Edit (UI only).')));
            },
            child: const Text(
              'Edit',
              style: TextStyle(fontWeight: FontWeight.w900, color: primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Profile header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? surfaceDark : Colors.white,
                          border: Border.all(
                            color: primary.withOpacity(0.25),
                            width: 2,
                          ),
                          boxShadow: isDark
                              ? const []
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
                          widget.initials,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: primary,
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
                            color: isDark ? surfaceDark : Colors.white,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : const Color(0xFFEAF1ED),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0D1B14),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.age} Years, ${widget.gender}',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.call,
                          label: 'Call',
                          isDark: isDark,
                          primary: primary,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Calling ${widget.phone} (UI only).',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.chat_bubble,
                          label: 'Message',
                          isDark: isDark,
                          primary: primary,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Messaging (UI only).'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabs,
                isScrollable: true,
                indicatorColor: primary,
                labelColor: primary,
                unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'Consultations'),
                  Tab(text: 'Documents'),
                  Tab(text: 'Prescription'),
                  Tab(text: 'Lab Records'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _DetailsTab(
                    isDark: isDark,
                    primary: primary,
                    surfaceDark: surfaceDark,
                  ),
                  _PlaceholderTab(title: 'Consultations'),
                  _PlaceholderTab(title: 'Documents'),
                  _PlaceholderTab(title: 'Prescription'),
                  _PlaceholderTab(title: 'Lab Records'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.primary,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF162D23) : Colors.white;
    final border = isDark ? Colors.white12 : const Color(0xFFEAF1ED);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF2B3A33),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({
    required this.isDark,
    required this.primary,
    required this.surfaceDark,
  });

  final bool isDark;
  final Color primary;
  final Color surfaceDark;

  @override
  Widget build(BuildContext context) {
    final card = isDark ? surfaceDark : Colors.white;
    final border = isDark ? Colors.white12 : const Color(0xFFEAF1ED);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      children: [
        _Card(
          card: card,
          border: border,
          titleIcon: Icons.person_outline,
          title: 'Profile Summary',
          primary: primary,
          child: Text(
            'Patient undergoing treatment for chronic migraine and seasonal allergies. '
            'Showing significant improvement in frequency of headaches since last visit.',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _MetricCard(
                card: card,
                border: border,
                title: 'Height',
                value: '175',
                unit: 'cm',
                icon: Icons.height,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                card: card,
                border: border,
                title: 'Weight',
                value: '78',
                unit: 'kg',
                icon: Icons.monitor_weight,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : const Color(0xFFF4F7F5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  border: Border(bottom: BorderSide(color: border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Last Recorded Vitals',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0D1B14),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : const Color(0xFFE9EFEC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Today, 9:30 AM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: _Vital(
                        icon: Icons.favorite,
                        label: 'BP',
                        value: '120/80',
                        isDark: isDark,
                      ),
                    ),
                    _divider(isDark),
                    Expanded(
                      child: _Vital(
                        icon: Icons.monitor_heart,
                        label: 'Heart Rate',
                        value: '72 bpm',
                        isDark: isDark,
                      ),
                    ),
                    _divider(isDark),
                    Expanded(
                      child: _Vital(
                        icon: Icons.thermostat,
                        label: 'Temp',
                        value: '36.5 °C',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        _Card(
          card: card,
          border: border,
          titleIcon: Icons.history,
          title: 'Medical History',
          primary: primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bullet(primary, 'Allergic to Penicillin.', isDark),
              const SizedBox(height: 10),
              _bullet(primary, 'History of mild hypertension in 2022.', isDark),
              const SizedBox(height: 10),
              _bullet(
                primary,
                'Previous surgery: Appendectomy (2018).',
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _divider(bool isDark) {
    return Container(
      width: 1,
      height: 72,
      color: isDark ? Colors.white10 : const Color(0xFFEAF1ED),
    );
  }

  static Widget _bullet(Color primary, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.card,
    required this.border,
    required this.titleIcon,
    required this.title,
    required this.primary,
    required this.child,
  });

  final Color card;
  final Color border;
  final IconData titleIcon;
  final String title;
  final Color primary;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(titleIcon, color: primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0D1B14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.card,
    required this.border,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.isDark,
  });

  final Color card;
  final Color border;
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              icon,
              size: 54,
              color: isDark ? Colors.white10 : const Color(0xFFEFF4F1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white54 : Colors.black45,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0D1B14),
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Vital extends StatelessWidget {
  const _Vital({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : const Color(0xFFF4F7F5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0D1B14),
          ),
        ),
      ],
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Text(
        '$title (placeholder)',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white60 : Colors.black45,
        ),
      ),
    );
  }
}
