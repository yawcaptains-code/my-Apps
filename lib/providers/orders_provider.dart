import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backend/repositories/orders_remote_repository.dart';
import '../backend/supabase_bootstrap.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

/// Persists and exposes the list of placed orders.
class OrdersProvider extends ChangeNotifier {
  static const _key = 'placed_orders';

  List<OrderModel> _orders = [];
  final OrdersRemoteRepository _remote = OrdersRemoteRepository();

  List<OrderModel> get orders => List.unmodifiable(_orders);

  int get count => _orders.length;

  // ── Initialisation ────────────────────────────────────────────────────────

  Future<void> loadFromPrefs() async {
    if (SupabaseBootstrap.isInitialized) {
      try {
        _orders = await _remote.fetchMyOrders();
        notifyListeners();
        // Keep local cache warm for offline fallback.
        await _persist();
        return;
      } catch (e) {
        debugPrint('Orders remote load failed, using local cache: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _orders = raw
        .map((s) => OrderModel.fromJsonString(s))
        .toList()
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    notifyListeners();
  }

  // ── Place order ───────────────────────────────────────────────────────────

  Future<void> placeOrder({
    required List<CartItem> items,
    required double total,
    required String recipientName,
    required String phone,
    required String address,
    required String paymentMethod,
    String? note,
  }) async {
    final order = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      total: total,
      recipientName: recipientName,
      phone: phone,
      address: address,
      paymentMethod: paymentMethod,
      note: note,
      placedAt: DateTime.now(),
    );
    _orders.insert(0, order);
    await _persist();

    if (SupabaseBootstrap.isInitialized) {
      try {
        await _remote.placeOrder(order);
      } catch (e) {
        debugPrint('Orders remote place failed: $e');
      }
    }

    notifyListeners();
  }

  // ── Update order status (admin) ───────────────────────────────────────────

  Future<void> updateStatus(String orderId, String newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;
    _orders[index].status = newStatus;
    await _persist();

    if (SupabaseBootstrap.isInitialized) {
      try {
        await _remote.updateStatus(orderId: orderId, status: newStatus);
      } catch (e) {
        debugPrint('Orders remote status update failed: $e');
      }
    }

    notifyListeners();
  }

  // ── Clear all history ─────────────────────────────────────────────────────

  Future<void> clearHistory() async {
    _orders.clear();
    await _persist();
    notifyListeners();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _orders.map((o) => o.toJsonString()).toList());
  }
}
