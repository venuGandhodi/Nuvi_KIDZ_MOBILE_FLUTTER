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
  late final AuthRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.watch(authRepositoryProvider);
  }

  Future<bool> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _repository.signInWithEmail(email, password);
      state = const AsyncData(null);
      return true;
    } on domain.AuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    } catch (e, st) {
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
      await _repository.signUpWithEmail(email, password, fullName);
      state = const AsyncData(null);
      return true;
    } on domain.AuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncError(
        domain.AuthException('Unexpected error occurred.'),
        st,
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});
