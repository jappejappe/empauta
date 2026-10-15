import 'package:empauta/widgets/flag_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BrazilFlagIcon renders with default and custom sizes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BrazilFlagIcon(width: 24, height: 16),
        ),
      ),
    );

    expect(find.byType(BrazilFlagIcon), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BrazilFlagIcon),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  testWidgets('UsaFlagIcon renders with default and custom sizes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UsaFlagIcon(width: 24, height: 16),
        ),
      ),
    );

    expect(find.byType(UsaFlagIcon), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(UsaFlagIcon),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });
}
