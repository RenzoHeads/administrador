import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../profile_tab_controller.dart';

class ChangeNameModal {
  static void show(BuildContext context, ProfileTabController controller) {
    final TextEditingController nombreController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cambiar nombre',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildNameFormField(nombreController),
                  const SizedBox(height: 20),
                  _buildActionButtons(
                    context,
                    formKey,
                    controller,
                    nombreController,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildNameFormField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Ingresa tu nombre',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                'assets/icons/icon_letterT.svg',
                width: 20,
                height: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu nombre';
            }
            return null;
          },
        ),
      ],
    );
  }

  static Widget _buildActionButtons(
    BuildContext context,
    GlobalKey<FormState> formKey,
    ProfileTabController controller,
    TextEditingController nombreController,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.grey[200],
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final resultado = await controller.actualizarNombreUsuario(
                  nombreController.text,
                );
                if (resultado) {
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.green,
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
