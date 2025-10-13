import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Claves de SharedPreferences usadas para cache
const String _kCachedRateKey = 'bcv_cached_rate';
const String _kCachedRateTsKey = 'bcv_cached_rate_ts';

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
    // Solo intento 4: Nueva API pública bcvapi.tech
    const String bcvapi = 'https://bcvapi.tech/api/v1/dolar';
    try {
      final http.Response resp = await http
          .get(Uri.parse(bcvapi))
          .timeout(_timeout);
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
    // Si falla la red, intentar devolver valor cacheado
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final double? cached = prefs.getDouble(_kCachedRateKey);
      if (cached != null && cached > 0) return cached;
    } catch (_) {
      // ignore prefs errors
    }
    return null;
  }

  /// Guarda en cache la tasa y marca la hora (epoch seconds)
  static Future<void> cacheUsdRate(double rate) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kCachedRateKey, rate);
      await prefs.setInt(_kCachedRateTsKey, DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);
    } catch (_) {
      // ignore
    }
  }

  /// Obtiene la edad del cache en segundos; devuelve null si no hay cache
  static Future<int?> cachedRateAgeSeconds() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? ts = prefs.getInt(_kCachedRateTsKey);
      if (ts == null) return null;
      final int now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      return now - ts;
    } catch (_) {
      return null;
    }
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
