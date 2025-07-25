import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/tarea.dart';
import '../../../services/lista_service.dart';
import '../../../services/tarea_service.dart';
import '../../../services/recordatorio_service.dart';
import '../../buscador/buscador_controller_page.dart';
import '../../calendario/calendario_controller_page.dart';
import '../../home/home_controler.dart';
import '../../principal/principal_controller.dart';
import '../../widgets/lista/lista_item_controller.dart';
import '../../../models/recordatorio.dart';

class VisualizarListaController extends GetxController {
  final int listaId;
  final ListaService _listaService = ListaService();
  final TareaService _tareaService = TareaService();
  final RecordatorioService _recordatorioService = RecordatorioService();
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
    // Primero eliminar recordatorios de todas las tareas de la lista
    await _eliminarRecordatoriosDeListaCompleta();

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

    await _principalController.eliminarListaConTareas(listaId);
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
    // Eliminar recordatorios asociados a la tarea
    await _eliminarRecordatoriosDeTarea(tareaId);

    await _principalController.EliminarTarea(tareaId);
    await ListaItemController.actualizarLista(listaId);
    await _homeController.recargarTodo();
    await _buscadorController.recargarBuscador();
    await _calendarioController.recargarCalendario();
    return true;
  }

  // Método helper para eliminar recordatorios de una tarea específica
  Future<void> _eliminarRecordatoriosDeTarea(int tareaId) async {
    try {
      final respuesta = await _recordatorioService
          .obtenerRecordatoriosDeUnaTarea(tareaId);

      if (respuesta.status == 200) {
        final recordatorios = respuesta.body as List<Recordatorio>;

        for (final recordatorio in recordatorios) {
          if (recordatorio.id != null) {
            await _recordatorioService.eliminarRecordatorio(recordatorio.id!);
          }
        }

        print('Recordatorios eliminados para la tarea $tareaId');
      }
    } catch (e) {
      print('Error al eliminar recordatorios de la tarea $tareaId: $e');
    }
  }

  // Método helper para eliminar recordatorios de todas las tareas de una lista
  Future<void> _eliminarRecordatoriosDeListaCompleta() async {
    try {
      // Usar el nuevo servicio para eliminar todos los recordatorios de la lista
      final respuesta = await _recordatorioService.eliminarRecordatoriosLista(
        listaId,
      );

      if (respuesta.status == 200) {
        final data = respuesta.body as Map<String, dynamic>;
        final recordatoriosEliminados = data['recordatorios_eliminados'] ?? 0;

        print(
          '✅ Eliminados $recordatoriosEliminados recordatorios de la lista $listaId',
        );
      } else {
        print(
          '⚠️ Error al eliminar recordatorios de la lista $listaId: ${respuesta.body}',
        );
      }
    } catch (e) {
      print('❌ Error al eliminar recordatorios de la lista $listaId: $e');
    }
  }
}
