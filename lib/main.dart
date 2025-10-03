import 'package:flutter/material.dart';
import 'data/schedules.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

void main() {
  runApp(const GasolinaApp());
}

class GasolinaApp extends StatelessWidget {
  const GasolinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendario Gasolina',
      theme: appTheme,
      home: const GasCalendarScreen(),
    );
  }
}

class GasCalendarScreen extends StatefulWidget {
  const GasCalendarScreen({super.key});

  @override
  State<GasCalendarScreen> createState() => _GasCalendarScreenState();
}

class _GasCalendarScreenState extends State<GasCalendarScreen> {
  late DateTime currentMonth; // anclado al día 1 del mes visible
  int lastDigit = 1;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    currentMonth = DateTime(now.year, now.month, 1);
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? d = prefs.getInt('last_digit');
    final int? y = prefs.getInt('sel_year');
    final int? m = prefs.getInt('sel_month');
    setState(() {
      if (d != null) lastDigit = d;
      if (y != null && m != null) {
        currentMonth = DateTime(y, m, 1);
      }
    });
  }

  Future<void> _savePrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_digit', lastDigit);
    await prefs.setInt('sel_year', currentMonth.year);
    await prefs.setInt('sel_month', currentMonth.month);
  }

  void _prevMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    });
    _savePrefs();
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    });
    _savePrefs();
  }

  @override
  Widget build(BuildContext context) {
    final int y = currentMonth.year;
    final int m = currentMonth.month;
    final List<int> days =
        GasSchedule.daysForDigit(year: y, month: m, lastDigit: lastDigit);
    final String pairLabel = GasSchedule.pairLabelForDigit(lastDigit);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario de Gasolina')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  tooltip: 'Mes anterior',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevMonth,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${_monthName(m)} $y',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Mes siguiente',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: lastDigit,
                    decoration: const InputDecoration(labelText: 'Último dígito de placa'),
                    items: List<DropdownMenuItem<int>>.generate(
                      10,
                      (int d) => DropdownMenuItem<int>(
                        value: d,
                        child: Text(d.toString()),
                      ),
                    ),
                    onChanged: (int? v) {
                      setState(() => lastDigit = v ?? 0);
                      _savePrefs();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Grupo: $pairLabel',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _CalendarGrid(
                      year: y,
                      month: m,
                      allowedDays: Set<int>.from(days),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Basado en calendarios oficiales Sept-Oct 2025.'),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const List<String> names = <String>[
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return names[m - 1];
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.year,
    required this.month,
    required this.allowedDays,
  });

  final int year;
  final int month;
  final Set<int> allowedDays;

  int _daysInMonth(int y, int m) => DateTime(y, m + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final DateTime first = DateTime(year, month, 1);
    final int firstWeekday = first.weekday; // 1=Mon..7=Sun
    final int startOffset = (firstWeekday + 6) % 7; // convertir a 0=Mon
    final int daysInMonth = _daysInMonth(year, month);
    int totalCells = startOffset + daysInMonth;
    if (totalCells % 7 != 0) totalCells += 7 - (totalCells % 7);

    final DateTime today = DateTime.now();
    final bool isCurrentMonth = (today.year == year && today.month == month);

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const <Widget>[
            _DowCell('L'), _DowCell('M'), _DowCell('X'), _DowCell('J'), _DowCell('V'), _DowCell('S'), _DowCell('D'),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.1,
          ),
          itemCount: totalCells,
          itemBuilder: (BuildContext context, int index) {
            if (index < startOffset || index >= startOffset + daysInMonth) {
              return const SizedBox.shrink();
            }
            final int day = index - startOffset + 1;
            final bool allowed = allowedDays.contains(day);
            final bool isToday = isCurrentMonth && today.day == day;
            final Color bg = allowed
                ? scheme.primaryContainer
                : scheme.surfaceVariant.withOpacity(0.35);
            final Color fg = allowed ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
            return Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
                border: isToday ? Border.all(color: scheme.primary, width: 2) : null,
              ),
              alignment: Alignment.center,
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: fg,
                  fontWeight: allowed ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DowCell extends StatelessWidget {
  const _DowCell(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
