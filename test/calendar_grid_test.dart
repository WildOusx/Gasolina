import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gasolina/widgets/calendar_grid.dart';

void main() {
  testWidgets('CalendarGrid builds and shows day-of-week headers', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 600,
            child: CalendarGrid(
              year: 2025,
              month: 10,
              allowedDays: {1,2,3},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Expect a weekday header like 'Lunes' when width is wide enough
    expect(find.textContaining('Lun'), findsOneWidget);
  });
}
