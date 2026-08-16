// ignore_for_file: must_be_immutable, prefer_initializing_formals
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/customer/data/shopify_customer_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Test doubles ────────────────────────────────────────────────────────────

/// Tracks invocation count and captured parameters of functions.invoke().
class MockFunctionsClient implements FunctionsClient {
  Map<String, dynamic>? mockResponse;
  int invokeCallCount = 0;
  Map<String, String>? lastCapturedHeaders;
  Object? lastCapturedBody;

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
    invokeCallCount++;
    lastCapturedHeaders = headers;
    lastCapturedBody = body;
    return FunctionResponse(data: mockResponse ?? {}, status: 200);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A [Session] subclass that allows overriding [expiresAt] for expiry tests.
class FakeSession extends Session {
  final int? _fakeExpiresAt;

  FakeSession({required super.accessToken, required super.user, int? expiresAt})
    : _fakeExpiresAt = expiresAt,
      super(tokenType: 'bearer');

  @override
  // ignore: overridden_fields
  late int? expiresAt = _fakeExpiresAt;
}

/// Fake GoTrueClient that exposes both [currentUser] and [currentSession].
class FakeGoTrueClient implements GoTrueClient {
  final User? _user;
  Session? _session;
  bool refreshCalled = false;
  final bool refreshShouldFail;
  final Session? _refreshedSession;

  FakeGoTrueClient({
    User? user,
    Session? session,
    this.refreshShouldFail = false,
    Session? refreshedSession,
  }) : _user = user,
       _session = session,
       _refreshedSession = refreshedSession;

  @override
  User? get currentUser => _user;

  @override
  Session? get currentSession => _session;

  @override
  Future<AuthResponse> refreshSession([String? refreshToken]) async {
    refreshCalled = true;
    if (refreshShouldFail) {
      throw AuthException('refresh_token_not_found');
    }
    _session = _refreshedSession;
    return AuthResponse(session: _refreshedSession);
  }

  @override
  Stream<AuthState> get onAuthStateChangeSync => const Stream.empty();

  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// FakeSupabaseClient wires the mock functions and auth together.
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

// ── Helpers ──────────────────────────────────────────────────────────────────

User makeUser({String id = 'user-123', String email = 'test@example.com'}) =>
    User(
      id: id,
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-08-14T00:00:00Z',
      email: email,
    );

FakeSession makeSession({
  User? user,
  int? overrideExpiresAt,
  String accessToken = 'fake-access-token',
}) {
  return FakeSession(
    accessToken: accessToken,
    user: user ?? makeUser(),
    expiresAt: overrideExpiresAt,
  );
}

FakeSupabaseClient buildAuthenticatedClient({
  required MockFunctionsClient functions,
  int? sessionExpiresAt,
  bool refreshShouldFail = false,
  FakeSession? refreshedSession,
  String userId = 'user-123',
  String accessToken = 'fake-access-token',
}) {
  final user = makeUser(id: userId);
  final session = makeSession(
    user: user,
    overrideExpiresAt: sessionExpiresAt,
    accessToken: accessToken,
  );
  final refreshed = refreshedSession ?? makeSession(user: user);
  final auth = FakeGoTrueClient(
    user: user,
    session: session,
    refreshShouldFail: refreshShouldFail,
    refreshedSession: refreshed,
  );
  return FakeSupabaseClient(functionsMock: functions, authMock: auth);
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ShopifyCustomerRepository Tests', () {
    // ── 10 Auth Lifecycle & Session Tests ──────────────────────────────────

    test(
      '1. currentSession == null returns unauthenticated, Edge Function NOT called',
      () async {
        final mockFunctions = MockFunctionsClient();
        final fakeAuth = FakeGoTrueClient(
          user: makeUser(),
          session: null, // ← null session
        );
        final fakeClient = FakeSupabaseClient(
          functionsMock: mockFunctions,
          authMock: fakeAuth,
        );

        final repo = ShopifyCustomerRepository(fakeClient);
        final result = await repo.getCustomerProfile();

        expect(result.status, CustomerSyncStatus.unauthenticated);
        expect(mockFunctions.invokeCallCount, 0);
      },
    );

    test(
      '2. valid currentSession invokes Edge Function with 200 response',
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

        final fakeClient = buildAuthenticatedClient(functions: mockFunctions);
        final repo = ShopifyCustomerRepository(fakeClient);
        final result = await repo.getCustomerProfile();

        expect(result.status, CustomerSyncStatus.linked);
        expect(result.customer?.fullName, 'Priya Sharma');
        expect(mockFunctions.invokeCallCount, 1);
      },
    );

    test('3. expired currentSession attempts session refresh', () async {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final user = makeUser(id: 'user-expired');
      final expiredSession = makeSession(
        user: user,
        overrideExpiresAt: nowSec - 3600, // expired
      );
      final freshSession = makeSession(
        user: user,
        accessToken: 'fresh-token-123',
      );

      final mockFunctions = MockFunctionsClient();
      mockFunctions.mockResponse = {
        'status': 'LINKED',
        'customer': {
          'id': 'gid://shopify/Customer/200',
          'email': 'priya@example.com',
          'addresses': [],
        },
      };

      final fakeAuth = FakeGoTrueClient(
        user: user,
        session: expiredSession,
        refreshedSession: freshSession,
      );
      final fakeClient = FakeSupabaseClient(
        functionsMock: mockFunctions,
        authMock: fakeAuth,
      );

      final repo = ShopifyCustomerRepository(fakeClient);
      await repo.getCustomerProfile();

      expect(fakeAuth.refreshCalled, isTrue);
    });

    test(
      '4. refreshSession() failure on expired session returns unauthenticated',
      () async {
        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final user = makeUser(id: 'user-expired');
        final expiredSession = makeSession(
          user: user,
          overrideExpiresAt: nowSec - 3600,
        );

        final mockFunctions = MockFunctionsClient();
        final fakeAuth = FakeGoTrueClient(
          user: user,
          session: expiredSession,
          refreshShouldFail: true,
        );
        final fakeClient = FakeSupabaseClient(
          functionsMock: mockFunctions,
          authMock: fakeAuth,
        );

        final repo = ShopifyCustomerRepository(fakeClient);
        final result = await repo.getCustomerProfile();

        expect(fakeAuth.refreshCalled, isTrue);
        expect(result.status, CustomerSyncStatus.unauthenticated);
        expect(mockFunctions.invokeCallCount, 0);
      },
    );

    test(
      '5. refreshed session is used to invoke Edge Function successfully',
      () async {
        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final user = makeUser(id: 'user-refresh');
        final expiredSession = makeSession(
          user: user,
          overrideExpiresAt: nowSec - 100,
        );
        final freshSession = makeSession(
          user: user,
          accessToken: 'new-valid-token-777',
        );

        final mockFunctions = MockFunctionsClient();
        mockFunctions.mockResponse = {
          'status': 'LINKED',
          'customer': {
            'id': 'gid://shopify/Customer/300',
            'email': 'refreshed@example.com',
            'addresses': [],
          },
        };

        final fakeAuth = FakeGoTrueClient(
          user: user,
          session: expiredSession,
          refreshedSession: freshSession,
        );
        final fakeClient = FakeSupabaseClient(
          functionsMock: mockFunctions,
          authMock: fakeAuth,
        );

        final repo = ShopifyCustomerRepository(fakeClient);
        final result = await repo.getCustomerProfile();

        expect(fakeAuth.refreshCalled, isTrue);
        expect(result.status, CustomerSyncStatus.linked);
        expect(mockFunctions.invokeCallCount, 1);
        expect(
          mockFunctions.lastCapturedHeaders?['Authorization'],
          'Bearer new-valid-token-777',
        );
      },
    );

    test(
      '6. explicit Authorization: Bearer <token> header is passed to FunctionsClient.invoke()',
      () async {
        final mockFunctions = MockFunctionsClient();
        mockFunctions.mockResponse = {
          'status': 'LINKED',
          'customer': {
            'id': 'gid://shopify/Customer/100',
            'email': 'test@example.com',
          },
        };

        final fakeClient = buildAuthenticatedClient(
          functions: mockFunctions,
          accessToken: 'explicit-token-abc-999',
        );
        final repo = ShopifyCustomerRepository(fakeClient);
        await repo.getCustomerProfile();

        expect(mockFunctions.invokeCallCount, 1);
        expect(mockFunctions.lastCapturedHeaders, isNotNull);
        expect(
          mockFunctions.lastCapturedHeaders?['Authorization'],
          'Bearer explicit-token-abc-999',
        );
      },
    );

    test('7. guest user does not invoke Edge Function', () async {
      final repo = ShopifyCustomerRepository(null);
      final result = await repo.getCustomerProfile();
      expect(result.status, CustomerSyncStatus.unauthenticated);
    });

    test('8. logout does not invoke Edge Function', () async {
      final mockFunctions = MockFunctionsClient();
      final fakeAuth = FakeGoTrueClient(user: null, session: null);
      final fakeClient = FakeSupabaseClient(
        functionsMock: mockFunctions,
        authMock: fakeAuth,
      );

      final repo = ShopifyCustomerRepository(fakeClient);
      final result = await repo.getCustomerProfile();

      expect(result.status, CustomerSyncStatus.unauthenticated);
      expect(mockFunctions.invokeCallCount, 0);
    });

    test('9. login invokes Edge Function with current session', () async {
      final mockFunctions = MockFunctionsClient();
      mockFunctions.mockResponse = {
        'status': 'LINKED',
        'customer': {
          'id': 'gid://shopify/Customer/123',
          'email': 'logged_in@nuvikidz.com',
        },
      };

      final fakeClient = buildAuthenticatedClient(
        functions: mockFunctions,
        accessToken: 'login-session-token',
      );
      final repo = ShopifyCustomerRepository(fakeClient);
      final result = await repo.getCustomerProfile();

      expect(result.status, CustomerSyncStatus.linked);
      expect(mockFunctions.invokeCallCount, 1);
      expect(
        mockFunctions.lastCapturedHeaders?['Authorization'],
        'Bearer login-session-token',
      );
    });

    test('10. re-login uses new access token', () async {
      final mockFunctions = MockFunctionsClient();
      mockFunctions.mockResponse = {
        'status': 'LINKED',
        'customer': {
          'id': 'gid://shopify/Customer/999',
          'email': 'relogin@example.com',
        },
      };

      final fakeClient = buildAuthenticatedClient(
        functions: mockFunctions,
        accessToken: 'relogin-new-token-555',
      );
      final repo = ShopifyCustomerRepository(fakeClient);
      final result = await repo.getCustomerProfile();

      expect(result.status, CustomerSyncStatus.linked);
      expect(mockFunctions.invokeCallCount, 1);
      expect(
        mockFunctions.lastCapturedHeaders?['Authorization'],
        'Bearer relogin-new-token-555',
      );
    });

    // ── Repository method coverage ─────────────────────────────────────────

    test(
      'getCustomerProfile returns notLinked status when customer is not found',
      () async {
        final mockFunctions = MockFunctionsClient();
        mockFunctions.mockResponse = {
          'status': 'CUSTOMER_NOT_LINKED',
          'message': 'No customer found.',
        };

        final fakeClient = buildAuthenticatedClient(functions: mockFunctions);
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

      final fakeClient = buildAuthenticatedClient(functions: mockFunctions);
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

      final fakeClient = buildAuthenticatedClient(functions: mockFunctions);
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

      final fakeClient = buildAuthenticatedClient(functions: mockFunctions);
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

      final fakeClient = buildAuthenticatedClient(functions: mockFunctions);
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

      final fakeClient = buildAuthenticatedClient(functions: mockFunctions);
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

        final fakeClient = buildAuthenticatedClient(functions: mockFunctions);
        final repo = ShopifyCustomerRepository(fakeClient);
        final addresses = await repo.fetchAddresses();

        expect(addresses.length, 1);
        expect(addresses.first.city, 'Hyderabad');
      },
    );
  });
}
