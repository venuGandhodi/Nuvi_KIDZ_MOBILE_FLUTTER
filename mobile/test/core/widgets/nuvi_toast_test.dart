import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/core/theme/nuvi_theme.dart';
import 'package:nuvi_kidz/core/widgets/nuvi_toast.dart';

void main() {
  testWidgets('toast with an action closes by itself', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NuviTheme.build(null),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => NuviToast.show(
                context,
                message: 'Added to bag',
                actionLabel: 'View bag',
                onAction: () {},
              ),
              child: const Text('add'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('add'));
    await tester.pumpAndSettle();
    expect(find.text('Added to bag'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Added to bag'), findsNothing);
  });
}
