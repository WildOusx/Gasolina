import 'package:flutter/material.dart';
import '../utils/quick_action_bus.dart';
import '../widgets/chip_info.dart';

/// Muestra un modal con información del día. Reemplaza `_showDayDetails` de `lib/main.dart`.
void showDayDetails(
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
              if (isToday) const ChipInfo(Icons.today, 'Hoy'),
              if (allowed) const ChipInfo(Icons.check_circle, 'Permitido'),
              if (isWeekend) const ChipInfo(Icons.weekend, 'Fin de semana'),
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
                  QuickActionBus.instance.triggerToday();
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
