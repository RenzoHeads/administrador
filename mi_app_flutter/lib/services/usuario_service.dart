import 'dart:convert';
import 'dart:io';
import '../../configs/contants.dart';
import '../../models/service_http_response.dart';
import 'package:http/http.dart' as http;
import '../../models/usuario.dart';
import 'auth_service.dart';

class UsuarioService {
  // Método login
  Future<ServiceHttpResponse?> login(Usuario usuario) async {
    ServiceHttpResponse serviceResponse = ServiceHttpResponse();
    final url = Uri.parse('${BASE_URL}usuario/validar');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'nombre': usuario.nombre,
          'contrasena': usuario.contrasena,
        }),
      );

      serviceResponse.status = response.statusCode;
      serviceResponse.body = response.body;
    } catch (e) {
      print("Error: $e");
      serviceResponse.status = 500;
      serviceResponse.body = 'Ocurrió un error al comunicarse con el servidor';
    }

    return serviceResponse;
  }

  //Obtener usuario por id
  Future<ServiceHttpResponse?> getUsuarioById(int id) async {
    ServiceHttpResponse serviceResponse = ServiceHttpResponse();
    final url = Uri.parse('${BASE_URL}usuario/$id');

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(url, headers: headers);

      serviceResponse.status = response.statusCode;
      serviceResponse.body = response.body;

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      print("Error: $e");
      serviceResponse.status = 500;
      serviceResponse.body = 'Ocurrió un error al obtener el usuario';
    }

    return serviceResponse;
  }

  // Método signUp
  Future<ServiceHttpResponse?> signUp(
    String nombre,
    String contrasena,
    String email,
  ) async {
    ServiceHttpResponse serviceResponse = ServiceHttpResponse();
    final url = Uri.parse('${BASE_URL}usuario/crear-usuario');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: {'nombre': nombre, 'contrasena': contrasena, 'email': email},
      );

      serviceResponse.status = response.statusCode;
      serviceResponse.body = response.body;
    } catch (e) {
      print('Error: $e');
      serviceResponse.status = 503;
      serviceResponse.body = 'Ocurrió un error al comunicarse con el servidor';
    }

    return serviceResponse;
  }

  // Eliminar usuario
  Future<ServiceHttpResponse?> deleteUsuario(int id) async {
    ServiceHttpResponse serviceResponse = ServiceHttpResponse();
    final url = Uri.parse('${BASE_URL}usuario/eliminar/$id');

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.delete(url, headers: headers);

      serviceResponse.status = response.statusCode;
      serviceResponse.body = response.body;

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      print('Error: $e');
      serviceResponse.status = 500;
      serviceResponse.body = 'Ocurrió un error al eliminar el usuario';
    }

    return serviceResponse;
  }

  // Verificar email
  Future<ServiceHttpResponse?> verifyEmail(String email) async {
    ServiceHttpResponse serviceResponse = ServiceHttpResponse();
    final url = Uri.parse('${BASE_URL}usuario/verificar-correo/$email');

    try {
      final response = await http.get(url);
      serviceResponse.status = response.statusCode;
      serviceResponse.body = response.body;
    } catch (e) {
      print('Error: $e');
      serviceResponse.status = 500;
      serviceResponse.body = 'Error al verificar el correo';
    }

    return serviceResponse;
  }

  // Solicitar recuperación de contraseña
  Future<ServiceHttpResponse?> requestPasswordRecovery(String email) async {
    ServiceHttpResponse serviceResponse = ServiceHttpResponse();
    final url = Uri.parse('${BASE_URL}usuario/solicitar-recuperacion');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      serviceResponse.status = response.statusCode;
      serviceResponse.body = response.body;
    } catch (e) {
      print('Error: $e');
      serviceResponse.status = 500;
      serviceResponse.body = 'Error al solicitar recuperación de contraseña';
    }

    return serviceResponse;
  }

  // Restablecer contraseña con token
  Future<ServiceHttpResponse?> resetPasswordWithToken(
    String token,
    String newPassword,
  ) async {
    ServiceHttpResponse serviceResponse = ServiceHttpResponse();
    final url = Uri.parse('${BASE_URL}usuario/restablecer-contrasena');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'reset_token': token, 'contrasena': newPassword}),
      );

      serviceResponse.status = response.statusCode;
      serviceResponse.body = response.body;
    } catch (e) {
      print('Error: $e');
      serviceResponse.status = 500;
      serviceResponse.body = 'Error al restablecer contraseña';
    }

    return serviceResponse;
  }

  // Subir foto de perfil
  Future<ServiceHttpResponse?> uploadProfilePhoto(int id, File photo) async {
    ServiceHttpResponse serviceResponse = ServiceHttpResponse();
    final url = Uri.parse('${BASE_URL}usuario/$id/foto-perfil');

    try {
      var request = http.MultipartRequest('POST', url);

      // Agregar headers JWT
      final token = await AuthService.getJwtToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath('file', photo.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      serviceResponse.status = response.statusCode;
      serviceResponse.body = response.body;

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      print('Error: $e');
      serviceResponse.status = 500;
      serviceResponse.body = 'Error al subir la foto de perfil';
    }

    return serviceResponse;
  }

  // Obtener URL de la foto de perfil
  Future<ServiceHttpResponse?> getProfilePhotoUrl(int id) async {
    ServiceHttpResponse serviceResponse = ServiceHttpResponse();
    final url = Uri.parse('${BASE_URL}usuario/$id/foto-perfil');

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(url, headers: headers);

      serviceResponse.status = response.statusCode;
      serviceResponse.body = response.body;

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      serviceResponse.status = 500;
      serviceResponse.body = 'Error al obtener la URL de la foto de perfil';
    }

    return serviceResponse;
  }

  // Eliminar foto de perfil
  Future<ServiceHttpResponse?> deleteProfilePhoto(int id) async {
    ServiceHttpResponse serviceResponse = ServiceHttpResponse();
    final url = Uri.parse('${BASE_URL}usuario/$id/foto-perfil');

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.delete(url, headers: headers);

      serviceResponse.status = response.statusCode;
      serviceResponse.body = response.body;

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      print('Error: $e');
      serviceResponse.status = 500;
      serviceResponse.body = 'Error al eliminar la foto de perfil';
    }

    return serviceResponse;
  }

  // Actualizar nombre de usuario
  Future<ServiceHttpResponse?> updateUserName(int id, String newName) async {
    ServiceHttpResponse serviceResponse = ServiceHttpResponse();
    final url = Uri.parse('${BASE_URL}usuario/actualizar-nombre/$id');
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode({'nombre': newName}),
      );

      serviceResponse.status = response.statusCode;
      serviceResponse.body = response.body;

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      print('Error: $e');
      serviceResponse.status = 500;
      serviceResponse.body = 'Error al actualizar el nombre de usuario';
    }

    return serviceResponse;
  }

  // Actualizar correo de usuario
  Future<ServiceHttpResponse?> updateUserEmail(int id, String newEmail) async {
    ServiceHttpResponse serviceResponse = ServiceHttpResponse();
    final url = Uri.parse('${BASE_URL}usuario/actualizar-correo/$id');

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode({'email': newEmail}),
      );

      serviceResponse.status = response.statusCode;
      serviceResponse.body = response.body;

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      print('Error: $e');
      serviceResponse.status = 500;
      serviceResponse.body = 'Error al actualizar el correo de usuario';
    }

    return serviceResponse;
  }

  //asignar token fcm
  Future<ServiceHttpResponse?> updateUserTokenFCM(
    int id,
    String tokenFCM,
  ) async {
    ServiceHttpResponse serviceResponse = ServiceHttpResponse();
    final url = Uri.parse('${BASE_URL}usuario/$id/token-fcm');

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({'token_fcm': tokenFCM}),
      );

      serviceResponse.status = response.statusCode;
      serviceResponse.body = response.body;

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      print('Error: $e');
      serviceResponse.status = 500;
      serviceResponse.body = 'Error al actualizar el token FCM del usuario';
    }

    return serviceResponse;
  }
}
