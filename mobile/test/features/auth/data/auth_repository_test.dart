import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:nuvi_kidz/features/auth/data/auth_repository.dart';
import 'package:nuvi_kidz/features/auth/domain/auth_exception.dart';

class FakeGoogleSignInAccount implements GoogleSignInAccount {
  final GoogleSignInAuthentication _auth;

  FakeGoogleSignInAccount(this._auth);

  @override
  Future<GoogleSignInAuthentication> get authentication => Future.value(_auth);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGoogleSignInAuthentication implements GoogleSignInAuthentication {
  @override
  final String? idToken;
  @override
  final String? accessToken;

  FakeGoogleSignInAuthentication({this.idToken, this.accessToken});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGoogleSignIn implements GoogleSignIn {
  final GoogleSignInAccount? accountToReturn;

  FakeGoogleSignIn({this.accountToReturn});

  @override
  Future<GoogleSignInAccount?> signIn() => Future.value(accountToReturn);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGoTrueClient implements supabase.GoTrueClient {
  bool signInWithIdTokenCalled = false;
  String? lastIdToken;
  String? lastAccessToken;
  bool shouldThrowAuthException = false;
  bool shouldThrowGenericException = false;

  @override
  Future<supabase.AuthResponse> signInWithIdToken({
    required supabase.OAuthProvider provider,
    required String idToken,
    String? accessToken,
    String? nonce,
    String? captchaToken,
  }) async {
    if (shouldThrowAuthException) {
      throw const supabase.AuthException('Invalid Google ID token');
    }
    if (shouldThrowGenericException) {
      throw Exception('Network error');
    }
    signInWithIdTokenCalled = true;
    lastIdToken = idToken;
    lastAccessToken = accessToken;
    return supabase.AuthResponse();
  }

  bool signInWithOAuthCalled = false;
  supabase.OAuthProvider? lastOAuthProvider;
  String? lastRedirectTo;

  @override
  Future<supabase.OAuthResponse> getOAuthSignInUrl({
    required supabase.OAuthProvider provider,
    String? redirectTo,
    String? scopes,
    Map<String, String>? queryParams,
  }) async {
    signInWithOAuthCalled = true;
    lastOAuthProvider = provider;
    lastRedirectTo = redirectTo;
    return supabase.OAuthResponse(
      provider: provider,
      url: 'https://mock.supabase.co/auth/v1/authorize',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSupabaseClient implements supabase.SupabaseClient {
  final FakeGoTrueClient _auth;

  FakeSupabaseClient(this._auth);

  @override
  supabase.GoTrueClient get auth => _auth;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeGoTrueClient fakeGoTrue;
  late FakeSupabaseClient fakeSupabase;
  late AuthRepository repository;

  setUp(() async {
    await dotenv.load(fileName: '.env');
    fakeGoTrue = FakeGoTrueClient();
    fakeSupabase = FakeSupabaseClient(fakeGoTrue);
    repository = AuthRepository(fakeSupabase);
  });

  group('AuthRepository.signInWithGoogle', () {
    test('1. Google sign-in success', () async {
      final fakeAuth = FakeGoogleSignInAuthentication(
        idToken: 'fake-id-token',
        accessToken: 'fake-access-token',
      );
      final fakeAccount = FakeGoogleSignInAccount(fakeAuth);
      final fakeGoogleSignIn = FakeGoogleSignIn(accountToReturn: fakeAccount);

      final result = await repository.signInWithGoogle(
        googleSignInOverride: fakeGoogleSignIn,
      );

      expect(result, isTrue);
      expect(fakeGoTrue.signInWithIdTokenCalled, isTrue);
      expect(fakeGoTrue.lastIdToken, 'fake-id-token');
      expect(fakeGoTrue.lastAccessToken, 'fake-access-token');
    });

    test('2. Missing ID token throws AuthException', () async {
      final fakeAuth = FakeGoogleSignInAuthentication(
        idToken: null,
        accessToken: 'fake-access-token',
      );
      final fakeAccount = FakeGoogleSignInAccount(fakeAuth);
      final fakeGoogleSignIn = FakeGoogleSignIn(accountToReturn: fakeAccount);

      expect(
        () =>
            repository.signInWithGoogle(googleSignInOverride: fakeGoogleSignIn),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Failed to obtain Google ID token'),
          ),
        ),
      );
    });

    test('3. Missing access token succeeds if ID token is present', () async {
      final fakeAuth = FakeGoogleSignInAuthentication(
        idToken: 'fake-id-token',
        accessToken: null,
      );
      final fakeAccount = FakeGoogleSignInAccount(fakeAuth);
      final fakeGoogleSignIn = FakeGoogleSignIn(accountToReturn: fakeAccount);

      final result = await repository.signInWithGoogle(
        googleSignInOverride: fakeGoogleSignIn,
      );

      expect(result, isTrue);
      expect(fakeGoTrue.signInWithIdTokenCalled, isTrue);
      expect(fakeGoTrue.lastIdToken, 'fake-id-token');
      expect(fakeGoTrue.lastAccessToken, isNull);
    });

    test('4. Google cancellation returns false without throwing', () async {
      final fakeGoogleSignIn = FakeGoogleSignIn(accountToReturn: null);

      final result = await repository.signInWithGoogle(
        googleSignInOverride: fakeGoogleSignIn,
      );

      expect(result, isFalse);
      expect(fakeGoTrue.signInWithIdTokenCalled, isFalse);
    });

    test('5. Supabase AuthException is caught and wrapped', () async {
      fakeGoTrue.shouldThrowAuthException = true;

      final fakeAuth = FakeGoogleSignInAuthentication(
        idToken: 'fake-id-token',
        accessToken: 'fake-access-token',
      );
      final fakeAccount = FakeGoogleSignInAccount(fakeAuth);
      final fakeGoogleSignIn = FakeGoogleSignIn(accountToReturn: fakeAccount);

      expect(
        () =>
            repository.signInWithGoogle(googleSignInOverride: fakeGoogleSignIn),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            equals('Invalid Google ID token'),
          ),
        ),
      );
    });

    test('6. Unexpected exception is wrapped in AuthException', () async {
      fakeGoTrue.shouldThrowGenericException = true;

      final fakeAuth = FakeGoogleSignInAuthentication(
        idToken: 'fake-id-token',
        accessToken: 'fake-access-token',
      );
      final fakeAccount = FakeGoogleSignInAccount(fakeAuth);
      final fakeGoogleSignIn = FakeGoogleSignIn(accountToReturn: fakeAccount);

      expect(
        () =>
            repository.signInWithGoogle(googleSignInOverride: fakeGoogleSignIn),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('An unexpected error occurred'),
          ),
        ),
      );
    });

    test(
      '7. Standard signInWithGoogle delegates to Supabase signInWithOAuth',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/url_launcher'),
              (methodCall) async => true,
            );

        final result = await repository.signInWithGoogle();

        expect(result, isTrue);
        expect(fakeGoTrue.signInWithOAuthCalled, isTrue);
        expect(fakeGoTrue.lastOAuthProvider, supabase.OAuthProvider.google);
        expect(
          fakeGoTrue.lastRedirectTo,
          'io.supabase.nuvikidz://login-callback/',
        );
      },
    );
  });
}
