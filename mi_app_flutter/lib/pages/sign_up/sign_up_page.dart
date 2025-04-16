import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sign_up_controller.dart';

class SignUpPage extends StatelessWidget {
  final SignUpController control = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Crear Cuenta',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: control.txtUsuario,
                  label: 'Nombre de Usuario',
                  icon: Icons.person_outline,
                  enabled: control.enabled.value,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: control.txtCorreo,
                  label: 'Correo Electrónico',
                  icon: Icons.email_outlined,
                  enabled: control.enabled.value,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: control.txtContrasenia,
                  label: 'Contraseña',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  enabled: control.enabled.value,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: control.txtContrasenia2,
                  label: 'Confirmar Contraseña',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  enabled: control.enabled.value,
                ),
                const SizedBox(height: 24),
                if (control.mensaje.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      control.mensaje.value,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _buildButton(
                  text: 'Crear cuenta',
                  icon: Icons.person_add,
                  isPrimary: true,
                  onPressed: control.enabled.value ? () => control.signUp(context) : null,
                ),
                const SizedBox(height: 16),
                _buildButton(
                  text: 'Ir a Login',
                  icon: Icons.login,
                  onPressed: control.enabled.value ? () => control.goToSignIn(context) : null,
                ),
                const SizedBox(height: 16),
                _buildButton(
                  text: 'Resetear Contraseña',
                  icon: Icons.restore,
                  onPressed: control.enabled.value ? () => control.goToResetPassword(context) : null,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabled: enabled,
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
    required IconData icon,
    bool isPrimary = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.red : Colors.redAccent.withOpacity(0.8),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
