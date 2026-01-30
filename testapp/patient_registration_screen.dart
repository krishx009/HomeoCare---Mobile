// File: lib/screens/patient_registration_screen.dart
import 'package:flutter/material.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  static const routeName = '/patient-new';

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();

  String _gender = 'Male';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _phoneCtrl.dispose();
    _emergencyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;

    final dd = picked.day.toString().padLeft(2, '0');
    final mm = picked.month.toString().padLeft(2, '0');
    final yyyy = picked.year.toString();
    setState(() => _dobCtrl.text = '$dd/$mm/$yyyy');
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13EC80);
    const bgLight = Color(0xFFF8FCFA);
    const bgDark = Color(0xFF102219);
    const surfaceDark = Color(0xFF1A2C24);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    InputDecoration deco(String hint, {IconData? icon}) {
      return InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? surfaceDark : Colors.white,
        suffixIcon: icon == null
            ? null
            : Icon(
                icon,
                color: isDark ? Colors.white54 : const Color(0xFF4C9A73),
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : const Color(0xFFcfe7db),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? bgDark : bgLight,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'New Patient',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0D1B14),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 130),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stepper (Step 1 active)
                    Row(
                      children: List.generate(5, (i) {
                        final active = i == 0;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i == 4 ? 0 : 8),
                            height: 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? primary
                                  : (isDark
                                        ? Colors.white12
                                        : const Color(0xFFcfe7db)),
                              borderRadius: BorderRadius.circular(99),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        blurRadius: 10,
                                        color: primary.withOpacity(0.35),
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : const [],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Step 1',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isDark ? primary : const Color(0xFF0EB561),
                          ),
                        ),
                        Text(
                          'Step 5',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Text(
                      'Basic Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0D1B14),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Please enter the patient's personal information.",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF4C9A73),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Text('Full Name', style: _labelStyle(isDark)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      decoration: deco('Enter full name'),
                    ),

                    const SizedBox(height: 14),
                    Text('Date of Birth', style: _labelStyle(isDark)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDob,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _dobCtrl,
                          readOnly: true,
                          decoration: deco(
                            'DD/MM/YYYY',
                            icon: Icons.calendar_month,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                    Text('Gender', style: _labelStyle(isDark)),
                    const SizedBox(height: 8),
                    _GenderSegment(
                      value: _gender,
                      onChanged: (v) => setState(() => _gender = v),
                      isDark: isDark,
                      primary: primary,
                    ),

                    const SizedBox(height: 14),
                    Text('Phone Number', style: _labelStyle(isDark)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: deco('(555) 000-0000', icon: Icons.call),
                    ),

                    const SizedBox(height: 14),
                    Text('Emergency Contact', style: _labelStyle(isDark)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emergencyCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: deco('(555) 000-0000', icon: Icons.emergency),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky bottom bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                decoration: BoxDecoration(
                  color: (isDark ? bgDark : bgLight).withOpacity(0.96),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white12 : const Color(0xFFE0E9E4),
                    ),
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark
                                  ? Colors.white
                                  : const Color(0xFF0D1B14),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.white24
                                    : const Color(0xFFcfe7db),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).maybePop(),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: const Color(0xFF0D1B14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Next: Body Metrics (not implemented yet).',
                                  ),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Next: Body Metrics',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _labelStyle(bool isDark) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w900,
      color: isDark ? Colors.white70 : const Color(0xFF0D1B14),
    );
  }
}

class _GenderSegment extends StatelessWidget {
  const _GenderSegment({
    required this.value,
    required this.onChanged,
    required this.isDark,
    required this.primary,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final options = const ['Male', 'Female', 'Other'];

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2C24) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFcfe7db),
        ),
      ),
      child: Row(
        children: options.map((opt) {
          final selected = opt == value;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected
                      ? primary.withOpacity(isDark ? 0.22 : 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? primary : Colors.transparent,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    color: selected
                        ? (isDark ? primary : const Color(0xFF0D1B14))
                        : (isDark ? Colors.white54 : Colors.black45),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
