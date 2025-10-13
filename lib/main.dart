import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/gas_calendar_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize date formatting for table_calendar / intl usage
  await initializeDateFormatting();

  // Initialize date formatting for common locales used by the app (helps table_calendar)
  await Future.wait([
    initializeDateFormatting('en_US'),
    initializeDateFormatting('es'),
  ]);

  runApp(const GasolinaApp());
}

class GasolinaApp extends StatefulWidget {
  const GasolinaApp({super.key});
  @override
  State<GasolinaApp> createState() => _GasolinaAppState();
}

class _GasolinaAppState extends State<GasolinaApp> {
  ThemeMode _themeMode = ThemeMode.system;
  final bool _loaded = true; // simplificado

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: appThemeLight(),
      darkTheme: appThemeDark(),
      home: GasCalendarScreen(
        themeMode: _themeMode,
        onThemeModeChanged: (ThemeMode m) => setState(() => _themeMode = m),
      ),
    );
  }
}
