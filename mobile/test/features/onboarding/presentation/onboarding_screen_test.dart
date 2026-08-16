import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
    return ProviderScope(
      overrides: [onboardingStorageProvider.overrideWithValue(storage)],
      child: const MaterialApp(home: OnboardingScreen()),
    );
  }

  group('OnboardingScreen Tests', () {
    testWidgets('renders page 1 with tagline, headline, and next button', (
      tester,
    ) async {
      final storage = FakeOnboardingStorage();

      await tester.pumpWidget(buildTestWidget(storage: storage));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to the universe'), findsOneWidget);
      expect(
        find.text('Every festival is brighter in little celebrations.'),
        findsOneWidget,
      );
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);
    });

    testWidgets('advances to next page when tapping NEXT', (tester) async {
      final storage = FakeOnboardingStorage();

      await tester.pumpWidget(buildTestWidget(storage: storage));
      await tester.pumpAndSettle();

      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('Tiny styles, big smiles'), findsOneWidget);
      expect(
        find.text('Thoughtfully selected styles for every little moment.'),
        findsOneWidget,
      );
    });

    testWidgets('displays GET STARTED on the final page', (tester) async {
      final storage = FakeOnboardingStorage();

      await tester.pumpWidget(buildTestWidget(storage: storage));
      await tester.pumpAndSettle();

      // Page 1 -> 2
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Page 2 -> 3
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('Made for little memories'), findsOneWidget);
      expect(
        find.text(
          'Discover outfits made for festivals, playtime and everyday joy.',
        ),
        findsOneWidget,
      );
      expect(find.text('GET STARTED'), findsOneWidget);
    });
  });
}
