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
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.cargando.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con avatar y botón de cerrar sesión
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      child: Obx(
                        () => Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  controller.profilePhotoUrl.value.isNotEmpty
                                      ? NetworkImage(
                                        controller.profilePhotoUrl.value,
                                      )
                                      : null,
                              backgroundColor: Colors.grey[300],
                              radius: 20,
                              child:
                                  controller.profilePhotoUrl.value.isEmpty
                                      ? Text(
                                        sesionControlador
                                                    .usuarioActual
                                                    .value
                                                    ?.nombre
                                                    .isNotEmpty ==
                                                true
                                            ? sesionControlador
                                                .usuarioActual
                                                .value!
                                                .nombre
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : "U",
                                        style: TextStyle(color: Colors.white),
                                      )
                                      : null,
                            ),
                            if (controller.loadingPhoto.value)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      onTap: () {
                        print(
                          'URL actual de la foto: ${controller.profilePhotoUrl.value}',
                        ); // Debug
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () => controller.cerrarSesionCompleta(),
                      tooltip: 'Cerrar sesión',
                    ),

                    //Agrega boton de recarga
                  ],
                ),
              ),

              // Título de la sección principal
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Obx(
                  () => Text(
                    controller.pestanaSeleccionada.value == 0
                        ? 'Principal'
                        : controller.pestanaSeleccionada.value == 1
                        ? 'Objetivos'
                        : 'Perfil',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          ),
        );
      }),

      // Botón flotante para agregar tarea o lista

      // Barra de navegación inferior
    );
  }

  // Pestañas (Tareas, Listas, Perfil)
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
