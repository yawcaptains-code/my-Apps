import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/contact_info_provider.dart';

/// Admin Page 3 – Contact Settings | Messages | Reports.
class AdminPage3Screen extends StatefulWidget {
  final int initialTab;
  const AdminPage3Screen({super.key, this.initialTab = 0});

  @override
  State<AdminPage3Screen> createState() => _AdminPage3ScreenState();
}

class _AdminPage3ScreenState extends State<AdminPage3Screen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTab);
    _loadUnread();
    _tab.addListener(() {
      if (_tab.index == 1) {
        // Immediately clear badge when admin opens messages tab
        setState(() => _unreadCount = 0);
      } else {
        _loadUnread();
      }
    });
  }

  Future<void> _loadUnread() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('chat_messages');
    int total = 0;
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      total = list
          .where((e) => (e as Map<String, dynamic>)['isUser'] == true)
          .length;
    }
    final seen = prefs.getInt('admin_msgs_seen_count') ?? 0;
    if (mounted) {
      setState(() => _unreadCount = (total - seen).clamp(0, 999));
    }
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
        title: const Text('Admin Page 3',
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
            tooltip: 'Admin Page 4',
            onPressed: () => Navigator.pushNamed(context, '/admin-page4'),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            const Tab(
                icon: Icon(Icons.contact_phone_rounded), text: 'Contact'),
            Tab(
              text: 'Messages',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded),
                  if (_unreadCount > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(
                            minWidth: 16, minHeight: 16),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _unreadCount > 99 ? '99+' : '$_unreadCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Tab(
                icon: Icon(Icons.flag_outlined), text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          const _ContactSettingsTab(),
          _MessagesTab(onViewed: () => setState(() => _unreadCount = 0)),
          const _ReportsTab(),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 1 – Contact Settings
// ══════════════════════════════════════════════════════════════════════════════

class _ContactSettingsTab extends StatefulWidget {
  const _ContactSettingsTab();
  @override
  State<_ContactSettingsTab> createState() => _ContactSettingsTabState();
}

class _ContactSettingsTabState extends State<_ContactSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _waCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ContactInfoProvider>();
    _phoneCtrl = TextEditingController(text: provider.phone);
    _waCtrl = TextEditingController(text: provider.whatsapp);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _waCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await context.read<ContactInfoProvider>().save(
          phone: _phoneCtrl.text,
          whatsapp: _waCtrl.text,
        );
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅  Contact info saved successfully!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFFC62828),
      ),
    );
  }

  Future<void> _testPhone() async {
    final number = _phoneCtrl.text.trim();
    if (number.isEmpty) return;
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _testWhatsApp() async {
    final number = _waCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (number.isEmpty) return;
    final uri = Uri.parse(
        'https://wa.me/$number?text=Hello%2C%20I%20would%20like%20to%20place%20an%20order');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header card ───────────────────────────────────────────────
              const _InfoBanner(
                icon: Icons.contact_phone_rounded,
                title: 'Company Contact Numbers',
                subtitle:
                    'Set the phone and WhatsApp numbers that customers will '
                    'call or message when they tap the icons in the app.',
              ),

              const SizedBox(height: 28),

              // ── Phone number ──────────────────────────────────────────────
              const _SectionLabel(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  color: Color(0xFFEF9A9A)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'e.g. +233244000000',
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: Color(0xFFEF9A9A)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFFDDE3EA)),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Test button
                  _TestButton(
                    icon: Icons.call_rounded,
                    color: const Color(0xFFEF9A9A),
                    tooltip: 'Test call',
                    onTap: _testPhone,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── WhatsApp number ───────────────────────────────────────────
              const _SectionLabel(
                  icon: Icons.message_rounded,
                  label: 'WhatsApp Number',
                  color: Color(0xFF25D366)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _waCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'e.g. +233244000000',
                        prefixIcon: const Icon(Icons.message_rounded,
                            color: Color(0xFF25D366)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFFDDE3EA)),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter a WhatsApp number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Test button
                  _TestButton(
                    icon: Icons.send_rounded,
                    color: const Color(0xFF25D366),
                    tooltip: 'Test WhatsApp',
                    onTap: _testWhatsApp,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Note about test buttons
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tap the action buttons beside each field to test the '
                      'number before saving.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // ── Save button ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _saving ? 'Saving…' : 'Save Contact Info',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF990000),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Live preview ──────────────────────────────────────────────
              _LivePreview(
                phoneCtrl: _phoneCtrl,
                waCtrl: _waCtrl,
                onPhone: _testPhone,
                onWhatsApp: _testWhatsApp,
              ),
            ],
          ),
        ),
      );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 2 – Messages (reads customer chat from SharedPreferences)
// ══════════════════════════════════════════════════════════════════════════════

// ── Shared chat message model for admin view ─────────────────────────────────
class _AdminChatMsg {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  const _AdminChatMsg(
      {required this.id,
      required this.text,
      required this.isUser,
      required this.timestamp});
}

class _MessagesTab extends StatefulWidget {
  final VoidCallback? onViewed;
  const _MessagesTab({this.onViewed});
  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
  static const _chatKey = 'chat_messages';
  static const _seenKey = 'admin_msgs_seen_count';
  List<_AdminChatMsg> _messages = [];
  bool _loading = true;
  bool _sending = false;
  final _replyCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chatKey);
    final List<_AdminChatMsg> result = [];
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final e in list) {
        final map = e as Map<String, dynamic>;
        result.add(_AdminChatMsg(
          id: map['id'] as String,
          text: map['text'] as String,
          isUser: map['isUser'] as bool,
          timestamp: DateTime.parse(map['timestamp'] as String),
        ));
      }
    }
    // Chronological order (oldest first) for chat view
    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    // Mark all as seen
    final userCount = result.where((m) => m.isUser).length;
    await prefs.setInt(_seenKey, userCount);
    setState(() {
      _messages = result;
      _loading = false;
    });
    // Notify parent to reset the badge to 0
    widget.onViewed?.call();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendReply() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;
    _replyCtrl.clear();
    setState(() => _sending = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chatKey);
    final List<Map<String, dynamic>> all = [];
    if (raw != null) {
      all.addAll((jsonDecode(raw) as List).cast<Map<String, dynamic>>());
    }
    final newMsg = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'text': text,
      'isUser': false,
      'timestamp': DateTime.now().toIso8601String(),
    };
    all.add(newMsg);
    await prefs.setString(_chatKey, jsonEncode(all));
    setState(() {
      _messages.add(_AdminChatMsg(
        id: newMsg['id'] as String,
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _sending = false;
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Chat History'),
        content: const Text(
            'This will delete all saved chat messages. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatKey);
    await prefs.setInt(_seenKey, 0);
    _load();
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final userCount = _messages.where((m) => m.isUser).length;
    return Column(
      children: [
        // ── Toolbar ────────────────────────────────────────────────────────
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$userCount customer message${userCount == 1 ? '' : 's'}',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700),
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh',
                  onPressed: _load),
              if (_messages.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: Colors.red),
                  tooltip: 'Clear all',
                  onPressed: _clearAll,
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        // ── Conversation ───────────────────────────────────────────────────
        Expanded(
          child: _messages.isEmpty
              ? const _EmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'No messages yet',
                  sub:
                      'Customer chat messages will appear here when sent.')
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = _messages[i];
                    final isUser = msg.isUser;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isUser) ...
                            [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFFC62828)
                                    .withValues(alpha: 0.15),
                                child: const Icon(Icons.person_rounded,
                                    size: 16,
                                    color: Color(0xFFC62828)),
                              ),
                              const SizedBox(width: 6),
                            ],
                          Flexible(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.sizeOf(ctx).width * 0.68,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 9),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Theme.of(ctx).colorScheme.surface
                                    : const Color(0xFF990000),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft:
                                      Radius.circular(isUser ? 4 : 16),
                                  bottomRight:
                                      Radius.circular(isUser ? 16 : 4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.07),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isUser
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                                children: [
                                  if (!isUser)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 3),
                                      child: Text(
                                        'Admin',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade300),
                                      ),
                                    ),
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                        color: isUser
                                            ? Theme.of(ctx).colorScheme.onSurface
                                            : Colors.white,
                                        fontSize: 14,
                                        height: 1.4),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _fmtTime(msg.timestamp),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: isUser
                                            ? Colors.grey.shade400
                                            : Colors.white54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!isUser) ...
                            [
                              const SizedBox(width: 6),
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFF990000)
                                    .withValues(alpha: 0.15),
                                child: const Icon(
                                    Icons.admin_panel_settings_rounded,
                                    size: 16,
                                    color: Color(0xFF990000)),
                              ),
                            ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        // ── Reply input ────────────────────────────────────────────────────
        const Divider(height: 1),
        SafeArea(
          top: false,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Reply to customer…',
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFF990000),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendReply(),
                  ),
                ),
                const SizedBox(width: 8),
                _sending
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF990000)),
                        ))
                    : FloatingActionButton.small(
                        heroTag: 'admin_reply_fab',
                        backgroundColor: const Color(0xFF990000),
                        onPressed: _sendReply,
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 3 – Reports
// ══════════════════════════════════════════════════════════════════════════════

class _ReportsTab extends StatefulWidget {
  const _ReportsTab();
  @override
  State<_ReportsTab> createState() => _ReportsTabState();
}

class _UserReport {
  final String id;
  final String name;
  final String issue;
  final DateTime timestamp;
  bool read;

  _UserReport({
    required this.id,
    required this.name,
    required this.issue,
    required this.timestamp,
    this.read = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'issue': issue,
        'timestamp': timestamp.toIso8601String(),
        'read': read,
      };

  factory _UserReport.fromJson(Map<String, dynamic> j) => _UserReport(
        id: j['id'] as String,
        name: j['name'] as String? ?? 'Anonymous',
        issue: j['issue'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        read: j['read'] as bool? ?? false,
      );
}

class _ReportsTabState extends State<_ReportsTab> {
  static const _key = 'user_reports';
  List<_UserReport> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    List<_UserReport> result = [];
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      result = list
          .map((e) => _UserReport.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {
      _reports = result;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_reports.map((r) => r.toJson()).toList()));
  }

  Future<void> _markRead(_UserReport r) async {
    if (r.read) return;
    setState(() => r.read = true);
    await _save();
  }

  Future<void> _delete(_UserReport r) async {
    setState(() => _reports.remove(r));
    await _save();
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Reports'),
        content:
            const Text('Delete all issue reports? Cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _reports.clear());
    await _save();
  }

  String _fmt(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _openDetail(BuildContext ctx, _UserReport r) {
    _markRead(r);
    showDialog<void>(
      context: ctx,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.flag_outlined, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
              child: Text(r.name, overflow: TextOverflow.ellipsis)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Issue:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey)),
            const SizedBox(height: 4),
            Text(r.issue),
            const SizedBox(height: 12),
            Text(
              'Submitted: ${r.timestamp.day}/${r.timestamp.month}/${r.timestamp.year}  '
              '${r.timestamp.hour.toString().padLeft(2, '0')}:'
              '${r.timestamp.minute.toString().padLeft(2, '0')}',
              style:
                  TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _delete(r);
              Navigator.pop(ctx);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF990000)),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final unread = _reports.where((r) => !r.read).length;
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_reports.length} report${_reports.length == 1 ? '' : 's'}'
                  '${unread > 0 ? '  •  $unread unread' : ''}',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: unread > 0
                          ? Colors.red.shade700
                          : Colors.grey.shade700),
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh',
                  onPressed: _load),
              if (_reports.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: Colors.red),
                  tooltip: 'Clear all',
                  onPressed: _clearAll,
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _reports.isEmpty
              ? const _EmptyState(
                  icon: Icons.flag_outlined,
                  label: 'No reports yet',
                  sub:
                      'Issue reports submitted by customers will appear here.')
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _reports.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final r = _reports[i];
                    return Dismissible(
                      key: ValueKey(r.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                      onDismissed: (_) => _delete(r),
                      child: Card(
                        margin: EdgeInsets.zero,
                        color: r.read
                            ? Colors.white
                            : const Color(0xFFFFF8E1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: r.read
                              ? BorderSide.none
                              : BorderSide(
                                  color: Colors.orange.shade200,
                                  width: 1.5),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: r.read
                                ? Colors.grey.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.15),
                            child: Icon(Icons.flag_outlined,
                                color: r.read
                                    ? Colors.grey
                                    : Colors.orange.shade700),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  r.name,
                                  style: TextStyle(
                                    fontWeight: r.read
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (!r.read)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Text('NEW',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight:
                                              FontWeight.bold)),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 3),
                              Text(
                                r.issue,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(_fmt(r.timestamp),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500)),
                            ],
                          ),
                          onTap: () => _openDetail(ctx, r),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Shared empty state ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  const _EmptyState(
      {required this.icon, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(label,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(sub,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InfoBanner(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF990000), Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey.shade800)),
      ],
    );
  }
}

class _TestButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _TestButton(
      {required this.icon,
      required this.color,
      required this.tooltip,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 52,
            height: 56,
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

/// Shows a real-time preview of what the contact icons will look like in
/// the orders screen.
class _LivePreview extends StatefulWidget {
  final TextEditingController phoneCtrl;
  final TextEditingController waCtrl;
  final VoidCallback onPhone;
  final VoidCallback onWhatsApp;

  const _LivePreview({
    required this.phoneCtrl,
    required this.waCtrl,
    required this.onPhone,
    required this.onWhatsApp,
  });

  @override
  State<_LivePreview> createState() => _LivePreviewState();
}

class _LivePreviewState extends State<_LivePreview> {
  @override
  void initState() {
    super.initState();
    widget.phoneCtrl.addListener(_rebuild);
    widget.waCtrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.phoneCtrl.removeListener(_rebuild);
    widget.waCtrl.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.phoneCtrl.text.trim();
    final wa = widget.waCtrl.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.preview_rounded,
                size: 16, color: Color(0xFF990000)),
            SizedBox(width: 6),
            Text('Live Preview',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF990000))),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'This is how the icons will appear and behave in the app:',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDE3EA)),
          ),
          child: Column(
            children: [
              _PreviewTile(
                icon: Icons.phone_outlined,
                color: const Color(0xFFEF9A9A),
                label: 'Phone Call',
                value: phone.isEmpty ? '(not set)' : phone,
                onTap: phone.isNotEmpty ? widget.onPhone : null,
              ),
              const Divider(height: 20),
              _PreviewTile(
                icon: Icons.message_rounded,
                color: const Color(0xFF25D366),
                label: 'WhatsApp',
                value: wa.isEmpty ? '(not set)' : wa,
                onTap: wa.isNotEmpty ? widget.onWhatsApp : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _PreviewTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(value,
                      style: TextStyle(
                          fontSize: 12,
                          color: value == '(not set)'
                              ? Colors.grey
                              : Colors.grey.shade700)),
                ],
              ),
            ),
            Icon(
              onTap != null ? Icons.open_in_new_rounded : Icons.block_rounded,
              size: 16,
              color: onTap != null ? color : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
