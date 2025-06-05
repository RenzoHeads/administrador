import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sign_up_controller.dart';

class SignUpPage extends StatelessWidget {
  final SignUpController control = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título principal de la página de registro
                _buildHeader(),
                const SizedBox(height: 32),

                // Campo de entrada para el nombre de usuario
                _buildUserField(),
                const SizedBox(height: 16),

                // Campo de entrada para el correo electrónico
                _buildEmailField(),
                const SizedBox(height: 16),

                // Campo de entrada para la contraseña
                _buildPasswordField(),
                const SizedBox(height: 16),

                // Campo de confirmación de contraseña
                _buildConfirmPasswordField(),
                const SizedBox(height: 24),

                // Botón principal de registro
                _buildRegisterButton(context),
                const SizedBox(height: 24),

                // Enlace para ir a la página de inicio de sesión
                _buildLoginLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget del encabezado con título de registro
  Widget _buildHeader() {
    return const Center(
      child: Text(
        'Crear Cuenta',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
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

  // Widget del campo de correo electrónico con validación
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Correo', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: control.txtCorreo,
          decoration: InputDecoration(
            hintText: 'Ingresa tu correo',
            prefixIcon: const Icon(Icons.email_outlined),
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
            controller: control.txtContrasenia,
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

  // Widget del campo de confirmación de contraseña con toggle independiente
  Widget _buildConfirmPasswordField() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Confirmar Contraseña',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: control.txtContrasenia2,
            obscureText: control.obscureConfirmPassword.value,
            decoration: InputDecoration(
              hintText: 'Confirma tu contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  control.obscureConfirmPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () => control.toggleConfirmPasswordVisibility(),
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

  // Widget del botón de registro
  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => control.signUp(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5DB075),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text('Registrarse', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  // Widget del enlace para ir a inicio de sesión
  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¿Ya tienes una cuenta? ',
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
          GestureDetector(
            onTap: () => control.goToSignIn(context),
            child: const Text(
              'Inicia Sesión',
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
}
