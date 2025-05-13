import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import '../../models/service_http_response.dart';
import '../../models/index.dart';
import '../../services/controladorsesion.dart';
import '../../services/usuario_service.dart';
import '../principal/principal_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SignInController extends GetxController {
  TextEditingController txtUsuario = TextEditingController();
  TextEditingController txtContrasena = TextEditingController();
  RxString mensaje = ''.obs;
  RxBool enabled = true.obs;
  UsuarioService usuarioService = UsuarioService();

  RxBool hayError = false.obs;
  final ControladorSesionUsuario controladorSesion =
      Get.find<ControladorSesionUsuario>();
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
    print('estoy en el controlador');
    UsuarioService service = UsuarioService();
    String usuario = txtUsuario.text;
    String contrasena = txtContrasena.text;
    Usuario u = Usuario(nombre: usuario, contrasena: contrasena, email: '');

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
          int usuarioId =
              serviceReponse.body is Map<String, dynamic>
                  ? serviceReponse.body['id'] ?? -1
                  : json.decode(serviceReponse.body)['id'] ?? -1;

          // Si obtenemos el id, hacemos la segunda llamada para obtener los datos completos del usuario
          if (usuarioId != -1) {
            ServiceHttpResponse? userDetailsResponse = await service
                .getUsuarioById(usuarioId);
            if (userDetailsResponse != null &&
                userDetailsResponse.status == 200) {
              // Mapear los detalles del usuario
              var userMap =
                  userDetailsResponse.body is Map<String, dynamic>
                      ? userDetailsResponse.body
                      : json.decode(userDetailsResponse.body);

              Usuario usuarioResponse = Usuario.fromMap(userMap);

              final tokenActual = await FirebaseMessaging.instance.getToken();
              String tokenGuardado = usuarioResponse.tokenFCM ?? '';

              if (tokenActual != null && tokenActual != tokenGuardado) {
                await service.updateUserTokenFCM(usuarioId, tokenActual);
                tokenGuardado = tokenActual;
              }

              // Guardar la información del usuario en el controlador de sesión
              controladorSesion.usuarioActual.value = usuarioResponse;

              controladorSesion.sesionIniciada.value = true;
              controladorSesion.iniciarSesion(
                usuarioResponse.id,
                usuarioResponse.nombre,
                usuarioResponse.contrasena,
                usuarioResponse.email,
                usuarioResponse.foto,
                tokenGuardado,
              );

              // Navegar a la página de inicio
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder:
                      (context) =>
                          PrincipalPage(), // Cambia a tu página de inicio
                  settings: RouteSettings(arguments: usuarioResponse.toJson()),
                ),
                (Route<dynamic> route) => false,
              );
            } else {
              _showError('No se encontraron los datos del usuario');
            }
          } else {
            _showError('No se pudo obtener el id del usuario');
          }
        } catch (e) {
          print('Error al procesar la respuesta: $e');
          _showError('Error procesando la respuesta');
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
