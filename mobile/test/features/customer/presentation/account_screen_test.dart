import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/auth/data/auth_repository.dart';
import 'package:nuvi_kidz/features/auth/presentation/auth_controller.dart';
import 'package:nuvi_kidz/features/customer/presentation/account_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/mock_http_overrides.dart';

class FakeGuestAuthRepository extends AuthRepository {
  @override
  User? get currentUser => null;
}

class FakeAuthenticatedAuthRepository extends AuthRepository {
  @override
  User? get currentUser => const User(
    id: 'mock-user-123',
    appMetadata: {},
    userMetadata: {'display_name': 'Mokshith Nuvi'},
    aud: 'authenticated',
    createdAt: '2026-01-01',
    email: 'mokshith@example.com',
  );
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues({});
  });

  group('AccountScreen Tests', () {
    testWidgets(
      'renders guest mode with Unlock Premium Features and Login button',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWithValue(
                FakeGuestAuthRepository(),
              ),
            ],
            child: const MaterialApp(home: AccountScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Guest User'), findsOneWidget);
        expect(find.text('Welcome to the Store'), findsOneWidget);
        expect(find.text('Push Notifications'), findsOneWidget);
        expect(find.text('Unlock Premium Features'), findsOneWidget);
        expect(find.text('Login / Register'), findsOneWidget);
        expect(find.text('WISHLIST'), findsOneWidget);
        expect(find.text('ORDERS'), findsOneWidget);
        expect(find.text('ADDRESSES'), findsOneWidget);
        expect(find.text('My Orders'), findsOneWidget);
        expect(find.text('My Addresses'), findsOneWidget);
        expect(find.text('Help & Support'), findsOneWidget);
        expect(find.text('LOG OUT'), findsNothing);
      },
    );

    testWidgets(
      'renders authenticated mode with customer name and LOG OUT button',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWithValue(
                FakeAuthenticatedAuthRepository(),
              ),
            ],
            child: const MaterialApp(home: AccountScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Mokshith Nuvi'), findsOneWidget);
        expect(find.text('mokshith@example.com'), findsOneWidget);
        expect(find.text('My Account'), findsOneWidget);
        expect(find.text('LOG OUT'), findsOneWidget);
        expect(find.text('Unlock Premium Features'), findsNothing);
      },
    );
  });
}
