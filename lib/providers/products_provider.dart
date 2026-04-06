import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backend/repositories/products_remote_repository.dart';
import '../backend/supabase_bootstrap.dart';
import '../models/product_model.dart';

/// Manages admin-uploaded drinks and provisions.
class ProductsProvider extends ChangeNotifier {
  static const _key = 'admin_products';

  List<ProductModel> _products = [];
  final ProductsRemoteRepository _remote = ProductsRemoteRepository();

  List<ProductModel> get products => List.unmodifiable(_products);

  List<ProductModel> get drinks =>
      _products.where((p) => p.category == 'drink').toList();

  List<ProductModel> get provisions =>
      _products.where((p) => p.category == 'provision').toList();

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadFromPrefs() async {
    if (SupabaseBootstrap.isInitialized) {
      try {
        _products = await _remote.fetchAll();
        notifyListeners();
        // Keep local cache warm for offline fallback.
        await _persist();
        return;
      } catch (e) {
        debugPrint('Products remote load failed, using local cache: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _products = raw
        .map((s) => ProductModel.fromJsonString(s))
        .toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    notifyListeners();
  }

  // ── Add ───────────────────────────────────────────────────────────────────

  Future<void> addProduct({
    required String name,
    required double price,
    required String imageUrl,
    required String category,
    String drinkType = '',
  }) async {
    final product = ProductModel(
      id: 'PROD-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      price: price,
      imageUrl: imageUrl,
      category: category,
      drinkType: drinkType,
      addedAt: DateTime.now(),
    );
    _products.insert(0, product);
    await _persist();

    if (SupabaseBootstrap.isInitialized) {
      try {
        await _remote.upsert(product);
      } catch (e) {
        debugPrint('Products remote upsert failed: $e');
      }
    }

    notifyListeners();
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    await _persist();

    if (SupabaseBootstrap.isInitialized) {
      try {
        await _remote.deleteById(id);
      } catch (e) {
        debugPrint('Products remote delete failed: $e');
      }
    }

    notifyListeners();
  }

  // ── Persist ───────────────────────────────────────────────────────────────

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, _products.map((p) => p.toJsonString()).toList());
  }
}
