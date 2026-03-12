import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the company phone and WhatsApp numbers that are set by the admin
/// in Admin Page 3 and consumed wherever contact icons are shown.
class ContactInfoProvider extends ChangeNotifier {
  static const _phoneKey = 'company_phone';
  static const _whatsappKey = 'company_whatsapp';

  String _phone = '';
  String _whatsapp = '';

  String get phone => _phone;
  String get whatsapp => _whatsapp;

  /// Returns the tel: URI if a number is saved, otherwise empty.
  String get phoneUri => _phone.isNotEmpty ? 'tel:$_phone' : '';

  /// Returns the wa.me/ URI if a number is saved, otherwise empty.
  String get whatsappUri => _whatsapp.isNotEmpty
      ? 'https://wa.me/${_whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}'
          '?text=Hello%2C%20I%20would%20like%20to%20place%20an%20order'
      : '';

  ContactInfoProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _phone = prefs.getString(_phoneKey) ?? '';
    _whatsapp = prefs.getString(_whatsappKey) ?? '';
    notifyListeners();
  }

  Future<void> save({required String phone, required String whatsapp}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone.trim());
    await prefs.setString(_whatsappKey, whatsapp.trim());
    _phone = phone.trim();
    _whatsapp = whatsapp.trim();
    notifyListeners();
  }
}
