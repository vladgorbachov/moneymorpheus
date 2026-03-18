import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:moneymorpheus/widgets/numpad_button.dart';

void main() {
  testWidgets('NumpadButton renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: NumpadButton(label: '1', onTap: () {}),
        ),
      ),
    );
    expect(find.text('1'), findsOneWidget);
  });
}
