import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthState, AuthChangeEvent;

import '../utils/nuvi_logger.dart';
import '../../features/auth/presentation/auth_controller.dart';
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
// ---------------------------------------------------------------------------
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/sign-in',
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

      // Unauthenticated user trying to reach a protected route.
      if (!isAuth && !isOnAuthScreen) {
        nuviLog(
          'NUVI-ROUTER',
          'Navigating to /sign-in (unauthenticated user on protected route)',
        );
        return '/sign-in';
      }

      // Authenticated user on an auth screen → send to home.
      if (isAuth && isOnAuthScreen) {
        nuviLog('NUVI-ROUTER', 'Google authentication navigation START');
        nuviLog(
          'NUVI-ROUTER',
          'Navigating to /home (authenticated user on auth screen)',
        );
        nuviLog('NUVI-ROUTER', 'Navigation COMPLETE');
        return '/home';
      }

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
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/category/:categoryId',
        builder: (context, state) {
          final id = state.pathParameters['categoryId'] ?? 'toddler';
          return CategoryListingScreen(categoryId: id);
        },
      ),
      GoRoute(
        path: '/product/:productId',
        builder: (context, state) {
          final id = state.pathParameters['productId'] ?? 'prod_dream_romper';
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const SavedAddressesScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const MyOrdersScreen(),
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
