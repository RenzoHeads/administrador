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
                  const _Header(),
                  const SizedBox(height: 32),
                  _UserField(controller: control.txtUsuario),
                  const SizedBox(height: 16),
                  _PasswordField(controller: control.txtContrasena),
                  const SizedBox(height: 4),
                  _ForgotPassword(onTap: () => control.goReset(context)),
                  const SizedBox(height: 24),
                  _LoginButton(control: control),
                  const SizedBox(height: 16),
                  _RegisterLink(onTap: () => control.goSignUp(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
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
}

class _UserField extends StatelessWidget {
  final TextEditingController controller;
  const _UserField({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text('Usuario', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
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
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordField({required this.controller});
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
        Row(
          children: const [
            Text(
              'Contraseña',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          decoration: InputDecoration(
            hintText: 'Ingresa tu contraseña',
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

class _ForgotPassword extends StatelessWidget {
  final VoidCallback onTap;
  const _ForgotPassword({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
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
}

class _LoginButton extends StatelessWidget {
  final SignInController control;
  const _LoginButton({required this.control});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = control.mensaje.value != '' && !control.hayError.value;
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              isLoading
                  ? null
                  : () {
                    if (control.txtUsuario.text.trim().isEmpty) {
                      control.mensaje.value = 'Por favor ingresa tu usuario';
                      control.hayError.value = true;
                      Future.delayed(const Duration(seconds: 3), () {
                        control.mensaje.value = '';
                      });
                      return;
                    }
                    if (control.txtContrasena.text.isEmpty) {
                      control.mensaje.value = 'Por favor ingresa tu contraseña';
                      control.hayError.value = true;
                      Future.delayed(const Duration(seconds: 3), () {
                        control.mensaje.value = '';
                      });
                      return;
                    }
                    control.goHome(context);
                  },
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
}

class _RegisterLink extends StatelessWidget {
  final VoidCallback onTap;
  const _RegisterLink({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¿No tienes una cuenta? ',
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
          GestureDetector(
            onTap: onTap,
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
}
