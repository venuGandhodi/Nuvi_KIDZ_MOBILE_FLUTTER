import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/customer/data/shopify_customer_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockFunctionsClient implements FunctionsClient {
  Map<String, dynamic>? mockResponse;

  @override
  Future<FunctionResponse> invoke(
    String functionName, {
    Map<String, String>? headers,
    Object? body,
    HttpMethod method = HttpMethod.post,
    Map<String, dynamic>? queryParameters,
    String? region,
    Future<void>? abortSignal,
    Iterable<MultipartFile>? files,
  }) async {
    return FunctionResponse(data: mockResponse ?? {}, status: 200);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGoTrueClient implements GoTrueClient {
  final User? _user;

  FakeGoTrueClient([this._user]);

  @override
  User? get currentUser => _user;

  @override
  Stream<AuthState> get onAuthStateChangeSync => const Stream.empty();

  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSupabaseClient extends SupabaseClient {
  final FunctionsClient functionsMock;
  final GoTrueClient authMock;

  FakeSupabaseClient({required this.functionsMock, required this.authMock})
    : super('https://mock.supabase.co', 'mock-anon-key');

  @override
  FunctionsClient get functions => functionsMock;

  @override
  GoTrueClient get auth => authMock;
}

void main() {
  group('ShopifyCustomerRepository Tests', () {
    test(
      'getCustomerProfile returns unauthenticated when no current user',
      () async {
        final repo = ShopifyCustomerRepository(null);
        final result = await repo.getCustomerProfile();
        expect(result.status, CustomerSyncStatus.unauthenticated);
      },
    );

    test(
      'getCustomerProfile returns linked customer on successful Edge function response',
      () async {
        final mockFunctions = MockFunctionsClient();
        mockFunctions.mockResponse = {
          'status': 'LINKED',
          'customer': {
            'id': 'gid://shopify/Customer/100',
            'firstName': 'Priya',
            'lastName': 'Sharma',
            'displayName': 'Priya Sharma',
            'email': 'priya@example.com',
            'addresses': [],
            'ordersCount': 2,
          },
        };

        final fakeAuth = FakeGoTrueClient(
          const User(
            id: 'user-123',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: '2026-08-14T00:00:00Z',
            email: 'priya@example.com',
          ),
        );

        final fakeClient = FakeSupabaseClient(
          functionsMock: mockFunctions,
          authMock: fakeAuth,
        );

        final repo = ShopifyCustomerRepository(fakeClient);
        final result = await repo.getCustomerProfile();

        expect(result.status, CustomerSyncStatus.linked);
        expect(result.customer?.fullName, 'Priya Sharma');
        expect(result.customer?.email, 'priya@example.com');
      },
    );

    test(
      'getCustomerProfile returns notLinked status when customer is not found',
      () async {
        final mockFunctions = MockFunctionsClient();
        mockFunctions.mockResponse = {
          'status': 'CUSTOMER_NOT_LINKED',
          'message': 'No customer found.',
        };

        final fakeAuth = FakeGoTrueClient(
          const User(
            id: 'user-456',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: '2026-08-14T00:00:00Z',
            email: 'newuser@example.com',
          ),
        );

        final fakeClient = FakeSupabaseClient(
          functionsMock: mockFunctions,
          authMock: fakeAuth,
        );

        final repo = ShopifyCustomerRepository(fakeClient);
        final result = await repo.getCustomerProfile();

        expect(result.status, CustomerSyncStatus.notLinked);
        expect(result.customer, isNull);
      },
    );

    test('getCustomerOrders returns parsed ShopifyOrder list', () async {
      final mockFunctions = MockFunctionsClient();
      mockFunctions.mockResponse = {
        'status': 'LINKED',
        'orders': [
          {
            'id': 'gid://shopify/Order/200',
            'name': '#1002',
            'orderNumber': 1002,
            'processedAt': '2026-08-14T12:00:00Z',
            'currentTotalPrice': {'amount': 1599.0, 'currencyCode': 'INR'},
            'lineItems': [],
          },
        ],
        'pageInfo': {'hasNextPage': false, 'endCursor': null},
      };

      final fakeAuth = FakeGoTrueClient(
        const User(
          id: 'user-123',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-08-14T00:00:00Z',
          email: 'priya@example.com',
        ),
      );

      final fakeClient = FakeSupabaseClient(
        functionsMock: mockFunctions,
        authMock: fakeAuth,
      );

      final repo = ShopifyCustomerRepository(fakeClient);
      final result = await repo.getCustomerOrders();

      expect(result.status, CustomerSyncStatus.linked);
      expect(result.orders.length, 1);
      expect(result.orders.first.name, '#1002');
      expect(result.orders.first.currentTotalPrice.amount, 1599.0);
    });

    test('createAddress returns parsed ShopifyAddress on SUCCESS', () async {
      final mockFunctions = MockFunctionsClient();
      mockFunctions.mockResponse = {
        'status': 'SUCCESS',
        'address': {
          'id': 'gid://shopify/MailingAddress/1',
          'address1': '123 Main St',
          'city': 'Hyderabad',
          'province': 'Telangana',
          'zip': '500001',
          'country': 'India',
        },
      };

      final fakeAuth = FakeGoTrueClient(
        const User(
          id: 'user-123',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-08-14T00:00:00Z',
          email: 'priya@example.com',
        ),
      );

      final fakeClient = FakeSupabaseClient(
        functionsMock: mockFunctions,
        authMock: fakeAuth,
      );

      final repo = ShopifyCustomerRepository(fakeClient);
      final address = await repo.createAddress({
        'address1': '123 Main St',
        'city': 'Hyderabad',
      });

      expect(address.id, 'gid://shopify/MailingAddress/1');
      expect(address.city, 'Hyderabad');
    });

    test('deleteAddress succeeds without error on SUCCESS', () async {
      final mockFunctions = MockFunctionsClient();
      mockFunctions.mockResponse = {'status': 'SUCCESS'};

      final fakeAuth = FakeGoTrueClient(
        const User(
          id: 'user-123',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-08-14T00:00:00Z',
          email: 'priya@example.com',
        ),
      );

      final fakeClient = FakeSupabaseClient(
        functionsMock: mockFunctions,
        authMock: fakeAuth,
      );

      final repo = ShopifyCustomerRepository(fakeClient);
      await expectLater(
        repo.deleteAddress('gid://shopify/MailingAddress/1'),
        completes,
      );
    });

    test('setDefaultAddress returns default address on SUCCESS', () async {
      final mockFunctions = MockFunctionsClient();
      mockFunctions.mockResponse = {
        'status': 'SUCCESS',
        'defaultAddress': {
          'id': 'gid://shopify/MailingAddress/1',
          'address1': '123 Main St',
          'city': 'Hyderabad',
        },
      };

      final fakeAuth = FakeGoTrueClient(
        const User(
          id: 'user-123',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-08-14T00:00:00Z',
          email: 'priya@example.com',
        ),
      );

      final fakeClient = FakeSupabaseClient(
        functionsMock: mockFunctions,
        authMock: fakeAuth,
      );

      final repo = ShopifyCustomerRepository(fakeClient);
      final defaultAddr = await repo.setDefaultAddress(
        'gid://shopify/MailingAddress/1',
      );

      expect(defaultAddr?.id, 'gid://shopify/MailingAddress/1');
    });

    test('updateAddress returns updated ShopifyAddress on SUCCESS', () async {
      final mockFunctions = MockFunctionsClient();
      mockFunctions.mockResponse = {
        'status': 'SUCCESS',
        'address': {
          'id': 'gid://shopify/MailingAddress/1',
          'address1': '456 Oak Avenue',
          'city': 'Mumbai',
        },
      };

      final fakeAuth = FakeGoTrueClient(
        const User(
          id: 'user-123',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-08-14T00:00:00Z',
          email: 'priya@example.com',
        ),
      );

      final fakeClient = FakeSupabaseClient(
        functionsMock: mockFunctions,
        authMock: fakeAuth,
      );

      final repo = ShopifyCustomerRepository(fakeClient);
      final updated = await repo.updateAddress(
        'gid://shopify/MailingAddress/1',
        {'address1': '456 Oak Avenue', 'city': 'Mumbai'},
      );

      expect(updated.id, 'gid://shopify/MailingAddress/1');
      expect(updated.city, 'Mumbai');
    });

    test(
      'fetchAddresses returns list of addresses from customer profile',
      () async {
        final mockFunctions = MockFunctionsClient();
        mockFunctions.mockResponse = {
          'status': 'LINKED',
          'customer': {
            'id': 'gid://shopify/Customer/100',
            'email': 'priya@example.com',
            'addresses': [
              {
                'id': 'gid://shopify/MailingAddress/1',
                'address1': '123 Main St',
                'city': 'Hyderabad',
              },
            ],
          },
        };

        final fakeAuth = FakeGoTrueClient(
          const User(
            id: 'user-123',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: '2026-08-14T00:00:00Z',
            email: 'priya@example.com',
          ),
        );

        final fakeClient = FakeSupabaseClient(
          functionsMock: mockFunctions,
          authMock: fakeAuth,
        );

        final repo = ShopifyCustomerRepository(fakeClient);
        final addresses = await repo.fetchAddresses();

        expect(addresses.length, 1);
        expect(addresses.first.city, 'Hyderabad');
      },
    );
  });
}
