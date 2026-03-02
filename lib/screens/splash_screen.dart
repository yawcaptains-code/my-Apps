import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/products_provider.dart';
import '../providers/carousel_provider.dart';
import '../providers/categories_provider.dart';

/// Animated splash screen shown on every cold start.
///
/// Loads persisted cart + order data, then navigates to /home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    // Load persisted data in parallel
    final [prefs, _, __, ___, ____, _____] = await Future.wait([
      SharedPreferences.getInstance(),
      context.read<CartProvider>().loadFromPrefs(),
      context.read<OrdersProvider>().loadFromPrefs(),
      context.read<ProductsProvider>().loadFromPrefs(),
      context.read<CarouselProvider>().loadFromPrefs(),
      context.read<CategoriesProvider>().loadFromPrefs(),
    ]);

    // Minimum splash display
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    // First-time users see onboarding; returning users go straight to home
    final seen = (prefs as SharedPreferences).getBool('onboarding_done') ?? false;
    Navigator.pushReplacementNamed(context, seen ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF023E8A), Color(0xFF0096C7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Animated logo ────────────────────────────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_drink_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── App name ─────────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const Column(
                    children: [
                      Text(
                        'Drink & Provision Hub',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your one-stop shop in Ghana 🇬🇭',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // ── Spinner ───────────────────────────────────────────────
                const SpinKitThreeBounce(
                  color: Colors.white54,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
