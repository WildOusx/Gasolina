import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio simple para obtener la tasa USD/BS del Banco Central de Venezuela.
/// Fuente: usa una API pública ligera que extrae el valor del BCV.
///
/// NOTA: Si la fuente cambia o no está disponible, devolvemos `null` y la UI
/// puede mostrar un mensaje y permitir reintentos manuales. Se encapsula aquí
/// para poder reemplazar la fuente en un solo sitio en el futuro.
class BcvService {
  static const Duration _timeout = Duration(seconds: 8);

  /// Intenta obtener la tasa de cambio oficial (USD -> Bs). Devuelve `null`
  /// cuando no está disponible o hay error de red.
  static Future<double?> fetchUsdRate() async {
    // Intento 0: página oficial BCV (lo más exacto). Se extrae con RegExp.
    const String official = 'https://www.bcv.org.ve/glosario/cambio-oficial';
    try {
      final http.Response resp = await http
          .get(
            Uri.parse(official),
            headers: const {
              'User-Agent': 'Mozilla/5.0 (Flutter; Dart) GasolinaApp/1.0',
              'Accept': 'text/html,application/xhtml+xml',
            },
          )
          .timeout(_timeout);
      if (resp.statusCode == 200) {
        final String html = resp.body;
        // Buscar el bloque del sidebar que lista monedas y su valor.
        // Patrón: USD 183,13690000 (puede variar en separadores)
        final RegExp re = RegExp(
          r'USD[^0-9]*([0-9][0-9\.,]*)',
          caseSensitive: false,
        );
        final RegExpMatch? m = re.firstMatch(html);
        if (m != null && m.groupCount >= 1) {
          final String raw = m.group(1)!;
          final double? p = _parseToDouble(raw);
          if (p != null && p > 0) return p;
        }
      }
    } catch (_) {
      // ignorar errores de red/scrape
    }

    // Intento 1: API ligera de bcventrada (comunidad) que refleja el BCV.
    // Ejemplos posibles:
    // - https://pydolarve.org/api/v1/dollar?page=bcv
    // - https://pydolarve.org/api/v1/dollar/latest (con filters)
    // Para robustez, usamos la primera y contemplamos estructura flexible.
    const String url = 'https://pydolarve.org/api/v1/dollar?page=bcv';
    try {
      final http.Response resp = await http
          .get(Uri.parse(url))
          .timeout(_timeout);
      if (resp.statusCode == 200) {
        final dynamic data = json.decode(resp.body);
        // Estructuras posibles: { 'monitors': { 'bcv': { 'price': '36.45' } } } o
        // [{ 'dollar': 'bcv', 'price': 36.45 }, ...]
        if (data is Map<String, dynamic>) {
          final dynamic monitors = data['monitors'];
          if (monitors is Map<String, dynamic>) {
            final dynamic bcv = monitors['bcv'];
            if (bcv is Map<String, dynamic>) {
              final dynamic price = bcv['price'];
              final double? p = _parseToDouble(price);
              if (p != null && p > 0) return p;
            }
          }
        }
        if (data is List) {
          for (final dynamic item in data) {
            if (item is Map<String, dynamic>) {
              final String? name = item['dollar']?.toString();
              if (name != null && name.toLowerCase().contains('bcv')) {
                final double? p = _parseToDouble(item['price']);
                if (p != null && p > 0) return p;
              }
            }
          }
        }
      }
    } catch (_) {
      // ignore network errors
    }

    // Intento 2 (fallback): otra ruta de la misma API.
    const String alt = 'https://pydolarve.org/api/v1/dollar/latest';
    try {
      final http.Response resp = await http
          .get(Uri.parse(alt))
          .timeout(_timeout);
      if (resp.statusCode == 200) {
        final dynamic data = json.decode(resp.body);
        if (data is List) {
          for (final dynamic item in data) {
            if (item is Map<String, dynamic>) {
              final String? name = item['dollar']?.toString();
              if (name != null && name.toLowerCase().contains('bcv')) {
                final double? p = _parseToDouble(item['price']);
                if (p != null && p > 0) return p;
              }
            }
          }
        }
      }
    } catch (_) {
      // ignore network errors
    }

    // Intento 3: API alternativa de DolarToday
    const String dolartoday = 'https://s3.amazonaws.com/dolartoday/data.json';
    try {
      final http.Response resp = await http
          .get(Uri.parse(dolartoday))
          .timeout(_timeout);
      if (resp.statusCode == 200) {
        final dynamic data = json.decode(resp.body);
        // La tasa BCV suele estar en data['USD']['promedio_real']
        if (data is Map<String, dynamic>) {
          final dynamic usd = data['USD'];
          if (usd is Map<String, dynamic>) {
            final dynamic bcv = usd['promedio_real'];
            final double? p = _parseToDouble(bcv);
            if (p != null && p > 0) return p;
          }
        }
      }
    } catch (_) {
      // ignore network errors
    }

    // Intento 4: Nueva API pública bcvapi.tech
    const String bcvapi = 'https://bcvapi.tech/api/v1/dolar';
    try {
      final http.Response resp = await http.get(Uri.parse(bcvapi)).timeout(_timeout);
      if (resp.statusCode == 200) {
        final dynamic data = json.decode(resp.body);
        if (data is Map<String, dynamic> && data.containsKey('tasa')) {
          final double? p = _parseToDouble(data['tasa']);
          if (p != null && p > 0) return p;
        }
      }
    } catch (_) {
      // ignore network errors
    }
    return null;
  }

  static double? _parseToDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      final String s = v.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(s) ?? double.tryParse(v);
    }
    return null;
  }
}
