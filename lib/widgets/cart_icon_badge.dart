import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

/// Reusable AppBar cart icon that shows a red badge with the current quantity.
/// Tapping it navigates to the /orders screen.
class CartIconBadge extends StatelessWidget {
  const CartIconBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final cartQty = context.watch<CartProvider>().totalQuantity;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: badges.Badge(
        showBadge: cartQty > 0,
        badgeContent: Text(
          '$cartQty',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Colors.redAccent,
          padding: EdgeInsets.all(5),
        ),
        child: IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          tooltip: 'View cart',
          onPressed: () => Navigator.pushNamed(context, '/orders'),
        ),
      ),
    );
  }
}
