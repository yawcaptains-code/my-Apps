import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

/// Full list of past orders, stored locally. Accessible from ProfileScreen
/// and also linked from OrdersScreen.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    await context.read<OrdersProvider>().loadFromPrefs();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>().orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadOrders,
          ),
          if (orders.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear history',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear History?'),
                    content: const Text(
                        'All order records will be permanently deleted.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Clear',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<OrdersProvider>().clearHistory();
                }
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? _EmptyHistory()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
                ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No orders yet',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Your placed orders will appear here.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.add_shopping_cart_outlined),
            label: const Text('Start Shopping'),
            onPressed: () => Navigator.pushNamed(context, '/home'),
          ),
        ],
      ),
    );
  }
}

// ── Single order card ─────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case 'Confirmed':
        return const Color(0xFFC62828);
      case 'Delivered':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFFD4A017);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ───────────────────────────────────────────────
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
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ── Date ─────────────────────────────────────────────────────
              Text(
                _formatDate(order.placedAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const Divider(height: 20),

              // ── Items ─────────────────────────────────────────────────────
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: _productImage(item),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(item.name,
                                style: const TextStyle(fontSize: 12))),
                        Text(
                          '×${item.quantity}  GH₵${item.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 8),

              // ── Total + payment ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('via ${order.paymentMethod}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11)),
                  Text(
                    'GH₵ ${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC62828),
                        fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _OrderDetailSheet(order: order),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month]} ${dt.day}, ${dt.year} · $h:$m';
  }
}

// ── Order detail bottom sheet ─────────────────────────────────────────────────

class _OrderDetailSheet extends StatelessWidget {
  final OrderModel order;
  const _OrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scroll) => SingleChildScrollView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 20),
            Text(order.id,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Placed: ${_formatDate(order.placedAt)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(height: 24),
            const _Label('Delivery To'),
            const SizedBox(height: 6),
            _DetailRow(Icons.person_outline, order.recipientName),
            _DetailRow(Icons.phone_outlined, order.phone),
            _DetailRow(Icons.location_on_outlined, order.address),
            if (order.note != null && order.note!.isNotEmpty)
              _DetailRow(Icons.notes_rounded, order.note!),
            const Divider(height: 24),
            const _Label('Items'),
            const SizedBox(height: 8),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: _productImage(item),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(item.name,
                              style: const TextStyle(fontSize: 13))),
                      Text('×${item.quantity}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 12),
                      Text('GH₵${item.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment: ${order.paymentMethod}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  'Total: GH₵ ${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC62828),
                      fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month]} ${dt.day}, ${dt.year} · $h:$m';
  }
}

// ── Shared product image helper ─────────────────────────────────────────────────────
Widget _productImage(CartItem item) {
  final url = item.imageUrl;
  if (url.isEmpty) {
    return Container(
      color: item.category == 'drink'
          ? const Color(0xFFB0E0FF)
          : const Color(0xFFB7E4C7),
      child: Icon(
        item.category == 'drink'
            ? Icons.local_drink_rounded
            : Icons.shopping_basket_rounded,
        color: const Color(0xFFC62828),
        size: 22,
      ),
    );
  }
  if (url.startsWith('data:')) {
    try {
      final bytes = base64Decode(url.split(',')[1]);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (_) {}
  }
  return Image.network(url, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFEEEEEE),
        child: const Icon(Icons.broken_image_outlined, size: 22),
      ));
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF7F0000),
          fontSize: 13));
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _DetailRow(this.icon, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
                child: Text(value, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );
}
