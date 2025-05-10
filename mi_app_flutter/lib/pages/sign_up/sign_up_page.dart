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
                _header(),
                const SizedBox(height: 32),
                _userField(control),
                const SizedBox(height: 16),
                _emailField(control),
                const SizedBox(height: 16),
                _passwordField(control),
                const SizedBox(height: 16),
                _confirmPasswordField(control),
                const SizedBox(height: 24),
                _registerButton(context, control),
                const SizedBox(height: 24),
                _loginLink(context, control),
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
      'Crear Cuenta',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  );
}

Widget _userField(SignUpController control) {
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

Widget _emailField(SignUpController control) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: const [
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

Widget _passwordField(SignUpController control) {
  return _PasswordField(
    controller: control.txtContrasenia,
    label: 'Contraseña',
    hint: 'Ingresa tu contraseña',
  );
}

Widget _confirmPasswordField(SignUpController control) {
  return _PasswordField(
    controller: control.txtContrasenia2,
    label: 'Confirmar Contraseña',
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
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
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

Widget _registerButton(BuildContext context, SignUpController control) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () => control.signUp(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5DB075),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: const Text('Registrarse', style: TextStyle(fontSize: 16)),
    ),
  );
}

Widget _loginLink(BuildContext context, SignUpController control) {
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
