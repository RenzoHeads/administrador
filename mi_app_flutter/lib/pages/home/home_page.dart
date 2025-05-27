import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controler.dart';
import '../../services/controladorsesion.dart';
import 'tabs/tarea_tab/tasks_tab.dart';
import 'tabs/lista_tab/lists_tab.dart';
import 'tabs/perfil_tab/profile_tab.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  final ControladorSesionUsuario sesionControlador =
      Get.find<ControladorSesionUsuario>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        if (controller.cargando.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtítulo dinámico
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Obx(
                () => Text(
                  controller.subtituloActual,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),

            // Pestañas personalizadas
            _buildTabs(),

            // Contenido según la pestaña seleccionada
            Expanded(
              child: Obx(() {
                switch (controller.pestanaSeleccionada.value) {
                  case 0:
                    return TasksTab();
                  case 1:
                    return ListsTab();
                  case 2:
                    return ProfileTab();
                  default:
                    return TasksTab();
                }
              }),
            ),
          ],
        );
      }),

      // Botón flotante para agregar tarea o lista

      // Barra de navegación inferior
    );
  }

  // Pestañas (Tareas, Listas, Perfil)
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Pestaña: Tareas
          Expanded(
            child: GestureDetector(
              onTap: () => controller.cambiarPestana(0),
              child: Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color:
                        controller.pestanaSeleccionada.value == 0
                            ? Colors.green[400]
                            : Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  child: Text(
                    "Tareas",
                    style: TextStyle(
                      color:
                          controller.pestanaSeleccionada.value == 0
                              ? Colors.white
                              : Colors.grey[600],
                      fontWeight:
                          controller.pestanaSeleccionada.value == 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          // Pestaña: Listas
          Expanded(
            child: GestureDetector(
              onTap: () => controller.cambiarPestana(1),
              child: Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color:
                        controller.pestanaSeleccionada.value == 1
                            ? Colors.green[400]
                            : Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  child: Text(
                    "Objetivos",
                    style: TextStyle(
                      color:
                          controller.pestanaSeleccionada.value == 1
                              ? Colors.white
                              : Colors.grey[600],
                      fontWeight:
                          controller.pestanaSeleccionada.value == 1
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          // Pestaña: Perfil
          Expanded(
            child: GestureDetector(
              onTap: () => controller.cambiarPestana(2),
              child: Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color:
                        controller.pestanaSeleccionada.value == 2
                            ? Colors.green[400]
                            : Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  child: Text(
                    "Perfil",
                    style: TextStyle(
                      color:
                          controller.pestanaSeleccionada.value == 2
                              ? Colors.white
                              : Colors.grey[600],
                      fontWeight:
                          controller.pestanaSeleccionada.value == 2
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
