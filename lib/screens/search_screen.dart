import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import 'product_detail_screen.dart';

/// Kept for backward compatibility with CategoryProductsScreen.
/// Products are now managed exclusively through [ProductsProvider].
class ProductCatalogue {
  // ignore: library_private_types_in_public_api
  static const List<_Product> all = [];
}

class _Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final IconData icon;
  final Color color;
  final String subcategory;

  const _Product(this.id, this.name, this.category, this.price,
      this.description, this.icon, this.color, this.subcategory);
}

// ─────────────────────────────────────────────────────────────────────────────

/// Live search screen across all admin-uploaded products.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Brief load to let the keyboard/carousel settle before showing all items.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  List<ProductModel> _filterResults(List<ProductModel> products) {
    if (_query.isEmpty) return products;
    final q = _query.toLowerCase();
    return products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.drinkType.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allProducts =
        context.watch<ProductsProvider>().products.toList();
    final results = _filterResults(allProducts);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white70,
          decoration: InputDecoration(
            hintText: 'Search drinks, provisions…',
            hintStyle: const TextStyle(color: Colors.white60),
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? _SearchShimmerList()
          : results.isEmpty
              ? _NoResults(query: _query)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: Text(
                        _query.isEmpty
                            ? '🛍️  All Products (${results.length})'
                            : '🔍  ${results.length} result${results.length == 1 ? '' : 's'} for "$_query"',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF7F0000),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) =>
                            _SearchResultTile(product: results[i]),
                      ),
                    ),
                  ],
                ),
    );
  }
}

// ── Search shimmer (shown on first load) ──────────────────────────────────────

class _SearchShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 13, width: double.infinity, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 11, width: 140, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── No results ────────────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No results for "$query"',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Try a different keyword.',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

IconData _productIcon(ProductModel p) {
  if (p.drinkType.toLowerCase().contains('alcohol')) {
    return Icons.local_bar_rounded;
  }
  if (p.category == 'drink') return Icons.local_drink_rounded;
  return Icons.shopping_bag_rounded;
}

Color _productColor(ProductModel p) {
  if (p.drinkType.toLowerCase().contains('alcohol')) {
    return const Color(0xFF9D0208);
  }
  if (p.category == 'drink') return const Color(0xFFF4A261);
  return const Color(0xFF4CAF50);
}

// ── Search result tile ────────────────────────────────────────────────────────

class _SearchResultTile extends StatelessWidget {
  final ProductModel product;
  const _SearchResultTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final color = _productColor(product);
    final icon = _productIcon(product);

    return Card(
      child: ListTile(
        onTap: () => Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: ProductDetailArgs(
            id: product.id,
            name: product.name,
            category: product.category,
            price: product.price,
            description: '',
            icon: icon,
            color: color,
          ),
        ),
        leading: _ProductImage(imageUrl: product.imageUrl, color: color, icon: icon),
        title: Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${product.drinkType.isNotEmpty ? product.drinkType : product.category} • GH₵ ${product.price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: Icon(Icons.add_shopping_cart_rounded, color: color),
          tooltip: 'Add to cart',
          onPressed: () {
            cart.addItem(
              id: product.id,
              name: product.name,
              category: product.category,
              price: product.price,
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text('${product.name} added!'),
                backgroundColor: color,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ));
          },
        ),
      ),
    );
  }
}

// ── Product image widget ──────────────────────────────────────────────────────

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final Color color;
  final IconData icon;
  const _ProductImage(
      {required this.imageUrl, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _placeholder();

    // For base64 data URLs, decode and use Image.memory
    if (imageUrl.startsWith('data:')) {
      try {
        final comma = imageUrl.indexOf(',');
        if (comma == -1) return _placeholder();
        final base64Str = imageUrl.substring(comma + 1).trim();
        final bytes = base64Decode(base64Str);
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            bytes,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          ),
        );
      } catch (_) {
        return _placeholder();
      }
    }

    // Network URLs
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: color),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
