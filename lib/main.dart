import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_actions/quick_actions.dart';

import 'data/bcv_service.dart';
import 'data/schedules.dart';
import 'theme.dart';

void main() {
  const QuickActions quickActions = QuickActions();
  quickActions.initialize((String type) async {
    if (type == 'action_today') {
      _QuickActionBus.instance.triggerToday();
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

class GasCalendarScreen extends StatefulWidget {
  const GasCalendarScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  @override
  State<GasCalendarScreen> createState() => _GasCalendarScreenState();
}

class _GasCalendarScreenState extends State<GasCalendarScreen> {
  @override
  Widget build(BuildContext context) {
    if (_loadingPrefs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final int y = currentMonth.year;
    final int m = currentMonth.month;
    final List<int> days = GasSchedule.daysForDigit(
      year: y,
      month: m,
      lastDigit: lastDigit,
    );
    final String pairLabel = GasSchedule.pairLabelForDigit(lastDigit);
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Gasolina'),
        actions: [
          IconButton(
            tooltip: 'Ir a hoy',
            icon: const Icon(Icons.today),
            onPressed: _goToday,
          ),
          PopupMenuButton<ThemeMode>(
            tooltip: 'Tema',
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : (widget.themeMode == ThemeMode.light
                        ? Icons.light_mode
                        : Icons.brightness_auto),
            ),
            onSelected: widget.onThemeModeChanged,
            itemBuilder: (_) => <PopupMenuEntry<ThemeMode>>[
              CheckedPopupMenuItem(
                value: ThemeMode.system,
                checked: widget.themeMode == ThemeMode.system,
                child: const Text('Sistema'),
              ),
              CheckedPopupMenuItem(
                value: ThemeMode.light,
                checked: widget.themeMode == ThemeMode.light,
                child: const Text('Claro'),
              ),
              CheckedPopupMenuItem(
                value: ThemeMode.dark,
                checked: widget.themeMode == ThemeMode.dark,
                child: const Text('Oscuro'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 700;
            final double spacing = 16;
            Widget calendarWidget = Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _CalendarSection(
                  pairLabel: pairLabel,
                  year: y,
                  month: m,
                  days: days,
                  keyboardOpen: keyboardOpen,
                ),
              ),
            );
            Widget calculatorWidget = Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _EmbeddedGasCalculator(
                  litrosCtrl: _litrosCtrl,
                  tasa: _tasa,
                  loading: _loadingTasa,
                  onRefresh: _fetchTasa,
                  dense: keyboardOpen,
                ),
              ),
            );
            // Encabezado y selector de placa
            Widget header = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _prevMonth,
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Mes anterior',
                    ),
                    Expanded(
                      child: Center(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _openMonthYearPicker,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              '${_monthName(m)} $y',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Mes siguiente',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Terminal de placa:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _PlateGroupChips(
                  selectedDigit: lastDigit,
                  onChanged: (d) {
                    setState(() => lastDigit = d);
                    _savePrefs();
                  },
                ),
                const SizedBox(height: 12),
              ],
            );
            if (isWide) {
              // Horizontal layout para pantallas anchas
              return Padding(
                padding: EdgeInsets.all(spacing),
                child: Column(
                  children: [
                    header,
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 2, child: calendarWidget),
                          SizedBox(width: spacing),
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 340,
                              minWidth: 220,
                            ),
                            child: calculatorWidget,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Vertical layout para pantallas pequeñas
              return Padding(
                padding: EdgeInsets.all(spacing),
                child: Column(
                  children: [
                    header,
                    Expanded(child: calendarWidget),
                    SizedBox(height: spacing),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 140,
                        maxHeight: 320,
                      ),
                      child: SingleChildScrollView(child: calculatorWidget),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  late DateTime currentMonth; // primer día del mes visible
  int lastDigit = 1;
  bool _loadingPrefs = true;

  // Calculadora embebida
  final TextEditingController _litrosCtrl = TextEditingController();
  double? _tasa;
  bool _loadingTasa = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentMonth = DateTime(now.year, now.month, 1);
    _loadPrefs();
    _fetchTasa();
  }

  @override
  void dispose() {
    _litrosCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? digit = prefs.getInt('last_digit');
    if (digit != null && digit >= 0 && digit <= 9) {
      lastDigit = digit;
    }
    setState(() => _loadingPrefs = false);
  }

  Future<void> _savePrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_digit', lastDigit);
  }

  void _goToday() {
    final DateTime now = DateTime.now();
    setState(() => currentMonth = DateTime(now.year, now.month, 1));
  }

  void _prevMonth() {
    setState(() {
      final int y = currentMonth.year;
      final int m = currentMonth.month;
      currentMonth = (m == 1) ? DateTime(y - 1, 12, 1) : DateTime(y, m - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      final int y = currentMonth.year;
      final int m = currentMonth.month;
      currentMonth = (m == 12) ? DateTime(y + 1, 1, 1) : DateTime(y, m + 1, 1);
    });
  }

  Future<void> _fetchTasa() async {
    setState(() {
      _loadingTasa = true;
    });
    try {
      final double? tasa = await BcvService.fetchUsdRate();
      setState(() {
        _tasa = tasa;
        _loadingTasa = false;
      });
    } catch (_) {
      setState(() => _loadingTasa = false);
    }
  }

  void _openMonthYearPicker() {
    // Placeholder: implement month/year picker if needed
  }

  String _monthName(int month) {
    const months = [
      '',
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
    return months[month];
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.year,
    required this.month,
    required this.allowedDays,
    this.baseHeightFactor = 0.95,
  });

  final int year;
  final int month;
  final Set<int> allowedDays;
  final double
  baseHeightFactor; // altura basada en ancho, sujeta a recálculo por alto disponible

  int _daysInMonth(int y, int m) => DateTime(y, m + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;
        const double rowSpacing = 6;
        const double headerBottomSpacing = 8;
        final double totalSpacing = rowSpacing * 6;
        final double cellWidth = (width - totalSpacing) / 7.0;
        final bool showFullDow = cellWidth >= 72;
        final DateTime first = DateTime(year, month, 1);
        final int firstWeekday = first.weekday;
        final int startOffset = (firstWeekday + 6) % 7;
        final int daysInMonth = _daysInMonth(year, month);
        int totalCells = startOffset + daysInMonth;
        if (totalCells % 7 != 0) totalCells += 7 - (totalCells % 7);
        final int weeks = (totalCells / 7).ceil();

        final double idealCellHeight = cellWidth * baseHeightFactor;
        const double dowApproxHeight = 22;
        final double verticalDecor =
            dowApproxHeight + headerBottomSpacing + (weeks - 1) * rowSpacing;
        final double availableForCellsRaw = maxHeight - verticalDecor;
        final double safeAvailableForCells = availableForCellsRaw > 0
            ? availableForCellsRaw
            : 0;
        final double maxPerCell = weeks > 0
            ? safeAvailableForCells / weeks
            : safeAvailableForCells;
        double cellHeight = idealCellHeight;
        if (maxPerCell > 0 && cellHeight > maxPerCell) {
          cellHeight = maxPerCell;
        }
        const double minLegible = 16;
        if (cellHeight < minLegible && maxPerCell > 0) {
          cellHeight = maxPerCell;
        }
        final double aspectRatio =
            cellWidth / (cellHeight <= 0 ? 1 : cellHeight);
        final double minCellSide = cellHeight < 40 ? cellHeight : 40;
        double? dayFontSize;
        if (cellHeight < 18) {
          dayFontSize = 9;
        } else if (cellHeight < 20) {
          dayFontSize = 10;
        } else if (cellHeight < 24) {
          dayFontSize = 11;
        } else if (cellHeight < 30) {
          dayFontSize = 12;
        }

        final int prevMonth = month == 1 ? 12 : month - 1;
        final int prevYear = month == 1 ? year - 1 : year;
        final int daysInPrevMonth = _daysInMonth(prevYear, prevMonth);

        final DateTime today = DateTime.now();
        final bool isCurrentMonth =
            (today.year == year && today.month == month);
        final ColorScheme scheme = Theme.of(context).colorScheme;

        Widget calendarContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _DowCell(showFullDow ? 'Lunes' : 'Lun'),
                  _DowCell(showFullDow ? 'Martes' : 'Mar'),
                  _DowCell(showFullDow ? 'Miércoles' : 'Mie'),
                  _DowCell(showFullDow ? 'Jueves' : 'Jue'),
                  _DowCell(showFullDow ? 'Viernes' : 'Vie'),
                  _DowCell(showFullDow ? 'Sábado' : 'Sáb', isWeekend: true),
                  _DowCell(showFullDow ? 'Domingo' : 'Dom', isWeekend: true),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: totalCells,
                itemBuilder: (BuildContext context, int index) {
                  if (index < startOffset) {
                    final int day = daysInPrevMonth - (startOffset - index) + 1;
                    final int weekday = (index % 7) + 1;
                    final bool isWknd =
                        (weekday == DateTime.saturday ||
                        weekday == DateTime.sunday);
                    return _OtherMonthDayCell(day: day, isWeekend: isWknd);
                  }
                  if (index >= startOffset + daysInMonth) {
                    final int day = index - (startOffset + daysInMonth) + 1;
                    final int weekday = (index % 7) + 1;
                    final bool isWknd =
                        (weekday == DateTime.saturday ||
                        weekday == DateTime.sunday);
                    return _OtherMonthDayCell(day: day, isWeekend: isWknd);
                  }
                  final int day = index - startOffset + 1;
                  final bool allowed = allowedDays.contains(day);
                  final bool isToday = isCurrentMonth && today.day == day;
                  final int weekday = DateTime(year, month, day).weekday;
                  final bool isWeekend =
                      (weekday == DateTime.saturday ||
                      weekday == DateTime.sunday);
                  final Color bg = allowed
                      ? scheme.primaryContainer
                      : (isWeekend
                            ? scheme.surfaceContainerHighest.withOpacity(0.18)
                            : scheme.surfaceContainerHighest.withOpacity(0.28));
                  final Color fg = allowed
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant.withOpacity(0.85);
                  return Semantics(
                    label:
                        'Día $day${isToday ? ', hoy' : ''}${allowed ? ', permitido' : ''}${isWeekend ? ', fin de semana' : ''}',
                    selected: isToday,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        splashColor: scheme.primary.withOpacity(0.10),
                        highlightColor: scheme.primary.withOpacity(0.08),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _showDayDetails(
                            context,
                            day,
                            allowed,
                            isWeekend,
                            isToday,
                          );
                        },
                        child: Stack(
                          children: <Widget>[
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(
                                  isToday ? 16 : 14,
                                ),
                                border: isToday
                                    ? Border.all(
                                        color: scheme.secondary,
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: isToday
                                    ? <BoxShadow>[
                                        BoxShadow(
                                          color: scheme.secondary.withOpacity(
                                            0.18,
                                          ),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              constraints: BoxConstraints(
                                minHeight: minCellSide,
                                minWidth: 40,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                day.toString(),
                                style: TextStyle(
                                  color: fg,
                                  fontWeight: allowed
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  fontSize: dayFontSize ?? 13,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            if (isToday)
                              Positioned(top: 6, right: 6, child: _TodayDot()),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );

        // Si el espacio vertical es muy pequeño, permitir scroll para evitar overflow
        if (maxHeight < 200) {
          return SingleChildScrollView(
            child: SizedBox(
              height: 320, // Altura mínima para mostrar el calendario completo
              child: calendarContent,
            ),
          );
        } else {
          return calendarContent;
        }
      },
    );
  }
}

// Nueva sección que contiene encabezado de placa + calendario (sin calculadora)
class _CalendarSection extends StatelessWidget {
  const _CalendarSection({
    required this.pairLabel,
    required this.year,
    required this.month,
    required this.days,
    required this.keyboardOpen,
  });
  final String pairLabel;
  final int year;
  final int month;
  final List<int> days;
  final bool keyboardOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Placa: $pairLabel',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: keyboardOpen ? 14 : null,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: keyboardOpen ? 4 : 6),
        Expanded(
          child: _CalendarGrid(
            year: year,
            month: month,
            allowedDays: Set<int>.from(days),
            baseHeightFactor: 0.9,
          ),
        ),
      ],
    );
  }
}

class _OtherMonthDayCell extends StatelessWidget {
  const _OtherMonthDayCell({required this.day, this.isWeekend = false});
  final int day;
  final bool isWeekend;
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    // El calendario ajusta su altura automáticamente; no se requiere variable de estado del teclado aquí.
    final bool keyboardOpenLocal = MediaQuery.of(context).viewInsets.bottom > 0;
    final double minSide = keyboardOpenLocal ? 28 : 40;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: BoxConstraints(
        minHeight: minSide,
        minWidth: 40,
      ), // adaptable si teclado abierto
      alignment: Alignment.center,
      child: Text(
        day.toString(),
        style: TextStyle(
          color: scheme.onSurfaceVariant.withOpacity(0.45),
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}

class _DowCell extends StatelessWidget {
  const _DowCell(this.label, {this.isWeekend = false});
  final String label;
  final bool isWeekend;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isWeekend
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : null,
          ),
        ),
      ),
    );
  }
}

// Clase _Legend eliminada porque ya no se usa

class _TodayDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: scheme.secondary,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.secondary.withOpacity(0.25),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _PlateGroupChips extends StatelessWidget {
  const _PlateGroupChips({
    required this.selectedDigit,
    required this.onChanged,
  });

  final int selectedDigit;
  final ValueChanged<int> onChanged;

  // Map representative digit to its label group.
  static const Map<int, String> _labels = <int, String>{
    1: '1-2',
    3: '3-4',
    5: '5-6',
    7: '7-8',
    9: '9-0',
  };

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle chipTextStyle = Theme.of(context).textTheme.labelMedium!
        .copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.06,
        );
    return Center(
      child: Wrap(
        spacing: 5,
        runSpacing: 1.5,
        children: _labels.entries.map((MapEntry<int, String> e) {
          final int repDigit = e.key;
          final String label = e.value;
          final bool selected = _isInGroup(selectedDigit, repDigit);
          return Tooltip(
            message: 'Grupo $label',
            child: ChoiceChip(
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(label, style: chipTextStyle),
              ),
              selected: selected,
              selectedColor: scheme.primaryContainer,
              backgroundColor: scheme.surfaceContainerHighest.withOpacity(0.10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
                side: selected
                    ? BorderSide(color: scheme.primary, width: 1)
                    : BorderSide(
                        color: scheme.outline.withOpacity(0.12),
                        width: 1,
                      ),
              ),
              elevation: selected ? 1 : 0,
              shadowColor: scheme.primary.withOpacity(0.06),
              onSelected: (bool s) {
                if (s) onChanged(repDigit);
              },
              showCheckmark: false,
              visualDensity: VisualDensity(horizontal: -2, vertical: -2),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }).toList(),
      ),
    );
  }

  // selectedDigit can be any 0-9 stored in prefs; treat 0 as member of group 9-0.
  bool _isInGroup(int digit, int representative) {
    switch (representative) {
      case 1:
        return digit == 1 || digit == 2;
      case 3:
        return digit == 3 || digit == 4;
      case 5:
        return digit == 5 || digit == 6;
      case 7:
        return digit == 7 || digit == 8;
      case 9:
        return digit == 9 || digit == 0;
    }
    return false;
  }
}

// Simple bus for quick actions
class _QuickActionBus extends ChangeNotifier {
  _QuickActionBus._();
  static final _QuickActionBus instance = _QuickActionBus._();
  void triggerToday() => notifyListeners();
}

void _showDayDetails(
  BuildContext context,
  int day,
  bool allowed,
  bool isWeekend,
  bool isToday,
) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Día $day', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (isToday) const _ChipInfo(Icons.today, 'Hoy'),
              if (allowed) const _ChipInfo(Icons.check_circle, 'Permitido'),
              if (isWeekend) const _ChipInfo(Icons.weekend, 'Fin de semana'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close),
                label: const Text('Cerrar'),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _QuickActionBus.instance.triggerToday();
                },
                icon: const Icon(Icons.today),
                label: const Text('Ir a Hoy'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ChipInfo extends StatelessWidget {
  const _ChipInfo(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) =>
      Chip(avatar: Icon(icon, size: 16), label: Text(label));
}

class _EmbeddedGasCalculator extends StatefulWidget {
  const _EmbeddedGasCalculator({
    required this.litrosCtrl,
    required this.tasa,
    required this.loading,
    required this.onRefresh,
    this.dense = false,
  });
  final TextEditingController litrosCtrl;
  final double? tasa;
  final bool loading;
  final VoidCallback onRefresh;
  final bool dense;

  @override
  State<_EmbeddedGasCalculator> createState() => _EmbeddedGasCalculatorState();
}

class _EmbeddedGasCalculatorState extends State<_EmbeddedGasCalculator> {
  String _litrosText = '';

  @override
  void initState() {
    super.initState();
    _litrosText = widget.litrosCtrl.text;
    widget.litrosCtrl.addListener(_onLitrosChanged);
  }

  @override
  void dispose() {
    widget.litrosCtrl.removeListener(_onLitrosChanged);
    super.dispose();
  }

  void _onLitrosChanged() {
    if (_litrosText != widget.litrosCtrl.text) {
      setState(() {
        _litrosText = widget.litrosCtrl.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double? litros = double.tryParse(_litrosText.replaceAll(',', '.'));
    double? totalUsd;
    double? totalBs;
    if (litros != null) {
      totalUsd = litros / 2; // regla solicitada
      if (widget.tasa != null)
        totalBs = totalUsd * widget.tasa!; // conversión con BCV
    }
    final NumberFormat fmtUsd = NumberFormat('#,##0.00', 'es_VE');
    final NumberFormat fmtBs = NumberFormat.currency(
      locale: 'es_VE',
      symbol: 'Bs',
      decimalDigits: 2,
    );
    final NumberFormat fmtTasa = NumberFormat('#,##0.00', 'es_VE');
    final scheme = Theme.of(context).colorScheme;
    final double vPad = widget.dense ? 2 : 10;
    final double hPad = widget.dense ? 8 : 14;
    final double titleFontSize = widget.dense
        ? 13
        : Theme.of(context).textTheme.titleMedium?.fontSize ?? 16;
    final double valueFontSize = widget.dense
        ? 13
        : Theme.of(context).textTheme.titleMedium?.fontSize ?? 16;
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.dense ? 14 : 20),
        color: scheme.surfaceContainerHighest.withOpacity(0.18),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.local_gas_station, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Calculadora de Gasolina',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.loading ? null : widget.onRefresh,
                tooltip: 'Actualizar tasa',
                icon: widget.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.refresh, color: scheme.primary),
              ),
            ],
          ),
          const Divider(height: 18, thickness: 1, indent: 0, endIndent: 0),
          TextField(
            controller: widget.litrosCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontSize: valueFontSize + 2,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              labelText: 'Litros',
              prefixIcon: const Icon(Icons.local_gas_station),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: scheme.primary.withOpacity(0.18)),
              ),
              filled: true,
              fillColor: scheme.surfaceContainerHighest.withOpacity(0.10),
            ),
          ),
          SizedBox(height: widget.dense ? 8 : 16),
          if (totalBs != null)
            Padding(
              padding: EdgeInsets.only(bottom: widget.dense ? 2 : 6),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Total en Bs:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: valueFontSize,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    fmtBs.format(totalBs),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: valueFontSize + 2,
                      color: scheme.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          if (totalUsd != null)
            Padding(
              padding: EdgeInsets.only(bottom: widget.dense ? 2 : 6),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Total en USD:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: valueFontSize,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${fmtUsd.format(totalUsd)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: valueFontSize + 2,
                      color: scheme.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          if (widget.tasa != null)
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 2),
              child: Row(
                children: [
                  Icon(Icons.trending_up, size: 16, color: scheme.secondary),
                  const SizedBox(width: 4),
                  Text(
                    'Tasa BCV: ${fmtTasa.format(widget.tasa)} Bs/USD',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (widget.tasa == null && !widget.loading)
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 2),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: scheme.error),
                  const SizedBox(width: 4),
                  Text(
                    'No se pudo obtener la tasa. Reintenta.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: scheme.error),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
