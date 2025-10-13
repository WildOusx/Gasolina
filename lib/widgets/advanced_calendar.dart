import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/schedules.dart';

/// Calendario avanzado que usa `table_calendar` y marca los días permitidos.
class AdvancedCalendar extends StatefulWidget {
  const AdvancedCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDigit,
    this.onDaySelected,
    this.pairLabel,
  });

  final int year;
  final int month;
  final int selectedDigit;
  final ValueChanged<DateTime?>? onDaySelected;
  final String? pairLabel;

  @override
  State<AdvancedCalendar> createState() => _AdvancedCalendarState();
}

class _AdvancedCalendarState extends State<AdvancedCalendar> {
  late final DateTime _firstDay;
  late final DateTime _lastDay;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<String, Set<int>> _allowedCache = <String, Set<int>>{};

  @override
  void initState() {
    super.initState();
    _firstDay = DateTime(widget.year - 1, 1, 1);
    _lastDay = DateTime(widget.year + 1, 12, 31);
    _focusedDay = DateTime(widget.year, widget.month, 1);
    _selectedDay = null;
  }

  Set<int> _allowedDaysForMonth(int year, int month) {
    final String key = '\$year-\$month-\${widget.selectedDigit}';
    if (_allowedCache.containsKey(key)) return _allowedCache[key]!;
    final List<int> days = GasSchedule.daysForDigit(year: year, month: month, lastDigit: widget.selectedDigit);
    final Set<int> s = Set<int>.from(days);
    _allowedCache[key] = s;
    return s;
  }

  List<String> _eventsForDay(DateTime day) {
    final Set<int> allowed = _allowedDaysForMonth(day.year, day.month);
    if (allowed.contains(day.day)) return ['permitido'];
    return const <String>[];
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header + small legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withAlpha((0.06 * 255).round()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.pairLabel ?? ''} — ${_focusedDay.month}/${_focusedDay.year}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TableCalendar<String>(
          focusedDay: _focusedDay,
          firstDay: _firstDay,
          lastDay: _lastDay,
          locale: locale,
          startingDayOfWeek: StartingDayOfWeek.monday,
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 12),
            weekendStyle: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 12)).copyWith(color: scheme.onSurfaceVariant),
            decoration: BoxDecoration(),
          ),
            headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withAlpha((0.06 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: scheme.onSurfaceVariant),
            rightChevronIcon: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ),
      availableGestures: AvailableGestures.horizontalSwipe,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
        if (widget.onDaySelected != null) widget.onDaySelected!(selected);
      },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final bool isAllowed = _eventsForDay(day).isNotEmpty;
              final bool isToday = isSameDay(day, DateTime.now());
              final bool isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
              final TextStyle style = Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: isAllowed ? scheme.onPrimaryContainer : null,
                    fontWeight: isAllowed ? FontWeight.w700 : FontWeight.normal,
                  );
              return Semantics(
                label: 'Día ${day.day}${isToday ? ', hoy' : ''}${isAllowed ? ', permitido' : ''}',
                selected: isToday,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isAllowed ? scheme.primaryContainer : (isWeekend ? scheme.surfaceContainerHighest : Colors.transparent),
                    borderRadius: BorderRadius.circular(isToday ? 14 : 10),
                    border: isToday
                        ? Border.all(color: scheme.secondary, width: 2)
                        : Border.all(color: Colors.transparent, width: 0),
          boxShadow: isToday
            ? [BoxShadow(color: scheme.secondary.withAlpha((0.12 * 255).round()), blurRadius: 6, spreadRadius: 1)]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(day.day.toString(), style: style),
                ),
              );
            },
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox.shrink();
              return Positioned(
                bottom: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: scheme.secondary, shape: BoxShape.circle),
                ),
              );
            },
          ),
          eventLoader: (day) => _eventsForDay(day),
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: scheme.secondary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: scheme.secondary.withAlpha(60),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            weekendTextStyle: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
