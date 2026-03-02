import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import 'search_screen.dart'; // for ProductCatalogue & _Product
import 'product_detail_screen.dart';

/// Arguments passed to [CategoryProductsScreen].
class CategoryArgs {
  final String subcategory;
  final String title;
  final Color color;
  final IconData icon;

  const CategoryArgs({
    required this.subcategory,
    required this.title,
    required this.color,
    required this.icon,
  });
}

/// Filtered product listing for a specific category / sub-category.
class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as CategoryArgs;

    final products = ProductCatalogue.all
        .where((p) => p.subcategory == args.subcategory)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(args.title),
        backgroundColor: args.color,
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(args.icon, size: 72, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No products here yet.',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.80,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (ctx, i) =>
                  _CategoryProductCard(product: products[i]),
            ),
    );
  }
}

// ── Product card ──────────────────────────────────────────────────────────────

class _CategoryProductCard extends StatelessWidget {
  final dynamic product; // _Product from search_screen.dart

  const _CategoryProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: ProductDetailArgs(
            id: product.id,
            name: product.name,
            category: product.category,
            price: product.price,
            description: product.description,
            icon: product.icon,
            color: product.color,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Icon(product.icon,
                      size: 54,
                      color: (product.color as Color).withOpacity(0.8)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name as String,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'GH₵ ${(product.price as double).toStringAsFixed(2)}',
                style: TextStyle(
                    color: product.color as Color,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    cart.addItem(
                      id: product.id as String,
                      name: product.name as String,
                      category: product.category as String,
                      price: product.price as double,
                    );
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content:
                            Text('${product.name} added to cart!'),
                        backgroundColor: product.color as Color,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ));
                  },
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label:
                      const Text('Add', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: product.color as Color,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
