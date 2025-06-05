import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'reset_token_controller.dart';

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
                _buildHeader(),
                const SizedBox(height: 32),
                _buildMessageDisplay(controller),
                const SizedBox(height: 16),
                _buildCodeField(controller),
                const SizedBox(height: 16),
                _buildPasswordField(controller),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(controller),
                const SizedBox(height: 32),
                _buildActionButton(context, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Recuperar contraseña',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildMessageDisplay(ResetTokenController controller) {
    return Obx(() {
      if (controller.mensaje.value.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              controller.hayError.value
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: controller.hayError.value ? Colors.red : Colors.green,
            width: 1,
          ),
        ),
        child: Text(
          controller.mensaje.value,
          style: TextStyle(
            color: controller.hayError.value ? Colors.red : Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    });
  }

  Widget _buildCodeField(ResetTokenController controller) {
    return _buildInputField(
      controller: controller.txtToken,
      label: 'Código',
      hint: 'Ingresa el código de verificación',
      icon: Icons.tag,
    );
  }

  Widget _buildPasswordField(ResetTokenController controller) {
    return _buildPasswordInputField(
      controller: controller.txtNewPassword,
      label: 'Nueva Contraseña',
      hint: 'Ingresa tu contraseña',
    );
  }

  Widget _buildConfirmPasswordField(ResetTokenController controller) {
    return _buildPasswordInputField(
      controller: controller.txtConfirmPassword,
      label: 'Confirmar Nueva Contraseña',
      hint: 'Confirma tu contraseña',
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: const Color(0xFFF6F7F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    bool obscure = true;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
                filled: true,
                fillColor: const Color(0xFFF6F7F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ResetTokenController controller,
  ) {
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
            disabledBackgroundColor: Colors.grey,
          ),
          child:
              controller.isLoading.value
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text(
                    'Restablecer Contraseña',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
        ),
      ),
    );
  }
}
