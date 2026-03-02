import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/cart_provider.dart';
import 'product_detail_screen.dart';

/// Master list of every product across both Drinks and Provisions.
/// Used by SearchScreen and CategoryProductsScreen.
class ProductCatalogue {
  static const List<_Product> all = [
    // ── Drinks ─────────────────────────────────────────────────────────────
    _Product('beer_001', 'Club Beer (33cl)', 'drink', 8.00,
        'A refreshing Ghanaian lager brewed with the finest barley and hops. Best served chilled.',
        Icons.local_drink_rounded, Color(0xFFF4A261), 'Alcoholic'),
    _Product('beer_002', 'Guinness (can)', 'drink', 10.00,
        'The world-famous Irish stout with a rich, creamy head. Full-bodied and bold.',
        Icons.local_bar_rounded, Color(0xFF212529), 'Alcoholic'),
    _Product('wine_001', 'Red Wine (bottle)', 'drink', 55.00,
        'A smooth, full-bodied red wine with notes of cherry, plum, and oak. Perfect with meat.',
        Icons.wine_bar_rounded, Color(0xFF9D0208), 'Alcoholic'),
    _Product('wine_002', 'White Wine (bottle)', 'drink', 52.00,
        'A crisp, dry white wine with citrus and floral notes. Great with seafood and chicken.',
        Icons.wine_bar_rounded, Color(0xFFD4A017), 'Alcoholic'),
    _Product('soda_001', 'Coca-Cola (50cl)', 'drink', 6.00,
        'The iconic cola beverage. Fizzy, sweet and refreshing. Best enjoyed ice-cold.',
        Icons.emoji_food_beverage_rounded, Color(0xFFCC0000), 'Non-Alcoholic'),
    _Product('soda_002', 'Fanta Orange (50cl)', 'drink', 5.50,
        'Bright, bubbly orange-flavoured soft drink. A favourite for the whole family.',
        Icons.emoji_food_beverage_rounded, Color(0xFFF4A261), 'Non-Alcoholic'),
    _Product('water_001', 'Voltic Water (1L)', 'drink', 4.00,
        'Premium Ghanaian natural mineral water. Pure, clean, and naturally refreshing.',
        Icons.water_drop_rounded, Color(0xFF0096C7), 'Non-Alcoholic'),
    _Product('water_002', 'Evian Water (500ml)', 'drink', 7.00,
        'Naturally filtered French mineral water from the Alps. Light and pure taste.',
        Icons.water_drop_rounded, Color(0xFF48CAE4), 'Non-Alcoholic'),

    // ── Provisions ─────────────────────────────────────────────────────────
    _Product('biscuit_001', 'Cabin Biscuits (pack)', 'provision', 12.00,
        'Classic Ghanaian cabin biscuits – crispy, lightly sweetened. Great for snacking and travel.',
        Icons.cookie_rounded, Color(0xFF52B788), 'Biscuits'),
    _Product('biscuit_002', 'Digestive Biscuits', 'provision', 18.50,
        'Whole wheat digestive biscuits with a mild sweetness. Perfect with tea or as a snack.',
        Icons.cookie_rounded, Color(0xFFD4A017), 'Biscuits'),
    _Product('recipe_001', 'Tomato Paste (tin)', 'provision', 5.00,
        'Concentrated tomato paste made from sun-ripened tomatoes. Essential for Ghanaian soups and stews.',
        Icons.rice_bowl_rounded, Color(0xFFE76F51), 'Cooking Ingredients'),
    _Product('recipe_002', 'Vegetable Oil (2L)', 'provision', 35.00,
        'Pure refined vegetable cooking oil. Ideal for frying, sautéing, and everyday cooking.',
        Icons.opacity_rounded, Color(0xFFFFD60A), 'Cooking Ingredients'),
    _Product('recipe_003', 'Basmati Rice (5kg)', 'provision', 95.00,
        'Long-grain aromatic basmati rice. Fluffy, fragrant, and delicious with any stew.',
        Icons.rice_bowl_rounded, Color(0xFF52B788), 'Cooking Ingredients'),
    _Product('soap_001', 'Omo Detergent (1kg)', 'provision', 22.00,
        'Powerful washing powder that removes tough stains in one wash. Fresh citrus scent.',
        Icons.soap_rounded, Color(0xFF457B9D), 'Soap & Detergents'),
    _Product('soap_002', 'Lux Bar Soap (3-pack)', 'provision', 14.00,
        'Luxurious moisturising bar soap with natural ingredients. Leaves skin soft and smooth.',
        Icons.soap_rounded, Color(0xFFE9C46A), 'Soap & Detergents'),
    _Product('soap_003', 'Dettol Hand Soap', 'provision', 19.00,
        'Antibacterial liquid hand soap that kills 99.9% of bacteria. Keeps your family protected.',
        Icons.soap_rounded, Color(0xFF2D6A4F), 'Soap & Detergents'),
  ];
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

/// Live search screen across all products.
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

  List<_Product> get _results {
    if (_query.isEmpty) return ProductCatalogue.all;
    final q = _query.toLowerCase();
    return ProductCatalogue.all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.subcategory.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
        backgroundColor: const Color(0xFF0077B6),
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
                          color: Color(0xFF023E8A),
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

// ── Search result tile ────────────────────────────────────────────────────────

class _SearchResultTile extends StatelessWidget {
  final _Product product;
  const _SearchResultTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

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
            description: product.description,
            icon: product.icon,
            color: product.color,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: product.color.withOpacity(0.15),
          child: Icon(product.icon, color: product.color, size: 20),
        ),
        title: Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${product.subcategory} • GH₵ ${product.price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: Icon(Icons.add_shopping_cart_rounded, color: product.color),
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
                backgroundColor: product.color,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ));
          },
        ),
      ),
    );
  }
}
