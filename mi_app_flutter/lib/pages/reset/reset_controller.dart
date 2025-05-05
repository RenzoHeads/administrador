import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/usuario_service.dart';

class ResetController extends GetxController {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtNewPassword = TextEditingController();
  RxString mensaje = ''.obs;
  RxBool hayError = false.obs;
  RxInt step = 1.obs; // 1: Email step, 2: Password step
  RxBool isLoading = false.obs; // Añadido para manejar estados de carga

  void goSignIn(BuildContext context) =>
      Navigator.pushNamed(context, '/sign-in');
  void goSignUp(BuildContext context) =>
      Navigator.pushNamed(context, '/sign-up');

  Future<void> checkEmail(BuildContext context) async {
    mensaje.value = '';
    hayError.value = false;
    isLoading.value = true;

    // Validación básica de email
    if (txtEmail.text.isEmpty || !txtEmail.text.contains('@')) {
      _showError('Ingrese un correo válido');
      isLoading.value = false;
      return;
    }

    final response = await UsuarioService().verifyEmail(txtEmail.text);
    isLoading.value = false;

    if (response == null) {
      _showError('Error de conexión con el servidor');
      return;
    }

    if (response.status == 200) {
      step.value = 2;
    } else if (response.status == 404) {
      _showError('Correo no registrado');
    } else {
      _showError('Error: ${response.body}');
    }
  }

  Future<void> updatePassword(BuildContext context) async {
    mensaje.value = '';
    hayError.value = false;
    isLoading.value = true;

    // Validación de contraseña
    if (txtNewPassword.text.length < 8) {
      _showError('La contraseña debe tener al menos 8 caracteres');
      isLoading.value = false;
      return;
    }

    final response = await UsuarioService().updatePasswordByEmail(
      txtEmail.text,
      txtNewPassword.text,
    );

    isLoading.value = false;

    if (response == null) {
      _showError('Error de conexión con el servidor');
      return;
    }

    if (response.status == 200) {
      mensaje.value = '¡Contraseña actualizada exitosamente!';
      hayError.value = false;
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushNamed(context, '/sign-in');
    } else {
      _showError('Error: ${response.body}');
    }
  }

  // Método para solicitar recuperación con token por email
  Future<void> requestPasswordRecovery(BuildContext context) async {
    mensaje.value = '';
    hayError.value = false;
    isLoading.value = true;

    if (txtEmail.text.isEmpty || !txtEmail.text.contains('@')) {
      _showError('Ingrese un correo válido');
      isLoading.value = false;
      return;
    }

    final response = await UsuarioService().requestPasswordRecovery(
      txtEmail.text,
    );
    isLoading.value = false;

    if (response == null) {
      _showError('Error de conexión con el servidor');
      return;
    }

    if (response.status == 200) {
      mensaje.value =
          'Se ha enviado un correo con instrucciones para recuperar tu contraseña';
      hayError.value = false;
      //Redirigir a la pagina de reset page token
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushNamed(
        context,
        '/reset-with-token',
        arguments: {'email': txtEmail.text},
      );
    } else if (response.status == 404) {
      _showError('Correo no registrado');
    } else {
      _showError('Error: ${response.body}');
    }
  }

  void _showError(String message) {
    mensaje.value = message;
    hayError.value = true;
    Future.delayed(const Duration(seconds: 3), () {
      if (mensaje.value == message) {
        // Solo limpiar si sigue siendo el mismo mensaje
        mensaje.value = '';
      }
    });
  }
}
