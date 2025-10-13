// Widgets relacionados con el calendario: CalendarGrid, CalendarSection, DowCell, OtherMonthDayCell, TodayDot

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/show_day_details.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    required this.year,
    required this.month,
    required this.allowedDays,
    this.baseHeightFactor = 0.95,
    super.key,
  });

  final int year;
  final int month;
  final Set<int> allowedDays;
  final double baseHeightFactor; // altura basada en ancho, sujeta a recálculo por alto disponible

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
        final double safeAvailableForCells = availableForCellsRaw > 0 ? availableForCellsRaw : 0;
        final double maxPerCell = weeks > 0 ? safeAvailableForCells / weeks : safeAvailableForCells;
        double cellHeight = idealCellHeight;
        if (maxPerCell > 0 && cellHeight > maxPerCell) {
          cellHeight = maxPerCell;
        }
        const double minLegible = 16;
        if (cellHeight < minLegible && maxPerCell > 0) {
          cellHeight = maxPerCell;
        }
        final double aspectRatio = cellWidth / (cellHeight <= 0 ? 1 : cellHeight);
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
        final bool isCurrentMonth = (today.year == year && today.month == month);
        final ColorScheme scheme = Theme.of(context).colorScheme;

        Widget calendarContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withAlpha((0.10 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  DowCell(showFullDow ? 'Lunes' : 'Lun'),
                  DowCell(showFullDow ? 'Martes' : 'Mar'),
                  DowCell(showFullDow ? 'Miércoles' : 'Mie'),
                  DowCell(showFullDow ? 'Jueves' : 'Jue'),
                  DowCell(showFullDow ? 'Viernes' : 'Vie'),
                  DowCell(showFullDow ? 'Sábado' : 'Sáb', isWeekend: true),
                  DowCell(showFullDow ? 'Domingo' : 'Dom', isWeekend: true),
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
                    final bool isWknd = (weekday == DateTime.saturday || weekday == DateTime.sunday);
                    return OtherMonthDayCell(day: day, isWeekend: isWknd);
                  }
                  if (index >= startOffset + daysInMonth) {
                    final int day = index - (startOffset + daysInMonth) + 1;
                    final int weekday = (index % 7) + 1;
                    final bool isWknd = (weekday == DateTime.saturday || weekday == DateTime.sunday);
                    return OtherMonthDayCell(day: day, isWeekend: isWknd);
                  }
                  final int day = index - startOffset + 1;
                  final bool allowed = allowedDays.contains(day);
                  final bool isToday = isCurrentMonth && today.day == day;
                  final int weekday = DateTime(year, month, day).weekday;
                  final bool isWeekend = (weekday == DateTime.saturday || weekday == DateTime.sunday);
                  final Color bg = allowed
                      ? scheme.primaryContainer
                      : (isWeekend
                          ? scheme.surfaceContainerHighest.withAlpha((0.18 * 255).round())
                          : scheme.surfaceContainerHighest.withAlpha((0.28 * 255).round()));
                  final Color fg = allowed
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant.withAlpha((0.85 * 255).round());
                  return Semantics(
                    label: 'Día $day${isToday ? ', hoy' : ''}${allowed ? ', permitido' : ''}${isWeekend ? ', fin de semana' : ''}',
                    selected: isToday,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        splashColor: scheme.primary.withAlpha((0.10 * 255).round()),
                        highlightColor: scheme.primary.withAlpha((0.08 * 255).round()),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          showDayDetails(context, day, allowed, isWeekend, isToday);
                        },
                        child: Stack(
                          children: <Widget>[
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(isToday ? 16 : 14),
                                border: isToday
                                    ? Border.all(
                                        color: scheme.secondary,
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: isToday
                                    ? <BoxShadow>[
                                        BoxShadow(
                                          color: scheme.secondary.withAlpha((0.18 * 255).round()),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              constraints: BoxConstraints(minHeight: minCellSide, minWidth: 40),
                              alignment: Alignment.center,
                              child: Text(
                                day.toString(),
                                style: TextStyle(
                                  color: fg,
                                  fontWeight: allowed ? FontWeight.w700 : FontWeight.normal,
                                  fontSize: dayFontSize ?? 13,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            if (isToday) Positioned(top: 6, right: 6, child: TodayDot()),
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
class CalendarSection extends StatelessWidget {
  const CalendarSection({
    required this.pairLabel,
    required this.year,
    required this.month,
    required this.days,
    super.key,
  });
  final String pairLabel;
  final int year;
  final int month;
  final List<int> days;

  @override
  Widget build(BuildContext context) {
    // Eliminado: variable local keyboardOpen no usada
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
        // Si el espacio vertical es muy pequeño o el teclado está abierto, solo muestra el encabezado
        if (keyboardOpen || constraints.maxHeight < 120) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Placa: $pairLabel',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Placa: $pairLabel',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Flexible(
                child: CalendarGrid(
                  year: year,
                  month: month,
                  allowedDays: Set<int>.from(days),
                  baseHeightFactor: 0.9,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class OtherMonthDayCell extends StatelessWidget {
  const OtherMonthDayCell({required this.day, this.isWeekend = false, super.key});
  final int day;
  final bool isWeekend;
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        day.toString(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isWeekend ? scheme.onSurfaceVariant : null,
        ),
      ),
    );
  }
}

class DowCell extends StatelessWidget {
  const DowCell(this.label, {this.isWeekend = false, super.key});
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
            color: isWeekend ? Theme.of(context).colorScheme.onSurfaceVariant : null,
          ),
        ),
      ),
    );
  }
}

class TodayDot extends StatelessWidget {
  const TodayDot({super.key});
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
            color: scheme.secondary.withAlpha((0.25 * 255).round()),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
