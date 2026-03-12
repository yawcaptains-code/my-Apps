import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import 'search_screen.dart'; // for ProductCatalogue & _Product
import 'product_detail_screen.dart';

/// Arguments passed to [CategoryProductsScreen].
class CategoryArgs {
  final String subcategory;
  final String title;
  final Color color;
  final IconData icon;
  /// The ShopCategory.id – used to match admin-uploaded products by drinkType.
  final String categoryId;

  const CategoryArgs({
    required this.subcategory,
    required this.title,
    required this.color,
    required this.icon,
    this.categoryId = '',
  });
}

/// Filtered product listing for a specific category / sub-category.
class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as CategoryArgs;

    final staticProducts = ProductCatalogue.all
        .where((p) => p.subcategory == args.subcategory)
        .toList();

    final adminProducts = args.categoryId.isEmpty
        ? <ProductModel>[]
        : context
            .watch<ProductsProvider>()
            .products
            .where((p) => p.drinkType == args.categoryId)
            .toList();

    final isEmpty = staticProducts.isEmpty && adminProducts.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.title),
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
      ),
      body: isEmpty
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
              itemCount: staticProducts.length + adminProducts.length,
              itemBuilder: (ctx, i) {
                if (i < staticProducts.length) {
                  return _CategoryProductCard(
                      product: staticProducts[i], color: args.color);
                }
                return _AdminCategoryProductCard(
                    product: adminProducts[i - staticProducts.length],
                    color: args.color);
              },
            ),
    );
  }
}

// â”€â”€ Product card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CategoryProductCard extends StatelessWidget {
  final dynamic product; // _Product from search_screen.dart
  final Color color;

  const _CategoryProductCard({required this.product, required this.color});

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
                      color: (product.color as Color).withValues(alpha: 0.8)),
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
                'GHâ‚µ ${(product.price as double).toStringAsFixed(2)}',
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

// ── Admin product card ────────────────────────────────────────────────────────

class _AdminCategoryProductCard extends StatelessWidget {
  final ProductModel product;
  final Color color;

  const _AdminCategoryProductCard(
      {required this.product, required this.color});

  Widget _buildImage() {
    final url = product.imageUrl;
    if (url.isEmpty) {
      return Icon(Icons.image_outlined,
          size: 54, color: color.withValues(alpha: 0.5));
    }
    if (url.startsWith('data:')) {
      try {
        final bytes = base64Decode(url.split(',')[1]);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(bytes,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover),
        );
      } catch (_) {
        return Icon(Icons.image_outlined,
            size: 54, color: color.withValues(alpha: 0.5));
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(url,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.image_outlined, size: 54,
                  color: color.withValues(alpha: 0.5))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                    width: double.infinity, child: _buildImage()),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'GH₵ ${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    cart.addItem(
                      id: product.id,
                      name: product.name,
                      category: product.category,
                      price: product.price,
                      imageUrl: product.imageUrl,
                    );
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text('${product.name} added to cart!'),
                        backgroundColor: color,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ));
                  },
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label:
                      const Text('Add', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
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
