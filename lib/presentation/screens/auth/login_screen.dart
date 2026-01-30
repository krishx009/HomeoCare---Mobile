// File: lib/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/ui_components.dart';

/// Login and Signup screen with Material Design 3
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Login controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Signup controllers
  final _nameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _clinicNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _confirmPasswordController.dispose();
    _clinicNameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted && authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_signupPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signUpWithEmail(
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text,
        name: _nameController.text.trim(),
      );

      if (mounted && authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: _isLoading,
          message: 'Please wait...',
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                    ).animate().fadeIn(duration: 200.ms),

                    const SizedBox(height: 8),

                    // Title
                    Text('Welcome Back', style: context.textTheme.headlineLarge)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: -0.1, end: 0),

                    const SizedBox(height: 6),

                    Text(
                      'Sign in to access the Homeocare receptionist dashboard.',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.textTertiary,
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                    const SizedBox(height: 24),

                    // Tab bar
                    Container(
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: const EdgeInsets.all(4),
                        dividerColor: Colors.transparent,
                        labelColor: context.textPrimary,
                        unselectedLabelColor: context.textTertiary,
                        tabs: const [
                          Tab(text: 'Login'),
                          Tab(text: 'Sign Up'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                    const SizedBox(height: 24),

                    // Tab content
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, child) {
                        return AnimatedSwitcher(
                          duration: 200.ms,
                          child: _tabController.index == 0
                              ? _buildLoginForm()
                              : _buildSignupForm(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Google login button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: context.cardColor,
              side: BorderSide(color: context.borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              // TODO: Implement Google Sign In
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Google Sign-In coming soon')),
              );
            },
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: Text(
              'Continue with Google',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: context.borderColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or login with email',
                style: context.textTheme.labelMedium,
              ),
            ),
            Expanded(child: Divider(color: context.borderColor)),
          ],
        ),

        const SizedBox(height: 24),

        // Email field
        const FieldLabel(label: 'Email Address', isRequired: true),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'receptionist@homeocare.com',
            suffixIcon: Icon(Icons.mail_outline, size: 20),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Password field
        const FieldLabel(label: 'Password', isRequired: true),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '••••••••••••',
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),

        const SizedBox(height: 8),

        // Forgot password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: Implement forgot password
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Forgot password coming soon')),
              );
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Login button
        PrimaryButton(
          label: 'Login',
          icon: Icons.arrow_forward,
          onPressed: _handleLogin,
          isLoading: _isLoading,
        ),

        const SizedBox(height: 24),

        // Sign up link
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: context.textTheme.bodyMedium,
              ),
              InkWell(
                onTap: () => _tabController.animateTo(1),
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      key: const ValueKey('signup'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name field
        const FieldLabel(label: 'Full Name', isRequired: true),
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Dr. John Smith',
            suffixIcon: Icon(Icons.person_outline, size: 20),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Clinic name field
        const FieldLabel(label: 'Clinic Name'),
        TextFormField(
          controller: _clinicNameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Homeocare Clinic',
            suffixIcon: Icon(Icons.local_hospital_outlined, size: 20),
          ),
        ),

        const SizedBox(height: 16),

        // Email field
        const FieldLabel(label: 'Email Address', isRequired: true),
        TextFormField(
          controller: _signupEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'doctor@homeocare.com',
            suffixIcon: Icon(Icons.mail_outline, size: 20),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Password field
        const FieldLabel(label: 'Password', isRequired: true),
        TextFormField(
          controller: _signupPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Min 6 characters',
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Confirm password field
        const FieldLabel(label: 'Confirm Password', isRequired: true),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            hintText: 'Re-enter password',
            suffixIcon: IconButton(
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _signupPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),

        const SizedBox(height: 24),

        // Sign up button
        PrimaryButton(
          label: 'Create Account',
          icon: Icons.arrow_forward,
          onPressed: _handleSignup,
          isLoading: _isLoading,
        ),

        const SizedBox(height: 24),

        // Login link
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: context.textTheme.bodyMedium,
              ),
              InkWell(
                onTap: () => _tabController.animateTo(0),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
