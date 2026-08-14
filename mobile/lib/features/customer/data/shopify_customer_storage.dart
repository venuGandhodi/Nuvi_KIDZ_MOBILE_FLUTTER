import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ShopifyCustomerStorage {
  static const _keyToken = 'shopify_customer_access_token';
  static const _keyExpiresAt = 'shopify_customer_token_expires_at';

  final FlutterSecureStorage _secureStorage;

  ShopifyCustomerStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  Future<void> saveCustomerToken(String token, DateTime expiresAt) async {
    await _secureStorage.write(key: _keyToken, value: token);
    await _secureStorage.write(
      key: _keyExpiresAt,
      value: expiresAt.toIso8601String(),
    );
  }

  Future<String?> getCustomerToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  Future<DateTime?> getTokenExpiresAt() async {
    final raw = await _secureStorage.read(key: _keyExpiresAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<bool> isTokenExpired() async {
    final expiresAt = await getTokenExpiresAt();
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt);
  }

  Future<void> clearCustomerToken() async {
    await _secureStorage.delete(key: _keyToken);
    await _secureStorage.delete(key: _keyExpiresAt);
  }
}
