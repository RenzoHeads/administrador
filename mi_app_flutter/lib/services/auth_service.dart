import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Servicio base para manejo de autenticación JWT
class AuthService {
  static const String _JWT_KEY = 'jwt_token';

  /// Obtiene el token JWT almacenado localmente
  static Future<String?> getJwtToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_JWT_KEY);
      return token;
    } catch (e) {
      print('Error al obtener JWT token: $e');
      return null;
    }
  }

  /// Guarda el token JWT localmente
  static Future<void> saveJwtToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_JWT_KEY, token);
    } catch (e) {
      print('Error al guardar JWT token: $e');
    }
  }

  /// Elimina el token JWT almacenado
  static Future<void> removeJwtToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_JWT_KEY);
    } catch (e) {
      print('Error al eliminar JWT token: $e');
    }
  }

  /// Obtiene los headers con autorización JWT para las peticiones HTTP
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getJwtToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Verifica si hay un token JWT válido
  static Future<bool> hasValidToken() async {
    final token = await getJwtToken();
    return token != null && token.isNotEmpty;
  }

  /// Maneja respuestas de autenticación no autorizada (401)
  static void handleUnauthorized() {
    // Eliminar token inválido
    removeJwtToken();

    // Redirigir a login si estamos usando GetX
    if (Get.isRegistered()) {
      Get.offAllNamed('/sign-in');
    }
  }

  /// Interceptor para manejar respuestas HTTP con errores de autenticación
  static void handleHttpResponse(http.Response response) {
    if (response.statusCode == 401) {
      handleUnauthorized();
    }
  }
}
