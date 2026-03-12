import 'dart:convert';
import 'cart_item.dart';

/// Represents a completed (placed) order saved locally.
class OrderModel {
  final String id;
  final List<CartItem> items;
  final double total;
  final String recipientName;
  final String phone;
  final String address;
  final String paymentMethod;
  final String? note;
  final DateTime placedAt;
  String status; // 'Pending' | 'Confirmed' | 'Delivered'

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    this.note,
    required this.placedAt,
    this.status = 'Pending',
  });

  // ── JSON serialisation ────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items
            .map((i) => {
                  'id': i.id,
                  'name': i.name,
                  'category': i.category,
                  'quantity': i.quantity,
                  'price': i.price,
                  'imageUrl': i.imageUrl,
                })
            .toList(),
        'total': total,
        'recipientName': recipientName,
        'phone': phone,
        'address': address,
        'paymentMethod': paymentMethod,
        'note': note,
        'placedAt': placedAt.toIso8601String(),
        'status': status,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        items: (json['items'] as List)
            .map((e) => CartItem(
                  id: e['id'] as String,
                  name: e['name'] as String,
                  category: e['category'] as String,
                  quantity: e['quantity'] as int,
                  price: (e['price'] as num).toDouble(),
                  imageUrl: (e['imageUrl'] as String?) ?? '',
                ))
            .toList(),
        total: (json['total'] as num).toDouble(),
        recipientName: json['recipientName'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String,
        paymentMethod: json['paymentMethod'] as String,
        note: json['note'] as String?,
        placedAt: DateTime.parse(json['placedAt'] as String),
        status: json['status'] as String? ?? 'Pending',
      );

  String toJsonString() => jsonEncode(toJson());
  static OrderModel fromJsonString(String s) =>
      OrderModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
