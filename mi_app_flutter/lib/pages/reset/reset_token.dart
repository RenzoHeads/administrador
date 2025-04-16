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
        txtNewPassword.text
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
      appBar: AppBar(
        title: const Text('Restablecer Contraseña'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Restablecer contraseña',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa el código recibido y tu nueva contraseña',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            
            // Campo de código - Modificado para tokens alfanuméricos
            TextField(
              controller: controller.txtToken,
              decoration: InputDecoration(
                labelText: 'Código de verificación',
                hintText: 'Ingresa el código de verificación completo',
                prefixIcon: const Icon(Icons.vpn_key),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            
            // Campo de contraseña
            TextField(
              controller: controller.txtNewPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                hintText: 'Mínimo 8 caracteres',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            
            // Campo de confirmar contraseña
            TextField(
              controller: controller.txtConfirmPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                hintText: 'Repite tu contraseña',
                prefixIcon: const Icon(Icons.lock_reset),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 24),
            
            // Mensaje de estado
            Obx(() {
              if (controller.mensaje.isEmpty) return const SizedBox.shrink();
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: controller.hayError.value 
                      ? Colors.red.withOpacity(0.1) 
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      controller.hayError.value 
                          ? Icons.error_outline 
                          : Icons.check_circle,
                      color: controller.hayError.value 
                          ? Colors.red 
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.mensaje.value,
                        style: TextStyle(
                          color: controller.hayError.value 
                              ? Colors.red 
                              : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            
            // Botón de enviar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value 
                    ? null 
                    : () => controller.resetPassword(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Restablecer contraseña',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}