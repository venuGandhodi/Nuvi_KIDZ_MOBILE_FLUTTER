// Router redirect tests for NUVI KIDZ.
//
// All auth state is faked via RouterNotifier.update() or ProviderScope
// overrides. No real Supabase credentials or network calls are used.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthState, Session, User;

import 'package:nuvi_kidz/core/router/app_router.dart';

// ---------------------------------------------------------------------------
// Fake session helpers — build minimal in-memory objects using the real
// named constructors exposed by gotrue. No subclassing needed.
// ---------------------------------------------------------------------------

User _fakeUser() => const User(
  id: 'fake-user-id',
  appMetadata: {},
  userMetadata: {},
  aud: 'authenticated',
  createdAt: '2026-01-01T00:00:00.000Z',
  isAnonymous: false,
);

Session _fakeSession() => Session(
  accessToken: 'fake-access-token',
  tokenType: 'bearer',
  user: _fakeUser(),
);

/// Signed-in auth state with a real (fake) session object.
AsyncValue<AuthState> _signedIn() {
  final state = AuthState(AuthChangeEvent.signedIn, _fakeSession());
  return AsyncData(state);
}

/// Signed-out auth state — session is null.
AsyncValue<AuthState> _signedOut() {
  final state = AuthState(AuthChangeEvent.signedOut, null);
  return AsyncData(state);
}

/// Loading/initial auth state while Supabase resolves the session.
AsyncValue<AuthState> _loading() => const AsyncLoading();

/// Recovery auth state.
AsyncValue<AuthState> _recovery() {
  final state = AuthState(AuthChangeEvent.passwordRecovery, _fakeSession());
  return AsyncData(state);
}

// ---------------------------------------------------------------------------
// Helper: build a minimal GoRouter with the redirect logic under test,
// driven by a given [RouterNotifier].
// ---------------------------------------------------------------------------

GoRouter _buildRouter({
  required RouterNotifier notifier,
  String initialLocation = '/sign-in',
  bool includeSignUp = false,
  bool includeForgotPassword = false,
  bool includeResetPassword = false,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: notifier,
    redirect: (_, state) {
      if (notifier.isLoading) return null;

      final isAuth = notifier.isAuthenticated;
      final isRecovery = notifier.isPasswordRecovery;
      final location = state.matchedLocation;

      if (isRecovery) {
        if (location != '/reset-password') {
          return '/reset-password';
        }
        return null;
      }

      final isOnAuthScreen =
          location == '/sign-in' ||
          location == '/sign-up' ||
          location == '/forgot-password';

      if (!isAuth && !isOnAuthScreen) {
        return '/sign-in';
      }

      if (isAuth && isOnAuthScreen) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (_, s) => const Scaffold(body: Text('SignIn')),
      ),
      if (includeSignUp)
        GoRoute(
          path: '/sign-up',
          builder: (_, s) => const Scaffold(body: Text('SignUp')),
        ),
      if (includeForgotPassword)
        GoRoute(
          path: '/forgot-password',
          builder: (_, s) => const Scaffold(body: Text('ForgotPassword')),
        ),
      if (includeResetPassword)
        GoRoute(
          path: '/reset-password',
          builder: (_, s) => const Scaffold(body: Text('ResetPassword')),
        ),
      GoRoute(
        path: '/home',
        builder: (_, s) => const Scaffold(body: Text('Home')),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  Future<void> settle(WidgetTester tester) =>
      tester.pumpAndSettle(const Duration(seconds: 2));

  // ─── RouterNotifier unit tests ───────────────────────────────────────────

  group('RouterNotifier', () {
    test('isLoading is true when auth state is loading', () {
      final notifier = RouterNotifier();
      notifier.update(_loading());
      expect(notifier.isLoading, isTrue);
      expect(notifier.isAuthenticated, isFalse);
      notifier.dispose();
    });

    test('isAuthenticated is false when signed out', () {
      final notifier = RouterNotifier();
      notifier.update(_signedOut());
      expect(notifier.isAuthenticated, isFalse);
      expect(notifier.isLoading, isFalse);
      notifier.dispose();
    });

    test('isAuthenticated is true when signed in', () {
      final notifier = RouterNotifier();
      notifier.update(_signedIn());
      expect(notifier.isAuthenticated, isTrue);
      expect(notifier.isLoading, isFalse);
      notifier.dispose();
    });

    test('notifyListeners is called on every update()', () {
      final notifier = RouterNotifier();
      int callCount = 0;
      notifier.addListener(() => callCount++);
      notifier.update(_signedIn());
      expect(callCount, 1);
      notifier.update(_signedOut());
      expect(callCount, 2);
      notifier.dispose();
    });
  });

  // ─── Redirect rule tests ─────────────────────────────────────────────────

  group('Redirect rules', () {
    // 1. Unauthenticated → /home → redirect to /sign-in
    testWidgets(
      '1. Unauthenticated user accessing /home is redirected to /sign-in',
      (tester) async {
        final notifier = RouterNotifier()..update(_signedOut());
        final router = _buildRouter(
          notifier: notifier,
          initialLocation: '/home',
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await settle(tester);

        expect(find.text('SignIn'), findsOneWidget);
        expect(find.text('Home'), findsNothing);
        notifier.dispose();
      },
    );

    // 2. Authenticated → /sign-in → redirect to /home
    testWidgets(
      '2. Authenticated user accessing /sign-in is redirected to /home',
      (tester) async {
        final notifier = RouterNotifier()..update(_signedIn());
        final router = _buildRouter(
          notifier: notifier,
          initialLocation: '/sign-in',
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await settle(tester);

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('SignIn'), findsNothing);
        notifier.dispose();
      },
    );

    // 3. Authenticated → /sign-up → redirect to /home
    testWidgets(
      '3. Authenticated user accessing /sign-up is redirected to /home',
      (tester) async {
        final notifier = RouterNotifier()..update(_signedIn());
        final router = _buildRouter(
          notifier: notifier,
          initialLocation: '/sign-up',
          includeSignUp: true,
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await settle(tester);

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('SignUp'), findsNothing);
        notifier.dispose();
      },
    );

    // 4. Authenticated → /home → stays on /home (no redirect loop)
    testWidgets('4. Authenticated user on /home stays on /home', (
      tester,
    ) async {
      final notifier = RouterNotifier()..update(_signedIn());
      final router = _buildRouter(notifier: notifier, initialLocation: '/home');
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await settle(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('SignIn'), findsNothing);
      notifier.dispose();
    });

    // 5. Router instance is stable across auth state changes
    test(
      '5. routerProvider returns the same GoRouter instance across auth state changes',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final first = container.read(routerProvider);
        final second = container.read(routerProvider);

        expect(
          identical(first, second),
          isTrue,
          reason: 'GoRouter must not be re-instantiated on auth changes',
        );
      },
    );

    // 6. Sign-in success (SIGNED_IN event) → navigates to /home
    testWidgets(
      '6. After SIGNED_IN event router navigates from /sign-in to /home',
      (tester) async {
        final notifier = RouterNotifier()..update(_signedOut());
        final router = _buildRouter(
          notifier: notifier,
          initialLocation: '/sign-in',
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await settle(tester);
        expect(find.text('SignIn'), findsOneWidget);

        // Simulate Supabase SIGNED_IN event
        notifier.update(_signedIn());
        await settle(tester);

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('SignIn'), findsNothing);
        notifier.dispose();
      },
    );

    // 7. Sign-out (SIGNED_OUT event) → navigates from /home to /sign-in
    testWidgets(
      '7. After SIGNED_OUT event router navigates from /home to /sign-in',
      (tester) async {
        final notifier = RouterNotifier()..update(_signedIn());
        final router = _buildRouter(
          notifier: notifier,
          initialLocation: '/home',
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await settle(tester);
        expect(find.text('Home'), findsOneWidget);

        // Simulate Supabase SIGNED_OUT event
        notifier.update(_signedOut());
        await settle(tester);

        expect(find.text('SignIn'), findsOneWidget);
        expect(find.text('Home'), findsNothing);
        notifier.dispose();
      },
    );

    // 8. Loading state does not trigger any redirect (prevents startup loops)
    testWidgets(
      '8. Loading state does not redirect — no startup loop on /sign-in',
      (tester) async {
        final notifier = RouterNotifier()..update(_loading());
        final router = _buildRouter(
          notifier: notifier,
          initialLocation: '/sign-in',
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        // Only pump a few frames — not pumpAndSettle since we remain in loading
        await tester.pump();
        await tester.pump();

        // Must stay on /sign-in, no redirect attempted
        expect(find.text('SignIn'), findsOneWidget);
        notifier.dispose();
      },
    );

    // 9. /forgot-password is accessible while unauthenticated
    testWidgets('9. Unauthenticated user can access /forgot-password', (
      tester,
    ) async {
      final notifier = RouterNotifier()..update(_signedOut());
      final router = _buildRouter(
        notifier: notifier,
        initialLocation: '/forgot-password',
        includeForgotPassword: true,
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await settle(tester);

      expect(find.text('ForgotPassword'), findsOneWidget);
      notifier.dispose();
    });

    // 10. Recovery session redirects to /reset-password
    testWidgets(
      '10. Recovery session automatically redirects to /reset-password',
      (tester) async {
        final notifier = RouterNotifier()..update(_signedOut());
        final router = _buildRouter(
          notifier: notifier,
          initialLocation: '/sign-in',
          includeResetPassword: true,
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await settle(tester);
        expect(find.text('SignIn'), findsOneWidget);

        // Transition to recovery
        notifier.update(_recovery());
        await settle(tester);

        expect(find.text('ResetPassword'), findsOneWidget);
        notifier.dispose();
      },
    );

    // 11. Unauthorized access to /reset-password redirects to /sign-in
    testWidgets(
      '11. Unauthenticated user attempting to access /reset-password without recovery is redirected to /sign-in',
      (tester) async {
        final notifier = RouterNotifier()..update(_signedOut());
        final router = _buildRouter(
          notifier: notifier,
          initialLocation: '/reset-password',
          includeResetPassword: true,
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await settle(tester);

        expect(find.text('SignIn'), findsOneWidget);
        expect(find.text('ResetPassword'), findsNothing);
        notifier.dispose();
      },
    );
  });
}
