import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/password_hasher.dart';

/// Simple customer registration screen.
///
/// On success, saves name/phone/email to SharedPreferences so
/// ProfileScreen is pre-populated after registration.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _avatar = ''; // base64-encoded profile photo

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _avatar = base64Encode(bytes));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate a network call (replace with real API later).
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // ── Persist profile to SharedPreferences ──────────────────────────────
    final prefs = await SharedPreferences.getInstance();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await prefs.setString('profile_name', _nameController.text.trim());
    await prefs.setString('profile_phone', _phoneController.text.trim());
    if (email.isNotEmpty) {
      await prefs.setString('profile_email', email);
    }
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hashPassword(password: password, salt: salt);
    await prefs.setString('profile_password_hash', hash);
    await prefs.setString('profile_password_salt', salt);
    await prefs.remove('profile_password');
    if (_avatar.isNotEmpty) {
      await prefs.setString('profile_avatar', _avatar);
    }
    await prefs.setBool('is_logged_in', false); // user must sign in
    // ─────────────────────────────────────────────────────────────────────────

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉  Account created, ${_nameController.text.trim()}! '
          'Please sign in to continue.',
        ),
        backgroundColor: const Color(0xFFC62828),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    // Redirect to login so the user must sign in after registration.
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create an Account'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7F0000), Color(0xFFC62828), Color(0xFFEF5350)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Header: tappable avatar with camera badge
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: const Color(0xFFB0E0FF),
                        backgroundImage: _avatar.isNotEmpty
                            ? MemoryImage(base64Decode(_avatar))
                            : null,
                        child: _avatar.isEmpty
                            ? const Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 56,
                                color: Color(0xFFC62828),
                              )
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFC62828),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Join Drink & Provision Hub',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7F0000),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Register to enjoy exclusive deals and order history.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),

              const SizedBox(height: 32),

              // ── Full Name ────────────────────────────────────────────────
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your full name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Phone Number ─────────────────────────────────────────────
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: 'e.g. 0244000000',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your phone number.';
                  }
                  if (v.trim().length < 10) {
                    return 'Enter a valid Ghanaian phone number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Email (optional) ─────────────────────────────────────────
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address (optional)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(v.trim())) {
                      return 'Enter a valid email address.';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Password ─────────────────────────────────────────────────
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please enter a password.';
                  }
                  if (v.length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // ── Submit button ─────────────────────────────────────────────
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                        'Register',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 16),

              // ── Already have account ──────────────────────────────────────
              Center(
                child: TextButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: const Text(
                    'Already have an account? Go back',
                    style: TextStyle(color: Color(0xFFC62828)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
