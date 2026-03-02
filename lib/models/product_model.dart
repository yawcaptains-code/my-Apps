import 'dart:convert';

/// Represents an admin-uploaded product (drink or provision).
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl; // network URL or empty string
  final String category; // 'drink' | 'provision'
  final DateTime addedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'addedAt': addedAt.toIso8601String(),
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String,
        category: json['category'] as String,
        addedAt: DateTime.parse(json['addedAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());

  factory ProductModel.fromJsonString(String s) =>
      ProductModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
