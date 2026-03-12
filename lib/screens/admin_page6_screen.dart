import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Admin Page 6 â€“ Onboarding Screen Editor (Pages 1, 2 & 3).
class AdminPage6Screen extends StatefulWidget {
  const AdminPage6Screen({super.key});

  @override
  State<AdminPage6Screen> createState() => _AdminPage6ScreenState();
}

class _AdminPage6ScreenState extends State<AdminPage6Screen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF990000),
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
        title: const Text('Admin Page 6',
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
            tooltip: 'Admin Page 7',
            onPressed: () => Navigator.pushNamed(context, '/admin-page7'),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.looks_one_outlined), text: 'Page 1'),
            Tab(icon: Icon(Icons.looks_two_outlined), text: 'Page 2'),
            Tab(icon: Icon(Icons.looks_3_outlined), text: 'Page 3'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _OnboardEditor(
            pageLabel: 'Page 1 â€“ Welcome',
            imageKey: 'onboarding_page1_image',
            titleKey: 'onboarding_page1_title',
            subtitleKey: 'onboarding_page1_subtitle',
            defaultTitle: 'Welcome to\nDrink & Provision Hub',
            defaultSubtitle:
                'Your one-stop shop for drinks and\neveryday provisions in Ghana.',
          ),
          _OnboardEditor(
            pageLabel: 'Page 2 â€“ Drinks',
            imageKey: 'onboarding_page2_image',
            titleKey: 'onboarding_page2_title',
            subtitleKey: 'onboarding_page2_subtitle',
            defaultTitle: 'Get All Your\nDrinkables Here',
            defaultSubtitle:
                'Tap anywhere on this page\nto explore our Drink Shop \u2192',
          ),
          _OnboardEditor(
            pageLabel: 'Page 3 â€“ Provisions',
            imageKey: 'onboarding_page3_image',
            titleKey: 'onboarding_page3_title',
            subtitleKey: 'onboarding_page3_subtitle',
            defaultTitle: 'Get All Provisions\nin One Basket',
            defaultSubtitle:
                'We save your time and the hustle.\nTap anywhere to explore Provisions \u2192',
          ),
        ],
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Reusable onboarding page editor
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _OnboardEditor extends StatefulWidget {
  final String pageLabel;
  final String imageKey;
  final String titleKey;
  final String subtitleKey;
  final String defaultTitle;
  final String defaultSubtitle;

  const _OnboardEditor({
    required this.pageLabel,
    required this.imageKey,
    required this.titleKey,
    required this.subtitleKey,
    required this.defaultTitle,
    required this.defaultSubtitle,
  });

  @override
  State<_OnboardEditor> createState() => _OnboardEditorState();
}

class _OnboardEditorState extends State<_OnboardEditor>
    with AutomaticKeepAliveClientMixin {
  Uint8List? _imageBytes;
  bool _loading = true;
  bool _savingImage = false;
  bool _savingText = false;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _subtitleCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(widget.imageKey);
    setState(() {
      if (raw != null && raw.contains(',')) {
        _imageBytes = base64Decode(raw.split(',')[1]);
      }
      _titleCtrl.text = prefs.getString(widget.titleKey) ?? '';
      _subtitleCtrl.text = prefs.getString(widget.subtitleKey) ?? '';
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    final xfile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() => _savingImage = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        widget.imageKey, 'data:image/jpeg;base64,${base64Encode(bytes)}');
    if (mounted) {
      setState(() {
        _imageBytes = bytes;
        _savingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.pageLabel} image saved!'),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<void> _clearImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(widget.imageKey);
    setState(() => _imageBytes = null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.pageLabel} image removed.'),
        backgroundColor: Colors.orange,
      ));
    }
  }

  Future<void> _saveText() async {
    setState(() => _savingText = true);
    final prefs = await SharedPreferences.getInstance();
    final title = _titleCtrl.text.trim();
    final subtitle = _subtitleCtrl.text.trim();
    if (title.isEmpty) {
      await prefs.remove(widget.titleKey);
    } else {
      await prefs.setString(widget.titleKey, title);
    }
    if (subtitle.isEmpty) {
      await prefs.remove(widget.subtitleKey);
    } else {
      await prefs.setString(widget.subtitleKey, subtitle);
    }
    if (mounted) {
      setState(() => _savingText = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.pageLabel} text saved!'),
        backgroundColor: Colors.green,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Text(
            widget.pageLabel,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Leave blank to use the default gradient / text.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // â”€â”€ Image preview â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF5A0000),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageBytes != null
                  ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: Colors.white38, size: 48),
                        SizedBox(height: 8),
                        Text('Tap to choose image',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 13)),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // â”€â”€ Image buttons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _savingImage ? null : _pickImage,
                  icon: _savingImage
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.upload_rounded),
                  label: Text(_savingImage ? 'Savingâ€¦' : 'Upload Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              if (_imageBytes != null) ...[
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _clearImage,
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text('Remove'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),

          // â”€â”€ Text inputs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Card(
            color: const Color(0xFF7F0000),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Page Text',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    'Default: "${widget.defaultTitle.replaceAll('\n', ' ')}"',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  _textField('Title (leave blank for default)', _titleCtrl),
                  const SizedBox(height: 10),
                  _textField('Subtitle (leave blank for default)',
                      _subtitleCtrl,
                      maxLines: 3),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _savingText ? null : _saveText,
                      icon: _savingText
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_rounded),
                      label: Text(_savingText ? 'Savingâ€¦' : 'Save Text'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(String hint, TextEditingController ctrl,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF5A0000),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.amber),
        ),
      ),
    );
  }
}

