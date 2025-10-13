import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../data/bcv_service.dart';
import '../data/schedules.dart';
import '../widgets/embedded_gas_calculator.dart';
import '../widgets/plate_group_chips.dart';
import '../widgets/advanced_calendar.dart';
import '../utils/show_day_details.dart';

class GasCalendarScreen extends StatefulWidget {
  const GasCalendarScreen({super.key, required this.themeMode, required this.onThemeModeChanged});
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  @override
  State<GasCalendarScreen> createState() => _GasCalendarScreenState();
}

class _GasCalendarScreenState extends State<GasCalendarScreen> {
  late final Stream<ConnectivityResult> _connectivityStream;
  bool _isOnline = true;
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
            Widget calculatorWidget = Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: EmbeddedGasCalculator(
                  litrosCtrl: _litrosCtrl,
                  tasa: _tasa,
                  loading: _loadingTasa,
                  onRefresh: _fetchTasa,
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
                PlateGroupChips(
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
              // Horizontal layout para pantallas anchas (ahora con AdvancedCalendar)
              return Padding(
                padding: EdgeInsets.all(spacing),
                child: Column(
                  children: [
                    header,
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: AdvancedCalendar(
                                  year: y,
                                  month: m,
                                  selectedDigit: lastDigit,
                                  pairLabel: pairLabel,
                                  onDaySelected: (d) {
                                    if (d != null) {
                                      final bool allowed = days.contains(d.day);
                                      final bool isWeekend = d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;
                                      final bool isToday = d.year == DateTime.now().year && d.month == DateTime.now().month && d.day == DateTime.now().day;
                                      showDayDetails(context, d.day, allowed, isWeekend, isToday);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: spacing),
                          Flexible(
                            flex: 1,
                            child: SingleChildScrollView(
                              child: calculatorWidget,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Vertical layout para pantallas pequeñas
              // Banner de estado de conectividad (solo visible si offline)
              final Widget connectivityBanner = AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: _isOnline ? 0 : 36,
                child: _isOnline
                    ? const SizedBox.shrink()
                    : Container(
                        color: Colors.redAccent,
                        alignment: Alignment.center,
                        child: const Text(
                          'Sin conexión — mostrando datos en cache',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              );

              return Padding(
                padding: EdgeInsets.all(spacing),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      header,
                      connectivityBanner,
                      // Para pantallas pequeñas usamos AdvancedCalendar para funciones extra
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: AdvancedCalendar(
                            year: y,
                            month: m,
                            selectedDigit: lastDigit,
                            pairLabel: pairLabel,
                            onDaySelected: (d) {
                              if (d != null) {
                                final bool allowed = days.contains(d.day);
                                final bool isWeekend = d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;
                                final bool isToday = d.year == DateTime.now().year && d.month == DateTime.now().month && d.day == DateTime.now().day;
                                showDayDetails(context, d.day, allowed, isWeekend, isToday);
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
                      calculatorWidget,
                    ],
                  ),
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
    // Inicializar monitor de conectividad
    _connectivityStream = Connectivity().onConnectivityChanged;
    _connectivityStream.listen((ConnectivityResult result) {
      final bool online = result != ConnectivityResult.none;
      if (online != _isOnline) {
        setState(() => _isOnline = online);
      }
    });

    _initAsync();
  }

  Future<void> _initAsync() async {
    await Future.wait([_loadPrefs(), _fetchTasa()]);
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
      if (tasa != null) {
        // Cachear la tasa para uso offline
        await BcvService.cacheUsdRate(tasa);
      }
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
