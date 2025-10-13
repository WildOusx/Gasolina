import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gasolina/widgets/embedded_gas_calculator.dart';
import 'package:gasolina/widgets/plate_group_chips.dart';

void main() {
  testWidgets('EmbeddedGasCalculator does not overflow on narrow width and large text scale', (WidgetTester tester) async {
    final TextEditingController ctrl = TextEditingController(text: '10');
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(200, 400)),
          child: Scaffold(
            body: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: EmbeddedGasCalculator(
                    litrosCtrl: ctrl,
                    tasa: 50.0,
                    loading: false,
                    onRefresh: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Ensure no exceptions and no overflow
    expect(tester.takeException(), isNull);
  });

  testWidgets('PlateGroupChips wraps correctly on narrow width', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(220, 400)),
          child: Scaffold(
            body: Center(
              child: PlateGroupChips(
                selectedDigit: 3,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ChoiceChip), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });
}
