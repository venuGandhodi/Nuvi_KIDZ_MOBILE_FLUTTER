import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../core/utils/nuvi_logger.dart';
import '../domain/auth_exception.dart';

class AuthRepository {
  final supabase.SupabaseClient? _supabase;

  AuthRepository([this._supabase]);

  Stream<supabase.AuthState> get authStateChanges =>
      _supabase?.auth.onAuthStateChange ?? const Stream.empty();
  supabase.User? get currentUser => _supabase?.auth.currentUser;

  Future<void> signInWithEmail(String email, String password) async {
    if (_supabase == null) return;
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
    if (_supabase == null) return;
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
    if (_supabase == null) return;
    nuviLog('NUVI-LOGOUT', 'Supabase signOut START');
    try {
      await _supabase.auth.signOut();
      nuviLog('NUVI-LOGOUT', 'Supabase signOut COMPLETE');
    } catch (e, st) {
      nuviLog('NUVI-LOGOUT', 'ERROR during Supabase signOut: $e');
      nuviLog('NUVI-LOGOUT', 'STACK TRACE:\n$st');
      rethrow;
    }
  }

  Future<bool> signInWithGoogle({GoogleSignIn? googleSignInOverride}) async {
    if (_supabase == null) {
      nuviLog('NUVI-GOOGLE', 'ERROR: Supabase client is null');
      return false;
    }

    nuviLog('NUVI-GOOGLE', 'signInWithOAuth START');
    nuviLog('NUVI-GOOGLE', 'OAuth provider: google');
    nuviLog('NUVI-GOOGLE', 'PKCE enabled: true');
    nuviLog('NUVI-GOOGLE', 'OAuth scopes configured: [email, profile, openid]');
    nuviLog(
      'NUVI-GOOGLE',
      'Redirect URI configured: io.supabase.nuvikidz://login-callback/',
    );

    try {
      if (googleSignInOverride != null) {
        nuviLog('NUVI-GOOGLE', 'Using googleSignInOverride for test execution');
        final googleUser = await googleSignInOverride.signIn();
        if (googleUser == null) {
          nuviLog('NUVI-GOOGLE', 'User cancelled Google Sign-In override');
          return false;
        }
        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;
        if (idToken == null || idToken.isEmpty) {
          nuviLog('NUVI-GOOGLE', 'ERROR: Google ID token is null or empty');
          throw AuthException('Failed to obtain Google ID token.');
        }
        await _supabase.auth.signInWithIdToken(
          provider: supabase.OAuthProvider.google,
          idToken: idToken,
          accessToken: googleAuth.accessToken,
        );
        nuviLog('NUVI-GOOGLE', 'signInWithOAuth RETURNED');
        nuviLog('NUVI-GOOGLE', 'OAuth initiation result received');
        return true;
      }

      // Supabase Native OAuth Flow via deep link callback
      nuviLog('NUVI-GOOGLE', 'authScreenLaunchMode: externalApplication');
      nuviLog('NUVI-GOOGLE', 'Calling Supabase signInWithOAuth()');
      final result = await _supabase.auth.signInWithOAuth(
        supabase.OAuthProvider.google,
        redirectTo: 'io.supabase.nuvikidz://login-callback/',
        authScreenLaunchMode: supabase.LaunchMode.externalApplication,
      );

      nuviLog('NUVI-GOOGLE', 'signInWithOAuth RETURNED');
      nuviLog(
        'NUVI-GOOGLE',
        'OAuth initiation result received. result=$result',
      );
      return result;
    } on supabase.AuthException catch (e, st) {
      nuviLog('NUVI-GOOGLE', 'signInWithOAuth ERROR');
      nuviLog('NUVI-GOOGLE', 'ERROR TYPE: ${e.runtimeType}');
      nuviLog('NUVI-GOOGLE', 'ERROR MESSAGE: ${e.message}');
      nuviLog('NUVI-GOOGLE', 'STACK TRACE:\n$st');
      throw AuthException(e.message);
    } on AuthException catch (e, st) {
      nuviLog('NUVI-GOOGLE', 'signInWithOAuth ERROR');
      nuviLog('NUVI-GOOGLE', 'ERROR TYPE: ${e.runtimeType}');
      nuviLog('NUVI-GOOGLE', 'ERROR MESSAGE: ${e.message}');
      nuviLog('NUVI-GOOGLE', 'STACK TRACE:\n$st');
      rethrow;
    } catch (e, st) {
      nuviLog('NUVI-GOOGLE', 'signInWithOAuth ERROR');
      nuviLog('NUVI-GOOGLE', 'ERROR TYPE: ${e.runtimeType}');
      nuviLog('NUVI-GOOGLE', 'ERROR MESSAGE: $e');
      nuviLog('NUVI-GOOGLE', 'STACK TRACE:\n$st');
      throw AuthException(
        'An unexpected error occurred during Google sign in: $e',
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (_supabase == null) return;
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
    if (_supabase == null) return;
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
