import 'package:flutter/foundation.dart';

/// QuickActionBus: utilidad simple para notificar acciones rápidas (public API).
/// Implementación basada en el `_QuickActionBus` original pero sin underscore para poder importarla.
class QuickActionBus extends ChangeNotifier {
  QuickActionBus._();
  static final QuickActionBus instance = QuickActionBus._();
  void triggerToday() => notifyListeners();
}
