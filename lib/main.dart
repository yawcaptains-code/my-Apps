import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/products_provider.dart';
import 'providers/carousel_provider.dart';
import 'providers/categories_provider.dart';
import 'providers/contact_info_provider.dart';
import 'providers/home_shop_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'backend/supabase_bootstrap.dart';
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
import 'screens/admin_page3_screen.dart';
import 'screens/admin_page4_screen.dart';
import 'screens/admin_page5_screen.dart';
import 'screens/admin_page6_screen.dart';
import 'screens/admin_page7_screen.dart';
import 'screens/carousel_preview_screen.dart';
import 'widgets/admin_route_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseBootstrap.initializeIfConfigured();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => CarouselProvider()),
        ChangeNotifierProvider(create: (_) => ContactInfoProvider()),
        ChangeNotifierProvider(create: (_) => HomeShopProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const DrinkProvisionApp(),
    ),
  );
}

class DrinkProvisionApp extends StatelessWidget {
  const DrinkProvisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Drink & Provision Hub',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,

      // ── Material 3 Theme ──────────────────────────────────────────────────
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC62828),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
          backgroundColor: Color(0xFFC62828),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC62828),
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

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC62828),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC62828),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
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
        '/admin-dashboard': (ctx) =>
          const AdminRouteGate(child: AdminDashboardScreen()),
        '/admin-page2': (ctx) =>
          const AdminRouteGate(child: AdminPage2Screen()),
        '/admin-page3': (ctx) {
          final tab =
              (ModalRoute.of(ctx)?.settings.arguments as int?) ?? 0;
          return AdminRouteGate(child: AdminPage3Screen(initialTab: tab));
        },
        '/admin-page4': (ctx) =>
          const AdminRouteGate(child: AdminPage4Screen()),
        '/admin-page5': (ctx) =>
          const AdminRouteGate(child: AdminPage5Screen()),
        '/admin-page6': (ctx) =>
          const AdminRouteGate(child: AdminPage6Screen()),
        '/admin-page7': (ctx) =>
          const AdminRouteGate(child: AdminPage7Screen()),
        '/carousel-preview': (ctx) => const CarouselPreviewScreen(),
      },
    );
  }
}
