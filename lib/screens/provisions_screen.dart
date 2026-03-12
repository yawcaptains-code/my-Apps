import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../providers/carousel_provider.dart';
import '../providers/categories_provider.dart';
import '../models/product_model.dart';
import '../widgets/cart_icon_badge.dart';
import 'category_products_screen.dart';

/// The main screen for browsing and adding provisions/groceries to the cart.
class ProvisionsScreen extends StatefulWidget {
  const ProvisionsScreen({super.key});

  @override
  State<ProvisionsScreen> createState() => _ProvisionsScreenState();
}

class _ProvisionsScreenState extends State<ProvisionsScreen> {
  // ── Promotional banners ───────────────────────────────────────────────────
  static const List<_BannerData> _banners = [
    _BannerData('🍪  Bulk Biscuits Deal', Color(0xFFEF5350)),
    _BannerData('🍳  Kitchen Essentials', Color(0xFFE76F51)),
    _BannerData('🧼  Soap & Detergents', Color(0xFFE57373)),
    _BannerData('🛒  Weekly Grocery Pack', Color(0xFFC62828)),
    _BannerData('🏷️  Member-Only Prices', Color(0xFFD4A017)),
  ];

  void _goToCategory(BuildContext context, String subcategory, String title, Color color, IconData icon, {String categoryId = ''}) {
    Navigator.pushNamed(
      context,
      '/category-products',
      arguments: CategoryArgs(
        subcategory: subcategory,
        title: title,
        color: color,
        icon: icon,
        categoryId: categoryId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provision Shop'),
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
            const _SectionHeader(title: 'Browse by Category', color: Color(0xFFC62828)),
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
                                Icons.shopping_basket_rounded,
                                categoryId: c.id),
                          ))
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // ── Admin provisions grouped by category ────────────────────────
            Consumer2<ProductsProvider, CategoriesProvider>(
              builder: (_, productsProvider, catsProvider, __) {
                final adminProvisions = productsProvider.provisions;
                if (adminProvisions.isEmpty) return const SizedBox.shrink();
                final cats = catsProvider.provisionCategories;
                final uncategorised = adminProvisions
                    .where((p) => cats.every((c) => c.id != p.drinkType))
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Per-category sections
                    for (final cat in cats) ...[
                      Builder(builder: (ctx) {
                        final catProducts = adminProvisions
                            .where((p) => p.drinkType == cat.id)
                            .toList();
                        if (catProducts.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                                title: '${cat.emoji}  ${cat.name}',
                                color: const Color(0xFFC62828)),
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
                              itemCount: catProducts.length,
                              itemBuilder: (ctx2, i) =>
                                  _AdminProductCard(product: catProducts[i]),
                            ),
                          ],
                        );
                      }),
                    ],
                    // Uncategorised fallback
                    if (uncategorised.isNotEmpty) ...[
                      const _SectionHeader(
                          title: '🆕  New Stock',
                          color: Color(0xFFC62828)),
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
                        itemCount: uncategorised.length,
                        itemBuilder: (ctx, i) =>
                            _AdminProductCard(product: uncategorised[i]),
                      ),
                    ],
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
              color: const Color(0xFFC62828),
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
        color: color.withValues(alpha: 0.10),
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

// ── Data holder classes ───────────────────────────────────────────────────────

class _BannerData {
  final String label;
  final Color color;
  const _BannerData(this.label, this.color);
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
                      color: Color(0xFFC62828),
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
                      imageUrl: product.imageUrl,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('✅  ${product.name} added to cart'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFFC62828),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC62828),
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
      color: const Color(0xFFC62828).withValues(alpha: 0.08),
      child: const Center(
        child: Icon(Icons.shopping_basket_rounded,
            color: Color(0xFFC62828), size: 36),
      ),
    );
  }
}
