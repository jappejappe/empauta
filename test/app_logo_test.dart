import 'package:empauta/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppLogo renders Empauta. with correct colors and underline', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLogo(),
        ),
      ),
    );

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Empauta.', findRichText: true), findsOneWidget);

    final textWidget = tester.widget<Text>(find.byType(Text));
    final span = textWidget.textSpan! as TextSpan;

    expect(span.style?.fontSize, 28);
    expect(span.style?.fontWeight, FontWeight.w800);
    expect(span.style?.letterSpacing, -1.2);
    expect(span.children?.length, 3);

    final emSpan = span.children![0] as TextSpan;
    expect(emSpan.text, 'Em');
    expect(emSpan.style?.color, const Color(0xFFE34B36));
    expect(emSpan.style?.decoration, TextDecoration.none);

    final pautaSpan = span.children![1] as TextSpan;
    expect(pautaSpan.text, 'pauta');
    expect(pautaSpan.style?.color, Colors.white);

    final dotSpan = span.children![2] as TextSpan;
    expect(dotSpan.text, '.');
    expect(dotSpan.style?.color, const Color(0xFFE34B36));
    expect(dotSpan.style?.decoration, TextDecoration.none);
  });

  testWidgets('AppLogo respects custom fontSize', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLogo(fontSize: 32),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.byType(Text));
    final span = textWidget.textSpan! as TextSpan;
    expect(span.style?.fontSize, 32);
  });
}
