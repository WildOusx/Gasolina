// Utilidades y datos del calendario de gasolina por placa.
//
// Reglas básicas asumidas (según láminas Sept-Oct 2025):
// - Los grupos de placas rotan diariamente en el orden: 1-2, 3-4, 5-6, 7-8, 9-0.
// - Para Septiembre y Octubre 2025, el día 1 del mes corresponde al grupo 5-6.
// - Si no se conoce un mes, por defecto se asume inicio 5-6 (índice 2).

class GasSchedule {
  // Orden de pares: 0=1-2, 1=3-4, 2=5-6, 3=7-8, 4=9-0
  static const List<List<int>> pairs = <List<int>>[
    <int>[1, 2],
    <int>[3, 4],
    <int>[5, 6],
    <int>[7, 8],
    <int>[9, 0],
  ];

  // Clave AAAA-MM -> índice de par que inicia el día 1 del mes.
  // En las imágenes: septiembre y octubre 2025 inician con 5-6 (índice 2).
  static const Map<String, int> startPairIndexByMonth = <String, int>{
    '2025-09': 2, // 5-6
    '2025-10': 2, // 5-6
  };

  static String monthKey(int year, int month) =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

  static int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  static String pairLabelForDigit(int digit) {
    if (<int>[1, 2].contains(digit)) return '1-2';
    if (<int>[3, 4].contains(digit)) return '3-4';
    if (<int>[5, 6].contains(digit)) return '5-6';
    if (<int>[7, 8].contains(digit)) return '7-8';
    return '9-0';
  }

  /// Obtiene el índice de par con el que inicia el día 1 del mes indicado.
  /// Si no está en el mapa, lo calcula en función de un mes base conocido
  /// (2025-09 => índice 2) y asumiendo rotación diaria continua sin pausas.
  static int startIndexForMonth(int year, int month) {
    final String key = monthKey(year, month);
    final int? known = startPairIndexByMonth[key];
    if (known != null) return known;

    // Mes base
    const int baseYear = 2025;
    const int baseMonth = 9;
    const int baseIdx = 2; // 5-6

    // Si exactamente mes base
    if (year == baseYear && month == baseMonth) return baseIdx;

    // Función para avanzar un mes
    int y = baseYear;
    int m = baseMonth;
    int idx = baseIdx;

    // Comparación cronológica simple
    bool isAfterBase =
        (year > baseYear) || (year == baseYear && month > baseMonth);

    if (isAfterBase) {
      // Adelante desde base hasta target (sin incluir target al sumar días)
      while (y != year || m != month) {
        final int dm =
            _daysInMonth(y, m) % pairs.length; // sólo modulo 5 importa
        idx = (idx + dm) % pairs.length;
        // siguiente mes
        m += 1;
        if (m > 12) {
          m = 1;
          y += 1;
        }
      }
      return idx;
    } else {
      // Retroceder desde base hasta target
      while (y != year || m != month) {
        // retrocedemos un mes primero para conocer sus días
        m -= 1;
        if (m < 1) {
          m = 12;
          y -= 1;
        }
        final int dm = _daysInMonth(y, m) % pairs.length;
        idx = (idx - dm) % pairs.length;
        if (idx < 0) idx += pairs.length;
      }
      return idx;
    }
  }

  /// Devuelve los días del mes en los que puede surtir la placa cuyo último
  /// dígito es [lastDigit].
  static List<int> daysForDigit({
    required int year,
    required int month,
    required int lastDigit,
  }) {
    final int startIdx = startIndexForMonth(year, month);
    final int totalDays = _daysInMonth(year, month);

    final List<int> result = <int>[];
    for (int day = 1; day <= totalDays; day++) {
      final int idx = (startIdx + (day - 1)) % pairs.length;
      if (pairs[idx].contains(lastDigit)) {
        result.add(day);
      }
    }
    return result;
  }
}
