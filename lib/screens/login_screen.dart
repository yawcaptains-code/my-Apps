import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Login screen.
///
/// On success, persists the phone/email to SharedPreferences so
/// ProfileScreen reflects the logged-in user.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final input = _phoneEmailController.text.trim();
    final password = _passwordController.text;

    // ── Admin credentials check (case-insensitive email) ──────────────────
    const adminEmail = 'Abmin@2026.com';
    const adminPassword = 'MKT@2026#heavenminded';

    if (input.toLowerCase() == adminEmail.toLowerCase() &&
        password == adminPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_admin', true);
      await prefs.setString('profile_email', adminEmail);
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushNamedAndRemoveUntil(
          context, '/admin-dashboard', (route) => false);
      return;
    }
    // ─────────────────────────────────────────────────────────────────────────

    // ── Regular user login ────────────────────────────────────────────────
    final prefs = await SharedPreferences.getInstance();
    if (input.contains('@')) {
      await prefs.setString('profile_email', input);
    } else {
      await prefs.setString('profile_phone', input);
    }
    if ((prefs.getString('profile_name') ?? '').isEmpty) {
      await prefs.setString('profile_name', 'Customer');
    }
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('is_admin', false);

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅  Logged in successfully! Welcome back.'),
        backgroundColor: Color(0xFF0077B6),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );

    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero header ───────────────────────────────────────────────
            _LoginHeader(),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Phone / Email ────────────────────────────────────
                    TextFormField(
                      controller: _phoneEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Phone or Email *',
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: 'e.g. 0244000000 or you@email.com',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter your phone number or email.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Password ─────────────────────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password *',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter your password.';
                        }
                        return null;
                      },
                    ),

                    // ── Forgot password link ──────────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Password reset coming soon.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                              color: Color(0xFF0077B6), fontSize: 13),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Sign in button ────────────────────────────────────
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // ── Divider ───────────────────────────────────────────
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Register link ─────────────────────────────────────
                    OutlinedButton.icon(
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text(
                        'Create a New Account',
                        style: TextStyle(fontSize: 15),
                      ),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(
                              context, '/register'),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                            color: Color(0xFF0077B6), width: 1.5),
                        foregroundColor: const Color(0xFF0077B6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Continue as guest ─────────────────────────────────
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (route) => false),
                        child: const Text(
                          'Continue as Guest',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),

                    const Divider(height: 32),

                    // ── Admin Portal link ─────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin-login'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.admin_panel_settings_outlined,
                                size: 16,
                                color: Colors.grey.shade500),
                            const SizedBox(width: 6),
                            Text(
                              'Admin Portal',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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

// ── Hero header widget ────────────────────────────────────────────────────────

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF023E8A), Color(0xFF0096C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white70),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.storefront_rounded,
              size: 56, color: Colors.white70),
          const SizedBox(height: 12),
          const Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Welcome back to Drink & Provision Hub',
            style: TextStyle(
              color: Colors.white.withOpacity(0.80),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
