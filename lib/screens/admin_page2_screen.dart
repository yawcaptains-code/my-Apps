import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/categories_provider.dart';

/// Admin Page 2 – Editable category management for Drinks and Provisions.
class AdminPage2Screen extends StatefulWidget {
  const AdminPage2Screen({super.key});

  @override
  State<AdminPage2Screen> createState() => _AdminPage2ScreenState();
}

class _AdminPage2ScreenState extends State<AdminPage2Screen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
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
        title: const Text('Admin Page 2 – Categories',
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
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.local_bar_outlined), text: 'Drinks'),
            Tab(
                icon: Icon(Icons.shopping_basket_outlined),
                text: 'Provisions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _CategoryManager(type: 'drink'),
          _CategoryManager(type: 'provision'),
        ],
      ),
    );
  }
}

// ── Category Manager (one per tab) ────────────────────────────────────────────

class _CategoryManager extends StatelessWidget {
  final String type;
  const _CategoryManager({required this.type});

  Color get _accent =>
      type == 'drink' ? const Color(0xFFC62828) : const Color(0xFFC62828);

  String get _label => type == 'drink' ? 'Drink' : 'Provision';

  @override
  Widget build(BuildContext context) {
    final cats = type == 'drink'
        ? context.watch<CategoriesProvider>().drinkCategories
        : context.watch<CategoriesProvider>().provisionCategories;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accent.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: _accent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'These categories appear in the $_label Shop. '
                  'Tap ✏️ to edit or 🗑 to delete.',
                  style: TextStyle(
                      fontSize: 12, color: _accent.withValues(alpha: 0.8)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: cats.isEmpty
              ? _EmptyState(accent: _accent, label: _label)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cats.length,
                  itemBuilder: (ctx, i) => _CategoryTile(
                    cat: cats[i],
                    type: type,
                    accent: _accent,
                  ),
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: Text('Add $_label Category',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () =>
                        _showCategorySheet(context, type, _accent),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: Icon(Icons.restore_rounded,
                      color: _accent.withValues(alpha: 0.7), size: 16),
                  label: Text('Reset to defaults',
                      style: TextStyle(
                          color: _accent.withValues(alpha: 0.7), fontSize: 12)),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        title: const Text('Reset Categories'),
                        content: Text(
                            'Replace all $_label categories with defaults?'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _accent),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      await context
                          .read<CategoriesProvider>()
                          .resetToDefaults(type);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Category Tile ─────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final ShopCategory cat;
  final String type;
  final Color accent;

  const _CategoryTile(
      {required this.cat, required this.type, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1.5,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: cat.color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: cat.color.withValues(alpha: 0.4)),
          ),
          child: cat.imageDataUri != null
              ? ClipOval(
                  child: Image.memory(
                    base64Decode(cat.imageDataUri!.split(',').last),
                    fit: BoxFit.cover,
                    width: 52,
                    height: 52,
                  ),
                )
              : Center(
                  child: Text(cat.emoji,
                      style: const TextStyle(fontSize: 26)),
                ),
        ),
        title: Text(cat.name,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                  color: cat.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '#${cat.colorValue.toRadixString(16).substring(2).toUpperCase()}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: accent),
              tooltip: 'Edit',
              onPressed: () =>
                  _showCategorySheet(context, type, accent, existing: cat),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.red),
              tooltip: 'Delete',
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    title: const Text('Delete Category'),
                    content: Text(
                        'Delete "${cat.name}"? This cannot be undone.'),
                    actions: [
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await context
                      .read<CategoriesProvider>()
                      .deleteCategory(type, cat.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add / Edit Bottom Sheet ───────────────────────────────────────────────────

void _showCategorySheet(
  BuildContext context,
  String type,
  Color accent, {
  ShopCategory? existing,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _CategorySheet(
      type: type,
      accent: accent,
      existing: existing,
    ),
  );
}

class _CategorySheet extends StatefulWidget {
  final String type;
  final Color accent;
  final ShopCategory? existing;

  const _CategorySheet(
      {required this.type, required this.accent, this.existing});

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  late final TextEditingController _nameCtrl;
  late String _emoji;
  late int _colorValue;
  String? _imageDataUri;
  Uint8List? _pickedBytes;
  bool _saving = false;

  static const List<int> _colors = [
    0xFFC62828, 0xFFEF9A9A, 0xFFF4A261, 0xFFEF5350,
    0xFFC62828, 0xFFE57373, 0xFFE76F51, 0xFFE9C46A,
    0xFFB56576, 0xFF6366F1, 0xFF10B981, 0xFFEF4444,
  ];

  static const List<String> _drinkEmojis = [
    '🍺', '🍹', '🥤', '🍾', '🍸', '🥃',
    '🍶', '🧃', '☕', '🍵', '🥂', '🍷',
    '🧋', '🫗', '🧊', '🍻', '🌊', '🍒',
  ];

  static const List<String> _provisionEmojis = [
    '🍪', '🍚', '🧼', '🧴', '🥚', '🫙',
    '🥫', '🧈', '🍞', '🥦', '🧅', '🫒',
    '🥩', '🍫', '🍬', '🥜', '🫘', '🧂',
    '🌽', '🥛', '🛒', '📦', '🧺', '🍳',
  ];

  List<String> get _emojis =>
      widget.type == 'drink' ? _drinkEmojis : _provisionEmojis;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.existing?.name ?? '');
    _emoji = widget.existing?.emoji ??
        (widget.type == 'drink' ? '🍹' : '🛒');
    _colorValue = widget.existing?.colorValue ??
        (widget.type == 'drink' ? 0xFFC62828 : 0xFFC62828);
    // Pre-populate existing image
    if (widget.existing?.imageDataUri != null) {
      _imageDataUri = widget.existing!.imageDataUri;
      final b64 = _imageDataUri!.split(',').last;
      _pickedBytes = base64Decode(b64);
    }
  }

  Future<void> _pickImage() async {
    final xfile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() {
      _pickedBytes = bytes;
      _imageDataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    });
  }

  void _removeImage() {
    setState(() {
      _pickedBytes = null;
      _imageDataUri = null;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a category name.')),
      );
      return;
    }
    setState(() => _saving = true);
    final provider = context.read<CategoriesProvider>();
    if (widget.existing != null) {
      await provider.editCategory(widget.type, widget.existing!.id,
          name, _emoji, _colorValue, imageDataUri: _imageDataUri);
    } else {
      await provider.addCategory(
          widget.type, name, _emoji, _colorValue,
          imageDataUri: _imageDataUri);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.existing != null
            ? 'Category updated!'
            : 'Category added!'),
        backgroundColor: widget.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                      isEdit
                          ? Icons.edit_outlined
                          : Icons.add_rounded,
                      color: widget.accent,
                      size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  isEdit ? 'Edit Category' : 'New Category',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Image upload widget
            const Text('Category Image (optional)',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF990000),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.accent.withValues(alpha: 0.4),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _pickedBytes != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.memory(_pickedBytes!,
                                fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Tap to change',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10)),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined,
                              size: 36,
                              color: widget.accent.withValues(alpha: 0.6)),
                          const SizedBox(height: 6),
                          Text('Tap to upload image',
                              style: TextStyle(
                                  color:
                                      widget.accent.withValues(alpha: 0.7),
                                  fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('(shows instead of emoji in shop)',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Preview circle
            Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Color(_colorValue),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(_colorValue).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _pickedBytes != null
                    ? ClipOval(
                        child: Image.memory(_pickedBytes!,
                            fit: BoxFit.cover,
                            width: 70,
                            height: 70),
                      )
                    : Center(
                        child: Text(_emoji,
                            style: const TextStyle(fontSize: 32)),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Name
            const Text('Category Name',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: widget.type == 'drink'
                    ? 'e.g. Alcoholic'
                    : 'e.g. Biscuits',
                prefixIcon: Icon(Icons.label_outline,
                    color: widget.accent),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: widget.accent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Emoji picker
            const Text('Choose Logo / Emoji',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _emojis.map((e) {
                  final sel = e == _emoji;
                  return GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: sel
                            ? Color(_colorValue).withValues(alpha: 0.2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel
                              ? Color(_colorValue)
                              : Colors.grey.shade200,
                          width: sel ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(e,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Color picker
            const Text('Choose Color',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colors.map((c) {
                final sel = c == _colorValue;
                return GestureDetector(
                  onTap: () => setState(() => _colorValue = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: sel
                            ? Colors.black54
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: Color(c).withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: sel
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Icon(isEdit
                        ? Icons.check_circle_outline_rounded
                        : Icons.add_circle_outline_rounded),
                label: Text(
                  _saving
                      ? 'Saving…'
                      : isEdit
                          ? 'Save Changes'
                          : 'Add Category',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final Color accent;
  final String label;

  const _EmptyState(
      {required this.accent, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined,
              size: 64, color: accent.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No $label categories yet.',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Tap the button below to add one.',
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
