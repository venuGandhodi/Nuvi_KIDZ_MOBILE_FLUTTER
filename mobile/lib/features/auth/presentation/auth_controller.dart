import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/nuvi_logger.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../customer/presentation/customer_controller.dart';
import '../../wishlist/presentation/wishlist_controller.dart';
import '../data/auth_repository.dart';
import '../domain/auth_exception.dart' as domain;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  try {
    return AuthRepository(Supabase.instance.client);
  } catch (_) {
    return AuthRepository();
  }
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initialized without forcing late dependency loading immediately
  }

  Future<bool> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(email, password);
      state = const AsyncData(null);
      // Trigger customer load AFTER setting state to AsyncData.
      // _triggerCustomerLoad() waits until the Supabase session is fully
      // committed before calling loadCustomer(), eliminating the race that
      // caused the 401 when loadCustomer() fired before the JWT was available.
      unawaited(_triggerCustomerLoad(label: 'signIn'));
      return true;
    } on domain.AuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    } on Exception catch (e, st) {
      state = AsyncError(
        domain.AuthException('Unexpected error occurred.'),
        st,
      );
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signUpWithEmail(email, password, fullName);
      state = const AsyncData(null);
      unawaited(_triggerCustomerLoad(label: 'signUp'));
      return true;
    } on domain.AuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    } on Exception catch (e, st) {
      state = AsyncError(
        domain.AuthException('Unexpected error occurred.'),
        st,
      );
      return false;
    }
  }

  Future<void> signOut() async {
    nuviLog('NUVI-AUTH', 'Sign out started');
    final authRepo = ref.read(authRepositoryProvider);
    bool isAuthedBefore = false;
    try {
      isAuthedBefore = authRepo.currentUser != null;
    } catch (_) {}
    nuviLog(
      'NUVI-AUTH',
      'Supabase session before logout: authenticated=$isAuthedBefore',
    );

    final custState = ref.read(customerControllerProvider);
    nuviLog(
      'NUVI-AUTH',
      'Customer state before logout: ${custState.customer != null ? "linked" : "unlinked"}',
    );

    ref.read(customerControllerProvider.notifier).clear();
    nuviLog('NUVI-AUTH', 'CustomerController cleared');

    ref.read(wishlistControllerProvider.notifier).clear();
    nuviLog('NUVI-AUTH', 'WishlistController cleared');

    await ref.read(cartControllerProvider.notifier).clearCart();
    nuviLog('NUVI-AUTH', 'Shopify cart cleanup completed');

    await authRepo.signOut();
    nuviLog('NUVI-AUTH', 'Supabase signOut completed');

    bool isAuthedAfter = false;
    try {
      isAuthedAfter = authRepo.currentUser != null;
    } catch (_) {}
    nuviLog(
      'NUVI-AUTH',
      'Supabase session after logout: authenticated=$isAuthedAfter',
    );
    nuviLog('NUVI-AUTH', 'Final auth state: unauthenticated');
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    nuviLog('NUVI-AUTH-CONTROLLER', 'Google sign-in START');
    try {
      nuviLog('NUVI-AUTH-CONTROLLER', 'Calling Supabase Google OAuth');
      final success = await ref.read(authRepositoryProvider).signInWithGoogle();
      nuviLog('NUVI-AUTH-CONTROLLER', 'OAuth completed. success=$success');

      if (success) {
        nuviLog(
          'NUVI-AUTH-CONTROLLER',
          'Calling CustomerController.loadCustomer() via session-verified trigger',
        );
        unawaited(_triggerCustomerLoad(label: 'signInWithGoogle'));
      }

      state = const AsyncData(null);
      nuviLog('NUVI-AUTH-CONTROLLER', 'Google sign-in COMPLETE');
      return success;
    } on domain.AuthException catch (e, st) {
      nuviLog('NUVI-AUTH-CONTROLLER', 'ERROR');
      nuviLog('NUVI-AUTH-CONTROLLER', 'ERROR TYPE: ${e.runtimeType}');
      nuviLog('NUVI-AUTH-CONTROLLER', 'ERROR MESSAGE: ${e.message}');
      nuviLog('NUVI-AUTH-CONTROLLER', 'STACK TRACE:\n$st');
      state = AsyncError(e, st);
      return false;
    } catch (e, st) {
      nuviLog('NUVI-AUTH-CONTROLLER', 'ERROR');
      nuviLog('NUVI-AUTH-CONTROLLER', 'ERROR TYPE: ${e.runtimeType}');
      nuviLog('NUVI-AUTH-CONTROLLER', 'ERROR MESSAGE: $e');
      nuviLog('NUVI-AUTH-CONTROLLER', 'STACK TRACE:\n$st');
      state = AsyncError(
        domain.AuthException('Unexpected error occurred: $e'),
        st,
      );
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      state = const AsyncData(null);
      return true;
    } on domain.AuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    } on Exception catch (e, st) {
      state = AsyncError(
        domain.AuthException('Unexpected error occurred.'),
        st,
      );
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).updatePassword(newPassword);
      state = const AsyncData(null);
      return true;
    } on domain.AuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    } on Exception catch (e, st) {
      state = AsyncError(
        domain.AuthException('Unexpected error occurred.'),
        st,
      );
      return false;
    }
  }

  /// Waits until the Supabase session is confirmed with a valid, non-null
  /// access token, then triggers [CustomerController.loadCustomer()].
  ///
  /// This eliminates the race where [loadCustomer()] was called immediately
  /// after [signInWithPassword()] returned — before [onAuthStateChange] fired
  /// with SIGNED_IN and before the SDK committed the session internally.
  ///
  /// Strategy:
  ///   1. Poll [currentSession] for up to 3 seconds (500 ms intervals).
  ///   2. Once a valid session exists, delegate to [loadCustomer()] which
  ///      also has its own session guard and refresh logic.
  ///   3. If no session appears within the timeout, log and abort silently
  ///      — the RouterNotifier INITIAL_SESSION handler will pick it up.
  Future<void> _triggerCustomerLoad({required String label}) async {
    nuviLog('NUVI-AUTH-DIAGNOSTIC', '[$label] _triggerCustomerLoad START');

    // Wait up to 3 seconds for the session to be committed by the SDK.
    // In test environments where Supabase is not initialized, we catch the
    // AssertionError from Supabase.instance and fall through immediately.
    const maxWaitMs = 3000;
    const pollIntervalMs = 100;
    var waited = 0;

    while (waited < maxWaitMs) {
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          final userId = session.user.id;
          nuviLog(
            'NUVI-AUTH-DIAGNOSTIC',
            '[$label] Session confirmed after ${waited}ms. userId=$userId',
          );
          // Delegate to CustomerController which has its own session guard.
          await ref.read(customerControllerProvider.notifier).loadCustomer();
          return;
        }
      } catch (_) {
        // Supabase not initialized (test environment): break polling and
        // delegate directly to CustomerController, which handles test fakes.
        nuviLog(
          'NUVI-AUTH-DIAGNOSTIC',
          '[$label] Supabase not initialized \u2014 skipping session poll (test environment)',
        );
        await ref.read(customerControllerProvider.notifier).loadCustomer();
        return;
      }
      await Future.delayed(const Duration(milliseconds: pollIntervalMs));
      waited += pollIntervalMs;
    }

    // Session did not appear within timeout. This is unexpected but handled
    // gracefully. The RouterNotifier's INITIAL_SESSION handler will trigger
    // loadCustomer() when the session eventually propagates.
    nuviLog(
      'NUVI-AUTH-DIAGNOSTIC',
      '[$label] Session not confirmed after ${maxWaitMs}ms \u2014 aborting. '
          'RouterNotifier will handle session restore.',
    );
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});
