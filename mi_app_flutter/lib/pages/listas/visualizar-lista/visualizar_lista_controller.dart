import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/tarea.dart';
import '../../../services/lista_service.dart';
import '../../../services/tarea_service.dart';
import '../../buscador/buscador_controller_page.dart';
import '../../calendario/calendario_controller_page.dart';
import '../../home/home_controler.dart';
import '../../principal/principal_controller.dart';
import '../../widgets/lista/lista_item_controller.dart';

class VisualizarListaController extends GetxController {
  final int listaId;
  final ListaService _listaService = ListaService();
  final TareaService _tareaService = TareaService();
  final HomeController _homeController = Get.find<HomeController>();
  final BuscadorController _buscadorController = Get.find<BuscadorController>();
  final CalendarioController _calendarioController =
      Get.find<CalendarioController>();
  final PrincipalController _principalController =
      Get.find<PrincipalController>();

  VisualizarListaController(this.listaId);

  Future<Map<String, dynamic>?> obtenerListaConTareas() async {
    final response = await _principalController.ObtenerListaConTareas(listaId);
    return response;
  }

  Future<bool> eliminarLista() async {
    final response = await _listaService.eliminarLista(listaId);
    if (response.status != 200) {
      // Obtener el mensaje de error específico del servidor si está disponible
      String errorMessage = 'No se pudo eliminar la lista';
      if (response.body is String) {
        errorMessage = response.body;
      } else if (response.body is Map && response.body['message'] != null) {
        errorMessage = response.body['message'];
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    await _principalController.verificarYEliminarListaConTareas(listaId);
    await _homeController.recargarTodo();
    await _buscadorController.recargarBuscador();
    await _calendarioController.recargarCalendario();

    Get.snackbar(
      'Éxito',
      'Lista eliminada correctamente',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    return true;
  }

  Future<bool> actualizarEstadoTarea(Tarea tarea, int nuevoEstadoId) async {
    final response = await _tareaService.actualizarEstadoTarea(
      tarea.id as int,
      nuevoEstadoId,
    );
    if (response.status != 200) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el estado de la tarea',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    final nuevaTarea = tarea.copyWith(estadoId: nuevoEstadoId);
    await _principalController.EditarTarea(nuevaTarea);
    await ListaItemController.actualizarLista(listaId);
    await _homeController.recargarTodo();
    await _buscadorController.recargarBuscador();
    await _calendarioController.recargarCalendario();
    return true;
  }

  Future<bool> eliminarTarea(int tareaId) async {
    await _principalController.EliminarTarea(tareaId);
    await ListaItemController.actualizarLista(listaId);
    await _homeController.recargarTodo();
    await _buscadorController.recargarBuscador();
    await _calendarioController.recargarCalendario();
    return true;
  }
}
