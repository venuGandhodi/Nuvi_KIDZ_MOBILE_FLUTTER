import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';
import '../domain/auth_exception.dart' as domain;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
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
      return true;
    } on domain.AuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    } on Exception catch (e, st) {
      // Don't swallow Error types (like LateInitializationError)
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
    await ref.read(authRepositoryProvider).signOut();
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
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
