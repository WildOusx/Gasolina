// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:gasolina/main.dart';

void main() {
  testWidgets('App builds and shows title', (WidgetTester tester) async {
    // Mock SharedPreferences for fast, synchronous resolution in tests.
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // Ensure intl date symbols are initialized for table_calendar
    await initializeDateFormatting();

    // Set a test window size so TableCalendar has bounded constraints
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Build the app and trigger a frame.
    await tester.pumpWidget(const GasolinaApp());
    // Allow async prefs/theme load to complete.
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Verify that an AppBar with the correct title exists.
    final Finder appBar = find.byType(AppBar);
    expect(appBar, findsOneWidget);
    // The title may be 'Calendario de Gasolina' or similar; check contains.
    expect(
      find.descendant(
        of: appBar,
        matching: find.byWidgetPredicate(
          (Widget w) =>
              w is Text && w.data != null && w.data!.contains('Gasolina'),
        ),
      ),
      findsOneWidget,
    );

    // Basic smoke: ensure the plate digit selector (ChoiceChips) exists.
    expect(find.byType(ChoiceChip), findsWidgets);
  });
}
