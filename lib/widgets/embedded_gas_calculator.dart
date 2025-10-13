// Widget para la calculadora embebida (EmbeddedGasCalculator)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmbeddedGasCalculator extends StatefulWidget {
  const EmbeddedGasCalculator({required this.litrosCtrl, required this.tasa, required this.loading, required this.onRefresh, super.key});
  final TextEditingController litrosCtrl;
  final double? tasa;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  State<EmbeddedGasCalculator> createState() => _EmbeddedGasCalculatorState();
}

class _EmbeddedGasCalculatorState extends State<EmbeddedGasCalculator> {
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
      if (widget.tasa != null) {
        totalBs = totalUsd * widget.tasa!; // conversión con BCV
      }
    }
    final NumberFormat fmtUsd = NumberFormat('#,##0.00', 'es_VE');
    final NumberFormat fmtBs = NumberFormat.currency(
      locale: 'es_VE',
      symbol: 'Bs',
      decimalDigits: 2,
    );
    final NumberFormat fmtTasa = NumberFormat('#,##0.00', 'es_VE');
    final scheme = Theme.of(context).colorScheme;
    final bool dense = MediaQuery.of(context).viewInsets.bottom > 0;
    final double vPad = dense ? 2 : 10;
    final double hPad = dense ? 8 : 14;
    final double titleFontSize = dense ? 13 : Theme.of(context).textTheme.titleMedium?.fontSize ?? 16;
    final double valueFontSize = dense ? 13 : Theme.of(context).textTheme.titleMedium?.fontSize ?? 16;
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(dense ? 14 : 20),
        color: scheme.surfaceContainerHighest.withAlpha((0.18 * 255).round()),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withAlpha((0.04 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use a Wrap to allow the header to flow into multiple lines on narrow widths
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: scheme.primary.withAlpha((0.13 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.local_gas_station, size: 20),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(
                  'Calculadora de Gasolina',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 36, maxWidth: 48),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
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
              ),
            ],
          ),
          const Divider(height: 18, thickness: 1, indent: 0, endIndent: 0),
          SizedBox(
            height: 48,
            child: TextField(
              controller: widget.litrosCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                fontSize: valueFontSize + 2,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 0,
                ),
                labelText: 'Litros',
                prefixIcon: const Icon(Icons.local_gas_station),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: scheme.primary.withAlpha((0.18 * 255).round()),
                  ),
                ),
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withAlpha((0.10 * 255).round()),
              ),
            ),
          ),
          SizedBox(height: dense ? 8 : 16),
          if (totalBs != null)
            Padding(
              padding: EdgeInsets.only(bottom: dense ? 2 : 6),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total en Bs:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: valueFontSize,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            fmtBs.format(totalBs),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: valueFontSize + 2,
                              color: scheme.primary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (totalUsd != null)
            Padding(
              padding: EdgeInsets.only(bottom: dense ? 2 : 6),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total en USD:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: valueFontSize,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '\$${fmtUsd.format(totalUsd)}',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: valueFontSize + 2,
                              color: scheme.primary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
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
                  Expanded(
                    child: Text(
                      'Tasa BCV: ${fmtTasa.format(widget.tasa)} Bs/USD',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
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
                  Expanded(
                    child: Text(
                      'No se pudo obtener la tasa. Reintenta.',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.error),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
