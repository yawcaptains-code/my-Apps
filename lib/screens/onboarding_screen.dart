import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// First-time user experience: a full-screen PageView with 3 pages.
///
/// â€¢ Page 1 â€“ Welcome splash (not tappable, just sets the scene).
/// â€¢ Page 2 â€“ Drinks teaser â†’ tap anywhere to enter the Drinks screen.
/// â€¢ Page 3 â€“ Provisions teaser â†’ tap anywhere to enter the Provisions screen.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  Uint8List? _page1ImageBytes;
  String? _page1Title;
  String? _page1Subtitle;
  Uint8List? _page2ImageBytes;
  String? _page2Title;
  String? _page2Subtitle;
  Uint8List? _page3ImageBytes;
  String? _page3Title;
  String? _page3Subtitle;

  @override
  void initState() {
    super.initState();
    _loadOnboardingData();
  }

  Future<void> _loadOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();

    Uint8List? decodeImage(String? raw) {
      if (raw != null && raw.contains(',')) return base64Decode(raw.split(',')[1]);
      return null;
    }
    String? toText(String? v) => (v != null && v.isNotEmpty) ? v : null;

    if (!mounted) return;
    setState(() {
      _page1ImageBytes = decodeImage(prefs.getString('onboarding_page1_image'));
      _page1Title = toText(prefs.getString('onboarding_page1_title'));
      _page1Subtitle = toText(prefs.getString('onboarding_page1_subtitle'));
      _page2ImageBytes = decodeImage(prefs.getString('onboarding_page2_image'));
      _page2Title = toText(prefs.getString('onboarding_page2_title'));
      _page2Subtitle = toText(prefs.getString('onboarding_page2_subtitle'));
      _page3ImageBytes = decodeImage(prefs.getString('onboarding_page3_image'));
      _page3Title = toText(prefs.getString('onboarding_page3_title'));
      _page3Subtitle = toText(prefs.getString('onboarding_page3_subtitle'));
    });
  }

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
          // â”€â”€ The page content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          PageView(
            controller: _controller,
            onPageChanged: (page) => setState(() {}),
            children: [
              _OnboardPage(
                gradient: const LinearGradient(
                  colors: [Color(0xFF990000), Color(0xFFCC2200)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.local_drink_rounded,
                title: _page1Title ?? 'Welcome to\nDrink & Provision Hub',
                subtitle: _page1Subtitle ?? 'Your one-stop shop for drinks and\neveryday provisions in Ghana.',
                onTap: null, // Page 1 is not tappable
                backgroundImageBytes: _page1ImageBytes,
              ),

              _OnboardPage(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B0000), Color(0xFF990000)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                icon: Icons.wine_bar_rounded,
                title: _page2Title ?? 'Get All Your\nDrinkables Here',
                subtitle: _page2Subtitle ?? 'Tap anywhere to create\nyour account and get started →',
                onTap: () => _goTo('/register'),
                backgroundImageBytes: _page2ImageBytes,
              ),

              _OnboardPage(
                gradient: const LinearGradient(
                  colors: [Color(0xFF990000), Color(0xFF4D0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.shopping_basket_rounded,
                title: _page3Title ?? 'Get All Provisions\nin One Basket',
                subtitle: _page3Subtitle ?? 'We save your time and the hustle.\nTap anywhere to create your account →',
                onTap: () => _goTo('/register'),
                backgroundImageBytes: _page3ImageBytes,
              ),
            ],
          ),

          // â”€â”€ Smooth page indicator dots at the bottom â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€ Private helper widget for each onboarding page â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _OnboardPage extends StatelessWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap; // null â†’ page is not tappable
  final Uint8List? backgroundImageBytes;

  const _OnboardPage({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.backgroundImageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: backgroundImageBytes != null
            ? null
            : BoxDecoration(gradient: gradient),
        child: backgroundImageBytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(backgroundImageBytes!, fit: BoxFit.cover),
                  Container(
                      color: Colors.black.withValues(alpha: 0.45)), // dim overlay
                  _pageContent(size),
                ],
              )
            : _pageContent(size),
      ),
    );
  }

  Widget _pageContent(Size size) {
    return SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ),

              // Animated "tap" hint when the page is tappable
              if (onTap != null) ...[
                const SizedBox(height: 32),
                const _AnimatedTapHint(),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Animated finger-tap hint with ripple waves ───────────────────────────────

class _AnimatedTapHint extends StatefulWidget {
  const _AnimatedTapHint();

  @override
  State<_AnimatedTapHint> createState() => _AnimatedTapHintState();
}

class _AnimatedTapHintState extends State<_AnimatedTapHint>
    with TickerProviderStateMixin {
  late final AnimationController _ripple1;
  late final AnimationController _ripple2;
  late final AnimationController _ripple3;
  late final AnimationController _finger;

  @override
  void initState() {
    super.initState();

    // Three staggered ripple rings, each 1200 ms, offset by 400 ms
    _ripple1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _ripple2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _ripple3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();

    // Stagger: delay ripple2 by 400 ms, ripple3 by 800 ms
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ripple2.forward(from: 0);
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _ripple3.forward(from: 0);
    });

    // Finger: press down and lift, 800 ms repeat
    _finger = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ripple1.dispose();
    _ripple2.dispose();
    _ripple3.dispose();
    _finger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Wave rings
          _RippleRing(controller: _ripple1),
          _RippleRing(controller: _ripple2),
          _RippleRing(controller: _ripple3),
          // Finger icon
          AnimatedBuilder(
            animation: _finger,
            builder: (_, __) {
              final press = CurvedAnimation(parent: _finger, curve: Curves.easeInOut).value;
              return Transform.translate(
                offset: Offset(0, press * 7),
                child: Transform.scale(
                  scale: 1.0 - press * 0.15,
                  child: Icon(
                    Icons.touch_app_rounded,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RippleRing extends StatelessWidget {
  final AnimationController controller;
  const _RippleRing({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = CurvedAnimation(parent: controller, curve: Curves.easeOut).value;
        return CustomPaint(
          size: const Size(120, 120),
          painter: _RipplePainter(progress: t),
        );
      },
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  const _RipplePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Ring grows from 24 px to 58 px radius
    final radius = 24.0 + (58.0 - 24.0) * progress;
    // Opacity fades from 0.75 → 0.0
    final opacity = (1.0 - progress) * 0.75;
    // Stroke thins from 3 → 1
    final strokeWidth = 3.0 - progress * 2.0;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth.clamp(0.5, 3.0);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter old) => old.progress != progress;
}
