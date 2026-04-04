import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/home_shop_provider.dart';
import '../widgets/cart_icon_badge.dart';

/// Home / Dashboard screen – the central hub after onboarding.
///
/// Shows a welcome header, quick-action tiles for the two shops,
/// a cart summary card, and a registration prompt.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    context.watch<CartProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdminSessionActive;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Drink & Provision Hub'),
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
        leading: isAdmin
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: 'Back to Intro',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/onboarding'),
              )
            : null,
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

            Consumer<HomeShopProvider>(
              builder: (ctx, shop, _) => Row(
                children: [
                  Expanded(
                    child: _ShopTile(
                      imageUrl: shop.drinkImageUrl,
                      icon: Icons.wine_bar_rounded,
                      label: shop.drinkLabel,
                      subtitle: shop.drinkSubtitle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC62828), Color(0xFFEF9A9A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => Navigator.pushNamed(context, '/drinks'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ShopTile(
                      imageUrl: shop.provisionImageUrl,
                      icon: Icons.shopping_basket_rounded,
                      label: shop.provisionLabel,
                      subtitle: shop.provisionSubtitle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC62828), Color(0xFFEF5350)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, '/provisions'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Cart summary card ──────────────────────────────────────────
            const _SectionTitle('🛒  Cart Summary'),
            const SizedBox(height: 12),
            _CartSummaryCard(cart: context.watch<CartProvider>()),

            const SizedBox(height: 24),

            // ── Quick links ────────────────────────────────────────────────
            const _SectionTitle('⚡  Quick Links'),
            const SizedBox(height: 12),
            _QuickLink(
              icon: Icons.receipt_long_rounded,
              label: 'View My Cart & Orders',
              color: const Color(0xFFC62828),
              onTap: () => Navigator.pushNamed(context, '/orders'),
            ),
            _QuickLink(
              icon: Icons.history_rounded,
              label: 'Order History',
              color: const Color(0xFF7F0000),
              onTap: () => Navigator.pushNamed(context, '/order-history'),
            ),
            _QuickLink(
              icon: Icons.person_add_alt_1_rounded,
              label: 'Create an Account',
              color: const Color(0xFFEF5350),
              onTap: () => Navigator.pushNamed(context, '/register'),
            ),
            _QuickLink(
              icon: Icons.login_rounded,
              label: 'Sign In',
              color: const Color(0xFF7F0000),
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
    return Consumer<HomeShopProvider>(
      builder: (ctx, shop, _) {
        final hasLogo = shop.logoImageUrl.isNotEmpty;
        Widget logoWidget;
        if (hasLogo) {
          try {
            final bytes = base64Decode(shop.logoImageUrl.split(',')[1]);
            logoWidget = ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                bytes,
                height: 100,
                fit: BoxFit.contain,
              ),
            );
          } catch (_) {
            logoWidget = _lesfamText();
          }
        } else {
          logoWidget = _lesfamText();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF7F0000),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7F0000).withValues(alpha: 0.45),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              logoWidget,
              if (!hasLogo) ...[  
                const SizedBox(height: 6),
                Container(
                  width: 100,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _lesfamText() => const Text(
    'LESFAM',
    style: TextStyle(
      color: Colors.white,
      fontSize: 42,
      fontWeight: FontWeight.w900,
      letterSpacing: 6,
      height: 1.1,
    ),
  );
}

// ── Shop Tile ─────────────────────────────────────────────────────────────────

class _ShopTile extends StatelessWidget {
  final String imageUrl;
  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ShopTile({
    required this.imageUrl,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  Widget _buildImage() {
    if (imageUrl.isEmpty) {
      return Icon(icon, color: Colors.white, size: 36);
    }
    try {
      final bytes = base64Decode(imageUrl.split(',')[1]);
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(bytes,
            height: 70, width: double.infinity, fit: BoxFit.cover),
      );
    } catch (_) {
      return Icon(icon, color: Colors.white, size: 36);
    }
  }

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
              color: Colors.black12.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
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
                color: Colors.white.withValues(alpha: 0.80),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB0E0FF), width: 1.5),
      ),
      child: hasItems
          ? Row(
              children: [
                const Icon(Icons.shopping_cart_rounded,
                    color: Color(0xFFC62828), size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cart.totalQuantity} item${cart.totalQuantity == 1 ? '' : 's'} in cart',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Total: GH₵ ${cart.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
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
                Text(
                  'Your cart is empty.\nStart adding items!',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5),
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
            ),
            trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface),
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
      childAspectRatio: 1.35,
      children: _items.map((item) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.$1, color: const Color(0xFFC62828), size: 24),
              const SizedBox(height: 4),
              Text(
                item.$2,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                item.$3,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 10),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
        color: Color(0xFF7F0000),
      ),
    );
  }
}
