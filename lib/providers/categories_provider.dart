import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Model ──────────────────────────────────────────────────────────────────────

class ShopCategory {
  final String id;
  String name;
  String emoji;
  int colorValue;
  String? imageDataUri;

  ShopCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
    this.imageDataUri,
  });

  factory ShopCategory.fromJson(Map<String, dynamic> j) => ShopCategory(
        id: j['id'] as String,
        name: j['name'] as String,
        emoji: j['emoji'] as String,
        colorValue: j['colorValue'] as int,
        imageDataUri: j['imageDataUri'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'colorValue': colorValue,
        'imageDataUri': imageDataUri,
      };

  Color get color => Color(colorValue);
}

// ── Provider ───────────────────────────────────────────────────────────────────

class CategoriesProvider extends ChangeNotifier {
  static const _drinkKey = 'shop_categories_drink';
  static const _provisionKey = 'shop_categories_provision';

  // Default drink categories
  static List<ShopCategory> get _defaultDrink => [
        ShopCategory(
            id: 'alcoholic',
            name: 'Alcoholic Beverages',
            emoji: '🍺',
            colorValue: 0xFFF4A261),
        ShopCategory(
            id: 'non_alcoholic',
            name: 'Non-Alcoholic Beverages',
            emoji: '🥤',
            colorValue: 0xFFEF9A9A),
      ];

  // Default provision categories
  static List<ShopCategory> get _defaultProvision => [
        ShopCategory(
            id: 'biscuits',
            name: 'Biscuits & Snacks',
            emoji: '🍪',
            colorValue: 0xFFEF5350),
        ShopCategory(
            id: 'cooking',
            name: 'Cooking Ingredients',
            emoji: '🍚',
            colorValue: 0xFFE76F51),
        ShopCategory(
            id: 'soap',
            name: 'Soap & Detergents',
            emoji: '🧼',
            colorValue: 0xFFE57373),
      ];

  List<ShopCategory> _drinkCats = [];
  List<ShopCategory> _provisionCats = [];

  List<ShopCategory> get drinkCategories => List.unmodifiable(_drinkCats);
  List<ShopCategory> get provisionCategories =>
      List.unmodifiable(_provisionCats);

  // ── Persistence ─────────────────────────────────────────────────────────────

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final drinkJson = prefs.getString(_drinkKey);
    if (drinkJson != null) {
      final list = jsonDecode(drinkJson) as List;
      _drinkCats = list
          .map((e) => ShopCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _drinkCats = _defaultDrink;
    }

    final provisionJson = prefs.getString(_provisionKey);
    if (provisionJson != null) {
      final list = jsonDecode(provisionJson) as List;
      _provisionCats = list
          .map((e) => ShopCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _provisionCats = _defaultProvision;
    }

    notifyListeners();
  }

  Future<void> _save(String type) async {
    final prefs = await SharedPreferences.getInstance();
    if (type == 'drink') {
      await prefs.setString(
          _drinkKey, jsonEncode(_drinkCats.map((c) => c.toJson()).toList()));
    } else {
      await prefs.setString(_provisionKey,
          jsonEncode(_provisionCats.map((c) => c.toJson()).toList()));
    }
  }

  // ── CRUD ────────────────────────────────────────────────────────────────────

  Future<void> addCategory(
      String type, String name, String emoji, int colorValue,
      {String? imageDataUri}) async {
    final id = 'cat_${DateTime.now().millisecondsSinceEpoch}';
    final cat = ShopCategory(
        id: id,
        name: name,
        emoji: emoji,
        colorValue: colorValue,
        imageDataUri: imageDataUri);
    if (type == 'drink') {
      _drinkCats.add(cat);
    } else {
      _provisionCats.add(cat);
    }
    await _save(type);
    notifyListeners();
  }

  Future<void> editCategory(String type, String id, String name, String emoji,
      int colorValue, {String? imageDataUri}) async {
    final list = type == 'drink' ? _drinkCats : _provisionCats;
    final index = list.indexWhere((c) => c.id == id);
    if (index == -1) return;
    list[index].name = name;
    list[index].emoji = emoji;
    list[index].colorValue = colorValue;
    list[index].imageDataUri = imageDataUri;
    await _save(type);
    notifyListeners();
  }

  Future<void> deleteCategory(String type, String id) async {
    if (type == 'drink') {
      _drinkCats.removeWhere((c) => c.id == id);
    } else {
      _provisionCats.removeWhere((c) => c.id == id);
    }
    await _save(type);
    notifyListeners();
  }

  Future<void> resetToDefaults(String type) async {
    if (type == 'drink') {
      _drinkCats = _defaultDrink;
    } else {
      _provisionCats = _defaultProvision;
    }
    await _save(type);
    notifyListeners();
  }
}
