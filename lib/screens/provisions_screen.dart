import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../providers/carousel_provider.dart';
import '../providers/categories_provider.dart';
import '../models/product_model.dart';
import '../widgets/cart_icon_badge.dart';
import 'product_detail_screen.dart';
import 'category_products_screen.dart';

/// The main screen for browsing and adding provisions/groceries to the cart.
class ProvisionsScreen extends StatefulWidget {
  const ProvisionsScreen({super.key});

  @override
  State<ProvisionsScreen> createState() => _ProvisionsScreenState();
}

class _ProvisionsScreenState extends State<ProvisionsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a brief network/data-load before revealing the product grid.
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  // ── Promotional banners ───────────────────────────────────────────────────
  static const List<_BannerData> _banners = [
    _BannerData('🍪  Bulk Biscuits Deal', Color(0xFF52B788)),
    _BannerData('🍳  Kitchen Essentials', Color(0xFFE76F51)),
    _BannerData('🧼  Soap & Detergents', Color(0xFF457B9D)),
    _BannerData('🛒  Weekly Grocery Pack', Color(0xFF2D6A4F)),
    _BannerData('🏷️  Member-Only Prices', Color(0xFFD4A017)),
  ];

  // ── Sample provision products ─────────────────────────────────────────────
  static const List<_ProductData> _products = [
    _ProductData('biscuit_001', 'Cabin Biscuits (pack)', 'provision', 12.00, Icons.cookie_rounded, Color(0xFF52B788)),
    _ProductData('biscuit_002', 'Digestive Biscuits', 'provision', 18.50, Icons.cookie_rounded, Color(0xFFD4A017)),
    _ProductData('recipe_001', 'Tomato Paste (tin)', 'provision', 5.00, Icons.rice_bowl_rounded, Color(0xFFE76F51)),
    _ProductData('recipe_002', 'Vegetable Oil (2L)', 'provision', 35.00, Icons.opacity_rounded, Color(0xFFFFD60A)),
    _ProductData('recipe_003', 'Basmati Rice (5kg)', 'provision', 95.00, Icons.rice_bowl_rounded, Color(0xFF52B788)),
    _ProductData('soap_001', 'Omo Detergent (1kg)', 'provision', 22.00, Icons.soap_rounded, Color(0xFF457B9D)),
    _ProductData('soap_002', 'Lux Bar Soap (3-pack)', 'provision', 14.00, Icons.soap_rounded, Color(0xFFE9C46A)),
    _ProductData('soap_003', 'Dettol Hand Soap', 'provision', 19.00, Icons.soap_rounded, Color(0xFF2D6A4F)),
  ];

  // ── Categories ────────────────────────────────────────────────────────────
  // Now loaded from CategoriesProvider (editable via admin)

  void _goToCategory(BuildContext context, String subcategory, String title, Color color, IconData icon) {
    Navigator.pushNamed(
      context,
      '/category-products',
      arguments: CategoryArgs(
        subcategory: subcategory,
        title: title,
        color: color,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      appBar: AppBar(
        title: const Text('Provision Shop'),
        backgroundColor: const Color(0xFF2D6A4F),
        actions: const [CartIconBadge()],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // ── Promotional carousel ────────────────────────────────────────
            Consumer<CarouselProvider>(
              builder: (_, cp, __) {
                final adminBanners = cp.provisionBanners;
                return adminBanners.isEmpty
                    ? const _PromoCarousel(banners: _banners)
                    : _AdminImageCarousel(dataUris: adminBanners);
              },
            ),

            const SizedBox(height: 20),

            // ── Categories ──────────────────────────────────────────────────
            const _SectionHeader(title: 'Browse by Category', color: Color(0xFF2D6A4F)),
            Consumer<CategoriesProvider>(
              builder: (_, cp, __) {
                final cats = cp.provisionCategories;
                return Column(
                  children: cats
                      .map((c) => _CategoryCard(
                            emoji: c.emoji,
                            label: c.name,
                            color: c.color,
                            imageDataUri: c.imageDataUri,
                            onTap: () => _goToCategory(
                                context, c.name, c.name, c.color,
                                Icons.shopping_basket_rounded),
                          ))
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // ── Featured Products ───────────────────────────────────────────
            const _SectionHeader(title: 'Featured Products', color: Color(0xFF2D6A4F)),
            _isLoading
                ? const _ShimmerProductGrid()
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.80,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (ctx, i) =>
                        _ProductCard(product: _products[i]),
                  ),

            // ── Admin uploaded provisions ───────────────────────────────────
            Consumer<ProductsProvider>(
              builder: (_, provider, __) {
                final adminProvisions = provider.provisions;
                if (adminProvisions.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(
                        title: '🆕  New Stock',
                        color: Color(0xFF2D6A4F)),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.80,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: adminProvisions.length,
                      itemBuilder: (ctx, i) =>
                          _AdminProductCard(product: adminProvisions[i]),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Promotional Carousel ──────────────────────────────────────────────────────

class _PromoCarousel extends StatelessWidget {
  final List<_BannerData> banners;
  const _PromoCarousel({required this.banners});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 170,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        enlargeCenterPage: true,
        viewportFraction: 0.88,
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      items: banners.map((b) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: b.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              b.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
// ── Admin Image Carousel ──────────────────────────────────────────

class _AdminImageCarousel extends StatelessWidget {
  final List<String> dataUris;
  const _AdminImageCarousel({required this.dataUris});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 170,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        enlargeCenterPage: true,
        viewportFraction: 0.88,
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      items: dataUris.map((uri) {
        Widget img;
        try {
          final bytes = base64Decode(uri.split(',')[1]);
          img = Image.memory(bytes,
              fit: BoxFit.cover, width: double.infinity);
        } catch (_) {
          img = Container(
              color: const Color(0xFF2D6A4F),
              child: const Center(
                  child: Icon(Icons.broken_image_outlined,
                      color: Colors.white, size: 40)));
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: img,
          ),
        );
      }).toList(),
    );
  }
}
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// ── Category Card ─────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final String? imageDataUri;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.emoji,
    required this.label,
    required this.color,
    this.imageDataUri,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: imageDataUri != null
                ? CircleAvatar(
                    backgroundColor: color,
                    child: ClipOval(
                      child: Image.memory(
                        base64Decode(imageDataUri!.split(',').last),
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: color,
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
            title: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 16,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}

// ── Product Card ──────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final _ProductData product;
  const _ProductCard({required this.product});

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
            description: _description(product.id),
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
                  child: Icon(
                    product.icon,
                    size: 54,
                    color: product.color.withOpacity(0.8),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'GH₵ ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF2D6A4F),
                fontWeight: FontWeight.bold,
              ),
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
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text('${product.name} added to cart!'),
                      backgroundColor: product.color,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ));
                },
                icon: const Icon(Icons.add_shopping_cart, size: 16),
                label: const Text('Add', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: product.color,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  String _description(String id) {
    const map = {
      'biscuit_001': 'Classic Ghanaian cabin biscuits – crispy, lightly sweetened. Great for snacking and travel.',
      'biscuit_002': 'Whole wheat digestive biscuits with a mild sweetness. Perfect with tea or as a snack.',
      'recipe_001': 'Concentrated tomato paste made from sun-ripened tomatoes. Essential for Ghanaian soups and stews.',
      'recipe_002': 'Pure refined vegetable cooking oil. Ideal for frying, sauéing, and everyday cooking.',
      'recipe_003': 'Long-grain aromatic basmati rice. Fluffy, fragrant, and delicious with any stew.',
      'soap_001': 'Powerful washing powder that removes tough stains in one wash. Fresh citrus scent.',
      'soap_002': 'Luxurious moisturising bar soap with natural ingredients. Leaves skin soft and smooth.',
      'soap_003': 'Antibacterial liquid hand soap that kills 99.9% of bacteria. Keeps your family protected.',
    };
    return map[id] ?? 'Premium quality product. Tap to learn more.';
  }
}
// ── Shimmer Loading Grid ──────────────────────────────────────────────────────

class _ShimmerProductGrid extends StatelessWidget {
  const _ShimmerProductGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.80,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 12, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 80, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(
                    height: 36,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ── Data holder classes ───────────────────────────────────────────────────────

class _BannerData {
  final String label;
  final Color color;
  const _BannerData(this.label, this.color);
}

class _ProductData {
  final String id;
  final String name;
  final String category;
  final double price;
  final IconData icon;
  final Color color;
  const _ProductData(this.id, this.name, this.category, this.price, this.icon, this.color);
}

// ── Admin Product Card ───────────────────────────────────────────────

class _AdminProductCard extends StatelessWidget {
  final ProductModel product;
  const _AdminProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: _buildProductImage(product.imageUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GH₵ ${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Color(0xFF2D6A4F),
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                GestureDetector(
                  onTap: () {
                    cart.addItem(
                      id: product.id,
                      name: product.name,
                      price: product.price,
                      category: product.category,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('✅  ${product.name} added to cart'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF2D6A4F),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D6A4F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_shopping_cart_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty) return _placeholder();
    if (imageUrl.startsWith('data:')) {
      try {
        final bytes = base64Decode(imageUrl.split(',')[1]);
        return Image.memory(bytes,
            width: double.infinity, fit: BoxFit.cover);
      } catch (_) {
        return _placeholder();
      }
    }
    return Image.network(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF2D6A4F).withOpacity(0.08),
      child: const Center(
        child: Icon(Icons.shopping_basket_rounded,
            color: Color(0xFF2D6A4F), size: 36),
      ),
    );
  }
}
