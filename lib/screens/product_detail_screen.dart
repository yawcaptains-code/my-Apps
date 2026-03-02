import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

/// Arguments passed via Navigator to [ProductDetailScreen].
class ProductDetailArgs {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final IconData icon;
  final Color color;

  const ProductDetailArgs({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Full-page product detail with description, quantity picker, and add-to-cart.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ProductDetailArgs;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── Hero app bar ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: args.color,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [args.color, args.color.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(args.icon, size: 110, color: Colors.white70),
                ),
              ),
            ),
            actions: [
              // Share placeholder
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Share coming soon.'),
                        behavior: SnackBarBehavior.floating),
                  );
                },
              ),
            ],
          ),

          // ── Content ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + category chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          args.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Chip(
                        label: Text(
                          args.category == 'drink' ? '🥤 Drink' : '🛒 Provision',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: args.color.withOpacity(0.12),
                        side: BorderSide.none,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    'GH₵ ${args.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: args.color,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Product Description',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    args.description,
                    style: const TextStyle(
                        fontSize: 14, height: 1.7, color: Colors.black87),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  const Divider(),

                  const SizedBox(height: 16),

                  // Product meta
                  _MetaRow(label: 'Category', value: args.category == 'drink' ? 'Drink' : 'Provision'),
                  const SizedBox(height: 8),
                  const _MetaRow(label: 'Availability', value: 'In Stock ✅'),
                  const SizedBox(height: 8),
                  const _MetaRow(label: 'Delivery', value: 'Same-day within Accra'),

                  const SizedBox(height: 28),

                  // ── Quantity picker ───────────────────────────────────────
                  Row(
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      _QtyButton(
                        icon: Icons.remove,
                        onPressed: () {
                          if (_qty > 1) setState(() => _qty--);
                        },
                        color: args.color,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$_qty',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.add,
                        onPressed: () => setState(() => _qty++),
                        color: args.color,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Subtotal
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: args.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                          'GH₵ ${(args.price * _qty).toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: args.color),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: Text(
                        'Add $_qty to Cart',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        final cart = context.read<CartProvider>();
                        for (var i = 0; i < _qty; i++) {
                          cart.addItem(
                            id: args.id,
                            name: args.name,
                            category: args.category,
                            price: args.price,
                          );
                        }
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(
                            content: Text(
                                '$_qty × ${args.name} added to cart!'),
                            backgroundColor: args.color,
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'View Cart',
                              textColor: Colors.white,
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/orders'),
                            ),
                          ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: args.color,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  const _QtyButton(
      {required this.icon, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
