import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backend/supabase_bootstrap.dart';
import '../providers/auth_provider.dart';
import '../services/password_hasher.dart';

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
    final enteredPassword = _passwordController.text;
    final prefs = await SharedPreferences.getInstance();

    String? supabaseError;
    if (SupabaseBootstrap.isInitialized && input.contains('@')) {
      try {
        await context.read<AuthProvider>().signInUser(
              email: input,
              password: enteredPassword,
            );

        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅  Logged in successfully! Welcome back.'),
            backgroundColor: Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        return;
      } catch (e) {
        supabaseError = e.toString();
      }
    }

    // ── Regular user credentials check ──────────────────────────────────────
    final savedPhone = prefs.getString('profile_phone') ?? '';
    final savedEmail = prefs.getString('profile_email') ?? '';
    final savedPasswordHash = prefs.getString('profile_password_hash') ?? '';
    final savedPasswordSalt = prefs.getString('profile_password_salt') ?? '';
    final legacyPassword = prefs.getString('profile_password') ?? '';

    final phoneOrEmailMatch =
        input == savedPhone || input.toLowerCase() == savedEmail.toLowerCase();

    final passwordMatches = savedPasswordHash.isNotEmpty &&
            savedPasswordSalt.isNotEmpty
        ? PasswordHasher.verifyPassword(
            password: enteredPassword,
            salt: savedPasswordSalt,
            expectedHash: savedPasswordHash,
          )
        : enteredPassword == legacyPassword;

    if (!phoneOrEmailMatch || !passwordMatches) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            supabaseError == null
                ? 'Incorrect phone/email or password. Please try again.'
                : 'Login failed: $supabaseError',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (savedPasswordHash.isEmpty || savedPasswordSalt.isEmpty) {
      final salt = PasswordHasher.generateSalt();
      final hash = PasswordHasher.hashPassword(
        password: enteredPassword,
        salt: salt,
      );
      await prefs.setString('profile_password_hash', hash);
      await prefs.setString('profile_password_salt', salt);
      await prefs.remove('profile_password');
    }

    await context.read<AuthProvider>().signInUser();

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅  Logged in successfully! Welcome back.'),
        backgroundColor: Color(0xFFC62828),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );

    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // â”€â”€ Hero header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _LoginHeader(),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // â”€â”€ Phone / Email â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

                    // â”€â”€ Password â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

                    // â”€â”€ Forgot password link â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
                              color: Color(0xFFC62828), fontSize: 13),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // â”€â”€ Sign in button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

                    // â”€â”€ Divider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

                    // â”€â”€ Register link â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
                            color: Color(0xFFC62828), width: 1.5),
                        foregroundColor: const Color(0xFFC62828),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

// â”€â”€ Hero header widget â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7F0000), Color(0xFFEF5350)],
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
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
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
              color: Colors.white.withValues(alpha: 0.80),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
