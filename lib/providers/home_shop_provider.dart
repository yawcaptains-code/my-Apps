import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores customisable content for the two shop tiles on the Home screen.
/// Admin edits via Admin Page 4 ("HOME").
class HomeShopProvider extends ChangeNotifier {
  static const _key = 'home_shop_settings';

  // ── Drink tile fields ─────────────────────────────────────────────────────
  String drinkLabel    = 'Drink Shop';
  String drinkSubtitle = 'Beers, wines, soft drinks & more';
  String drinkImageUrl = ''; // base64 data URI or ''

  // ── Logo field ──────────────────────────────────────────────────────────────
  String logoImageUrl = ''; // base64 data URI or ''

  // ── Provision tile fields ─────────────────────────────────────────────────
  String provisionLabel    = 'Provision Shop';
  String provisionSubtitle = 'Groceries, cleaning, snacks & more';
  String provisionImageUrl = ''; // base64 data URI or ''

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    final m = jsonDecode(raw) as Map<String, dynamic>;
    logoImageUrl      = (m['logoImageUrl']      as String?) ?? '';
    drinkLabel       = (m['drinkLabel']       as String?) ?? drinkLabel;
    drinkSubtitle    = (m['drinkSubtitle']    as String?) ?? drinkSubtitle;
    drinkImageUrl    = (m['drinkImageUrl']    as String?) ?? '';
    provisionLabel   = (m['provisionLabel']   as String?) ?? provisionLabel;
    provisionSubtitle= (m['provisionSubtitle']as String?) ?? provisionSubtitle;
    provisionImageUrl= (m['provisionImageUrl']as String?) ?? '';
    notifyListeners();
  }

  Future<void> save({
    required String logoImageUrl,
    required String drinkLabel,
    required String drinkSubtitle,
    required String drinkImageUrl,
    required String provisionLabel,
    required String provisionSubtitle,
    required String provisionImageUrl,
  }) async {
    this.logoImageUrl      = logoImageUrl;
    this.drinkLabel        = drinkLabel;
    this.drinkSubtitle     = drinkSubtitle;
    this.drinkImageUrl     = drinkImageUrl;
    this.provisionLabel    = provisionLabel;
    this.provisionSubtitle = provisionSubtitle;
    this.provisionImageUrl = provisionImageUrl;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({
      'logoImageUrl':      logoImageUrl,
      'drinkLabel':        drinkLabel,
      'drinkSubtitle':     drinkSubtitle,
      'drinkImageUrl':     drinkImageUrl,
      'provisionLabel':    provisionLabel,
      'provisionSubtitle': provisionSubtitle,
      'provisionImageUrl': provisionImageUrl,
    }));
  }
}
