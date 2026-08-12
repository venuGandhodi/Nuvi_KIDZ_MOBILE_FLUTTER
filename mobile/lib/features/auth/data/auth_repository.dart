import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../domain/auth_exception.dart';

class AuthRepository {
  final supabase.SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Stream<supabase.AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;
  supabase.User? get currentUser => _supabase.auth.currentUser;

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('An unexpected error occurred during sign in.');
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': fullName},
      );
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('An unexpected error occurred during sign up.');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
