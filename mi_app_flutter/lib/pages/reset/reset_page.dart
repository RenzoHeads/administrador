import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'reset_controller.dart';

class ResetPage extends StatelessWidget {
  final ResetController control = Get.put(ResetController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildEmailInput(),
              const SizedBox(height: 16),
              _buildMessageBox(),
              const SizedBox(height: 24),
              _buildActionButton(context),
              const SizedBox(height: 16),
              _buildSignInButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Recuperar contraseña',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Ingresa tu correo electrónico para recibir un código de verificación',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    ],
  );

  Widget _buildEmailInput() => TextField(
    controller: control.txtEmail,
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(
      labelText: 'Correo electrónico',
      hintText: 'ejemplo@dominio.com',
      prefixIcon: const Icon(Icons.email_outlined),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    ),
  );

  Widget _buildMessageBox() => Obx(() {
    if (control.mensaje.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: control.hayError.value 
            ? Colors.red.withOpacity(0.1) 
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            control.hayError.value 
                ? Icons.error_outline 
                : Icons.check_circle_outline,
            color: control.hayError.value 
                ? Colors.red 
                : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              control.mensaje.value,
              style: TextStyle(
                color: control.hayError.value 
                    ? Colors.red 
                    : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  });

  Widget _buildActionButton(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 50,
    child: Obx(() => ElevatedButton(
      onPressed: control.isLoading.value ? null : () => control.requestPasswordRecovery(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: control.isLoading.value
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Enviar código',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    )),
  );

  Widget _buildSignInButton(BuildContext context) => SizedBox(
    width: double.infinity,
    child: TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        'Volver al inicio de sesión',
        style: TextStyle(color: Colors.grey),
      ),
    ),
  );
}