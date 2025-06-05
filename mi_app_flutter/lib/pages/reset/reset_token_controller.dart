import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/usuario_service.dart';

class ResetTokenController extends GetxController {
  final txtToken = TextEditingController();
  final txtNewPassword = TextEditingController();
  final txtConfirmPassword = TextEditingController();
  final mensaje = ''.obs;
  final hayError = false.obs;
  final isLoading = false.obs;

  Future<void> resetPassword(BuildContext context) async {
    _resetMessages();
    isLoading.value = true;

    if (!_validateInputs()) {
      isLoading.value = false;
      return;
    }

    try {
      final response = await UsuarioService().resetPasswordWithToken(
        txtToken.text.trim(),
        txtNewPassword.text,
      );

      isLoading.value = false;

      if (response == null) {
        _showError('Error de conexión con el servidor');
        return;
      }

      if (response.status == 200) {
        _showSuccess('¡Contraseña actualizada exitosamente!');
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacementNamed(context, '/sign-in');
      } else {
        _showError('Error: ${response.body}');
      }
    } catch (e) {
      isLoading.value = false;
      _showError('Error: ${e.toString()}');
    }
  }

  bool _validateInputs() {
    if (txtToken.text.isEmpty) {
      _showError('Ingresa el código de verificación');
      return false;
    }

    if (txtNewPassword.text.length < 8) {
      _showError('La contraseña debe tener al menos 8 caracteres');
      return false;
    }

    if (txtNewPassword.text != txtConfirmPassword.text) {
      _showError('Las contraseñas no coinciden');
      return false;
    }

    return true;
  }

  void _resetMessages() {
    mensaje.value = '';
    hayError.value = false;
  }

  void _showError(String message) {
    mensaje.value = message;
    hayError.value = true;
  }

  void _showSuccess(String message) {
    mensaje.value = message;
    hayError.value = false;
  }

  @override
  void onClose() {
    txtToken.dispose();
    txtNewPassword.dispose();
    txtConfirmPassword.dispose();
    super.onClose();
  }
}
