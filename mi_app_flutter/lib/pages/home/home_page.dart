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
          children: [_buildSubtitle(), _buildTabs(), _buildTabContent()],
        );
      }),
    );
  }

  // Widget para el subtítulo dinámico
  Widget _buildSubtitle() {
    return Padding(
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
    );
  }

  // Widget para las pestañas personalizadas
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          _buildTabButton(index: 0, title: "Tareas"),
          SizedBox(width: 8),
          _buildTabButton(index: 1, title: "Objetivos"),
          SizedBox(width: 8),
          _buildTabButton(index: 2, title: "Perfil"),
        ],
      ),
    );
  }

  // Widget individual para cada botón de pestaña
  Widget _buildTabButton({required int index, required String title}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.cambiarPestana(index),
        child: Obx(
          () => Container(
            decoration: BoxDecoration(
              color: _getTabBackgroundColor(index),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                color: _getTabTextColor(index),
                fontWeight: _getTabFontWeight(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para el contenido de las pestañas
  Widget _buildTabContent() {
    return Expanded(
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
    );
  }

  // Métodos auxiliares para los estilos de las pestañas
  Color _getTabBackgroundColor(int index) {
    return controller.pestanaSeleccionada.value == index
        ? Colors.green[400]!
        : Colors.grey[200]!;
  }

  Color _getTabTextColor(int index) {
    return controller.pestanaSeleccionada.value == index
        ? Colors.white
        : Colors.grey[600]!;
  }

  FontWeight _getTabFontWeight(int index) {
    return controller.pestanaSeleccionada.value == index
        ? FontWeight.bold
        : FontWeight.normal;
  }
}
