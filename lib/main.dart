import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    const ShortcutItem(type: 'action_today', localizedTitle: 'Ir a Hoy', icon: 'ic_launcher'),
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
    );
  }
}

class GasCalendarScreen extends StatefulWidget {
  const GasCalendarScreen({super.key, this.onAccentChanged, this.themeMode = ThemeMode.system, this.onThemeModeChanged});

  final ValueChanged<Color>? onAccentChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  State<GasCalendarScreen> createState() => _GasCalendarScreenState();
}

class _GasCalendarScreenState extends State<GasCalendarScreen> {
  late DateTime currentMonth; // anclado al día 1 del mes visible
  int lastDigit = 1;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    currentMonth = DateTime(now.year, now.month, 1);
    _loadPrefs();
    // Listen to quick action 'today'
    _QuickActionBus.instance.addListener(_handleQuickAction);
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
      _loadingPrefs = false;
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
    HapticFeedback.selectionClick();
    _savePrefs();
    _announceMonth();
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    });
    HapticFeedback.selectionClick();
    _savePrefs();
    _announceMonth();
  }

  void _goToday() {
    final DateTime now = DateTime.now();
    setState(() {
      currentMonth = DateTime(now.year, now.month, 1);
    });
    HapticFeedback.lightImpact();
    _savePrefs();
    _announceMonth(prefix: 'Hoy:');
  }

  void _handleQuickAction() {
    _goToday();
  }

  @override
  void dispose() {
    _QuickActionBus.instance.removeListener(_handleQuickAction);
    super.dispose();
  }

  Future<void> _openMonthYearPicker() async {
    int selYear = currentMonth.year;
    int selMonth = currentMonth.month;
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Seleccionar mes y año'),
          content: SizedBox(
            width: 400,
            child: StatefulBuilder(
              builder: (BuildContext ctx2, StateSetter setLocalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          tooltip: 'Año anterior',
                          onPressed: () => setLocalState(() => selYear--),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: Center(
                            child: Text('$selYear', style: Theme.of(context).textTheme.titleMedium),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Año siguiente',
                          onPressed: () => setLocalState(() => selYear++),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List<Widget>.generate(12, (int i) {
                        final int month = i + 1;
                        final bool selected = (month == selMonth);
                        return ChoiceChip(
                          label: Text(_monthName(month)),
                          selected: selected,
                          onSelected: (_) => setLocalState(() => selMonth = month),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                setState(() => currentMonth = DateTime(selYear, selMonth, 1));
                _savePrefs();
                _announceMonth();
                Navigator.of(ctx).pop();
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  void _announceMonth({String prefix = 'Mes:'}) {
    final String label = '$prefix ${_monthName(currentMonth.month)} ${currentMonth.year}';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(label), duration: const Duration(milliseconds: 1200)));
  }

  @override
  Widget build(BuildContext context) {
    final int y = currentMonth.year;
    final int m = currentMonth.month;
    final List<int> days =
        GasSchedule.daysForDigit(year: y, month: m, lastDigit: lastDigit);
    final String pairLabel = GasSchedule.pairLabelForDigit(lastDigit);

    if (_loadingPrefs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Gasolina'),
        actions: <Widget>[
          if (widget.onThemeModeChanged != null)
            PopupMenuButton<ThemeMode>(
              tooltip: 'Tema',
              icon: Icon(
                widget.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : (widget.themeMode == ThemeMode.light ? Icons.light_mode : Icons.brightness_auto),
              ),
              onSelected: (ThemeMode m) => widget.onThemeModeChanged?.call(m),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Shortcuts(
            shortcuts: <LogicalKeySet, Intent>{
              LogicalKeySet(LogicalKeyboardKey.arrowLeft): const _PrevMonthIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowRight): const _NextMonthIntent(),
              LogicalKeySet(LogicalKeyboardKey.enter): const _TodayIntent(),
            },
            child: Actions(
              actions: <Type, Action<Intent>>{
                _PrevMonthIntent: CallbackAction<_PrevMonthIntent>(onInvoke: (Intent i) => _prevMonth()),
                _NextMonthIntent: CallbackAction<_NextMonthIntent>(onInvoke: (Intent i) => _nextMonth()),
                _TodayIntent: CallbackAction<_TodayIntent>(onInvoke: (Intent i) => _goToday()),
              },
              child: Focus(
                autofocus: true,
                child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _openMonthYearPicker,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Tooltip(
                          message: 'Cambiar mes/año',
                          child: Text(
                            '${_monthName(m)} $y',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Terminal de placa: ', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                _PlateGroupChips(
                  selectedDigit: lastDigit,
                  onChanged: (int d) {
                    setState(() => lastDigit = d);
                    _savePrefs();
                  },
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
                    Text('Placa: $pairLabel',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (Widget child, Animation<double> anim) {
                        final Animation<Offset> offset = Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero)
                            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
                        return SlideTransition(position: offset, child: FadeTransition(opacity: anim, child: child));
                      },
                      child: KeyedSubtree(
                        key: ValueKey<String>('cal-$y-$m-${lastDigit.toString()}'),
                        child: _CalendarGrid(
                          year: y,
                          month: m,
                          allowedDays: Set<int>.from(days),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        _Legend(color: Theme.of(context).colorScheme.primaryContainer, label: 'Permitido'),
                        _Legend(outlineColor: Theme.of(context).colorScheme.primary, label: 'Hoy'),
                        _Legend(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.22), label: 'Fin de semana'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
              ),
            ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToday,
        icon: const Icon(Icons.today),
        label: const Text('Hoy'),
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
    // Use LayoutBuilder to adapt cell sizes to available width.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        // Deduct the crossAxisSpacing (6 px between 7 columns means 6*6 = 36 px)
        final double totalSpacing = 6 * 6;
        final double cellWidth = (width - totalSpacing) / 7.0;
        // Aim for near-square cells, but allow a bit more height for legibility.
        final double cellHeight = cellWidth * 1.05;
        final double aspectRatio = cellWidth / cellHeight; // ~0.95
        final bool showFullDow = cellWidth >= 72; // Mostrar nombre completo cuando hay espacio suficiente
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
              children: <Widget>[
                _DowCell(showFullDow ? 'Lunes' : 'L'),
                _DowCell(showFullDow ? 'Martes' : 'M'),
                _DowCell(showFullDow ? 'Miércoles' : 'X'),
                _DowCell(showFullDow ? 'Jueves' : 'J'),
                _DowCell(showFullDow ? 'Viernes' : 'V'),
                _DowCell(showFullDow ? 'Sábado' : 'S', isWeekend: true),
                _DowCell(showFullDow ? 'Domingo' : 'D', isWeekend: true),
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
                if (index < startOffset || index >= startOffset + daysInMonth) {
                  return const SizedBox.shrink();
                }
                final int day = index - startOffset + 1;
                final bool allowed = allowedDays.contains(day);
                final bool isToday = isCurrentMonth && today.day == day;
                final int weekday = DateTime(year, month, day).weekday; // 1-7
                final bool isWeekend = (weekday == DateTime.saturday || weekday == DateTime.sunday);
                final Color bg = allowed
                    ? scheme.primaryContainer
                    : (isWeekend
                        ? scheme.surfaceVariant.withOpacity(0.22)
                        : scheme.surfaceVariant.withOpacity(0.35));
                final Color fg = allowed ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
                return Semantics(
                  label: 'Día $day${isToday ? ', hoy' : ''}${allowed ? ', permitido' : ''}${isWeekend ? ', fin de semana' : ''}',
                  selected: isToday,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _showDayDetails(context, day, allowed, isWeekend, isToday);
                      },
                      child: Stack(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(10),
                              border: isToday
                                  ? Border.all(color: scheme.secondary, width: 3)
                                  : null,
                              boxShadow: isToday
                                  ? <BoxShadow>[
                                      BoxShadow(
                                        color: scheme.secondary.withOpacity(0.2),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                            alignment: Alignment.center,
                            child: Text(
                              day.toString(),
                              style: TextStyle(
                                color: fg,
                                fontWeight: allowed ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isToday)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: _TodayDot(),
                            ),
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
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(
                fontWeight: FontWeight.w600,
                color: isWeekend ? Theme.of(context).colorScheme.onSurfaceVariant : null,
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
    final Color effectiveOutline = outlineColor ?? (color != null ? color!.withOpacity(0.9) : scheme.outline);
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

// Keyboard intents
class _PrevMonthIntent extends Intent { const _PrevMonthIntent(); }
class _NextMonthIntent extends Intent { const _NextMonthIntent(); }
class _TodayIntent extends Intent { const _TodayIntent(); }

// Removed color palette menu item helper as the palette menu is disabled for now.

void _showDayDetails(BuildContext context, int day, bool allowed, bool isWeekend, bool isToday) {
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
            Wrap(spacing: 12, runSpacing: 8, children: <Widget>[
              if (isToday) const _ChipInfo(Icons.today, 'Hoy'),
              if (allowed) const _ChipInfo(Icons.check_circle, 'Permitido'),
              if (isWeekend) const _ChipInfo(Icons.weekend, 'Fin de semana'),
            ]),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                FilledButton.icon(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close), label: const Text('Cerrar')),
                const Spacer(),
                TextButton.icon(onPressed: () { Navigator.of(ctx).pop(); _QuickActionBus.instance.triggerToday(); }, icon: const Icon(Icons.today), label: const Text('Ir a Hoy')),
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
  final IconData icon; final String label;
  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
