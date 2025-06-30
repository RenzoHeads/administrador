import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_tab_controller.dart';
import '../../../../services/controladorsesion.dart';
import 'modals/change_name_modal.dart';
import 'modals/change_image_modal.dart';
import 'modals/change_email_modal.dart';

class ProfileTab extends StatelessWidget {
  final ProfileTabController controller = Get.find<ProfileTabController>();
  final ControladorSesionUsuario sesionControlador =
      Get.find<ControladorSesionUsuario>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            const Text(
              'Cuenta',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            // Opciones de cuenta
            _buildOptionItem(
              'Cambiar nombre',
              'Edita tu nombre de usuario',
              Icons.chevron_right,
              () => ChangeNameModal.show(context, controller),
            ),
            _buildDivider(),

            _buildOptionItem(
              'Cambiar imagen de perfil',
              'Sube o modifica tu foto de perfil',
              Icons.chevron_right,
              () => ChangeImageModal.show(context, controller),
            ),
            _buildDivider(),

            _buildOptionItem(
              'Cambiar correo electrónico',
              'Actualiza tu email de contacto',
              Icons.chevron_right,
              () => ChangeEmailModal.show(context, controller),
            ),

            const SizedBox(height: 20),
            // Título de sección Notificaciones
            const Text(
              'Notificaciones',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            // Opciones de notificaciones
            Obx(
              () => _buildSwitchItem(
                'Notificaciones del sistema',
                'Recibir notificaciones a tu dispositivo',
                controller.notificacionesSistema.value,
                controller.toggleNotificacionesSistema,
              ),
            ),
            _buildDivider(),

            Obx(
              () => _buildSwitchItem(
                'Mostrar solo notificaciones urgentes',
                'Filtra las alertas para tareas de alta prioridad',
                controller.notificacionesUrgentes.value,
                controller.toggleNotificacionesUrgentes,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(icon, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    String title,
    String subtitle,
    bool initialValue,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: initialValue,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 0.5, color: Colors.grey[300]);
  }
}
