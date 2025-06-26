import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import '../../models/service_http_response.dart';

import '../../models/usuario.dart';
import '../../services/controladorsesion.dart';
import '../../services/usuario_service.dart';
import '../principal/principal_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SignInController extends GetxController {
  TextEditingController txtUsuario = TextEditingController();
  TextEditingController txtContrasena = TextEditingController();
  RxString mensaje = ''.obs;
  RxBool enabled = true.obs;
  RxBool obscurePassword = true.obs; // Add this line
  UsuarioService usuarioService = UsuarioService();

  RxBool hayError = false.obs;
  final ControladorSesionUsuario controladorSesion =
      Get.find<ControladorSesionUsuario>();

  // Add this method
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Add this method for showing errors (used in _handleLogin)
  void showError(String message) {
    _showError(message);
  }

  void goToSignUp(BuildContext context) {
    if (enabled.value) {
      Navigator.pushNamed(context, '/sign-up');
    }
  }

  void goToResetPassword(BuildContext context) {
    if (enabled.value) {
      Navigator.pushNamed(context, '/reset-password');
    }
  }

  void goHome(BuildContext context) async {
    UsuarioService service = UsuarioService();
    String nombre = txtUsuario.text;
    String contrasena = txtContrasena.text;
    Usuario u = Usuario(nombre: nombre, contrasena: contrasena, email: '');

    // Hacer login y obtener el id del usuario
    ServiceHttpResponse? serviceReponse = await service.login(u);

    if (serviceReponse == null) {
      this.mensaje.value = 'No hay respuesta del servidor';
      this.hayError.value = true;
      Future.delayed(Duration(seconds: 3), () {
        this.mensaje.value = '';
      });
      return;
    }

    if (serviceReponse.status == 200) {
      this.mensaje.value = 'Usuario y contraseña válidos';
      this.hayError.value = false;
      Future.delayed(Duration(seconds: 3), () async {
        try {
          // Procesamos la respuesta
          Map<String, dynamic> responseData =
              serviceReponse.body is Map<String, dynamic>
                  ? serviceReponse.body
                  : json.decode(serviceReponse.body);

          print(
            'Respuesta del servidor: $responseData',
          ); // Debug          // Verificar que la respuesta sea exitosa
          if (responseData['success'] == true) {
            Map<String, dynamic> userData = responseData['user'];
            String? jwtToken = responseData['token'];

            print(
              '🎯 JWT Token extraído: ${jwtToken != null ? "Token presente (${jwtToken.length} chars)" : "Sin token"}',
            );

            // Crear usuario con los datos recibidos
            Usuario usuarioResponse = Usuario(
              id: userData['id'],
              nombre: userData['nombre'],
              email: userData['email'],
              contrasena: contrasena, // Usar la contraseña ingresada
            );

            // Obtener token FCM
            final tokenActual = await FirebaseMessaging.instance.getToken();

            // Actualizar token FCM si es necesario
            if (tokenActual != null && usuarioResponse.id != null) {
              await service.updateUserTokenFCM(
                usuarioResponse.id!,
                tokenActual,
              );
            }

            // Guardar la información del usuario en el controlador de sesión
            await controladorSesion.iniciarSesion(
              usuarioResponse.id,
              usuarioResponse.nombre,
              usuarioResponse.contrasena,
              usuarioResponse.email,
              usuarioResponse.foto,
              tokenActual,
              jwtToken: jwtToken,
            );

            // Navegar a la página de inicio
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => PrincipalPage(),
                settings: RouteSettings(arguments: usuarioResponse.toJson()),
              ),
              (Route<dynamic> route) => false,
            );
          } else {
            _showError(responseData['message'] ?? 'Error en el login');
          }
        } catch (e) {
          _showError('Error procesando la respuesta del servidor');
        }
      });
    } else {
      _showError(serviceReponse.body.toString());
    }
  }

  void _showError(String message) {
    this.mensaje.value = message;
    this.hayError.value = true;
    Future.delayed(Duration(seconds: 3), () {
      this.mensaje.value = '';
    });
  }

  void goReset(BuildContext context) async {
    Navigator.pushNamed(context, '/reset');
  }

  void goSignUp(BuildContext context) async {
    Navigator.pushNamed(context, '/sign-up');
  }
}
