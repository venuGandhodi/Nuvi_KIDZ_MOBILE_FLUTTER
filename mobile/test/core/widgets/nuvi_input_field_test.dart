import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/core/widgets/nuvi_input_field.dart';

void main() {
  testWidgets('NuviInputField renders label and accepts input', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NuviInputField(
            label: 'Email',
            hint: 'Enter your email',
            controller: controller,
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'test@example.com');
    await tester.pump();

    expect(controller.text, 'test@example.com');
  });
}
