import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/cart_icon_badge.dart';

/// Home / Dashboard screen – the central hub after onboarding.
///
/// Shows a welcome header, quick-action tiles for the two shops,
/// a cart summary card, and a registration prompt.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text('Drink & Provision Hub'),
        backgroundColor: const Color(0xFF0077B6),
        automaticallyImplyLeading: false,
        actions: const [CartIconBadge()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome banner ─────────────────────────────────────────────
            _WelcomeBanner(),

            const SizedBox(height: 24),

            // ── Section: Shops ─────────────────────────────────────────────
            const _SectionTitle('🛍️  Our Shops'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ShopTile(
                    icon: Icons.wine_bar_rounded,
                    label: 'Drink Shop',
                    subtitle: 'Beers, wines, soft drinks & more',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => Navigator.pushNamed(context, '/drinks'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ShopTile(
                    icon: Icons.shopping_basket_rounded,
                    label: 'Provision Shop',
                    subtitle: 'Groceries, cleaning, snacks & more',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D6A4F), Color(0xFF52B788)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () =>
                        Navigator.pushNamed(context, '/provisions'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Cart summary card ──────────────────────────────────────────
            const _SectionTitle('🛒  Cart Summary'),
            const SizedBox(height: 12),
            _CartSummaryCard(cart: cart),

            const SizedBox(height: 24),

            // ── Quick links ────────────────────────────────────────────────
            const _SectionTitle('⚡  Quick Links'),
            const SizedBox(height: 12),
            _QuickLink(
              icon: Icons.receipt_long_rounded,
              label: 'View My Cart & Orders',
              color: const Color(0xFF0077B6),
              onTap: () => Navigator.pushNamed(context, '/orders'),
            ),
            _QuickLink(
              icon: Icons.history_rounded,
              label: 'Order History',
              color: const Color(0xFF023E8A),
              onTap: () => Navigator.pushNamed(context, '/order-history'),
            ),
            _QuickLink(
              icon: Icons.person_add_alt_1_rounded,
              label: 'Create an Account',
              color: const Color(0xFF52B788),
              onTap: () => Navigator.pushNamed(context, '/register'),
            ),
            _QuickLink(
              icon: Icons.login_rounded,
              label: 'Sign In',
              color: const Color(0xFF023E8A),
              onTap: () => Navigator.pushNamed(context, '/login'),
            ),

            const SizedBox(height: 24),

            // ── Info tiles ─────────────────────────────────────────────────
            const _SectionTitle('ℹ️  Why Shop With Us?'),
            const SizedBox(height: 12),
            const _InfoGrid(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Welcome Banner ────────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF023E8A), Color(0xFF0096C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0077B6).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back! 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Explore top deals on drinks\nand daily provisions in Ghana.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/drinks'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF023E8A),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Shop Now',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.local_drink_rounded,
              size: 72, color: Colors.white24),
        ],
      ),
    );
  }
}

// ── Shop Tile ─────────────────────────────────────────────────────────────────

class _ShopTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ShopTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.80),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cart Summary Card ─────────────────────────────────────────────────────────

class _CartSummaryCard extends StatelessWidget {
  final CartProvider cart;
  const _CartSummaryCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    final hasItems = cart.totalQuantity > 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB0E0FF), width: 1.5),
      ),
      child: hasItems
          ? Row(
              children: [
                const Icon(Icons.shopping_cart_rounded,
                    color: Color(0xFF0077B6), size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cart.totalQuantity} item${cart.totalQuantity == 1 ? '' : 's'} in cart',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Total: GH₵ ${cart.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Color(0xFF0077B6), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/orders'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                  child: const Text('View'),
                ),
              ],
            )
          : Row(
              children: [
                Icon(Icons.shopping_cart_outlined,
                    color: Colors.grey.shade400, size: 36),
                const SizedBox(width: 14),
                const Text(
                  'Your cart is empty.\nStart adding items!',
                  style: TextStyle(color: Colors.grey, height: 1.5),
                ),
              ],
            ),
    );
  }
}

// ── Quick Link Tile ───────────────────────────────────────────────────────────

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLink({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: color, fontSize: 14),
            ),
            trailing: Icon(Icons.chevron_right, color: color),
          ),
        ),
      ),
    );
  }
}

// ── Info Grid ─────────────────────────────────────────────────────────────────

class _InfoGrid extends StatelessWidget {
  const _InfoGrid();

  static const List<(IconData, String, String)> _items = [
    (Icons.verified_rounded, 'Quality Products',
        'Only trusted brands stocked.'),
    (Icons.delivery_dining_rounded, 'Fast Delivery',
        'Quick delivery across Ghana.'),
    (Icons.attach_money_rounded, 'Great Prices',
        'Competitive daily pricing.'),
    (Icons.support_agent_rounded, 'Support 24/7',
        'Always here to help you.'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: _items.map((item) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.$1, color: const Color(0xFF0077B6), size: 26),
              const SizedBox(height: 6),
              Text(
                item.$2,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                item.$3,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF023E8A),
      ),
    );
  }
}
