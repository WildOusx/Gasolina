// Widget para los chips de selección de placa (PlateGroupChips)

import 'package:flutter/material.dart';

class PlateGroupChips extends StatelessWidget {
  const PlateGroupChips({required this.selectedDigit, required this.onChanged, super.key});

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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double baseFontSize = screenWidth < 400 ? 10 : 12;
    final TextStyle chipTextStyle = Theme.of(context).textTheme.labelMedium!.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: baseFontSize,
          letterSpacing: 0.06,
        );
    final EdgeInsetsGeometry chipPadding = screenWidth < 400
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    return Center(
      child: Wrap(
        spacing: 6,
        runSpacing: 2,
        children: _labels.entries.map((MapEntry<int, String> e) {
          final int repDigit = e.key;
          final String label = e.value;
          final bool selected = _isInGroup(selectedDigit, repDigit);
          return Tooltip(
            message: 'Grupo $label',
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48),
              child: Semantics(
                button: true,
                label: 'Seleccionar grupo $label',
                toggled: selected,
                child: ChoiceChip(
                  label: Padding(
                    padding: chipPadding,
                    child: Text(
                      label,
                      style: chipTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  selected: selected,
                  selectedColor: scheme.primaryContainer,
                  backgroundColor: scheme.surfaceContainerHighest.withAlpha((0.10 * 255).round()),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                    side: selected
                        ? BorderSide(color: scheme.primary, width: 1)
                        : BorderSide(
                            color: scheme.outline.withAlpha((0.12 * 255).round()),
                            width: 1,
                          ),
                  ),
                  elevation: selected ? 1 : 0,
                  shadowColor: scheme.primary.withAlpha((0.06 * 255).round()),
                  onSelected: (bool s) {
                    if (s) onChanged(repDigit);
                  },
                  showCheckmark: false,
                  visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
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
