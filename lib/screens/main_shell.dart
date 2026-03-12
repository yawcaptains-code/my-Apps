import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../providers/cart_provider.dart';
import 'home_screen.dart';
import 'drinks_screen.dart';
import 'provisions_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

/// Persistent bottom navigation shell – 5 tabs:
/// Home · Drink Shop · Provision Shop · Cart · Profile
class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  static const List<Widget> _screens = [
    HomeScreen(),
    DrinksScreen(),
    ProvisionsScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final cartQty = context.watch<CartProvider>().totalQuantity;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // ── Search FAB (visible on Home & Drinks & Provisions tabs) ──────────
      floatingActionButton: _currentIndex <= 2
          ? FloatingActionButton(
              heroTag: 'search_fab',
              backgroundColor: const Color(0xFFC62828),
              tooltip: 'Search products',
              onPressed: () => Navigator.pushNamed(context, '/search'),
              child: const Icon(Icons.search_rounded, color: Colors.white),
            )
          : null,

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        elevation: 8,
        indicatorColor: const Color(0xFFC62828).withValues(alpha: 0.15),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon:
                Icon(Icons.home_rounded, color: Color(0xFFC62828)),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.wine_bar_outlined),
            selectedIcon:
                Icon(Icons.wine_bar_rounded, color: Color(0xFFC62828)),
            label: 'Drinks',
          ),
          const NavigationDestination(
            icon: Icon(Icons.shopping_basket_outlined),
            selectedIcon: Icon(Icons.shopping_basket_rounded,
                color: Color(0xFFC62828)),
            label: 'Provisions',
          ),
          NavigationDestination(
            icon: badges.Badge(
              showBadge: cartQty > 0,
              badgeContent: Text('$cartQty',
                  style:
                      const TextStyle(color: Colors.white, fontSize: 10)),
              badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.redAccent,
                  padding: EdgeInsets.all(4)),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: badges.Badge(
              showBadge: cartQty > 0,
              badgeContent: Text('$cartQty',
                  style:
                      const TextStyle(color: Colors.white, fontSize: 10)),
              badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.redAccent,
                  padding: EdgeInsets.all(4)),
              child: const Icon(Icons.shopping_cart_rounded,
                  color: Color(0xFFC62828)),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon:
                Icon(Icons.person_rounded, color: Color(0xFFC62828)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
