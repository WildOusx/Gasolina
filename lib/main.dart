import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

import 'screens/gas_calendar_screen.dart';
import 'utils/quick_action_bus.dart';
import 'theme.dart';

void main() {
  const QuickActions quickActions = QuickActions();
  quickActions.initialize((String type) async {
    if (type == 'action_today') {
      QuickActionBus.instance.triggerToday();
    }
  });
  quickActions.setShortcutItems(<ShortcutItem>[
    const ShortcutItem(
      type: 'action_today',
      localizedTitle: 'Ir a Hoy',
      icon: 'ic_launcher',
    ),
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
