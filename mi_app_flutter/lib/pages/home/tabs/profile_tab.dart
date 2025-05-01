import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controler.dart';
import '../../../services/controladorsesion.dart';

class ProfileTab extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();
  final ControladorSesionUsuario sesionControlador = Get.find<ControladorSesionUsuario>();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => CircleAvatar(
              backgroundImage: controller.profilePhotoUrl.value.isNotEmpty
                  ? NetworkImage(controller.profilePhotoUrl.value)
                  : null,
              backgroundColor: Colors.grey[300],
              radius: 50,
              child: controller.profilePhotoUrl.value.isEmpty
                  ? Text(
                      sesionControlador.usuarioActual.value?.nombre?.isNotEmpty == true
                        ? sesionControlador.usuarioActual.value!.nombre!.substring(0, 1).toUpperCase()
                        : "U",
                      style: TextStyle(color: Colors.white, fontSize: 32),
                    )
                  : null,
            )),
            SizedBox(height: 16),
            Text(
              sesionControlador.usuarioActual.value?.nombre ?? "Usuario",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.navegarAPerfil(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Ver perfil completo',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}