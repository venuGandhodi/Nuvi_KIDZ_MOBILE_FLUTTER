import 'package:shared_preferences/shared_preferences.dart';

class ShopifyCartStorage {
  static const String _cartIdKey = 'shopify_cart_id';
  final SharedPreferences? _injectedPrefs;

  ShopifyCartStorage({SharedPreferences? preferences})
      : _injectedPrefs = preferences;

  Future<SharedPreferences> get _prefs async =>
      _injectedPrefs ?? await SharedPreferences.getInstance();

  Future<String?> getCartId() async {
    try {
      final prefs = await _prefs;
      final id = prefs.getString(_cartIdKey);
      if (id != null && id.trim().isNotEmpty) {
        return id.trim();
      }
    } catch (_) {
      // Graceful fallback
    }
    return null;
  }

  Future<void> saveCartId(String cartId) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_cartIdKey, cartId);
    } catch (_) {
      // Graceful fallback
    }
  }

  Future<void> clearCartId() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_cartIdKey);
    } catch (_) {
      // Graceful fallback
    }
  }
}
