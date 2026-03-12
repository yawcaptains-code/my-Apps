import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/theme_provider.dart';

/// User profile / account screen.
///
/// Saves name, phone, email, and address to SharedPreferences.
/// Provides logout and settings placeholders.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _nameKey    = 'profile_name';
  static const _phoneKey   = 'profile_phone';
  static const _emailKey   = 'profile_email';
  static const _addressKey = 'profile_address';
  static const _avatarKey  = 'profile_avatar';

  String _name    = '';
  String _phone   = '';
  String _email   = '';
  String _address = '';
  String _avatar  = '';   // base64-encoded image
  bool   _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name    = prefs.getString(_nameKey)    ?? '';
      _phone   = prefs.getString(_phoneKey)   ?? '';
      _email   = prefs.getString(_emailKey)   ?? '';
      _address = prefs.getString(_addressKey) ?? '';
      _avatar  = prefs.getString(_avatarKey)  ?? '';
      _isAdmin = prefs.getBool('is_admin')    ?? false;
    });
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
    final b64 = base64Encode(bytes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarKey, b64);
    setState(() => _avatar = b64);
  }

  Future<void> _save(
      String name, String phone, String email, String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_addressKey, address);
    setState(() {
      _name = name;
      _phone = phone;
      _email = email;
      _address = address;
    });
  }

  void _openEditSheet() {
    final nameCtrl = TextEditingController(text: _name);
    final phoneCtrl = TextEditingController(text: _phone);
    final emailCtrl = TextEditingController(text: _email);
    final addressCtrl = TextEditingController(text: _address);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profile',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter your name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                    prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Default Delivery Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await _save(
                      nameCtrl.text.trim(),
                      phoneCtrl.text.trim(),
                      emailCtrl.text.trim(),
                      addressCtrl.text.trim(),
                    );
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Profile saved! ✅'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFFEF5350),
                      ),
                    );
                  },
                  child: const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _name.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit profile',
            onPressed: _openEditSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            _ProfileHeader(
              name: _name,
              phone: _phone,
              isLoggedIn: isLoggedIn,
              avatar: _avatar,
              onPickAvatar: _pickAvatar,
            ),

            const SizedBox(height: 20),

            // ── Account details ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoggedIn) ...[
                    const _SectionLabel('Account Details'),
                    _InfoTile(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: _name.isEmpty ? '—' : _name),
                    _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: _phone.isEmpty ? '—' : _phone),
                    if (_email.isNotEmpty)
                      _InfoTile(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: _email),
                    if (_address.isNotEmpty)
                      _InfoTile(
                          icon: Icons.location_on_outlined,
                          label: 'Default Address',
                          value: _address),
                    const SizedBox(height: 20),
                  ],

                  // ── Quick links ──────────────────────────────────────────
                  const _SectionLabel('Quick Links'),
                  _ProfileAction(
                    icon: Icons.receipt_long_rounded,
                    label: 'My Order History',
                    onTap: () =>
                        Navigator.pushNamed(context, '/order-history'),
                  ),
                  _ProfileAction(
                    icon: Icons.login_rounded,
                    label: isLoggedIn ? 'Switch Account / Sign In' : 'Sign In',
                    onTap: () => Navigator.pushNamed(context, '/login'),
                  ),
                  _ProfileAction(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Create an Account',
                    onTap: () => Navigator.pushNamed(context, '/register'),
                  ),

                  const SizedBox(height: 20),

                  // ── Settings ─────────────────────────────────────────────
                  const _SectionLabel('Settings'),
                  _ProfileAction(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    trailing: Switch(
                      value: true,
                      onChanged: (_) => _snack(context, 'Notification settings coming soon.'),
                      activeThumbColor: const Color(0xFFC62828),
                    ),
                    onTap: () {},
                  ),
                  _ProfileAction(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    trailing: Switch(
                      value: context.watch<ThemeProvider>().isDark,
                      onChanged: (_) => context.read<ThemeProvider>().toggle(),
                      activeThumbColor: const Color(0xFFC62828),
                    ),
                    onTap: () => context.read<ThemeProvider>().toggle(),
                  ),
                  _ProfileAction(
                    icon: Icons.info_outline_rounded,
                    label: 'About App',
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'Drink & Provision Hub',
                      applicationVersion: '1.0.0',
                      applicationLegalese:
                          '© 2026 Drink & Provision Hub. All rights reserved.',
                    ),
                  ),

                  // ── Admin Portal (only visible when admin is logged in) ──
                  if (_isAdmin) ...[  
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/admin-dashboard'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4A0000), Color(0xFFC62828)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.admin_panel_settings_rounded,
                                color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Admin Dashboard',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text('Manage orders & customers',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12)),
                              ],
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.white70, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Logout ────────────────────────────────────────────────
                  if (isLoggedIn)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.logout_rounded,
                            color: Colors.redAccent),
                        label: const Text('Sign Out',
                            style: TextStyle(color: Colors.redAccent)),
                        onPressed: () async {
                          final prefs =
                              await SharedPreferences.getInstance();
                          await prefs.remove(_nameKey);
                          await prefs.remove(_phoneKey);
                          await prefs.remove(_emailKey);
                          await prefs.remove(_addressKey);
                          await prefs.remove(_avatarKey);
                          await prefs.setBool('is_admin', false);
                          await _load();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Signed out.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String phone;
  final bool isLoggedIn;
  final String avatar;
  final VoidCallback onPickAvatar;

  const _ProfileHeader({
    required this.name,
    required this.phone,
    required this.isLoggedIn,
    required this.avatar,
    required this.onPickAvatar,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;
    if (avatar.isNotEmpty) {
      try {
        avatarImage = MemoryImage(base64Decode(avatar));
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7F0000), Color(0xFFEF5350)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onPickAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white24,
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? Text(
                          isLoggedIn && name.isNotEmpty
                              ? name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC62828),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      size: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isLoggedIn ? name : 'Guest User',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            isLoggedIn
                ? (phone.isEmpty ? 'Tap ✏️ to add phone' : phone)
                : 'Sign in to unlock all features',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFFC62828),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: const Color(0xFFC62828), size: 20),
        title:
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        subtitle:
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ProfileAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFC62828)),
        title: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
