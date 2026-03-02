import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

/// Shared cart state used across both the Drinks and Provisions screens.
///
/// Cart is persisted to [SharedPreferences] so it survives app restarts.
class CartProvider extends ChangeNotifier {
  static const _key = 'cart_items';

  // Internal map: item id → CartItem
  final Map<String, CartItem> _items = {};

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Load previously saved cart from local storage on startup.
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      decoded.forEach((id, data) {
        _items[id] = CartItem(
          id: data['id'] as String,
          name: data['name'] as String,
          category: data['category'] as String,
          quantity: data['quantity'] as int,
          price: (data['price'] as num).toDouble(),
        );
      });
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_items.map((k, v) => MapEntry(k, {
          'id': v.id,
          'name': v.name,
          'category': v.category,
          'quantity': v.quantity,
          'price': v.price,
        })));
    await prefs.setString(_key, encoded);
  }

  /// An unmodifiable view of all cart items.
  Map<String, CartItem> get items => Map.unmodifiable(_items);

  /// Total number of individual product lines in the cart.
  int get itemCount => _items.length;

  /// Total quantity (sum of all item quantities) – shown on the badge.
  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  /// Grand total in Ghana Cedis.
  double get totalAmount =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Adds an item to the cart. If it already exists, increments quantity.
  void addItem({
    required String id,
    required String name,
    required String category,
    required double price,
  }) {
    if (_items.containsKey(id)) {
      _items[id] = _items[id]!.copyWith(quantity: _items[id]!.quantity + 1);
    } else {
      _items[id] = CartItem(
        id: id,
        name: name,
        category: category,
        price: price,
      );
    }
    notifyListeners();
    _persist();
  }

  /// Increments the quantity of an existing cart item.
  void increment(String id) {
    if (_items.containsKey(id)) {
      _items[id] = _items[id]!.copyWith(quantity: _items[id]!.quantity + 1);
      notifyListeners();
      _persist();
    }
  }

  /// Decrements the quantity. Removes item when quantity reaches 0.
  void decrement(String id) {
    if (!_items.containsKey(id)) return;
    if (_items[id]!.quantity <= 1) {
      _items.remove(id);
    } else {
      _items[id] = _items[id]!.copyWith(quantity: _items[id]!.quantity - 1);
    }
    notifyListeners();
    _persist();
  }

  /// Removes an item from the cart entirely.
  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
    _persist();
  }

  /// Clears the entire cart (e.g. after checkout).
  void clear() {
    _items.clear();
    notifyListeners();
    _persist();
  }
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    