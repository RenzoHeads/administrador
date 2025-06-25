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

  // Método para solicitar recuperación con token por email
  Future<void> requestPasswordRecovery(BuildContext context) async {
    print('DEBUG: Iniciando requestPasswordRecovery');
    print('DEBUG: Email ingresado: ${txtEmail.text}');

    mensaje.value = '';
    hayError.value = false;
    isLoading.value = true;

    if (txtEmail.text.isEmpty || !txtEmail.text.contains('@')) {
      print('DEBUG: Validación de email falló');
      _showError('Ingrese un correo válido');
      isLoading.value = false;
      return;
    }

    try {
      print('DEBUG: Llamando al servicio...');
      final response = await UsuarioService().requestPasswordRecovery(
        txtEmail.text,
      );

      print('DEBUG: Respuesta del servicio recibida');
      print('DEBUG: Response: $response');
      print('DEBUG: Status: ${response?.status}');
      print('DEBUG: Body: ${response?.body}');

      isLoading.value = false;

      if (response == null) {
        print('DEBUG: Response es null');
        _showError('Error de conexión con el servidor');
        return;
      }

      // Verificar diferentes códigos de estado
      switch (response.status) {
        case 200:
          print('DEBUG: Éxito - Status 200');
          mensaje.value =
              'Se ha enviado un correo con instrucciones para recuperar tu contraseña';
          hayError.value = false;

          await Future.delayed(const Duration(seconds: 2));

          if (context.mounted) {
            Navigator.pushNamed(
              context,
              '/reset-with-token',
              arguments: {'email': txtEmail.text},
            );
          }
          break;

        case 404:
          print('DEBUG: Status 404 - Correo no registrado');
          _showError('Correo no registrado');
          break;

        case 500:
          print('DEBUG: Status 500 - Error del servidor');
          _showError('Error interno del servidor');
          break;

        default:
          print('DEBUG: Status ${response.status} - Error: ${response.body}');
          _showError('Error: ${response.body}');
      }
    } catch (e) {
      print('DEBUG: Excepción capturada en controlador: $e');
      print('DEBUG: Tipo de excepción: ${e.runtimeType}');
      isLoading.value = false;
      _showError('Error inesperado: $e');
    }

    print('DEBUG: Finalizando requestPasswordRecovery');
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
