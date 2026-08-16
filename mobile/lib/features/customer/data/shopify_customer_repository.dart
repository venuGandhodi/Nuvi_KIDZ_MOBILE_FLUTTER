import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/nuvi_logger.dart';
import '../../order/domain/shopify_order.dart';
import '../domain/shopify_customer.dart';

enum CustomerSyncStatus { linked, notLinked, ambiguous, error, unauthenticated }

class CustomerSyncResult {
  final CustomerSyncStatus status;
  final ShopifyCustomer? customer;
  final String? message;

  const CustomerSyncResult({required this.status, this.customer, this.message});
}

class CustomerOrdersResult {
  final CustomerSyncStatus status;
  final List<ShopifyOrder> orders;
  final bool hasNextPage;
  final String? endCursor;
  final String? message;

  const CustomerOrdersResult({
    required this.status,
    this.orders = const [],
    this.hasNextPage = false,
    this.endCursor,
    this.message,
  });
}

class ShopifyCustomerRepository {
  final SupabaseClient? _supabase;

  ShopifyCustomerRepository([this._supabase]);

  // ── Low-level client accessor ──────────────────────────────────────────────
  // Returns the injected client (for tests) or the global Supabase instance.
  // Returns null if Supabase is not initialized (test environments that don't
  // inject a client and haven't called Supabase.initialize).
  SupabaseClient? get _client {
    if (_supabase != null) return _supabase;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get hasCurrentUser => _client?.auth.currentUser != null;

  // ── Centralized Edge Function Invoker ──────────────────────────────────────
  //
  // Requirements satisfied:
  //   1. Obtains current Supabase session via client.auth.currentSession.
  //   2. If session is null, returns null (unauthenticated).
  //   3. Checks session expiration against current timestamp.
  //   4. If expired or near-expiry (< 60s), calls official refreshSession().
  //   5. Reads session again after refresh to verify fresh token.
  //   6. Verifies freshSession != null, accessToken.isNotEmpty, user != null.
  //   7. Explicitly passes 'Authorization': 'Bearer <freshSession.accessToken>'
  //      to client.functions.invoke('shopify-customer-sync', ...).
  //   8. Never logs the access token or refresh token.
  //   9. Logs safe diagnostics only.
  //  10. All 7 methods delegate through this single helper.
  Future<FunctionResponse?> _invokeShopifyCustomerSync(
    Map<String, dynamic> body,
  ) async {
    final client = _client;

    if (client == null) {
      nuviLog('NUVI-AUTH', 'sessionExists=false');
      nuviLog('NUVI-AUTH', 'userExists=false');
      nuviLog('NUVI-AUTH', 'accessTokenExists=false');
      return null;
    }

    var session = client.auth.currentSession;
    if (session == null) {
      nuviLog('NUVI-AUTH', 'sessionExists=false');
      nuviLog('NUVI-AUTH', 'userExists=${client.auth.currentUser != null}');
      nuviLog('NUVI-AUTH', 'accessTokenExists=false');
      nuviLog(
        'NUVI-SHOPIFY-CUSTOMER',
        'No valid Supabase session — aborting Edge Function call',
      );
      return null;
    }

    final expiresAt = session.expiresAt;
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final isExpired = expiresAt != null && expiresAt < nowSec;
    final nearExpiry = expiresAt != null && (expiresAt - nowSec) < 60;

    if (isExpired || nearExpiry) {
      nuviLog(
        'NUVI-AUTH',
        'Session expired or near-expiry (isExpired=$isExpired, nearExpiry=$nearExpiry) — refreshing',
      );
      try {
        final refreshResult = await client.auth.refreshSession();
        session = refreshResult.session ?? client.auth.currentSession;
      } catch (refreshError) {
        nuviLog(
          'NUVI-AUTH',
          'Session refresh failed: ${refreshError.runtimeType}',
        );
        if (isExpired) {
          nuviLog(
            'NUVI-SHOPIFY-CUSTOMER',
            'Token was expired and refresh failed — aborting Edge Function call',
          );
          return null;
        }
      }
    }

    final freshSession = session ?? client.auth.currentSession;
    if (freshSession == null || freshSession.accessToken.isEmpty) {
      nuviLog(
        'NUVI-SHOPIFY-CUSTOMER',
        'freshSession is invalid after refresh check — aborting',
      );
      return null;
    }

    final currentExpiresAt = freshSession.expiresAt;
    final currentIsExpired =
        currentExpiresAt != null &&
        currentExpiresAt < (DateTime.now().millisecondsSinceEpoch ~/ 1000);

    // ── Safe diagnostics (no token values ever logged) ──────────────────────
    nuviLog('NUVI-AUTH', 'sessionExists=true');
    nuviLog('NUVI-AUTH', 'userExists=true');
    nuviLog('NUVI-AUTH', 'userId=${freshSession.user.id}');
    nuviLog('NUVI-AUTH', 'accessTokenExists=true');
    nuviLog('NUVI-AUTH', 'sessionExpiresAt=$currentExpiresAt');
    nuviLog('NUVI-AUTH', 'tokenExpired=$currentIsExpired');
    nuviLog('NUVI-AUTH', 'Invoking shopify-customer-sync with current session');

    nuviLog('NUVI-SHOPIFY-CUSTOMER', 'Invoking shopify-customer-sync');

    return await client.functions.invoke(
      'shopify-customer-sync',
      body: body,
      headers: {'Authorization': 'Bearer ${freshSession.accessToken}'},
    );
  }

  // ── Public methods ─────────────────────────────────────────────────────────

  Future<CustomerSyncResult> getCustomerProfile() async {
    nuviLog('NUVI-SHOPIFY-CUSTOMER', 'action=GET_CUSTOMER');

    try {
      final response = await _invokeShopifyCustomerSync({
        'action': 'GET_CUSTOMER',
      });

      if (response == null) {
        return const CustomerSyncResult(
          status: CustomerSyncStatus.unauthenticated,
          message: 'No valid Supabase session.',
        );
      }

      nuviLog(
        'NUVI-SHOPIFY-CUSTOMER',
        'Edge Function invocation COMPLETE. HTTP status=${response.status}',
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        nuviLog(
          'NUVI-SHOPIFY-CUSTOMER',
          'ERROR: Invalid response format from Edge Function',
        );
        return const CustomerSyncResult(
          status: CustomerSyncStatus.error,
          message: 'Invalid response format from server.',
        );
      }

      final statusStr = data['status'] as String?;
      if (statusStr == 'CUSTOMER_NOT_LINKED') {
        nuviLog('NUVI-SHOPIFY-CUSTOMER', 'Status: CUSTOMER_NOT_LINKED');
        return CustomerSyncResult(
          status: CustomerSyncStatus.notLinked,
          message: data['message'] as String?,
        );
      }

      if (statusStr == 'CUSTOMER_MAPPING_AMBIGUOUS') {
        nuviLog('NUVI-SHOPIFY-CUSTOMER', 'Status: CUSTOMER_MAPPING_AMBIGUOUS');
        return CustomerSyncResult(
          status: CustomerSyncStatus.ambiguous,
          message: data['message'] as String?,
        );
      }

      if (statusStr == 'LINKED' && data['customer'] != null) {
        nuviLog('NUVI-SHOPIFY-CUSTOMER', 'Status: LINKED');
        final customer = ShopifyCustomer.fromJson(
          data['customer'] as Map<String, dynamic>,
        );
        return CustomerSyncResult(
          status: CustomerSyncStatus.linked,
          customer: customer,
        );
      }

      nuviLog(
        'NUVI-SHOPIFY-CUSTOMER',
        'Status: ERROR / UNKNOWN (${data['error'] ?? "Unknown"})',
      );
      return CustomerSyncResult(
        status: CustomerSyncStatus.error,
        message:
            data['error'] as String? ?? 'Unable to retrieve customer profile.',
      );
    } catch (e, st) {
      nuviLog('NUVI-SHOPIFY-CUSTOMER', 'ERROR');
      nuviLog('NUVI-SHOPIFY-CUSTOMER', 'ERROR TYPE: ${e.runtimeType}');
      nuviLog('NUVI-SHOPIFY-CUSTOMER', 'ERROR MESSAGE: $e');
      nuviLog('NUVI-SHOPIFY-CUSTOMER', 'STACK TRACE:\n$st');
      return CustomerSyncResult(
        status: CustomerSyncStatus.error,
        message: e.toString(),
      );
    }
  }

  Future<CustomerOrdersResult> getCustomerOrders({
    int first = 20,
    String? after,
  }) async {
    nuviLog(
      'NUVI-SHOPIFY-CUSTOMER',
      'action=GET_ORDERS, first=$first, after=$after',
    );

    try {
      final response = await _invokeShopifyCustomerSync({
        'action': 'GET_ORDERS',
        'first': first,
        'after': ?after,
      });

      if (response == null) {
        return const CustomerOrdersResult(
          status: CustomerSyncStatus.unauthenticated,
          message: 'No valid Supabase session.',
        );
      }

      nuviLog(
        'NUVI-SHOPIFY-CUSTOMER',
        'Edge Function invocation COMPLETE. HTTP status=${response.status}',
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return const CustomerOrdersResult(
          status: CustomerSyncStatus.error,
          message: 'Invalid response format from server.',
        );
      }

      final statusStr = data['status'] as String?;
      if (statusStr == 'CUSTOMER_NOT_LINKED') {
        return CustomerOrdersResult(
          status: CustomerSyncStatus.notLinked,
          message: data['message'] as String?,
        );
      }

      if (statusStr == 'LINKED') {
        final rawOrders = data['orders'] as List<dynamic>? ?? [];
        final orders = rawOrders
            .map((e) => ShopifyOrder.fromJson(e as Map<String, dynamic>))
            .toList();

        final pageInfo = data['pageInfo'] as Map<String, dynamic>?;
        final hasNextPage = pageInfo?['hasNextPage'] as bool? ?? false;
        final endCursor = pageInfo?['endCursor'] as String?;

        return CustomerOrdersResult(
          status: CustomerSyncStatus.linked,
          orders: orders,
          hasNextPage: hasNextPage,
          endCursor: endCursor,
        );
      }

      return CustomerOrdersResult(
        status: CustomerSyncStatus.error,
        message: data['error'] as String? ?? 'Unable to retrieve orders.',
      );
    } catch (e, st) {
      nuviLog('NUVI-SHOPIFY-CUSTOMER', 'ERROR');
      nuviLog('NUVI-SHOPIFY-CUSTOMER', 'ERROR TYPE: ${e.runtimeType}');
      nuviLog('NUVI-SHOPIFY-CUSTOMER', 'ERROR MESSAGE: $e');
      nuviLog('NUVI-SHOPIFY-CUSTOMER', 'STACK TRACE:\n$st');
      return CustomerOrdersResult(
        status: CustomerSyncStatus.error,
        message: e.toString(),
      );
    }
  }

  Future<ShopifyOrder?> getCustomerOrder(String orderId) async {
    nuviLog('NUVI-SHOPIFY-CUSTOMER', 'action=GET_ORDER, orderId=$orderId');

    try {
      final response = await _invokeShopifyCustomerSync({
        'action': 'GET_ORDER',
        'orderId': orderId,
      });

      if (response == null) return null;

      nuviLog(
        'NUVI-SHOPIFY-CUSTOMER',
        'Edge Function invocation COMPLETE. HTTP status=${response.status}',
      );

      final data = response.data;
      if (data is Map<String, dynamic> &&
          data['status'] == 'LINKED' &&
          data['order'] != null) {
        return ShopifyOrder.fromJson(data['order'] as Map<String, dynamic>);
      }
      return null;
    } catch (e, st) {
      nuviLog('NUVI-SHOPIFY-CUSTOMER', 'ERROR');
      nuviLog('NUVI-SHOPIFY-CUSTOMER', 'ERROR TYPE: ${e.runtimeType}');
      nuviLog('NUVI-SHOPIFY-CUSTOMER', 'ERROR MESSAGE: $e');
      nuviLog('NUVI-SHOPIFY-CUSTOMER', 'STACK TRACE:\n$st');
      return null;
    }
  }

  Future<ShopifyAddress> createAddress(Map<String, dynamic> addressData) async {
    nuviLog('NUVI-SHOPIFY-CUSTOMER', 'Edge Function CREATE_ADDRESS START');
    final response = await _invokeShopifyCustomerSync({
      'action': 'CREATE_ADDRESS',
      'address': addressData,
    });

    if (response == null) throw Exception('No valid Supabase session.');

    final data = response.data;
    if (data is Map<String, dynamic> &&
        data['status'] == 'SUCCESS' &&
        data['address'] != null) {
      return ShopifyAddress.fromJson(data['address'] as Map<String, dynamic>);
    }

    final errMsg =
        (data is Map<String, dynamic> ? data['error'] : null) ??
        'Unable to save address.';
    throw Exception(errMsg);
  }

  Future<ShopifyAddress> updateAddress(
    String addressId,
    Map<String, dynamic> addressData,
  ) async {
    nuviLog('NUVI-SHOPIFY-CUSTOMER', 'Edge Function UPDATE_ADDRESS START');
    final response = await _invokeShopifyCustomerSync({
      'action': 'UPDATE_ADDRESS',
      'addressId': addressId,
      'address': addressData,
    });

    if (response == null) throw Exception('No valid Supabase session.');

    final data = response.data;
    if (data is Map<String, dynamic> &&
        data['status'] == 'SUCCESS' &&
        data['address'] != null) {
      return ShopifyAddress.fromJson(data['address'] as Map<String, dynamic>);
    }

    final errMsg =
        (data is Map<String, dynamic> ? data['error'] : null) ??
        'Unable to update address.';
    throw Exception(errMsg);
  }

  Future<void> deleteAddress(String addressId) async {
    nuviLog('NUVI-SHOPIFY-CUSTOMER', 'Edge Function DELETE_ADDRESS START');
    final response = await _invokeShopifyCustomerSync({
      'action': 'DELETE_ADDRESS',
      'addressId': addressId,
    });

    if (response == null) throw Exception('No valid Supabase session.');

    final data = response.data;
    if (data is Map<String, dynamic> && data['status'] == 'SUCCESS') {
      return;
    }

    final errMsg =
        (data is Map<String, dynamic> ? data['error'] : null) ??
        'Unable to delete address.';
    throw Exception(errMsg);
  }

  Future<ShopifyAddress?> setDefaultAddress(String addressId) async {
    nuviLog('NUVI-SHOPIFY-CUSTOMER', 'Edge Function SET_DEFAULT_ADDRESS START');
    final response = await _invokeShopifyCustomerSync({
      'action': 'SET_DEFAULT_ADDRESS',
      'addressId': addressId,
    });

    if (response == null) throw Exception('No valid Supabase session.');

    final data = response.data;
    if (data is Map<String, dynamic> && data['status'] == 'SUCCESS') {
      if (data['defaultAddress'] != null) {
        return ShopifyAddress.fromJson(
          data['defaultAddress'] as Map<String, dynamic>,
        );
      }
      return null;
    }

    final errMsg =
        (data is Map<String, dynamic> ? data['error'] : null) ??
        'Unable to set default address.';
    throw Exception(errMsg);
  }

  Future<CustomerSyncResult> fetchCustomer() => getCustomerProfile();

  Future<List<ShopifyAddress>> fetchAddresses() async {
    final result = await getCustomerProfile();
    return result.customer?.addresses ?? [];
  }
}

final shopifyCustomerRepositoryProvider = Provider<ShopifyCustomerRepository>((
  ref,
) {
  try {
    return ShopifyCustomerRepository(Supabase.instance.client);
  } catch (_) {
    return ShopifyCustomerRepository();
  }
});
