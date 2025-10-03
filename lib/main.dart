import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/bcv_service.dart';
import 'data/schedules.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_actions/quick_actions.dart';
import 'theme.dart';

void main() {
  // Configure home screen quick actions (Android/iOS)
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
  Color _accent = AppColors.red;
  bool _loaded = false;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemePrefs();
  }

  Future<void> _loadThemePrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? c = prefs.getInt('accent_color');
    final String? mode = prefs.getString('theme_mode');
    setState(() {
      if (c != null) _accent = Color(c);
      if (mode != null) {
        switch (mode) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          default:
            _themeMode = ThemeMode.system;
        }
      }
      _loaded = true;
    });
  }

  Future<void> _setAccent(Color c) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // Usar .value para persistencia (toArgb no existe en Flutter estable)
  await prefs.setInt('accent_color', c.value);
  setState(() => _accent = c);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'system';
    if (mode == ThemeMode.light) key = 'light';
    if (mode == ThemeMode.dark) key = 'dark';
    await prefs.setString('theme_mode', key);
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return MaterialApp(
        theme: appThemeLight(),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
        debugShowCheckedModeBanner: false,
      );
    }
    return MaterialApp(
      title: 'Gasolina',
      theme: appThemeLight(accent: _accent),
      darkTheme: appThemeDark(accent: _accent),
      themeMode: _themeMode,
      home: GasCalendarScreen(
        onAccentChanged: _setAccent,
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GasCalendarScreen extends StatefulWidget {
  const GasCalendarScreen({
    super.key,
    this.onAccentChanged,
    this.themeMode = ThemeMode.system,
    this.onThemeModeChanged,
  });

  final ValueChanged<Color>? onAccentChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  State<GasCalendarScreen> createState() => _GasCalendarScreenState();
}

class _GasCalendarScreenState extends State<GasCalendarScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializa currentMonth al primer día del mes actual
    final now = DateTime.now();
    currentMonth = DateTime(now.year, now.month, 1);
  }
  // Navega al mes actual (hoy)
  void _goToday() {
    // TODO: Implementar funcionalidad para ir al mes actual
    // Por ahora solo es un stub para evitar el error
  }

  // Navega al mes anterior
  void _prevMonth() {
    // TODO: Implementar funcionalidad para ir al mes anterior
    // Por ahora solo es un stub para evitar el error
  }

  // Navega al mes siguiente
  void _nextMonth() {
    // TODO: Implementar funcionalidad para ir al mes siguiente
    // Por ahora solo es un stub para evitar el error
  }

  // Guarda preferencias del usuario
  void _savePrefs() {
    // TODO: Implementar guardado de preferencias si se desea funcionalidad completa
    // Por ahora solo es un stub para evitar el error
  }

  // --- Calculadora de gasolina ---
  void _openGasCalculator() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext ctx) => GasCalculatorSheet(),
    );
  }

  late DateTime currentMonth; // anclado al día 1 del mes visible
  int lastDigit = 1;
  bool _loadingPrefs = true;

  // Abre el selector de mes/a[0mo
  Future<void> _openMonthYearPicker() async {
    // TODO: Implementar selector de mes/a[0mo si se desea funcionalidad completa
    // Por ahora solo es un stub para evitar el error
  }

  @override
  Widget build(BuildContext context) {
    final int y = currentMonth.year;
    final int m = currentMonth.month;
    final List<int> days = GasSchedule.daysForDigit(
      year: y,
      month: m,
      lastDigit: lastDigit,
    );
    final String pairLabel = GasSchedule.pairLabelForDigit(lastDigit);

    if (_loadingPrefs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Gasolina'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Ir a hoy',
            icon: const Icon(Icons.today),
            onPressed: _goToday,
          ),
          if (widget.onThemeModeChanged != null)
            PopupMenuButton<ThemeMode>(
              tooltip: 'Tema',
              icon: Icon(
                widget.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : (widget.themeMode == ThemeMode.light
                          ? Icons.light_mode
                          : Icons.brightness_auto),
              ),
              onSelected: (ThemeMode m) => widget.onThemeModeChanged?.call(m),
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<ThemeMode>>[
                    CheckedPopupMenuItem<ThemeMode>(
                      value: ThemeMode.system,
                      checked: widget.themeMode == ThemeMode.system,
                      child: const Text('Sistema'),
                    ),
                    CheckedPopupMenuItem<ThemeMode>(
                      value: ThemeMode.light,
                      checked: widget.themeMode == ThemeMode.light,
                      child: const Text('Claro'),
                    ),
                    CheckedPopupMenuItem<ThemeMode>(
                      value: ThemeMode.dark,
                      checked: widget.themeMode == ThemeMode.dark,
                      child: const Text('Oscuro'),
                    ),
                  ],
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Encabezado y chips
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> anim) {
                  final Animation<Offset> slide = Tween<Offset>(
                    begin: const Offset(0.15, 0),
                    end: Offset.zero,
                  ).animate(anim);
                  return SlideTransition(
                    position: slide,
                    child: FadeTransition(opacity: anim, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<String>('month-$y-$m'),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Mes anterior',
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _prevMonth,
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
                              child: Tooltip(
                                message: 'Cambiar mes/año',
                                child: Text(
                                  '${_monthName(m)} $y',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Mes siguiente',
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextMonth,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Terminal de placa: ',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: KeyedSubtree(
                      key: ValueKey<int>(lastDigit),
                      child: _PlateGroupChips(
                        selectedDigit: lastDigit,
                        onChanged: (int d) {
                          setState(() => lastDigit = d);
                          _savePrefs();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Calendario expandido
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Placa: $pairLabel',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder:
                                (Widget child, Animation<double> anim) {
                                  final Animation<Offset> offset =
                                      Tween<Offset>(
                                        begin: const Offset(0.1, 0),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: anim,
                                          curve: Curves.easeOut,
                                        ),
                                      );
                                  return SlideTransition(
                                    position: offset,
                                    child: FadeTransition(
                                      opacity: anim,
                                      child: child,
                                    ),
                                  );
                                },
                            child: KeyedSubtree(
                              key: ValueKey<String>(
                                'cal-$y-$m-${lastDigit.toString()}',
                              ),
                              child: _CalendarGrid(
                                year: y,
                                month: m,
                                allowedDays: Set<int>.from(days),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            _Legend(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              label: 'Permitido',
                            ),
                            _Legend(
                              outlineColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              label: 'Hoy',
                            ),
                            _Legend(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.22),
                              label: 'Fin de semana',
                            ),
                            _Legend(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.10),
                              label: 'Otro mes',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openGasCalculator,
        icon: const Icon(Icons.local_gas_station),
        label: const Text('Calculadora'),
        tooltip: 'Calculadora de precio de gasolina',
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double totalSpacing = 6 * 6;
        final double cellWidth = (width - totalSpacing) / 7.0;
        final double cellHeight = cellWidth * 1.05;
        final double aspectRatio = cellWidth / cellHeight;
        final bool showFullDow = cellWidth >= 72;
        final DateTime first = DateTime(year, month, 1);
        final int firstWeekday = first.weekday; // 1=Mon..7=Sun
        final int startOffset = (firstWeekday + 6) % 7;
        final int daysInMonth = _daysInMonth(year, month);
        int totalCells = startOffset + daysInMonth;
        if (totalCells % 7 != 0) totalCells += 7 - (totalCells % 7);

        // Previous month data
        final int prevMonth = month == 1 ? 12 : month - 1;
        final int prevYear = month == 1 ? year - 1 : year;
        final int daysInPrevMonth = _daysInMonth(prevYear, prevMonth);

        final DateTime today = DateTime.now();
        final bool isCurrentMonth =
            (today.year == year && today.month == month);

        final ColorScheme scheme = Theme.of(context).colorScheme;

        return Column(
          children: <Widget>[
            Row(
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
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: aspectRatio,
              ),
              itemCount: totalCells,
              itemBuilder: (BuildContext context, int index) {
                // Previous month days
                if (index < startOffset) {
                  final int day = daysInPrevMonth - (startOffset - index) + 1;
                  final int weekday = (index % 7) + 1; // 1-7
                  final bool isWknd =
                      (weekday == DateTime.saturday ||
                      weekday == DateTime.sunday);
                  return _OtherMonthDayCell(day: day, isWeekend: isWknd);
                }
                // Next month days
                if (index >= startOffset + daysInMonth) {
                  final int day = index - (startOffset + daysInMonth) + 1;
                  final int weekday = (index % 7) + 1; // 1-7
                  final bool isWknd =
                      (weekday == DateTime.saturday ||
                      weekday == DateTime.sunday);
                  return _OtherMonthDayCell(day: day, isWeekend: isWknd);
                }

                // Current month
                final int day = index - startOffset + 1;
                final bool allowed = allowedDays.contains(day);
                final bool isToday = isCurrentMonth && today.day == day;
                final int weekday = DateTime(year, month, day).weekday; // 1-7
                final bool isWeekend =
                    (weekday == DateTime.saturday ||
                    weekday == DateTime.sunday);
                final Color bg = allowed
                    ? scheme.primaryContainer
                    : (isWeekend
                          ? scheme.surfaceContainerHighest.withOpacity(0.22)
                          : scheme.surfaceContainerHighest.withOpacity(0.35));
                final Color fg = allowed
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant;
                return Semantics(
                  label:
                      'Día $day${isToday ? ', hoy' : ''}${allowed ? ', permitido' : ''}${isWeekend ? ', fin de semana' : ''}',
                  selected: isToday,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
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
                          Container(
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(10),
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
                                          0.2,
                                        ),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            constraints: const BoxConstraints(
                              minHeight: 44,
                              minWidth: 44,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              day.toString(),
                              style: TextStyle(
                                color: fg,
                                fontWeight: allowed
                                    ? FontWeight.w600
                                    : FontWeight.normal,
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
          ],
        );
      },
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
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
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

class _Legend extends StatelessWidget {
  const _Legend({this.color, this.outlineColor, required this.label});
  final Color? color;
  final Color? outlineColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color effectiveOutline =
        outlineColor ??
        (color != null ? color!.withOpacity(0.9) : scheme.outline);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: effectiveOutline, width: 2),
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _labels.entries.map((MapEntry<int, String> e) {
        final int repDigit = e.key; // representative digit
        final String label = e.value;
        final bool selected = _isInGroup(selectedDigit, repDigit);
        return Tooltip(
          message: 'Grupo $label',
          child: ChoiceChip(
            label: Text(label),
            selected: selected,
            selectedColor: scheme.primaryContainer,
            onSelected: (bool s) {
              if (s) onChanged(repDigit);
            },
          ),
        );
      }).toList(),
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
  final ThemeData theme = Theme.of(context);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext ctx) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Día $day', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                if (isToday) const _ChipInfo(Icons.today, 'Hoy'),
                if (allowed) const _ChipInfo(Icons.check_circle, 'Permitido'),
                if (isWeekend) const _ChipInfo(Icons.weekend, 'Fin de semana'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
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
      );
    },
  );
}

class _ChipInfo extends StatelessWidget {
  const _ChipInfo(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 16), label: Text(label));
  }
}

// --- Calculadora de gasolina ---
class GasCalculatorSheet extends StatefulWidget {
  const GasCalculatorSheet({super.key});

  @override
  State<GasCalculatorSheet> createState() => _GasCalculatorSheetState();
}

class _GasCalculatorSheetState extends State<GasCalculatorSheet> {
  final TextEditingController _litrosCtrl = TextEditingController();
  final TextEditingController _precioBsCtrl = TextEditingController(
    text: '0.50',
  );
  double? _tasa;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTasa();
  }

  Future<void> _fetchTasa() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final double? t = await BcvService.fetchUsdRate();
    setState(() {
      _tasa = t;
      _loading = false;
      if (t == null) {
        _error = 'No se pudo obtener la tasa BCV.';
      }
    });
  }

  @override
  void dispose() {
    _litrosCtrl.dispose();
    _precioBsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double? litros = double.tryParse(
      _litrosCtrl.text.replaceAll(',', '.'),
    );
    final double? precioBs = double.tryParse(
      _precioBsCtrl.text.replaceAll(',', '.'),
    );
    double? totalBs;
    double? totalUsd;
    if (litros != null && precioBs != null) {
      totalBs = litros * precioBs;
      if (_tasa != null && _tasa! > 0) {
        totalUsd = totalBs / _tasa!;
      }
    }
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_gas_station, size: 28),
              const SizedBox(width: 10),
              Text(
                'Calculadora de Gasolina',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar tasa',
                onPressed: _loading ? null : _fetchTasa,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _litrosCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Litros',
                    prefixIcon: Icon(Icons.local_gas_station),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _precioBsCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Precio Bs/Litro',
                    prefixText: 'Bs ',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (totalBs != null)
            Row(
              children: [
                const Text(
                  'Total: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Bs ${totalBs.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (totalUsd != null) ...[
                  const SizedBox(width: 18),
                  const Text('≈ '),
                  Text(
                    '\u0024${totalUsd.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ],
            ),
          if (_tasa != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Tasa BCV: ${_tasa!.toStringAsFixed(2)} Bs/USD',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Spacer(),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                label: const Text('Cerrar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
