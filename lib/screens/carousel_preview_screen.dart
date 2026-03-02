import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carousel_provider.dart';

/// Full-screen showcase of both the Drinks and Provisions carousels,
/// with animated arrow annotations showing exactly where each carousel
/// will appear on its respective shop page.
class CarouselPreviewScreen extends StatefulWidget {
  const CarouselPreviewScreen({super.key});

  @override
  State<CarouselPreviewScreen> createState() => _CarouselPreviewScreenState();
}

class _CarouselPreviewScreenState extends State<CarouselPreviewScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _arrowCtrl;
  late final Animation<double> _arrowBounce;

  @override
  void initState() {
    super.initState();
    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _arrowBounce = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _arrowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CarouselProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003557),
        foregroundColor: Colors.white,
        title: const Text('Carousel Preview',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: const Text('Live Preview',
                  style: TextStyle(fontSize: 11, color: Colors.white)),
              backgroundColor: Colors.green.shade700,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Intro banner ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.amber, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'These carousels appear at the top of the Drink Shop '
                      'and Provision Shop pages for all users.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // ── Drinks Carousel ──────────────────────────────────────────
            _CarouselSection(
              title: 'Drinks Shop Carousel',
              subtitle: 'Appears at the top of the Drink Shop screen',
              accentColor: const Color(0xFF0096C7),
              icon: Icons.local_bar_rounded,
              arrowBounce: _arrowBounce,
              banners: cp.drinkBanners,
              fallbackBanners: const [
                _FallbackBanner('☀️  Summer Drinks', Color(0xFF0096C7)),
                _FallbackBanner('🆕  New Arrivals', Color(0xFF023E8A)),
                _FallbackBanner('🍺  Beer Promos', Color(0xFFF4A261)),
                _FallbackBanner('🥤  Soft Drinks Sale', Color(0xFF2EC4B6)),
                _FallbackBanner('🍷  Wine Collection', Color(0xFF9D0208)),
              ],
            ),

            const SizedBox(height: 40),

            // ── Provisions Carousel ───────────────────────────────────────
            _CarouselSection(
              title: 'Provisions Shop Carousel',
              subtitle: 'Appears at the top of the Provision Shop screen',
              accentColor: const Color(0xFF52B788),
              icon: Icons.shopping_basket_rounded,
              arrowBounce: _arrowBounce,
              banners: cp.provisionBanners,
              fallbackBanners: const [
                _FallbackBanner('🍪  Bulk Biscuits Deal', Color(0xFF52B788)),
                _FallbackBanner('🍳  Kitchen Essentials', Color(0xFFE76F51)),
                _FallbackBanner('🧼  Soap & Detergents', Color(0xFF457B9D)),
                _FallbackBanner('🛒  Weekly Grocery Pack', Color(0xFF2D6A4F)),
                _FallbackBanner('🏷️  Member-Only Prices', Color(0xFFD4A017)),
              ],
            ),

            const SizedBox(height: 32),

            // ── Tip card ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.lightbulb_outline_rounded,
                      color: Colors.amber, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tip: Go back to the Banners tab and upload images to '
                      'replace the default text slides with your own photos.',
                      style: TextStyle(color: Colors.amber, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Carousel Section ──────────────────────────────────────────────────────────

class _CarouselSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final Animation<double> arrowBounce;
  final List<String> banners;
  final List<_FallbackBanner> fallbackBanners;

  const _CarouselSection({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.arrowBounce,
    required this.banners,
    required this.fallbackBanners,
  });

  @override
  Widget build(BuildContext context) {
    final hasAdmin = banners.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label row
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),

        const SizedBox(height: 10),

        // Status badge
        Row(
          children: [
            AnimatedBuilder(
              animation: arrowBounce,
              builder: (_, __) => Transform.translate(
                offset: Offset(arrowBounce.value, 0),
                child: Icon(Icons.arrow_forward_rounded,
                    color: accentColor, size: 22),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: hasAdmin
                    ? Colors.green.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hasAdmin
                      ? Colors.green.shade400
                      : Colors.orange.shade400,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasAdmin
                        ? Icons.check_circle_outline_rounded
                        : Icons.image_outlined,
                    size: 13,
                    color: hasAdmin
                        ? Colors.green.shade400
                        : Colors.orange.shade400,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    hasAdmin
                        ? '${banners.length} custom image${banners.length > 1 ? 's' : ''} active'
                        : 'Using default text slides',
                    style: TextStyle(
                      fontSize: 12,
                      color: hasAdmin
                          ? Colors.green.shade300
                          : Colors.orange.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Phone frame mockup
        Center(
          child: Container(
            width: 340,
            decoration: BoxDecoration(
              color: const Color(0xFF1C2B38),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fake app bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        title.contains('Drinks')
                            ? 'Drink Shop'
                            : 'Provision Shop',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ← arrow pointing up at carousel
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: arrowBounce,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, -arrowBounce.value * 0.5),
                        child: Column(
                          children: [
                            Icon(Icons.arrow_drop_up_rounded,
                                color: Colors.yellowAccent, size: 28),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.yellowAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.yellowAccent, width: 1),
                              ),
                              child: const Text(
                                'Your carousel appears here',
                                style: TextStyle(
                                    color: Colors.yellowAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Actual live carousel
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: hasAdmin
                      ? _ImageCarousel(dataUris: banners, accent: accentColor)
                      : _TextCarousel(
                          items: fallbackBanners, accent: accentColor),
                ),

                const SizedBox(height: 10),

                // Fake content below
                ...List.generate(
                  2,
                  (_) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Text fallback carousel ────────────────────────────────────────────────────

class _TextCarousel extends StatelessWidget {
  final List<_FallbackBanner> items;
  final Color accent;
  const _TextCarousel({required this.items, required this.accent});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 130,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 2),
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: items.map((b) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: b.color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              b.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Image carousel ────────────────────────────────────────────────────────────

class _ImageCarousel extends StatelessWidget {
  final List<String> dataUris;
  final Color accent;
  const _ImageCarousel({required this.dataUris, required this.accent});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 130,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 2),
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: dataUris.map((uri) {
        Widget img;
        try {
          final bytes = base64Decode(uri.split(',')[1]);
          img = Image.memory(bytes, fit: BoxFit.cover, width: double.infinity);
        } catch (_) {
          img = Container(
            color: accent,
            child: const Center(
              child: Icon(Icons.broken_image_outlined,
                  color: Colors.white, size: 32),
            ),
          );
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: img,
          ),
        );
      }).toList(),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _FallbackBanner {
  final String label;
  final Color color;
  const _FallbackBanner(this.label, this.color);
}
