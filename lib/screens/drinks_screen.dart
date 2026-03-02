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

/// The main screen for browsing and adding drinks to the cart.
class DrinksScreen extends StatefulWidget {
  const DrinksScreen({super.key});

  @override
  State<DrinksScreen> createState() => _DrinksScreenState();
}

class _DrinksScreenState extends State<DrinksScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a brief network/data-load before revealing the product grid.
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  // ── Promotional banner data ───────────────────────────────────────────────
  static const List<_BannerData> _banners = [
    _BannerData('☀️  Summer Drinks', Color(0xFF0096C7)),
    _BannerData('🆕  New Arrivals', Color(0xFF023E8A)),
    _BannerData('🍺  Beer Promos', Color(0xFFF4A261)),
    _BannerData('🥤  Soft Drinks Sale', Color(0xFF2EC4B6)),
    _BannerData('🍷  Wine Collection', Color(0xFF9D0208)),
  ];

  // ── Sample drink products ─────────────────────────────────────────────────
  static const List<_ProductData> _drinks = [
    _ProductData('beer_001', 'Club Beer (33cl)', 'drink', 8.00, Icons.local_drink_rounded, Color(0xFFF4A261)),
    _ProductData('beer_002', 'Guinness (can)', 'drink', 10.00, Icons.local_bar_rounded, Color(0xFF212529)),
    _ProductData('wine_001', 'Red Wine (bottle)', 'drink', 55.00, Icons.wine_bar_rounded, Color(0xFF9D0208)),
    _ProductData('wine_002', 'White Wine (bottle)', 'drink', 52.00, Icons.wine_bar_rounded, Color(0xFFD4A017)),
    _ProductData('soda_001', 'Coca-Cola (50cl)', 'drink', 6.00, Icons.emoji_food_beverage_rounded, Color(0xFFCC0000)),
    _ProductData('soda_002', 'Fanta Orange (50cl)', 'drink', 5.50, Icons.emoji_food_beverage_rounded, Color(0xFFF4A261)),
    _ProductData('water_001', 'Voltic Water (1L)', 'drink', 4.00, Icons.water_drop_rounded, Color(0xFF0096C7)),
    _ProductData('water_002', 'Evian Water (500ml)', 'drink', 7.00, Icons.water_drop_rounded, Color(0xFF48CAE4)),
  ];

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
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text('Drink Shop'),
        backgroundColor: const Color(0xFF0077B6),
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
                final adminBanners = cp.drinkBanners;
                return adminBanners.isEmpty
                    ? const _PromoCarousel(banners: _banners)
                    : _AdminImageCarousel(dataUris: adminBanners);
              },
            ),

            const SizedBox(height: 20),

            // ── Section: Categories ─────────────────────────────────────────
            const _SectionHeader(title: 'Browse by Category'),
            Consumer<CategoriesProvider>(
              builder: (_, cp, __) {
                final cats = cp.drinkCategories;
                return Column(
                  children: cats
                      .map((c) => _CategoryCard(
                            emoji: c.emoji,
                            label: c.name,
                            color: c.color,
                            imageDataUri: c.imageDataUri,
                            onTap: () => _goToCategory(
                                context,
                                c.name,
                                c.name,
                                c.color,
                                Icons.local_bar_rounded),
                          ))
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // ── Section: Featured products ──────────────────────────────────
            const _SectionHeader(title: 'Featured Products'),
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
                      childAspectRatio: 0.82,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _drinks.length,
                    itemBuilder: (ctx, i) =>
                        _ProductCard(product: _drinks[i]),
                  ),

            // ── Admin uploaded drinks ───────────────────────────────────────
            Consumer<ProductsProvider>(
              builder: (_, provider, __) {
                final adminDrinks = provider.drinks;
                if (adminDrinks.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(title: '🆕  New Arrivals'),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.82,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: adminDrinks.length,
                      itemBuilder: (ctx, i) =>
                          _AdminProductCard(product: adminDrinks[i]),
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
    final width = MediaQuery.sizeOf(context).width;
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
          width: width,
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
                fontSize: 22,
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
              color: const Color(0xFF0077B6),
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
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF023E8A),
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
        color: color.withOpacity(0.12),
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
                color: color.withOpacity(0.9),
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
                color: Color(0xFF0077B6),
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
                    ..showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart!'),
                        backgroundColor: product.color,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
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
      'beer_001': 'A refreshing Ghanaian lager brewed with the finest barley and hops. Best served chilled.',
      'beer_002': 'The world-famous Irish stout with a rich, creamy head. Full-bodied and bold.',
      'wine_001': 'A smooth, full-bodied red wine with notes of cherry, plum, and oak. Perfect with meat.',
      'wine_002': 'A crisp, dry white wine with citrus and floral notes. Great with seafood and chicken.',
      'soda_001': 'The iconic cola beverage. Fizzy, sweet and refreshing. Best enjoyed ice-cold.',
      'soda_002': 'Bright, bubbly orange-flavoured soft drink. A favourite for the whole family.',
      'water_001': 'Premium Ghanaian natural mineral water. Pure, clean, and naturally refreshing.',
      'water_002': 'Naturally filtered French mineral water from the Alps. Light and pure taste.',
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
          childAspectRatio: 0.82,
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

// ── Data holder classes (const for efficiency) ───────────────────────────────

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
          // Image
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
                      color: Color(0xFF0077B6),
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
                        backgroundColor: const Color(0xFF0077B6),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0077B6),
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
      color: const Color(0xFF0077B6).withOpacity(0.08),
      child: const Center(
        child: Icon(Icons.local_bar_rounded,
            color: Color(0xFF0077B6), size: 36),
      ),
    );
  }
}
