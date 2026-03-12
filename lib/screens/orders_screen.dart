import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/cart_provider.dart';
import '../providers/contact_info_provider.dart';
import '../models/cart_item.dart';

/// Orders / Cart screen – shows all items added from both Drinks and Provisions,
/// with quantity controls, payment information, and communication options.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final contact = context.watch<ContactInfoProvider>();
    final items = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart & Orders'),
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
          // Clear cart button
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear cart',
              onPressed: () {
                context.read<CartProvider>().clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cart cleared.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? _EmptyCartMessage()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cart item list ───────────────────────────────────────
                  const _SectionTitle('🛒  Cart Items'),
                  const SizedBox(height: 8),
                  ...items.map((item) => _CartItemTile(item: item)),

                  const SizedBox(height: 16),

                  // ── Order Total ──────────────────────────────────────────
                  _TotalTile(total: cart.totalAmount),

                  const SizedBox(height: 24),

                  // ── Payment Info ─────────────────────────────────────────
                  const _PaymentInfoCard(),

                  const SizedBox(height: 24),

                  // ── Bulk Purchase Note ───────────────────────────────────
                  const _BulkPurchaseNote(),

                  const SizedBox(height: 24),

                  // ── Communication Options ────────────────────────────────
                  const _SectionTitle('📞  Get in Touch'),
                  const SizedBox(height: 8),
                  _ContactOption(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Message Chat',
                    subtitle: 'Open in-app chat with support',
                    color: const Color(0xFFC62828),
                    onTap: () => Navigator.pushNamed(context, '/chat'),
                  ),
                  _ContactOption(
                    icon: Icons.phone_outlined,
                    label: 'Phone Call',
                    subtitle: contact.phone.isNotEmpty
                        ? contact.phone
                        : 'Call our support line',
                    color: const Color(0xFFEF9A9A),
                    onTap: contact.phoneUri.isNotEmpty
                        ? () => _launch(contact.phoneUri)
                        : null,
                  ),
                  _ContactOption(
                    icon: Icons.message_rounded,
                    label: 'WhatsApp',
                    subtitle: contact.whatsapp.isNotEmpty
                        ? contact.whatsapp
                        : 'Chat with us on WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: contact.whatsappUri.isNotEmpty
                        ? () => _launch(contact.whatsappUri)
                        : null,
                  ),
                  _ContactOption(
                    icon: Icons.flag_outlined,
                    label: 'Report an Issue',
                    subtitle: 'Let us know about a problem',
                    color: const Color(0xFFE76F51),
                    onTap: () => _showReportDialog(context),
                  ),

                  const SizedBox(height: 24),

                  // ── Order history link ──────────────────────────────────────
                  OutlinedButton.icon(
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('View Order History'),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/order-history'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Color(0xFFC62828)),
                      foregroundColor: const Color(0xFFC62828),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Checkout CTA ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.payment_rounded),
                      label: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/checkout'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFEF5350),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Register CTA ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text(
                        'Register to be a Customer',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showReportDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final issueCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.flag_outlined, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          const Text('Report an Issue'),
        ]),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Your Name (optional)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: issueCtrl,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Describe the issue',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please describe the issue'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.send_rounded),
            label: const Text('Submit'),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE76F51)),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              // Save to SharedPreferences so admin can view it
              final prefs = await SharedPreferences.getInstance();
              final raw = prefs.getString('user_reports');
              final List<dynamic> list =
                  raw != null ? jsonDecode(raw) as List<dynamic> : [];
              list.add({
                'id': DateTime.now().microsecondsSinceEpoch.toString(),
                'name': nameCtrl.text.trim().isEmpty
                    ? 'Anonymous'
                    : nameCtrl.text.trim(),
                'issue': issueCtrl.text.trim(),
                'timestamp': DateTime.now().toIso8601String(),
                'read': false,
              });
              await prefs.setString('user_reports', jsonEncode(list));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        '✅  Your report has been submitted. Thank you!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFFC62828),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ── Empty cart illustration ────────────────────────────────────────────────────

class _EmptyCartMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 96, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add drinks or provisions to get started.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Go to Drink Shop'),
            onPressed: () => Navigator.pushNamed(context, '/drinks'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.shopping_basket_outlined),
            label: const Text('Go to Provision Shop'),
            onPressed: () => Navigator.pushNamed(context, '/provisions'),
          ),
        ],
      ),
    );
  }
}

// ── Individual cart item row ───────────────────────────────────────────────────

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Product image or fallback icon
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 48,
                height: 48,
                child: _buildItemImage(item),
              ),
            ),
            const SizedBox(width: 12),

            // Name + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(
                    'GH₵ ${item.price.toStringAsFixed(2)} each',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Quantity controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QtyButton(
                  icon: Icons.remove,
                  onPressed: () => cart.decrement(item.id),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                _QtyButton(
                  icon: Icons.add,
                  onPressed: () => cart.increment(item.id),
                ),
              ],
            ),

            // Line total
            const SizedBox(width: 12),
            Text(
              'GH₵\n${item.totalPrice.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildItemImage(CartItem item) {
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
          size: 28,
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
          child: const Icon(Icons.broken_image_outlined, size: 28),
        ));
  }
}

// ── Small +/− button ──────────────────────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QtyButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFC62828)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFFC62828)),
      ),
    );
  }
}

// ── Total tile ────────────────────────────────────────────────────────────────

class _TotalTile extends StatelessWidget {
  final double total;
  const _TotalTile({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFC62828),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Grand Total',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(
            'GH₵ ${total.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── Payment info card ─────────────────────────────────────────────────────────

class _PaymentInfoCard extends StatelessWidget {
  const _PaymentInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB0E0FF), width: 1.5),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment_rounded, color: Color(0xFFC62828)),
              SizedBox(width: 8),
              Text(
                'Payment Methods',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF7F0000)),
              ),
            ],
          ),
          SizedBox(height: 10),
          _PaymentMethod(
              icon: Icons.phone_android_rounded,
              text: 'MTN Mobile Money (MoMo)'),
          _PaymentMethod(
              icon: Icons.phone_android_rounded,
              text: 'Vodafone Cash'),
          _PaymentMethod(
              icon: Icons.phone_android_rounded,
              text: 'AirtelTigo Money'),
          _PaymentMethod(
              icon: Icons.account_balance_outlined,
              text: 'Direct Bank Transfer'),
        ],
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PaymentMethod({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Bulk purchase note ────────────────────────────────────────────────────────

class _BulkPurchaseNote extends StatelessWidget {
  const _BulkPurchaseNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4A017).withValues(alpha: 0.4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: Color(0xFFD4A017), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'For bulk purchases, please call or WhatsApp us for special '
              'arrangement and exclusive pricing.',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact option tile ───────────────────────────────────────────────────────

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ContactOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        enabled: enabled,
        leading: CircleAvatar(
          backgroundColor:
              enabled ? color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
          child: Icon(icon, color: enabled ? color : Colors.grey.shade400),
        ),
        title: Text(label,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          enabled ? subtitle : 'Not configured — set in Admin Page 3',
          style: TextStyle(
              fontSize: 12,
              color: enabled ? Colors.grey : Colors.orange.shade700),
        ),
        trailing: Icon(
          enabled ? Icons.chevron_right : Icons.settings_outlined,
          color: enabled ? null : Colors.orange.shade400,
        ),
        onTap: onTap,
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF7F0000)),
    );
  }
}
