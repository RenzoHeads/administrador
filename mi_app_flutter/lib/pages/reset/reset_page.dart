import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'reset_controller.dart';

class ResetPage extends StatelessWidget {
  final ResetController control = Get.put(ResetController());

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
                _header(),
                const SizedBox(height: 32),
                _emailField(control),
                const SizedBox(height: 32),
                _actionButton(context, control),
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

Widget _emailField(ResetController control) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Correo', style: TextStyle(fontSize: 14, color: Colors.grey)),
      const SizedBox(height: 6),
      TextFormField(
        controller: control.txtEmail,
        keyboardType: TextInputType.emailAddress,
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

Widget _actionButton(BuildContext context, ResetController control) {
  return SizedBox(
    width: double.infinity,
    child: Obx(
      () => ElevatedButton(
        onPressed:
            control.isLoading.value
                ? null
                : () => control.requestPasswordRecovery(context),
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
            control.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                  'Recibir codigo',
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
