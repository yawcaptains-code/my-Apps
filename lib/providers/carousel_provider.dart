import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores admin-uploaded carousel banner images (base64) per category.
class CarouselProvider extends ChangeNotifier {
  static const _keyDrink = 'carousel_banners_drink';
  static const _keyProvision = 'carousel_banners_provision';

  List<String> _drinkBanners = [];
  List<String> _provisionBanners = [];

  List<String> get drinkBanners => List.unmodifiable(_drinkBanners);
  List<String> get provisionBanners => List.unmodifiable(_provisionBanners);

  /// Load persisted banners from SharedPreferences.
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final dRaw = prefs.getString(_keyDrink);
    final pRaw = prefs.getString(_keyProvision);
    if (dRaw != null) {
      _drinkBanners = List<String>.from(jsonDecode(dRaw) as List);
    }
    if (pRaw != null) {
      _provisionBanners = List<String>.from(jsonDecode(pRaw) as List);
    }
    notifyListeners();
  }

  Future<void> addBanner(String category, String base64Image) async {
    if (category == 'drink') {
      _drinkBanners = [..._drinkBanners, base64Image];
    } else {
      _provisionBanners = [..._provisionBanners, base64Image];
    }
    notifyListeners();
    await _persist();
  }

  Future<void> removeBanner(String category, int index) async {
    if (category == 'drink') {
      final list = [..._drinkBanners];
      list.removeAt(index);
      _drinkBanners = list;
    } else {
      final list = [..._provisionBanners];
      list.removeAt(index);
      _provisionBanners = list;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDrink, jsonEncode(_drinkBanners));
    await prefs.setString(_keyProvision, jsonEncode(_provisionBanners));
  }
}
