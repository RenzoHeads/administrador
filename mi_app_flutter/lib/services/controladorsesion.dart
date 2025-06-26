import 'package:get/get.dart';
import 'dart:convert';
import '../models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ControladorSesionUsuario extends GetxController {
  Rx<Usuario?> usuarioActual = Rx<Usuario?>(null);
  RxBool sesionIniciada = false.obs;

  @override
  void onInit() {
    super.onInit();
    verificarEstadoSesion();
  }

  // Iniciar sesión con JWT
  Future<void> iniciarSesion(
    int? id,
    String nombre,
    String contrasena,
    String email,
    String? foto,
    String? tokenFCM, {
    String? jwtToken,
  }) async {
    usuarioActual.value = Usuario(
      id: id,
      nombre: nombre,
      contrasena: contrasena,
      email: email,
      foto: foto,
      tokenFCM: tokenFCM,
    );
    sesionIniciada.value = true;

    // Guardar JWT token si se proporciona
    if (jwtToken != null && jwtToken.isNotEmpty) {
      await AuthService.saveJwtToken(jwtToken);
    }

    // Guardar en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (id != null) await prefs.setInt('idUsuario', id);
    await prefs.setString('nombre', nombre);
    await prefs.setString('contrasena', contrasena);
    await prefs.setString('email', email);
    await prefs.setString('foto', foto ?? '');
    await prefs.setString('tokenFCM', tokenFCM ?? '');
    await prefs.setBool('sesionActiva', true);

    // Alternativa: guardar objeto completo como JSON
    await prefs.setString(
      'usuarioData',
      jsonEncode(usuarioActual.value!.toJson()),
    );
  }

  Future<void> verificarEstadoSesion() async {
    final prefs = await SharedPreferences.getInstance();
    bool? sesionActiva = prefs.getBool('sesionActiva');

    // Verificar si hay token JWT válido
    bool hasJWT = await AuthService.hasValidToken();

    if (sesionActiva == true && hasJWT) {
      String? usuarioJson = prefs.getString('usuarioData');
      if (usuarioJson != null) {
        try {
          usuarioActual.value = Usuario.fromJson(usuarioJson);
          sesionIniciada.value = true;
        } catch (e) {
          print('Error al reconstruir usuario desde JSON: $e');
          // Si hay error, cerrar sesión
          await cerrarSesion();
        }
      }
    } else {
      // Si no hay token válido, cerrar sesión
      await cerrarSesion();
    }
  }

  //Metodo para actualizar el usuario
  Future<void> actualizarUsuario(Usuario usuario) async {
    usuarioActual.value = usuario;

    // Guardar en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuarioData', jsonEncode(usuario.toJson()));
  }

  // Obtener el usuario actual
  Usuario? obtenerUsuarioActual() {
    return usuarioActual.value;
  }

  // Obtener JWT token
  Future<String?> obtenerJwtToken() async {
    return await AuthService.getJwtToken();
  }

  // Verificar si la sesión es válida (con JWT)
  Future<bool> esSesionValida() async {
    return sesionIniciada.value && await AuthService.hasValidToken();
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    usuarioActual.value = null;
    sesionIniciada.value = false;

    // Eliminar JWT token
    await AuthService.removeJwtToken();

    // Borrar datos de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navegar a la página de inicio de sesión
    Get.offAllNamed('/sign-in');
  }
}
