import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/home_shop_provider.dart';

/// Admin Page 4 – HOME tile editor.
/// Lets the admin customise the label, subtitle, and image shown on
/// the two "Our Shop" tiles (Drink & Provision) on the Home screen.
class AdminPage4Screen extends StatefulWidget {
  const AdminPage4Screen({super.key});

  @override
  State<AdminPage4Screen> createState() => _AdminPage4ScreenState();
}

class _AdminPage4ScreenState extends State<AdminPage4Screen> {
  // Logo
  String _logoImageUrl = '';

  // Drink tile controllers
  late TextEditingController _drinkLabelCtrl;
  late TextEditingController _drinkSubCtrl;
  String _drinkImageUrl = '';

  // Provision tile controllers
  late TextEditingController _provLabelCtrl;
  late TextEditingController _provSubCtrl;
  String _provImageUrl = '';

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<HomeShopProvider>();
    _logoImageUrl   = p.logoImageUrl;
    _drinkLabelCtrl = TextEditingController(text: p.drinkLabel);
    _drinkSubCtrl   = TextEditingController(text: p.drinkSubtitle);
    _drinkImageUrl  = p.drinkImageUrl;
    _provLabelCtrl  = TextEditingController(text: p.provisionLabel);
    _provSubCtrl    = TextEditingController(text: p.provisionSubtitle);
    _provImageUrl   = p.provisionImageUrl;
  }

  @override
  void dispose() {
    _drinkLabelCtrl.dispose();
    _drinkSubCtrl.dispose();
    _provLabelCtrl.dispose();
    _provSubCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85, maxWidth: 800);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _logoImageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}');
  }

  Future<void> _pickImage(bool isDrink) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final b64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    setState(() {
      if (isDrink) {
        _drinkImageUrl = b64;
      } else {
        _provImageUrl = b64;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<HomeShopProvider>().save(
          logoImageUrl:      _logoImageUrl,
          drinkLabel:        _drinkLabelCtrl.text.trim().isEmpty
              ? 'Drink Shop' : _drinkLabelCtrl.text.trim(),
          drinkSubtitle:     _drinkSubCtrl.text.trim(),
          drinkImageUrl:     _drinkImageUrl,
          provisionLabel:    _provLabelCtrl.text.trim().isEmpty
              ? 'Provision Shop' : _provLabelCtrl.text.trim(),
          provisionSubtitle: _provSubCtrl.text.trim(),
          provisionImageUrl: _provImageUrl,
        );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅  Home page tiles updated!'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2D0000), Color(0xFF990000), Color(0xFFC62828)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: const Text('HOME',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            tooltip: 'Admin Page 5',
            onPressed: () => Navigator.pushNamed(context, '/admin-page5'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              icon: Icons.home_rounded,
              title: 'Home Page — "Our Shop" Tiles',
              subtitle: 'Customise the two shop cards shown to users',
            ),
            const SizedBox(height: 20),

            // ── LESFAM LOGO ────────────────────────────────────────────────
            _LogoEditor(
              imageUrl: _logoImageUrl,
              onPickImage: _pickLogo,
              onClearImage: () => setState(() => _logoImageUrl = ''),
            ),

            const SizedBox(height: 24),

            // ── Drink tile ─────────────────────────────────────────────────
            _TileEditor(
              sectionTitle: '🍺  Drink Shop Tile',
              labelCtrl: _drinkLabelCtrl,
              subtitleCtrl: _drinkSubCtrl,
              imageUrl: _drinkImageUrl,
              onPickImage: () => _pickImage(true),
              onClearImage: () => setState(() => _drinkImageUrl = ''),
              accentColor: const Color(0xFFC62828),
            ),

            const SizedBox(height: 24),

            // ── Provision tile ─────────────────────────────────────────────
            _TileEditor(
              sectionTitle: '🛒  Provision Shop Tile',
              labelCtrl: _provLabelCtrl,
              subtitleCtrl: _provSubCtrl,
              imageUrl: _provImageUrl,
              onPickImage: () => _pickImage(false),
              onClearImage: () => setState(() => _provImageUrl = ''),
              accentColor: const Color(0xFFEF5350),
            ),

            const SizedBox(height: 32),

            // ── Save button ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Saving…' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFC62828),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Logo editor ─────────────────────────────────────────────────────────────

class _LogoEditor extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;

  const _LogoEditor({
    required this.imageUrl,
    required this.onPickImage,
    required this.onClearImage,
  });

  Widget _preview() {
    if (imageUrl.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF7F0000).withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF7F0000).withValues(alpha: 0.25)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_outlined,
                  size: 40,
                  color: const Color(0xFF7F0000).withValues(alpha: 0.35)),
              const SizedBox(height: 6),
              Text('No logo set',
                  style: TextStyle(
                      color: const Color(0xFF7F0000).withValues(alpha: 0.4),
                      fontSize: 13)),
            ],
          ),
        ),
      );
    }
    try {
      final bytes = base64Decode(imageUrl.split(',')[1]);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(bytes,
            height: 120, width: double.infinity, fit: BoxFit.contain),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🖼️  LESFAM LOGO',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF7F0000)),
            ),
            const SizedBox(height: 4),
            Text(
              'Upload the logo shown in the home page welcome banner',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600]),
            ),
            const SizedBox(height: 14),
            _preview(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickImage,
                    icon: const Icon(Icons.upload_rounded),
                    label: const Text('Upload Logo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7F0000),
                      side: const BorderSide(color: Color(0xFF7F0000)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                if (imageUrl.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  IconButton(
                    tooltip: 'Remove logo',
                    onPressed: onClearImage,
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.red),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SectionHeader(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F0000), Color(0xFFC62828)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Per-tile editor ───────────────────────────────────────────────────────────

class _TileEditor extends StatelessWidget {
  final String sectionTitle;
  final TextEditingController labelCtrl;
  final TextEditingController subtitleCtrl;
  final String imageUrl;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;
  final Color accentColor;

  const _TileEditor({
    required this.sectionTitle,
    required this.labelCtrl,
    required this.subtitleCtrl,
    required this.imageUrl,
    required this.onPickImage,
    required this.onClearImage,
    required this.accentColor,
  });

  Widget _buildPreview() {
    if (imageUrl.isEmpty) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: accentColor.withValues(alpha: 0.3), style: BorderStyle.solid),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_outlined,
                  size: 40, color: accentColor.withValues(alpha: 0.4)),
              const SizedBox(height: 6),
              Text('No image set',
                  style: TextStyle(
                      color: accentColor.withValues(alpha: 0.5), fontSize: 13)),
            ],
          ),
        ),
      );
    }
    try {
      final bytes = base64Decode(imageUrl.split(',')[1]);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(bytes,
            height: 140, width: double.infinity, fit: BoxFit.cover),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sectionTitle,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: accentColor)),
            const SizedBox(height: 14),

            // Label field
            TextFormField(
              controller: labelCtrl,
              decoration: InputDecoration(
                labelText: 'Tile Label',
                hintText: 'e.g. Drink Shop',
                prefixIcon: const Icon(Icons.title_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: accentColor, width: 2)),
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle field
            TextFormField(
              controller: subtitleCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Subtitle / Description',
                hintText: 'Short description shown under the label',
                prefixIcon: const Icon(Icons.notes_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: accentColor, width: 2)),
              ),
            ),
            const SizedBox(height: 16),

            // Image preview
            _buildPreview(),
            const SizedBox(height: 12),

            // Image action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickImage,
                    icon: const Icon(Icons.upload_rounded),
                    label: const Text('Upload Image'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentColor,
                      side: BorderSide(color: accentColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                if (imageUrl.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  IconButton(
                    tooltip: 'Remove image',
                    onPressed: onClearImage,
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.red),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

