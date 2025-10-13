import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gasolina/widgets/embedded_gas_calculator.dart';

void main() {
  testWidgets('EmbeddedGasCalculator builds and shows label', (WidgetTester tester) async {
    final controller = TextEditingController(text: '4');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmbeddedGasCalculator(
            litrosCtrl: controller,
            tasa: 24.5,
            loading: false,
            onRefresh: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.textContaining('Calculadora'), findsOneWidget);
  });
}
