import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/products_provider.dart';
import 'providers/carousel_provider.dart';
import 'providers/categories_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/search_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/category_products_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_page2_screen.dart';
import 'screens/carousel_preview_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => CarouselProvider()),
      ],
      child: const DrinkProvisionApp(),
    ),
  );
}

class DrinkProvisionApp extends StatelessWidget {
  const DrinkProvisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drink & Provision Hub',
      debugShowCheckedModeBanner: false,

      // ── Material 3 Theme ──────────────────────────────────────────────────
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
          backgroundColor: Color(0xFF0077B6),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0077B6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),

      // ── Named Routes ──────────────────────────────────────────────────────
      // Splash loads persisted data then decides where to go.
      initialRoute: '/splash',
      routes: {
        '/splash': (ctx) => const SplashScreen(),
        '/onboarding': (ctx) => const OnboardingScreen(),
        // Main shell with persistent bottom nav (5 tabs)
        '/home': (ctx) => const MainShell(),
        '/drinks': (ctx) => const MainShell(initialIndex: 1),
        '/provisions': (ctx) => const MainShell(initialIndex: 2),
        '/orders': (ctx) => const MainShell(initialIndex: 3),
        '/profile': (ctx) => const MainShell(initialIndex: 4),
        // Standalone screens
        '/register': (ctx) => const RegisterScreen(),
        '/login': (ctx) => const LoginScreen(),
        '/checkout': (ctx) => const CheckoutScreen(),
        '/search': (ctx) => const SearchScreen(),
        '/product-detail': (ctx) => const ProductDetailScreen(),
        '/order-history': (ctx) => const OrderHistoryScreen(),
        '/category-products': (ctx) => const CategoryProductsScreen(),
        '/chat': (ctx) => const ChatScreen(),
        '/admin-login': (ctx) => const AdminLoginScreen(),
        '/admin-dashboard': (ctx) => const AdminDashboardScreen(),
        '/admin-page2': (ctx) => const AdminPage2Screen(),
        '/carousel-preview': (ctx) => const CarouselPreviewScreen(),
      },
    );
  }
}
