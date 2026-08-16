import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/onboarding/data/onboarding_storage.dart';
import 'package:nuvi_kidz/features/onboarding/presentation/splash_screen.dart';
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
      child: const MaterialApp(home: SplashScreen()),
    );
  }

  group('SplashScreen Tests', () {
    testWidgets('renders dark green brand splash screen and tagline', (
      tester,
    ) async {
      final storage = FakeOnboardingStorage();

      await tester.pumpWidget(buildTestWidget(storage: storage));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Tiny styles, big smiles ♡'), findsOneWidget);
      expect(find.text('Tap to continue'), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
