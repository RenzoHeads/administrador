import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../models/lista.dart';
import '../../models/tarea.dart';
import '../../pages/listas/lista_crear.dart';
import '../../pages/listas/lista_ia_modal.dart';
import '../../services/lista_service.dart';
import '../../services/controladorsesion.dart';
import '../../pages/home/home_controler.dart';
import '../principal/principal_controller.dart';
import '../calendario/calendario_controller_page.dart';
import '../buscador/buscador_controller_page.dart';
import '../notificaciones/notificacion_controller_page.dart';

class CustomFAB extends StatelessWidget {
  final Function()? onTapTask;
  final Function()? onTapList;
  final Function()? onTapManual;
  final Function()? onTapIA;

  const CustomFAB({
    Key? key,
    this.onTapTask,
    this.onTapList,
    this.onTapManual,
    this.onTapIA,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showCreateOptionsModal(context);
      },
      backgroundColor: Colors.green,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showCreateOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Crear nueva',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildOptionItem(
                      context: context,
                      svgPath: 'assets/icons/icon_lista.svg',
                      label: 'Lista',
                      backgroundColor: const Color(0xFFFFF8EC),
                      onTap: () {
                        Navigator.pop(context);
                        _showCreateListTypeModal(context);
                      },
                    ),
                    const SizedBox(width: 16), // Espacio entre las dos opciones
                    _buildOptionItem(
                      context: context,
                      svgPath: 'assets/icons/icon_tarea.svg',
                      label: 'Tarea',
                      backgroundColor: const Color(0xFFFFF1F0),
                      onTap: () {
                        Navigator.pop(context);
                        if (onTapTask != null) {
                          onTapTask!();
                        } else {
                          Get.toNamed('/crear-tarea');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _showCreateListModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: CrearListaModal(
                onBack: () {
                  Navigator.pop(context);
                  _showCreateOptionsModal(context);
                },
                onClose: () => Navigator.pop(context),
              ),
            ),
          ),
    );
  }

  void _showCreateListTypeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                          _showCreateOptionsModal(context);
                        },
                      ),
                      const Text(
                        'Crear Lista',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildOptionItem(
                      context: context,
                      svgPath: 'assets/icons/icon_manual.svg',
                      label: 'Manual',
                      backgroundColor: const Color(0xFFFFF8EC),
                      onTap: () {
                        Navigator.pop(context);
                        // Ahora muestra el modal en lugar de navegar
                        _showCreateListModal(context);
                      },
                    ),
                    const SizedBox(width: 16), // Espacio entre las dos opciones
                    _buildOptionItem(
                      context: context,
                      svgPath: 'assets/icons/icon_ia.svg',
                      label: 'Con IA',
                      backgroundColor: const Color(0xFFF8F0FF),
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder:
                              (context) => ListaIAModal(
                                onGenerar: (prompt) async {
                                  final sesion =
                                      Get.find<ControladorSesionUsuario>();
                                  final principal =
                                      Get.find<PrincipalController>();
                                  final usuario = sesion.usuarioActual.value;
                                  if (usuario == null || usuario.id == null) {
                                    Get.snackbar(
                                      'Error',
                                      'No hay usuario autenticado',
                                    );
                                    return;
                                  }
                                  final listaService = ListaService();
                                  final response = await listaService
                                      .generarListaIA(
                                        prompt: prompt,
                                        usuarioId: usuario.id!,
                                      );
                                  if (response.status == 200) {
                                    // El response.body ahora contiene objetos mapeados
                                    final data =
                                        response.body as Map<String, dynamic>;
                                    final Lista lista = data['lista'] as Lista;
                                    final List<Tarea> tareas =
                                        data['tareas'] as List<Tarea>;

                                    // Agregar la lista y las tareas al principal_controller
                                    await principal.AgregarLista(lista);
                                    for (Tarea tarea in tareas) {
                                      await principal.AgregarTarea(tarea);
                                    }

                                    // Recargar todas las páginas
                                    if (Get.isRegistered<HomeController>()) {
                                      final homeController =
                                          Get.find<HomeController>();
                                      await homeController.recargarTodo();
                                    }

                                    if (Get.isRegistered<
                                      BuscadorController
                                    >()) {
                                      final buscadorController =
                                          Get.find<BuscadorController>();
                                      await buscadorController
                                          .recargarBuscador();
                                    }

                                    if (Get.isRegistered<
                                      CalendarioController
                                    >()) {
                                      final calendarioController =
                                          Get.find<CalendarioController>();
                                      await calendarioController
                                          .recargarCalendario();
                                    }

                                    if (Get.isRegistered<
                                      NotificacionController
                                    >()) {
                                      final notificacionController =
                                          Get.find<NotificacionController>();
                                      await notificacionController
                                          .cargarRecordatoriosDelDia();
                                    }

                                    // Cerrar todos los modales y refrescar pantalla de listas
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).popUntil((route) => route.isFirst);

                                    Get.snackbar(
                                      'Éxito',
                                      'Lista generada correctamente con ${tareas.length} tareas',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                  } else {
                                    Get.snackbar(
                                      'Error',
                                      'Error al generar la lista',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                                onClose: () => Navigator.pop(context),
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required String svgPath,
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    // Dimensiones fijas: 166 x 90
    const width = 166.0;
    const height = 90.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(svgPath, width: 40, height: 40),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
