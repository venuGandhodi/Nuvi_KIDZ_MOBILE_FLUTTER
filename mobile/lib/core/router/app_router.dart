import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthState, AuthChangeEvent;

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/home/presentation/home_screen.dart';

// ---------------------------------------------------------------------------
// RouterNotifier
//
// Bridges the Riverpod [authStateProvider] stream into a [ChangeNotifier] that
// GoRouter can use as a [refreshListenable].  This is the pattern recommended
// by the go_router + riverpod community:
//
//   • GoRouter is created ONCE and never re-instantiated.
//   • When the auth stream emits an event (SIGNED_IN, SIGNED_OUT, etc.) this
//     notifier calls [notifyListeners()], which causes GoRouter to re-evaluate
//     its redirect() callback — without tearing down the navigation stack.
// ---------------------------------------------------------------------------
class RouterNotifier extends ChangeNotifier {
  // Cached auth state so the redirect() callback can read it synchronously.
  AsyncValue<AuthState> _authState = const AsyncLoading();

  AsyncValue<AuthState> get authState => _authState;

  /// True when a valid session is confirmed (not loading / not errored).
  bool get isAuthenticated => _authState.value?.session != null;

  /// True while the initial Supabase session is still being resolved.
  bool get isLoading => _authState.isLoading;

  /// True when the current auth change event is password recovery.
  bool get isPasswordRecovery =>
      _authState.value?.event == AuthChangeEvent.passwordRecovery;

  /// Called by [routerNotifierProvider] whenever [authStateProvider] changes.
  void update(AsyncValue<AuthState> newState) {
    _authState = newState;
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// routerNotifierProvider
//
// A Riverpod provider that owns the [RouterNotifier] instance.  It listens to
// [authStateProvider] and forwards every change to the notifier.
// ---------------------------------------------------------------------------
final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier();

  // Forward every auth state change into the notifier.
  ref.listen<AsyncValue<AuthState>>(
    authStateProvider,
    (_, next) => notifier.update(next),
    fireImmediately: true,
  );

  ref.onDispose(notifier.dispose);

  return notifier;
});

// ---------------------------------------------------------------------------
// routerProvider
//
// Creates the [GoRouter] ONCE.  Auth-driven redirects are handled via
// [refreshListenable] — the router instance itself is never recreated.
// ---------------------------------------------------------------------------
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/sign-in',
    refreshListenable: notifier,
    redirect: (context, state) {
      // Do not redirect while Supabase is resolving the initial session.
      // This prevents the /sign-in → /home → /sign-in startup loop.
      if (notifier.isLoading) return null;

      final isAuth = notifier.isAuthenticated;
      final isRecovery = notifier.isPasswordRecovery;
      final location = state.matchedLocation;

      // In password recovery mode, we must redirect to /reset-password
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

      // Unauthenticated user trying to reach a protected route.
      if (!isAuth && !isOnAuthScreen) {
        return '/sign-in';
      }

      // Authenticated user on an auth screen → send to home.
      if (isAuth && isOnAuthScreen) {
        return '/home';
      }

      // No redirect needed.
      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      // PHASE 1 PLACEHOLDER — replace with full home route when implemented.
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
});
