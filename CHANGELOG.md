### [1.0.0] - 2025-10-12

### Refactorización

- Se dividió el archivo grande `lib/main.dart` en varios archivos para mejorar la legibilidad y mantenibilidad:
  - `lib/screens/gas_calendar_screen.dart` - pantalla principal `GasCalendarScreen` y su lógica.
  - `lib/widgets/calendar_grid.dart` - renderizado del calendario: `CalendarGrid`, `CalendarSection`, `OtherMonthDayCell`, `DowCell`, `TodayDot`.
  - `lib/widgets/plate_group_chips.dart` - widget `PlateGroupChips`.
  - `lib/widgets/embedded_gas_calculator.dart` - calculadora embebida y su estado.
  - `lib/widgets/chip_info.dart` - pequeño helper para chips usado en modales.
  - `lib/utils/quick_action_bus.dart` - singleton para quick-actions.
  - `lib/utils/show_day_details.dart` - helper para modal de detalles por día.
- Se simplificó `lib/main.dart` para inicializar la app y establecer `GasCalendarScreen` como la ruta principal.

### Diseño y responsividad

- Mejoras en el encabezado de `EmbeddedGasCalculator`:
  - Reemplazado el `Row` inflexible por un `Wrap` y se restringió el ancho del título para evitar overflow en pantallas estrechas.
  - Las filas de totales y la tasa usan ahora `Expanded`/`Flexible` y `TextOverflow.ellipsis` para evitar desbordes horizontales.
- Reemplazado el `SizedBox(height: 320)` fijo en `CalendarGrid` por un cálculo dinámico de `minHeight` basado en:
  - número de semanas en el mes
  - altura mínima por celda
  - altura del encabezado y DOW
    Esto mejora el comportamiento en vistas con muy poca altura y evita recortes visuales.
- `GasCalendarScreen` usa `LayoutBuilder` con un breakpoint (`isWide = 700px`) para alternar entre layout horizontal (dos columnas) y vertical.
- `PlateGroupChips` usa `Wrap` y adapta el tamaño de fuente y padding según el ancho de pantalla.

### Tests

- Se añadieron tests para reforzar el layout y prevenir regresiones:
  - `test/calendar_grid_test.dart` (existente)
  - `test/embedded_gas_calculator_test.dart` (existente)
  - `test/plate_group_chips_test.dart` (existente)
  - `test/responsiveness_test.dart` (nuevo): prueba `EmbeddedGasCalculator` y `PlateGroupChips` en anchos estrechos y asegura que no haya excepciones de layout.
- Todos los tests pasan localmente:
  - `flutter analyze` → Sin issues.
  - `flutter test --reporter expanded` → Todos los tests pasaron (6/6) el 2025-10-12.

### Miscelánea

- Pequeñas mejoras de UX y consistencia visual (uso de `colorScheme`, estilos de contenedores).
- `lib/widgets/embedded_gas_calculator.dart` ahora usa `IconButton` con constraints y `visualDensity` compacto.

## Verificación

Comandos para reproducir la verificación local:

```powershell
flutter pub get
flutter analyze
flutter test --reporter expanded
```

## Archivos modificados (resumen)

- lib/main.dart
- lib/screens/gas_calendar_screen.dart
- lib/widgets/calendar_grid.dart
- lib/widgets/plate_group_chips.dart
- lib/widgets/embedded_gas_calculator.dart
- lib/widgets/chip_info.dart
- lib/utils/quick_action_bus.dart
- lib/utils/show_day_details.dart
- test/responsiveness_test.dart (nuevo)

## Próximos pasos recomendados

- Añadir tests de accesibilidad: textScale extremos, teclado abierto (`viewInsets`) y landscape en teléfonos estrechos.
- Considerar exportadores (barrel files) para `lib/widgets` para imports más limpios.
- Ejecutar `flutter pub upgrade` para actualizar dependencias y resolver posibles incompatibilidades.

---
