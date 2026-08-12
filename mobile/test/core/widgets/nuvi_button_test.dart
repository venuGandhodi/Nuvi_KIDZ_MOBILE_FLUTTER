import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/core/widgets/nuvi_button.dart';

void main() {
  testWidgets('NuviButton renders text and responds to tap', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NuviButton(
            text: 'Test Button',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);

    await tester.tap(find.byType(NuviButton));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('NuviButton shows loading indicator when isLoading is true', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NuviButton(
            text: 'Test Button',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
