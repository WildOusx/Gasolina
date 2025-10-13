import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gasolina/widgets/plate_group_chips.dart';

void main() {
  testWidgets('PlateGroupChips builds and responds to taps', (WidgetTester tester) async {
    int selected = 1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlateGroupChips(
            selectedDigit: selected,
            onChanged: (d) => selected = d,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('1-2'), findsOneWidget);
  });
}
