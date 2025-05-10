import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/usuario_service.dart';

class ResetTokenController extends GetxController {
  TextEditingController txtToken = TextEditingController();
  TextEditingController txtNewPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();
  RxString mensaje = ''.obs;
  RxBool hayError = false.obs;
  RxBool isLoading = false.obs;

  Future<void> resetPassword(BuildContext context) async {
    mensaje.value = '';
    hayError.value = false;
    isLoading.value = true;

    // Validaciones
    if (txtToken.text.isEmpty) {
      _showError('Ingresa el código de verificación');
      isLoading.value = false;
      return;
    }

    if (txtNewPassword.text.length < 8) {
      _showError('La contraseña debe tener al menos 8 caracteres');
      isLoading.value = false;
      return;
    }

    if (txtNewPassword.text != txtConfirmPassword.text) {
      _showError('Las contraseñas no coinciden');
      isLoading.value = false;
      return;
    }

    try {
      // Llamada a la API
      final response = await UsuarioService().resetPasswordWithToken(
        txtToken.text.trim(), // Asegurarse de que no haya espacios
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
        Navigator.pushReplacementNamed(context, '/sign-in');
      } else {
        _showError('Error: ${response.body}');
      }
    } catch (e) {
      isLoading.value = false;
      _showError('Error: ${e.toString()}');
    }
  }

  void _showError(String message) {
    mensaje.value = message;
    hayError.value = true;
  }
}

class ResetTokenPage extends StatelessWidget {
  const ResetTokenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResetTokenController());
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                const SizedBox(height: 32),
                _codeField(controller),
                const SizedBox(height: 16),
                _passwordField(controller),
                const SizedBox(height: 16),
                _confirmPasswordField(controller),
                const SizedBox(height: 32),
                _actionButton(context, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _header() {
  return const Center(
    child: Text(
      'Recuperar contraseña',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  );
}

Widget _codeField(ResetTokenController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Código', style: TextStyle(fontSize: 14, color: Colors.grey)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller.txtToken,
        decoration: InputDecoration(
          hintText: 'Ingresa tu correo',
          prefixIcon: const Icon(Icons.tag),
          filled: true,
          fillColor: const Color(0xFFF6F7F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),
        ),
      ),
    ],
  );
}

Widget _passwordField(ResetTokenController controller) {
  return _PasswordField(
    controller: controller.txtNewPassword,
    label: 'Nueva Contraseña',
    hint: 'Ingresa tu contraseña',
  );
}

Widget _confirmPasswordField(ResetTokenController controller) {
  return _PasswordField(
    controller: controller.txtConfirmPassword,
    label: 'Confirmar Nueva Contraseña',
    hint: 'Confirma tu contraseña',
  );
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
  });
  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            filled: true,
            fillColor: const Color(0xFFF6F7F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _actionButton(BuildContext context, ResetTokenController controller) {
  return SizedBox(
    width: double.infinity,
    child: Obx(
      () => ElevatedButton(
        onPressed:
            controller.isLoading.value
                ? null
                : () => controller.resetPassword(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5DB075),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                  'Ir a inicio de sesion',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
      ),
    ),
  );
}
