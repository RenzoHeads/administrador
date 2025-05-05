import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../models/service_http_response.dart';
import '../../services/usuario_service.dart';

class SignUpController extends GetxController {
  TextEditingController txtUsuario = TextEditingController();
  // Email is now required for the API
  TextEditingController txtCorreo = TextEditingController();
  TextEditingController txtContrasenia = TextEditingController();
  TextEditingController txtContrasenia2 = TextEditingController();
  UsuarioService usuarioService = UsuarioService();
  RxBool enabled = true.obs;
  RxString mensaje = ''.obs;

  void goToSignIn(BuildContext context) {
    if (enabled.value) {
      Navigator.pushNamed(context, '/sign-in');
    }
  }

  void goToResetPassword(BuildContext context) {
    if (enabled.value) {
      Navigator.pushNamed(context, '/reset-password');
    }
  }

  Future<void> signUp(BuildContext context) async {
    if (enabled.value) {
      enabled.value = false;
      String usuario = txtUsuario.text;
      String email = txtCorreo.text;
      String contrasenia = txtContrasenia.text;
      String contrasenia2 = txtContrasenia2.text;

      if (contrasenia != contrasenia2) {
        mensaje.value = 'Contraseñas no coinciden';
        Future.delayed(Duration(seconds: 3), () {
          mensaje.value = '';
          enabled.value = true;
        });
      } else if (email.isEmpty) {
        mensaje.value = 'El correo electrónico es requerido';
        Future.delayed(Duration(seconds: 3), () {
          mensaje.value = '';
          enabled.value = true;
        });
      } else {
        ServiceHttpResponse? response = await usuarioService.signUp(
          usuario,
          contrasenia,
          email,
        );

        if (response != null) {
          if (response.status == 200) {
            mensaje.value = 'Usuario Creado';
            Future.delayed(Duration(seconds: 3), () {
              mensaje.value = '';
              enabled.value = true;
              goToSignIn(context);
            });
          } else {
            enabled.value = true;
            mensaje.value = response.body;
          }
        } else {
          enabled.value = true;
          mensaje.value = 'No hay respuesta del servidor';
        }
      }
    }
  }
}
