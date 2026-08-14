import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvi_kidz/features/auth/presentation/sign_in_screen.dart';
import 'package:nuvi_kidz/features/auth/presentation/sign_up_screen.dart';
import 'package:nuvi_kidz/features/auth/presentation/forgot_password_screen.dart';
import 'package:nuvi_kidz/features/auth/presentation/reset_password_screen.dart';
import 'package:nuvi_kidz/features/auth/presentation/auth_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nuvi_kidz/features/auth/data/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository implements AuthRepository {
  bool signInWithGoogleCalled = false;
  bool sendPasswordResetEmailCalled = false;
  String? resetEmailSent;
  bool updatePasswordCalled = false;
  String? updatedPassword;
  bool signOutCalled = false;

  @override
  Future<bool> signInWithGoogle({GoogleSignIn? googleSignInOverride}) async {
    signInWithGoogleCalled = true;
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    sendPasswordResetEmailCalled = true;
    resetEmailSent = email;
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    updatePasswordCalled = true;
    updatedPassword = newPassword;
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('SignInScreen displays Sign Up link and navigates', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/sign-in',
      routes: [
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/sign-up',
          builder: (context, state) =>
              const Scaffold(body: Text('Sign Up Screen Dummy')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    expect(find.text('Don\'t have an account? '), findsOneWidget);
    expect(find.text('Sign Up'), findsWidgets);

    // Need to scroll down to see the button
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign Up').last);
    await tester.pumpAndSettle();

    expect(find.text('Sign Up Screen Dummy'), findsOneWidget);
  });

  testWidgets('SignUpScreen displays Sign In link and navigates', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/sign-up',
      routes: [
        GoRoute(
          path: '/sign-in',
          builder: (context, state) =>
              const Scaffold(body: Text('Sign In Screen Dummy')),
        ),
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => const SignUpScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    expect(find.text('Already have an account? '), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In').last);
    await tester.pumpAndSettle();

    expect(find.text('Sign In Screen Dummy'), findsOneWidget);
  });

  testWidgets('Google button invokes AuthController Google sign-in method', (
    tester,
  ) async {
    final mockRepo = MockAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        child: const MaterialApp(home: SignInScreen()),
      ),
    );

    final googleButton = find.text('Continue with Google');
    expect(googleButton, findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    await tester.tap(googleButton);
    await tester.pump();

    expect(mockRepo.signInWithGoogleCalled, true);

    mockRepo.signInWithGoogleCalled = false;
    await tester.tap(googleButton);
    expect(mockRepo.signInWithGoogleCalled, false);

    await tester.pumpAndSettle();
  });

  testWidgets('ForgotPasswordScreen link exists and navigates to it', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/sign-in',
      routes: [
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) =>
              const Scaffold(body: Text('ForgotPasswordDummy')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    final link = find.text('Forgot Password?');
    expect(link, findsOneWidget);

    await tester.tap(link);
    await tester.pumpAndSettle();

    expect(find.text('ForgotPasswordDummy'), findsOneWidget);
  });

  testWidgets('ForgotPasswordScreen validation (empty and invalid format)', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
    );

    final submitButton = find.text('Send Reset Link');
    expect(submitButton, findsOneWidget);

    // Tap submit while empty
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsOneWidget);

    // Enter invalid format
    await tester.enterText(find.byType(TextFormField), 'invalidemail');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email'), findsOneWidget);

    // Enter valid email and check that error clears
    await tester.enterText(find.byType(TextFormField), 'test@domain.com');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsNothing);
    expect(find.text('Please enter a valid email'), findsNothing);
  });

  testWidgets(
    'ForgotPasswordScreen submits correctly and displays success state',
    (tester) async {
      final mockRepo = MockAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: ForgotPasswordScreen()),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test@domain.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump(); // Start async call

      expect(mockRepo.sendPasswordResetEmailCalled, true);
      expect(mockRepo.resetEmailSent, 'test@domain.com');

      await tester.pumpAndSettle(); // Complete async call
      expect(find.text('Email Sent!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    },
  );

  testWidgets('ForgotPasswordScreen back to sign in link navigates', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/forgot-password',
      routes: [
        GoRoute(
          path: '/sign-in',
          builder: (context, state) =>
              const Scaffold(body: Text('SignInScreenDummy')),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    final backLink = find.text('Back to Sign In');
    expect(backLink, findsOneWidget);

    await tester.tap(backLink);
    await tester.pumpAndSettle();

    expect(find.text('SignInScreenDummy'), findsOneWidget);
  });

  testWidgets('ResetPasswordScreen displays fields and validates fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ResetPasswordScreen())),
    );

    expect(find.text('New Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);

    final submitButton = find.text('Update Password');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Verify empty validations
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Confirm password is required'), findsOneWidget);

    // Enter short password
    await tester.enterText(find.byType(TextFormField).first, '123');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);

    // Passwords mismatch
    await tester.enterText(find.byType(TextFormField).first, '123456');
    await tester.enterText(find.byType(TextFormField).last, 'abcdef');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets(
    'ResetPasswordScreen updates password and triggers sign out recovery reset',
    (tester) async {
      final mockRepo = MockAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: ResetPasswordScreen()),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'newpassword123',
      );
      await tester.enterText(find.byType(TextFormField).last, 'newpassword123');

      await tester.tap(find.text('Update Password'));
      await tester.pump(); // Starts async update

      expect(mockRepo.updatePasswordCalled, true);
      expect(mockRepo.updatedPassword, 'newpassword123');

      await tester.pumpAndSettle(); // Finishes updates & signs out
      expect(mockRepo.signOutCalled, true);
    },
  );
}
