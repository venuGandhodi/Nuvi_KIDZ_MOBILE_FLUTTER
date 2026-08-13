import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  Future<bool> signInWithGoogle({GoogleSignIn? googleSignInOverride}) async {
    try {
      final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'];
      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];

      final googleSignIn =
          googleSignInOverride ??
          GoogleSignIn(
            clientId: (iosClientId != null && iosClientId.isNotEmpty)
                ? iosClientId
                : null,
            serverClientId: (webClientId != null && webClientId.isNotEmpty)
                ? webClientId
                : null,
          );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled Google Sign-In
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || idToken.isEmpty) {
        throw AuthException('Failed to obtain Google ID token.');
      }

      await _supabase.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return true;
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred during Google sign in.',
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.nuvikidz://login-callback/',
      );
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred during password reset request.',
      );
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred during password update.',
      );
    }
  }
}
