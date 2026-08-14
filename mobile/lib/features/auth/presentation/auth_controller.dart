import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/nuvi_logger.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../customer/presentation/customer_controller.dart';
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
      // Fetch customer data securely using the Supabase session
      unawaited(ref.read(customerControllerProvider.notifier).loadCustomer());
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

  Future<bool> signUp(String email, String password, String fullName) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signUpWithEmail(email, password, fullName);
      unawaited(ref.read(customerControllerProvider.notifier).loadCustomer());
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

  Future<void> signOut() async {
    nuviLog('NUVI-LOGOUT', 'Logout START');
    nuviLog('NUVI-LOGOUT', 'CustomerController.clear START');
    ref.read(customerControllerProvider.notifier).clear();
    nuviLog('NUVI-LOGOUT', 'CustomerController.clear COMPLETE');

    nuviLog('NUVI-LOGOUT', 'CartController.clearCart START');
    await ref.read(cartControllerProvider.notifier).clearCart();
    nuviLog('NUVI-LOGOUT', 'CartController.clearCart COMPLETE');

    await ref.read(authRepositoryProvider).signOut();
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    nuviLog('NUVI-AUTH-CONTROLLER', 'Google sign-in START');
    try {
      nuviLog('NUVI-AUTH-CONTROLLER', 'Calling Supabase Google OAuth');
      final success = await ref.read(authRepositoryProvider).signInWithGoogle();
      nuviLog('NUVI-AUTH-CONTROLLER', 'OAuth completed. success=$success');

      if (success) {
        final authRepo = ref.read(authRepositoryProvider);
        final userAvailable = authRepo.currentUser != null;
        nuviLog(
          'NUVI-AUTH-CONTROLLER',
          'Supabase session available=${userAvailable ? "true" : "false"}',
        );
        nuviLog(
          'NUVI-AUTH-CONTROLLER',
          'Supabase user available=${userAvailable ? "true" : "false"}',
        );

        nuviLog(
          'NUVI-AUTH-CONTROLLER',
          'Calling CustomerController.loadCustomer()',
        );
        unawaited(ref.read(customerControllerProvider.notifier).loadCustomer());
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
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});
