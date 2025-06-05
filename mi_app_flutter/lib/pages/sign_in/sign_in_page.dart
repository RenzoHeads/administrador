import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sign_in_controller.dart';

class SignInPage extends StatelessWidget {
  final SignInController control = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título principal de la página
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Campo de entrada para el usuario
                  _buildUserField(),
                  const SizedBox(height: 16),

                  // Campo de entrada para la contraseña
                  _buildPasswordField(),
                  const SizedBox(height: 4),

                  // Enlace para recuperar contraseña
                  _buildForgotPasswordLink(context),
                  const SizedBox(height: 24),

                  // Botón principal de inicio de sesión
                  _buildLoginButton(context),
                  const SizedBox(height: 16),

                  // Enlace para registro de nuevos usuarios
                  _buildRegisterLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget del encabezado con título
  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Center(
          child: Text(
            'Iniciar sesión',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 32),
      ],
    );
  }

  // Widget del campo de usuario con validación visual
  Widget _buildUserField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Usuario', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: control.txtUsuario,
          decoration: InputDecoration(
            hintText: 'Ingresa tu nombre',
            prefixIcon: const Icon(Icons.person_outline),
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

  // Widget del campo de contraseña con toggle de visibilidad
  Widget _buildPasswordField() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Contraseña',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: control.txtContrasena,
            obscureText: control.obscurePassword.value,
            decoration: InputDecoration(
              hintText: 'Ingresa tu contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  control.obscurePassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () => control.togglePasswordVisibility(),
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
      ),
    );
  }

  // Widget del enlace para recuperar contraseña
  Widget _buildForgotPasswordLink(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => control.goReset(context),
        child: const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: Color(0xFF5DB075),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Widget del botón de inicio de sesión con estados de carga
  Widget _buildLoginButton(BuildContext context) {
    return Obx(() {
      final isLoading = control.mensaje.value != '' && !control.hayError.value;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : () => _handleLogin(context),
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
              isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Ingresar', style: TextStyle(fontSize: 16)),
        ),
      );
    });
  }

  // Widget del enlace para registro de nuevos usuarios
  Widget _buildRegisterLink(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¿No tienes una cuenta? ',
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
          GestureDetector(
            onTap: () => control.goSignUp(context),
            child: const Text(
              'Regístrate',
              style: TextStyle(
                color: Color(0xFF5DB075),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para manejar la lógica de inicio de sesión
  void _handleLogin(BuildContext context) {
    if (control.txtUsuario.text.trim().isEmpty) {
      control.showError('Por favor ingresa tu usuario');
      return;
    }

    if (control.txtContrasena.text.isEmpty) {
      control.showError('Por favor ingresa tu contraseña');
      return;
    }

    control.goHome(context);
  }
}
