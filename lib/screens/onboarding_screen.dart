import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// First-time user experience: a full-screen PageView with 3 pages.
///
/// • Page 1 – Welcome splash (not tappable, just sets the scene).
/// • Page 2 – Drinks teaser → tap anywhere to enter the Drinks screen.
/// • Page 3 – Provisions teaser → tap anywhere to enter the Provisions screen.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goTo(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── The page content ─────────────────────────────────────────────
          PageView(
            controller: _controller,
            onPageChanged: (page) => setState(() {}),
            children: [
              const _OnboardPage(
                gradient: LinearGradient(
                  colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.local_drink_rounded,
                title: 'Welcome to\nDrink & Provision Hub',
                subtitle: 'Your one-stop shop for drinks and\neveryday provisions in Ghana.',
                onTap: null, // Page 1 is not tappable
              ),

              _OnboardPage(
                gradient: const LinearGradient(
                  colors: [Color(0xFF023E8A), Color(0xFF48CAE4)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                icon: Icons.wine_bar_rounded,
                title: 'Get All Your\nDrinkables Here',
                subtitle: 'Tap anywhere on this page\nto explore our Drink Shop →',
                onTap: () => _goTo('/drinks'),
              ),

              _OnboardPage(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D6A4F), Color(0xFFB7E4C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.shopping_basket_rounded,
                title: 'Get All Provisions\nin One Basket',
                subtitle: 'We save your time and the hustle.\nTap anywhere to explore Provisions →',
                onTap: () => _goTo('/provisions'),
              ),
            ],
          ),

          // ── Smooth page indicator dots at the bottom ──────────────────────
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white38,
                  dotHeight: 10,
                  dotWidth: 10,
                  expansionFactor: 3,
                  spacing: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private helper widget for each onboarding page ───────────────────────────

class _OnboardPage extends StatelessWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap; // null → page is not tappable

  const _OnboardPage({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height),
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Large decorative icon
              Icon(
                icon,
                size: (size.width * 0.30).clamp(60.0, size.height * 0.28),
                color: Colors.white70,
              ),
              const SizedBox(height: 24),

              // Bold headline
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: (size.width * 0.075).clamp(18.0, size.height * 0.07),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Subtitle / call-to-action hint
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: (size.width * 0.042).clamp(13.0, size.height * 0.04),
                    color: Colors.white.withOpacity(0.85),
                    height: 1.5,
                  ),
                ),
              ),

              // Visual "tap" hint when the page is tappable
              if (onTap != null) ...[
                const SizedBox(height: 32),
                Icon(
                  Icons.touch_app_rounded,
                  size: 32,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }
}
