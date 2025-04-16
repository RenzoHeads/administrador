import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sign_in_controller.dart';

class SignInPage extends StatelessWidget {
  final SignInController control = Get.put(SignInController());

  Widget _buildBody(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: orientation == Orientation.portrait
              ? Column(
                  children: [
                    _headerVertical(context),
                    _form(context),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _headerHorizontal(context)),
                    Expanded(child: _form(context)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _headerVertical(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          'Bienvenido',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _headerHorizontal(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Bienvenido',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  Widget _form(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: control.txtUsuario,
          decoration: InputDecoration(
            labelText: 'Usuario',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: control.txtContrasena,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
          ),
        ),
        Obx(() {
          return (control.mensaje.value == '')
              ? const SizedBox(height: 16)
              : Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: control.hayError.value 
                        ? Colors.red.withOpacity(0.1) 
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: control.hayError.value 
                          ? Colors.red.shade300 
                          : Colors.green.shade300,
                    ),
                  ),
                  child: Text(
                    control.mensaje.value,
                    style: TextStyle(
                      color: control.hayError.value
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
        }),
        const SizedBox(height: 24),
        Obx(() {
          final isLoading = control.mensaje.value != '' && !control.hayError.value;
          return ElevatedButton(
            onPressed: isLoading 
                ? null 
                : () {
                    // Basic validation
                    if (control.txtUsuario.text.trim().isEmpty) {
                      control.mensaje.value = 'Por favor ingrese su usuario';
                      control.hayError.value = true;
                      Future.delayed(Duration(seconds: 3), () {
                        control.mensaje.value = '';
                      });
                      return;
                    }
                    if (control.txtContrasena.text.isEmpty) {
                      control.mensaje.value = 'Por favor ingrese su contraseña';
                      control.hayError.value = true;
                      Future.delayed(Duration(seconds: 3), () {
                        control.mensaje.value = '';
                      });
                      return;
                    }
                    control.goHome(context);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: isLoading 
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Ingresar', style: TextStyle(fontSize: 16)),
          );
        }),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            control.goSignUp(context);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Crear Cuenta', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            control.goReset(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Recuperar Contraseña', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: _buildBody(context),
      ),
    );
  }
}
