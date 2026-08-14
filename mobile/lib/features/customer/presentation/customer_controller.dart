import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/nuvi_logger.dart';
import '../data/shopify_customer_repository.dart';
import '../domain/shopify_customer.dart';
import '../../order/domain/shopify_order.dart';

class CustomerState {
  final ShopifyCustomer? customer;
  final List<ShopifyOrder> orders;
  final CustomerSyncStatus syncStatus;
  final bool isLoading;
  final bool isLoadingOrders;
  final bool hasNextPage;
  final String? endCursor;
  final String? errorMessage;
  final bool isAuthenticated;

  const CustomerState({
    this.customer,
    this.orders = const [],
    this.syncStatus = CustomerSyncStatus.unauthenticated,
    this.isLoading = false,
    this.isLoadingOrders = false,
    this.hasNextPage = false,
    this.endCursor,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  CustomerState copyWith({
    ShopifyCustomer? customer,
    List<ShopifyOrder>? orders,
    CustomerSyncStatus? syncStatus,
    bool? isLoading,
    bool? isLoadingOrders,
    bool? hasNextPage,
    String? endCursor,
    String? errorMessage,
    bool? isAuthenticated,
    bool clearCustomer = false,
  }) {
    return CustomerState(
      customer: clearCustomer ? null : (customer ?? this.customer),
      orders: orders ?? this.orders,
      syncStatus: syncStatus ?? this.syncStatus,
      isLoading: isLoading ?? this.isLoading,
      isLoadingOrders: isLoadingOrders ?? this.isLoadingOrders,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      endCursor: endCursor ?? this.endCursor,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class CustomerController extends Notifier<CustomerState> {
  @override
  CustomerState build() {
    Future.microtask(() => loadCustomer());
    return const CustomerState(isLoading: true);
  }

  /// Loads the customer profile and orders via the secure Edge Function.
  Future<void> loadCustomer() async {
    nuviLog('NUVI-CUSTOMER', 'loadCustomer START');
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(shopifyCustomerRepositoryProvider);
      final userAvailable = repo.hasCurrentUser;

      nuviLog(
        'NUVI-CUSTOMER',
        'Supabase session available=${userAvailable ? "true" : "false"}',
      );
      nuviLog(
        'NUVI-CUSTOMER',
        'Supabase authenticated user available=${userAvailable ? "true" : "false"}',
      );

      nuviLog('NUVI-CUSTOMER', 'Calling Shopify customer bridge');
      final profileResult = await repo.getCustomerProfile();
      nuviLog('NUVI-CUSTOMER', 'Shopify customer bridge RESPONSE');
      nuviLog('NUVI-CUSTOMER', 'Customer status: ${profileResult.status.name}');

      if (profileResult.status == CustomerSyncStatus.unauthenticated) {
        state = const CustomerState(
          syncStatus: CustomerSyncStatus.unauthenticated,
          isAuthenticated: false,
          isLoading: false,
        );
        nuviLog('NUVI-CUSTOMER', 'loadCustomer COMPLETE (unauthenticated)');
        return;
      }

      if (profileResult.status == CustomerSyncStatus.notLinked) {
        state = state.copyWith(
          syncStatus: CustomerSyncStatus.notLinked,
          isAuthenticated: true,
          isLoading: false,
          errorMessage: profileResult.message,
        );
        nuviLog('NUVI-CUSTOMER', 'loadCustomer COMPLETE (notLinked)');
        return;
      }

      if (profileResult.status == CustomerSyncStatus.ambiguous) {
        state = state.copyWith(
          syncStatus: CustomerSyncStatus.ambiguous,
          isAuthenticated: true,
          isLoading: false,
          errorMessage: profileResult.message,
        );
        nuviLog('NUVI-CUSTOMER', 'loadCustomer COMPLETE (ambiguous)');
        return;
      }

      if (profileResult.status == CustomerSyncStatus.linked &&
          profileResult.customer != null) {
        final ordersResult = await repo.getCustomerOrders(first: 20);

        state = state.copyWith(
          customer: profileResult.customer,
          orders: ordersResult.orders,
          hasNextPage: ordersResult.hasNextPage,
          endCursor: ordersResult.endCursor,
          syncStatus: CustomerSyncStatus.linked,
          isAuthenticated: true,
          isLoading: false,
          errorMessage: null,
        );
        nuviLog('NUVI-CUSTOMER', 'loadCustomer COMPLETE (linked)');
      } else {
        state = state.copyWith(
          syncStatus: CustomerSyncStatus.error,
          isAuthenticated: true,
          isLoading: false,
          errorMessage:
              profileResult.message ?? 'Failed to load customer profile.',
        );
        nuviLog('NUVI-CUSTOMER', 'loadCustomer COMPLETE (error)');
      }
    } catch (e, st) {
      nuviLog('NUVI-CUSTOMER', 'ERROR');
      nuviLog('NUVI-CUSTOMER', 'ERROR TYPE: ${e.runtimeType}');
      nuviLog('NUVI-CUSTOMER', 'ERROR MESSAGE: $e');
      nuviLog('NUVI-CUSTOMER', 'STACK TRACE:\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load profile. Please try again.',
      );
    }
  }

  /// Loads more orders using cursor-based pagination.
  Future<void> loadMoreOrders() async {
    if (state.isLoadingOrders ||
        !state.hasNextPage ||
        state.endCursor == null) {
      return;
    }

    state = state.copyWith(isLoadingOrders: true);
    try {
      final repo = ref.read(shopifyCustomerRepositoryProvider);
      final result = await repo.getCustomerOrders(
        first: 20,
        after: state.endCursor,
      );

      if (result.status == CustomerSyncStatus.linked) {
        state = state.copyWith(
          orders: [...state.orders, ...result.orders],
          hasNextPage: result.hasNextPage,
          endCursor: result.endCursor,
          isLoadingOrders: false,
        );
      } else {
        state = state.copyWith(isLoadingOrders: false);
      }
    } catch (e, st) {
      nuviLog('NUVI-CUSTOMER', 'ERROR loading more orders: $e');
      nuviLog('NUVI-CUSTOMER', 'STACK TRACE:\n$st');
      state = state.copyWith(isLoadingOrders: false);
    }
  }

  /// Retrieves an order by ID or order name.
  ShopifyOrder? getOrderById(String orderId) {
    try {
      return state.orders.firstWhere(
        (o) =>
            o.id == orderId ||
            o.name == orderId ||
            '${o.orderNumber}' == orderId ||
            o.id.endsWith('/$orderId'),
      );
    } catch (_) {
      return null;
    }
  }

  /// Creates a new address on the linked Shopify customer.
  Future<bool> createAddress(Map<String, dynamic> addressData) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(shopifyCustomerRepositoryProvider);
      await repo.createAddress(addressData);
      await loadCustomer();
      return true;
    } catch (e) {
      nuviLog('NUVI-CUSTOMER', 'createAddress ERROR: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to save address. Please check details and try again.',
      );
      return false;
    }
  }

  /// Updates an existing address on the linked Shopify customer.
  Future<bool> updateAddress(
    String addressId,
    Map<String, dynamic> addressData,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(shopifyCustomerRepositoryProvider);
      await repo.updateAddress(addressId, addressData);
      await loadCustomer();
      return true;
    } catch (e) {
      nuviLog('NUVI-CUSTOMER', 'updateAddress ERROR: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to update address. Please try again.',
      );
      return false;
    }
  }

  /// Deletes an address from the linked Shopify customer.
  Future<bool> deleteAddress(String addressId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(shopifyCustomerRepositoryProvider);
      await repo.deleteAddress(addressId);
      await loadCustomer();
      return true;
    } catch (e) {
      nuviLog('NUVI-CUSTOMER', 'deleteAddress ERROR: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to delete address. Please try again.',
      );
      return false;
    }
  }

  /// Sets an existing address as default on the linked Shopify customer.
  Future<bool> setDefaultAddress(String addressId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(shopifyCustomerRepositoryProvider);
      await repo.setDefaultAddress(addressId);
      await loadCustomer();
      return true;
    } catch (e) {
      nuviLog('NUVI-CUSTOMER', 'setDefaultAddress ERROR: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to set default address. Please try again.',
      );
      return false;
    }
  }

  /// Resets state on logout.
  void clear() {
    nuviLog('NUVI-CUSTOMER', 'CustomerController.clear executed');
    state = const CustomerState(
      syncStatus: CustomerSyncStatus.unauthenticated,
      isAuthenticated: false,
      isLoading: false,
    );
  }
}

final customerControllerProvider =
    NotifierProvider<CustomerController, CustomerState>(() {
      return CustomerController();
    });
