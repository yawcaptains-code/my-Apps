import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/cart_provider.dart';
import '../models/cart_item.dart';

/// Orders / Cart screen – shows all items added from both Drinks and Provisions,
/// with quantity controls, payment information, and communication options.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Cart & Orders'),
        backgroundColor: const Color(0xFF0077B6),
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
                    color: const Color(0xFF0077B6),
                    onTap: () => Navigator.pushNamed(context, '/chat'),
                  ),
                  _ContactOption(
                    icon: Icons.phone_outlined,
                    label: 'Phone Call',
                    subtitle: 'Call our support line',
                    color: const Color(0xFF2EC4B6),
                    onTap: () => _launch('tel:+233244000000'),
                  ),
                  _ContactOption(
                    icon: Icons.message_rounded,
                    label: 'WhatsApp',
                    subtitle: 'Chat with us on WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () => _launch(
                        'https://wa.me/233244000000?text=Hello%2C%20I%20would%20like%20to%20place%20an%20order'),
                  ),
                  _ContactOption(
                    icon: Icons.flag_outlined,
                    label: 'Report an Issue',
                    subtitle: 'Let us know about a problem',
                    color: const Color(0xFFE76F51),
                    onTap: () => _launch('mailto:support@drinkprovisionhub.com?subject=Issue%20Report'),
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
                      side: const BorderSide(color: Color(0xFF0077B6)),
                      foregroundColor: const Color(0xFF0077B6),
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
                        backgroundColor: const Color(0xFF52B788),
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
            // Category icon
            CircleAvatar(
              backgroundColor: item.category == 'drink'
                  ? const Color(0xFFB0E0FF)
                  : const Color(0xFFB7E4C7),
              child: Icon(
                item.category == 'drink'
                    ? Icons.local_drink_rounded
                    : Icons.shopping_basket_rounded,
                color: item.category == 'drink'
                    ? const Color(0xFF0077B6)
                    : const Color(0xFF2D6A4F),
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
                  color: Color(0xFF0077B6),
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
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
          border: Border.all(color: const Color(0xFF0077B6)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF0077B6)),
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
        color: const Color(0xFF0077B6),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB0E0FF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_rounded, color: Color(0xFF0077B6)),
              SizedBox(width: 8),
              Text(
                'Payment Methods',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF023E8A)),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
        border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
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
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(label,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right),
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
          fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF023E8A)),
    );
  }
}
