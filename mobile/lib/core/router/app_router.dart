import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthState, AuthChangeEvent;

import '../utils/nuvi_logger.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/customer/presentation/customer_controller.dart';
import '../../features/customer/data/shopify_customer_repository.dart';
import '../../core/widgets/app_shell.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/category/presentation/category_listing_screen.dart';
import '../../features/product/presentation/product_detail_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/order_confirmation_screen.dart';
import '../../features/customer/presentation/account_screen.dart';
import '../../features/customer/presentation/my_orders_screen.dart';
import '../../features/customer/presentation/order_details_screen.dart';
import '../../features/customer/presentation/saved_addresses_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/wishlist/presentation/wishlist_screen.dart';

// ---------------------------------------------------------------------------
// RouterNotifier
//
// Bridges the Riverpod [authStateProvider] stream into a [ChangeNotifier] that
// GoRouter can use as a [refreshListenable].
// ---------------------------------------------------------------------------
class RouterNotifier extends ChangeNotifier {
  AsyncValue<AuthState> _authState = const AsyncLoading();

  AsyncValue<AuthState> get authState => _authState;

  bool get isAuthenticated => _authState.value?.session != null;

  bool get isLoading => _authState.isLoading;

  bool get isPasswordRecovery =>
      _authState.value?.event == AuthChangeEvent.passwordRecovery;

  void update(AsyncValue<AuthState> newState) {
    _authState = newState;
    nuviLog(
      'NUVI-ROUTER',
      'Auth state changed. isAuthenticated=$isAuthenticated, isLoading=$isLoading',
    );
    nuviLog('NUVI-ROUTER', 'Router refresh triggered');
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// routerNotifierProvider
// ---------------------------------------------------------------------------
final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier();

  ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
    notifier.update(next);

    // ── Cold-start session restore & post-login customer sync ─────────────
    // When the Supabase SDK emits INITIAL_SESSION (app restart with a
    // persisted session) or SIGNED_IN (fresh login that has propagated),
    // trigger loadCustomer() if the customer state is still in its default
    // idle/unauthenticated state. This covers Test 8 (cold restart while
    // authenticated) and acts as a reliable single synchronization point.
    //
    // AuthController._triggerCustomerLoad() already handles the typical
    // email/Google sign-in path. This listener covers session restore.
    final event = next.value?.event;
    final session = next.value?.session;
    final isSessionEvent =
        event == AuthChangeEvent.initialSession ||
        event == AuthChangeEvent.signedIn;

    if (isSessionEvent && session != null) {
      final customerState = ref.read(customerControllerProvider);
      final needsLoad =
          customerState.customer == null &&
          !customerState.isLoading &&
          customerState.syncStatus == CustomerSyncStatus.unauthenticated;

      if (needsLoad) {
        nuviLog(
          'NUVI-ROUTER',
          'Session event=${event?.name} with active session — '
              'triggering loadCustomer() for cold-start restore',
        );
        // Use Future.microtask so this runs after the current frame
        // completes and the Supabase SDK has fully committed the session.
        Future.microtask(
          () => ref.read(customerControllerProvider.notifier).loadCustomer(),
        );
      }
    }
  }, fireImmediately: true);

  ref.onDispose(notifier.dispose);

  return notifier;
});

// ---------------------------------------------------------------------------
// routerProvider
// ---------------------------------------------------------------------------
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      if (notifier.isLoading) {
        nuviLog(
          'NUVI-ROUTER',
          'Router evaluation skipped (initial session loading)',
        );
        return null;
      }

      final isAuth = notifier.isAuthenticated;
      final isRecovery = notifier.isPasswordRecovery;
      final location = state.matchedLocation;

      nuviLog(
        'NUVI-ROUTER',
        'Evaluating redirect for location: $location (isAuth=$isAuth, isRecovery=$isRecovery)',
      );

      if (isRecovery) {
        if (location != '/reset-password') {
          nuviLog(
            'NUVI-ROUTER',
            'Navigating to /reset-password (password recovery mode)',
          );
          return '/reset-password';
        }
        return null;
      }

      final isOnAuthScreen =
          location == '/sign-in' ||
          location == '/sign-up' ||
          location == '/forgot-password';

      // Only specifically protected routes (e.g. saved addresses management) require login
      final requiresAuth = location == '/addresses';

      if (!isAuth && requiresAuth) {
        nuviLog(
          'NUVI-ROUTER',
          'Navigating to /sign-in (unauthenticated user on protected route)',
        );
        return '/sign-in';
      }

      // Authenticated user on an auth screen → send to home.
      if (isAuth && isOnAuthScreen) {
        nuviLog('NUVI-ROUTER', 'Authenticated user on auth screen -> /home');
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
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
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(state: state, child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/category/:categoryId',
            builder: (context, state) {
              final id = state.pathParameters['categoryId'] ?? 'toddler';
              return CategoryListingScreen(categoryId: id);
            },
          ),
          GoRoute(
            path: '/account',
            builder: (context, state) => const AccountScreen(),
          ),
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const MyOrdersScreen(),
          ),
          GoRoute(
            path: '/wishlist',
            builder: (context, state) => const WishlistScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/product/:productId',
        builder: (context, state) {
          final id = state.pathParameters['productId'] ?? 'prod_dream_romper';
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const SavedAddressesScreen(),
      ),
      GoRoute(
        path: '/orders/:orderId',
        builder: (context, state) {
          final id = state.pathParameters['orderId'] ?? '';
          return OrderDetailsScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-confirmation',
        builder: (context, state) {
          final orderId = state.extra as String?;
          return OrderConfirmationScreen(orderId: orderId);
        },
      ),
    ],
  );
});
