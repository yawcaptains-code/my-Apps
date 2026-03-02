import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/orders_provider.dart';
import '../providers/products_provider.dart';
import '../providers/carousel_provider.dart';
import '../models/order.dart';
import '../models/product_model.dart';

/// Admin Dashboard Screen
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTab = 0; // 0=Overview, 1=Orders, 2=Customers, 3=Products

  void _logout() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from admin portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_admin', false);
              if (!mounted) return;
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final orders = ordersProvider.orders;

    final totalRevenue =
        orders.fold<double>(0, (sum, o) => sum + o.total);
    final pending =
        orders.where((o) => o.status == 'Pending').length;
    final confirmed =
        orders.where((o) => o.status == 'Confirmed').length;
    final delivered =
        orders.where((o) => o.status == 'Delivered').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003557),
        foregroundColor: Colors.white,
        title: const Text('Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            tooltip: 'Admin Page 2',
            onPressed: () =>
                Navigator.pushNamed(context, '/admin-page2'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Tab Bar ───────────────────────────────────────────────────────
          Container(
            color: const Color(0xFF003557),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TabButton(
                      label: 'Overview',
                      icon: Icons.dashboard_outlined,
                      selected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0)),
                  _TabButton(
                      label: 'Orders',
                      icon: Icons.receipt_long_outlined,
                      selected: _selectedTab == 1,
                      badge: pending,
                      onTap: () => setState(() => _selectedTab = 1)),
                  _TabButton(
                      label: 'Customers',
                      icon: Icons.people_outline,
                      selected: _selectedTab == 2,
                      onTap: () => setState(() => _selectedTab = 2)),
                  _TabButton(
                      label: 'Products',
                      icon: Icons.inventory_2_outlined,
                      selected: _selectedTab == 3,
                      onTap: () => setState(() => _selectedTab = 3)),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: _selectedTab == 0
                ? _OverviewTab(
                    totalOrders: orders.length,
                    totalRevenue: totalRevenue,
                    pending: pending,
                    confirmed: confirmed,
                    delivered: delivered,
                    recentOrders: orders.take(5).toList(),
                    onViewAll: () => setState(() => _selectedTab = 1),
                  )
                : _selectedTab == 1
                    ? _OrdersTab(orders: orders)
                    : _selectedTab == 2
                        ? _CustomersTab(orders: orders)
                        : const _ProductsTab(),
          ),
        ],
      ),
    );
  }
}

// ── Tab Button ────────────────────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    this.badge = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? Colors.white : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    color: selected ? Colors.white : Colors.white54,
                    size: 20),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white54,
                    fontSize: 11,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            if (badge > 0)
              Positioned(
                top: 0,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final int totalOrders;
  final double totalRevenue;
  final int pending;
  final int confirmed;
  final int delivered;
  final List<OrderModel> recentOrders;
  final VoidCallback onViewAll;

  const _OverviewTab({
    required this.totalOrders,
    required this.totalRevenue,
    required this.pending,
    required this.confirmed,
    required this.delivered,
    required this.recentOrders,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),

          // ── Stat cards row 1 ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Orders',
                  value: '$totalOrders',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF0077B6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Revenue',
                  value: 'GH₵ ${totalRevenue.toStringAsFixed(2)}',
                  icon: Icons.attach_money_rounded,
                  color: const Color(0xFF2ECC71),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Stat cards row 2 ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Pending',
                  value: '$pending',
                  icon: Icons.hourglass_empty_rounded,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Confirmed',
                  value: '$confirmed',
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF0077B6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Delivered',
                  value: '$delivered',
                  icon: Icons.local_shipping_outlined,
                  color: const Color(0xFF2ECC71),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Recent orders ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Orders',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recentOrders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No orders yet.',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...recentOrders.map((o) => _OrderListTile(order: o)),
        ],
      ),
    );
  }
}

// ── Orders Tab ────────────────────────────────────────────────────────────────

class _OrdersTab extends StatefulWidget {
  final List<OrderModel> orders;
  const _OrdersTab({required this.orders});

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  String _filter = 'All';

  static const _filters = ['All', 'Pending', 'Confirmed', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All'
        ? widget.orders
        : widget.orders.where((o) => o.status == _filter).toList();

    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final isSelected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor:
                        const Color(0xFF0077B6).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF0077B6),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF0077B6)
                          : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('No orders found.',
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) =>
                      _OrderListTile(order: filtered[i], showActions: true),
                ),
        ),
      ],
    );
  }
}

// ── Customers Tab ─────────────────────────────────────────────────────────────

class _CustomersTab extends StatelessWidget {
  final List<OrderModel> orders;
  const _CustomersTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    // Deduplicate by phone
    final Map<String, Map<String, dynamic>> customers = {};
    for (final o in orders) {
      if (customers.containsKey(o.phone)) {
        customers[o.phone]!['orders'] =
            (customers[o.phone]!['orders'] as int) + 1;
        customers[o.phone]!['spent'] =
            (customers[o.phone]!['spent'] as double) + o.total;
      } else {
        customers[o.phone] = {
          'name': o.recipientName,
          'phone': o.phone,
          'address': o.address,
          'orders': 1,
          'spent': o.total,
        };
      }
    }
    final list = customers.values.toList();

    return list.isEmpty
        ? const Center(
            child: Text('No customers yet.',
                style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final c = list[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xFF0077B6).withOpacity(0.15),
                    child: Text(
                      (c['name'] as String)
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFF0077B6),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(c['name'] as String,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${c['phone']}  •  ${c['address']}',
                      style: const TextStyle(fontSize: 12)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${c['orders']} order${(c['orders'] as int) > 1 ? 's' : ''}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'GH₵ ${(c['spent'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2ECC71)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ── Order List Tile ───────────────────────────────────────────────────────────

class _OrderListTile extends StatelessWidget {
  final OrderModel order;
  final bool showActions;

  const _OrderListTile({required this.order, this.showActions = false});

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFF0077B6);
      case 'Delivered':
        return const Color(0xFF2ECC71);
      default:
        return Colors.orange;
    }
  }

  Future<void> _updateStatus(BuildContext context) async {
    const statuses = ['Pending', 'Confirmed', 'Delivered'];
    final chosen = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update Order Status',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...statuses.map((s) {
              final isCurrent = s == order.status;
              final color = switch (s) {
                'Confirmed' => const Color(0xFF0077B6),
                'Delivered' => const Color(0xFF2ECC71),
                _ => Colors.orange,
              };
              return ListTile(
                leading: Icon(
                  isCurrent
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: color,
                ),
                title: Text(s,
                    style: TextStyle(
                        color: isCurrent ? color : Colors.black87,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal)),
                onTap: () => Navigator.pop(context, s),
              );
            }),
          ],
        ),
      ),
    );
    if (chosen != null && chosen != order.status) {
      await context.read<OrdersProvider>().updateStatus(order.id, chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(order.id,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(order.recipientName,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
            Text(order.phone,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GH₵ ${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003557),
                      fontSize: 15),
                ),
                Text(
                  _formatDate(order.placedAt),
                  style:
                      const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            if (showActions) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  // View items
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showOrderItems(context, order),
                      icon: const Icon(Icons.list_alt_outlined, size: 16),
                      label: const Text('Items',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 6),
                        side: const BorderSide(color: Color(0xFF0077B6)),
                        foregroundColor: const Color(0xFF0077B6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Update status
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(context),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Status',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003557),
                        padding:
                            const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showOrderItems(BuildContext context, OrderModel order) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items — ${order.id}',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...order.items.map(
              (item) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(item.name,
                    style: const TextStyle(fontSize: 13)),
                trailing: Text(
                  '${item.quantity} × GH₵ ${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'GH₵ ${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003557),
                      fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
// ── Products Tab ──────────────────────────────────────────────────────────────

class _ProductsTab extends StatefulWidget {
  const _ProductsTab();

  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Sub-tabs: Drinks | Provisions ─────────────────────────────────
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabCtrl,
            labelColor: const Color(0xFF003557),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF003557),
            tabs: const [
              Tab(icon: Icon(Icons.local_bar_outlined), text: 'Drinks'),
              Tab(
                  icon: Icon(Icons.shopping_basket_outlined),
                  text: 'Provisions'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: const [
              _ProductUploadPanel(category: 'drink'),
              _ProductUploadPanel(category: 'provision'),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Product Upload Panel ──────────────────────────────────────────────────────

class _ProductUploadPanel extends StatefulWidget {
  final String category; // 'drink' | 'provision'
  const _ProductUploadPanel({required this.category});

  @override
  State<_ProductUploadPanel> createState() => _ProductUploadPanelState();
}

class _ProductUploadPanelState extends State<_ProductUploadPanel> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  Uint8List? _pickedImageBytes;
  bool _isSaving = false;

  Color get _accent => widget.category == 'drink'
      ? const Color(0xFF0077B6)
      : const Color(0xFF2D6A4F);

  IconData get _icon => widget.category == 'drink'
      ? Icons.local_bar_outlined
      : Icons.shopping_basket_outlined;

  String get _label =>
      widget.category == 'drink' ? 'Drink' : 'Provision';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (xfile != null) {
      final bytes = await xfile.readAsBytes();
      setState(() => _pickedImageBytes = bytes);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final imageUrl = _pickedImageBytes != null
        ? 'data:image/jpeg;base64,${base64Encode(_pickedImageBytes!)}'
        : '';
    await context.read<ProductsProvider>().addProduct(
          name: _nameCtrl.text.trim(),
          price: double.parse(_priceCtrl.text.trim()),
          imageUrl: imageUrl,
          category: widget.category,
        );
    _nameCtrl.clear();
    _priceCtrl.clear();
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _pickedImageBytes = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_label added successfully!'),
        backgroundColor: _accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.category == 'drink'
        ? context.watch<ProductsProvider>().drinks
        : context.watch<ProductsProvider>().provisions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Upload Form ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _accent.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                    color: _accent.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_icon, color: _accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Add New $_label',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tap-to-upload image picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _accent, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(10),
                        color: _accent.withOpacity(0.05),
                      ),
                      child: _pickedImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _pickedImageBytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: _accent,
                                    size: 44),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to upload $_label image',
                                  style: TextStyle(
                                      color: _accent,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Choose from gallery',
                                  style: TextStyle(
                                      color: _accent.withOpacity(0.6),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (_pickedImageBytes != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            setState(() => _pickedImageBytes = null),
                        icon: const Icon(Icons.close_rounded,
                            size: 16, color: Colors.red),
                        label: const Text('Remove image',
                            style: TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Name
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: '$_label Name *',
                      hintText:
                          widget.category == 'drink'
                              ? 'e.g. Club Beer (33cl)'
                              : 'e.g. Basmati Rice (5kg)',
                      prefixIcon:
                          Icon(Icons.label_outline, color: _accent),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _accent, width: 2),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter the $_label name.'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Price
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price (GH₵) *',
                      hintText: 'e.g. 12.50',
                      prefixIcon:
                          Icon(Icons.attach_money, color: _accent),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _accent, width: 2),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter the price.';
                      }
                      if (double.tryParse(v.trim()) == null) {
                        return 'Enter a valid number.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5),
                            )
                          : const Icon(Icons.add_circle_outline_rounded),
                      label: Text(
                        _isSaving ? 'Saving…' : 'Add $_label',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
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

          const SizedBox(height: 24),

          // ── Existing products list ──────────────────────────────────────
          Row(
            children: [
              Icon(_icon, color: _accent, size: 18),
              const SizedBox(width: 6),
              Text(
                'Uploaded ${_label}s (${products.length})',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _accent),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (products.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text('No ${_label.toLowerCase()}s added yet.',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ...products.map((p) => _ProductTile(
                  product: p,
                  accent: _accent,
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        title: const Text('Delete Product'),
                        content: Text(
                            'Delete "${p.name}"? This cannot be undone.'),
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
                    if (confirm == true) {
                      await context
                          .read<ProductsProvider>()
                          .deleteProduct(p.id);
                    }
                  },
                )),

          // ── Carousel Banner Upload (inline) ─────────────────────────────
          const SizedBox(height: 32),
          Divider(color: _accent.withOpacity(0.2), thickness: 1),
          const SizedBox(height: 8),
          _EmbeddedBannerSection(category: widget.category),
        ],
      ),
    );
  }
}

// ── Product Tile ──────────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final Color accent;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.accent,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImage(product.imageUrl, accent),
        ),
        title: Text(product.name,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          'GH₵ ${product.price.toStringAsFixed(2)}',
          style: TextStyle(
              color: accent,
              fontWeight: FontWeight.bold,
              fontSize: 13),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              color: Colors.red),
          onPressed: onDelete,
          tooltip: 'Delete',
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl, Color color) {
    if (imageUrl.isEmpty) return _iconPlaceholder(color);
    if (imageUrl.startsWith('data:')) {
      try {
        final bytes = base64Decode(imageUrl.split(',')[1]);
        return Image.memory(bytes,
            width: 52, height: 52, fit: BoxFit.cover);
      } catch (_) {
        return _iconPlaceholder(color);
      }
    }
    return Image.network(
      imageUrl,
      width: 52,
      height: 52,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _iconPlaceholder(color),
    );
  }

  Widget _iconPlaceholder(Color color) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image_not_supported_outlined,
          color: color.withOpacity(0.5), size: 24),
    );
  }
}

// ── Carousel Banners Tab ──────────────────────────────────────────────────────

class _CarouselBannersTab extends StatefulWidget {
  const _CarouselBannersTab();

  @override
  State<_CarouselBannersTab> createState() => _CarouselBannersTabState();
}

class _CarouselBannersTabState extends State<_CarouselBannersTab> {
  int _subTab = 0; // 0 = Drinks, 1 = Provisions

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tab selector
        Container(
          color: Colors.white,
          child: Row(
            children: [
              _SubTab(
                  label: 'Drinks',
                  icon: Icons.local_bar_outlined,
                  selected: _subTab == 0,
                  accent: const Color(0xFF0077B6),
                  onTap: () => setState(() => _subTab = 0)),
              _SubTab(
                  label: 'Provisions',
                  icon: Icons.shopping_basket_outlined,
                  selected: _subTab == 1,
                  accent: const Color(0xFF2D6A4F),
                  onTap: () => setState(() => _subTab = 1)),
            ],
          ),
        ),
        Expanded(
          child: _BannerUploadPanel(
              category: _subTab == 0 ? 'drink' : 'provision'),
        ),
      ],
    );
  }
}

// ── Embedded Banner Section (inline inside ProductUploadPanel) ────────────────

class _EmbeddedBannerSection extends StatefulWidget {
  final String category;
  const _EmbeddedBannerSection({required this.category});

  @override
  State<_EmbeddedBannerSection> createState() =>
      _EmbeddedBannerSectionState();
}

class _EmbeddedBannerSectionState extends State<_EmbeddedBannerSection> {
  Uint8List? _pickedBytes;
  bool _isSaving = false;

  Color get _accent => widget.category == 'drink'
      ? const Color(0xFF0077B6)
      : const Color(0xFF2D6A4F);

  String get _label =>
      widget.category == 'drink' ? 'Drinks' : 'Provisions';

  Future<void> _pick() async {
    final xfile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile != null) {
      final bytes = await xfile.readAsBytes();
      setState(() => _pickedBytes = bytes);
    }
  }

  Future<void> _upload() async {
    if (_pickedBytes == null) return;
    setState(() => _isSaving = true);
    final dataUri =
        'data:image/jpeg;base64,${base64Encode(_pickedBytes!)}';
    await context
        .read<CarouselProvider>()
        .addBanner(widget.category, dataUri);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _pickedBytes = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Banner added to $_label carousel!'),
        backgroundColor: _accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.category == 'drink'
        ? context.watch<CarouselProvider>().drinkBanners
        : context.watch<CarouselProvider>().provisionBanners;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────
        Row(
          children: [
            Icon(Icons.photo_library_outlined, color: _accent, size: 20),
            const SizedBox(width: 8),
            Text(
              '$_label Carousel Banners',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Preview button ─────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.preview_rounded),
            label: const Text('Preview Carousels on Shop Pages'),
            onPressed: () =>
                Navigator.pushNamed(context, '/carousel-preview'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _accent,
              side: BorderSide(color: _accent),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ── Upload card ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _accent.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                  color: _accent.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: _accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Add Carousel Banner',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Tap-to-pick area
              GestureDetector(
                onTap: _pick,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: _accent),
                    borderRadius: BorderRadius.circular(12),
                    color: _accent.withOpacity(0.04),
                  ),
                  child: _pickedBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_pickedBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: _accent, size: 46),
                            const SizedBox(height: 8),
                            Text('Tap to select banner image',
                                style: TextStyle(
                                    color: _accent,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(
                                'Recommended: 16:9 or wide landscape image',
                                style: TextStyle(
                                    color: _accent.withOpacity(0.6),
                                    fontSize: 12)),
                          ],
                        ),
                ),
              ),

              if (_pickedBytes != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _pickedBytes = null),
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: Colors.red),
                    label: const Text('Remove',
                        style:
                            TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ),
              ],

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed:
                      (_pickedBytes == null || _isSaving) ? null : _upload,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Icon(Icons.upload_rounded),
                  label: Text(
                    _isSaving ? 'Uploading…' : 'Add to Carousel',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Current banners list ──────────────────────────────────────
        Row(
          children: [
            Icon(Icons.view_carousel_outlined, color: _accent, size: 18),
            const SizedBox(width: 6),
            Text(
              '$_label Banners (${banners.length})',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _accent),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (banners.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  const Text('No banners uploaded yet.',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text(
                      'Static carousel will show until you add images.',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          ...banners.asMap().entries.map(
                (entry) => _BannerTile(
                  index: entry.key,
                  dataUri: entry.value,
                  accent: _accent,
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        title: const Text('Remove Banner'),
                        content: const Text(
                            'Remove this banner from the carousel?'),
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
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await context
                          .read<CarouselProvider>()
                          .removeBanner(widget.category, entry.key);
                    }
                  },
                ),
              ),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Banner Upload Panel ───────────────────────────────────────────────────────

class _BannerUploadPanel extends StatefulWidget {
  final String category;
  const _BannerUploadPanel({required this.category});

  @override
  State<_BannerUploadPanel> createState() => _BannerUploadPanelState();
}

class _BannerUploadPanelState extends State<_BannerUploadPanel> {
  Uint8List? _pickedBytes;
  bool _isSaving = false;

  Color get _accent => widget.category == 'drink'
      ? const Color(0xFF0077B6)
      : const Color(0xFF2D6A4F);

  String get _label =>
      widget.category == 'drink' ? 'Drinks' : 'Provisions';

  Future<void> _pick() async {
    final xfile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile != null) {
      final bytes = await xfile.readAsBytes();
      setState(() => _pickedBytes = bytes);
    }
  }

  Future<void> _upload() async {
    if (_pickedBytes == null) return;
    setState(() => _isSaving = true);
    final dataUri =
        'data:image/jpeg;base64,${base64Encode(_pickedBytes!)}';
    await context
        .read<CarouselProvider>()
        .addBanner(widget.category, dataUri);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _pickedBytes = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Banner added to $_label carousel!'),
        backgroundColor: _accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.category == 'drink'
        ? context.watch<CarouselProvider>().drinkBanners
        : context.watch<CarouselProvider>().provisionBanners;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Preview button ─────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.preview_rounded),
              label: const Text('Preview Carousels on Shop Pages'),
              onPressed: () =>
                  Navigator.pushNamed(context, '/carousel-preview'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _accent,
                side: BorderSide(color: _accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ── Upload card ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _accent.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                    color: _accent.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.photo_library_outlined,
                        color: _accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Add $_label Carousel Banner',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tap-to-pick area
                GestureDetector(
                  onTap: _pick,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _accent, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                      color: _accent.withOpacity(0.04),
                    ),
                    child: _pickedBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(_pickedBytes!,
                                fit: BoxFit.cover,
                                width: double.infinity),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: _accent, size: 46),
                              const SizedBox(height: 8),
                              Text('Tap to select banner image',
                                  style: TextStyle(
                                      color: _accent,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(
                                  'Recommended: 16:9 or wide landscape image',
                                  style: TextStyle(
                                      color: _accent.withOpacity(0.6),
                                      fontSize: 12)),
                            ],
                          ),
                  ),
                ),

                if (_pickedBytes != null) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () =>
                          setState(() => _pickedBytes = null),
                      icon: const Icon(Icons.close_rounded,
                          size: 16, color: Colors.red),
                      label: const Text('Remove',
                          style: TextStyle(
                              color: Colors.red, fontSize: 12)),
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed:
                        (_pickedBytes == null || _isSaving) ? null : _upload,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Icon(Icons.upload_rounded),
                    label: Text(
                      _isSaving ? 'Uploading…' : 'Add to Carousel',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Current banners list ───────────────────────────────────────
          Row(
            children: [
              Icon(Icons.view_carousel_outlined, color: _accent, size: 18),
              const SizedBox(width: 6),
              Text(
                '$_label Banners (${banners.length})',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _accent),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (banners.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.photo_library_outlined,
                        size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    const Text('No banners uploaded yet.',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    const Text(
                        'Static carousel will show until you add images.',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            ...banners.asMap().entries.map(
                  (entry) => _BannerTile(
                    index: entry.key,
                    dataUri: entry.value,
                    accent: _accent,
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          title: const Text('Remove Banner'),
                          content: const Text(
                              'Remove this banner from the carousel?'),
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
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await context
                            .read<CarouselProvider>()
                            .removeBanner(widget.category, entry.key);
                      }
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Banner Tile ───────────────────────────────────────────────────────────────

class _BannerTile extends StatelessWidget {
  final int index;
  final String dataUri;
  final Color accent;
  final VoidCallback onDelete;

  const _BannerTile({
    required this.index,
    required this.dataUri,
    required this.accent,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    try {
      final bytes = base64Decode(dataUri.split(',')[1]);
      imageWidget = Image.memory(bytes,
          width: 72, height: 54, fit: BoxFit.cover);
    } catch (_) {
      imageWidget = Container(
        width: 72,
        height: 54,
        color: accent.withOpacity(0.1),
        child: Icon(Icons.broken_image_outlined,
            color: accent.withOpacity(0.4)),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageWidget,
        ),
        title: Text(
          'Banner ${index + 1}',
          style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text('Carousel slide ${index + 1}',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: IconButton(
          icon:
              const Icon(Icons.delete_outline_rounded, color: Colors.red),
          onPressed: onDelete,
          tooltip: 'Remove',
        ),
      ),
    );
  }
}

// ── Sub-tab selector (reused inside Banners tab) ──────────────────────────────

class _SubTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _SubTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: selected ? accent : Colors.transparent, width: 2.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? accent : Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selected ? accent : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}