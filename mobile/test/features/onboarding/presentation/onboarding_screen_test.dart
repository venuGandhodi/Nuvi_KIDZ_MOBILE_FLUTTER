import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvi_kidz/features/onboarding/data/onboarding_storage.dart';
import 'package:nuvi_kidz/features/onboarding/presentation/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/mock_http_overrides.dart';

class FakeOnboardingStorage extends OnboardingStorage {
  bool completed = false;

  @override
  Future<bool> hasCompletedOnboarding() async => completed;

  @override
  Future<void> setCompletedOnboarding([bool completed = true]) async {
    this.completed = completed;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget({required FakeOnboardingStorage storage}) {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/sign-in',
          builder: (context, state) =>
              const Scaffold(body: Text('Sign In Dummy')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [onboardingStorageProvider.overrideWithValue(storage)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Next'));
    await tester.pumpAndSettle();
  }

  group('OnboardingScreen Tests', () {
    testWidgets('renders Discover with Skip and the next arrow', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(storage: FakeOnboardingStorage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Discover\nAdorable Styles'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.bySemanticsLabel('Next'), findsOneWidget);
    });

    testWidgets('moves to Shop & Explore, then Our Aim', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(storage: FakeOnboardingStorage()),
      );
      await tester.pumpAndSettle();

      await next(tester);
      expect(find.text('Shop & Explore\nwith Ease'), findsOneWidget);

      await next(tester);
      expect(find.text('Our Aim'), findsOneWidget);
      expect(find.text('Premium\nQuality'), findsOneWidget);
      expect(find.bySemanticsLabel('Get started'), findsOneWidget);
    });

    testWidgets('finishing onboarding saves it and opens sign in', (
      tester,
    ) async {
      final storage = FakeOnboardingStorage();
      await tester.pumpWidget(buildTestWidget(storage: storage));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(storage.completed, isTrue);
      expect(find.text('Sign In Dummy'), findsOneWidget);
    });
  });
}
