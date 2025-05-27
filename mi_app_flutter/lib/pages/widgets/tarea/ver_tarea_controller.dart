// =============== ver_tarea_controller.dart (modificado) ===============
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/tarea.dart';
import '../../../models/categoria.dart';
import '../../../models/etiqueta.dart';
import '../../../models/lista.dart';
import '../../../services/tarea_service.dart';
import '../../../models/prioridad.dart';
import '../../../models/estado.dart';
import '../../widgets/lista/lista_item_controller.dart';
import '../../principal/principal_controller.dart';
import '../../home/home_controler.dart';
import '../../buscador/buscador_controller_page.dart';
import '../../calendario/calendario_controller_page.dart';

class VerTareaController extends GetxController {
  final TareaService _tareaService = TareaService();
  final PrincipalController _principalController =
      Get.find<PrincipalController>();
  final HomeController _homeController = Get.find<HomeController>();
  final BuscadorController _buscadorController = Get.find<BuscadorController>();
  final CalendarioController _calendarioController =
      Get.find<CalendarioController>();

  // Variables (ya no son RxBool, son valores simples)
  bool cargando = false;
  bool editando = false;
  Tarea? tarea;
  Categoria? categoria;
  Lista? lista;
  List<Etiqueta> etiquetas = [];
  Prioridad? priori;
  Estado? estado;
  Color colorPrioridad = Colors.transparent; // Color de prioridad
  Color colorEstado = Colors.transparent; // Color de estado
  bool datosYaCargados =
      false; // Bandera para controlar si ya se cargaron datos

  // ID de tarea para identificar este controlador específico
  final int tareaId;

  // Formateo de fechas
  String fechaCreacion = '';
  String horaCreacion = '';
  String fechaVencimiento = '';
  String horaVencimiento = '';

  // Constructor con ID de tarea obligatorio
  VerTareaController({required this.tareaId});

  @override
  void onInit() {
    super.onInit();
    // Solo cargamos los datos si no se han cargado previamente
    if (!datosYaCargados) {
      cargarTarea(tareaId);
    }
  }

  @override
  void onClose() {
    // Limpiar recursos si es necesario
    super.onClose();
  }

  // Método estático para actualizar una tarea específica
  static Future<void> actualizarTarea(int tareaId) async {
    // Buscar el controlador por su tag único
    final String tag = 'tarea_$tareaId';
    if (Get.isRegistered<VerTareaController>(tag: tag)) {
      final controller = Get.find<VerTareaController>(tag: tag);
      await controller.cargarTarea(tareaId);
    }
  }

  // Metodo estatico para eliminar una tarea específica
  static Future<bool> eliminarTareaDefinitivo(int tareaId) async {
    // Buscar el controlador por su tag único
    final String tag = 'tarea_$tareaId';
    if (Get.isRegistered<VerTareaController>(tag: tag)) {
      final controller = Get.find<VerTareaController>(tag: tag);
      return await controller.eliminarTarea(tareaId);
    }
    return false; // Si no se encuentra el controlador, no se puede eliminar
  }

  // Cargar todos los datos de la tarea desde PrincipalController
  Future<void> cargarTarea(int tareaId) async {
    try {
      if (cargando) return; // Evitar múltiples cargas simultáneas

      cargando = true;
      // Notificar solo a los widgets con ID específico
      update(['tarea_$tareaId']);

      // 1. Obtener la tarea del PrincipalController
      tarea = await _principalController.ObtenerTareaPorId(tareaId);

      if (tarea != null) {
        print('Tarea cargada desde PrincipalController: $tarea');

        // Formatear fechas
        // Formatear fecha de creación
        final DateTime fechaCreacionDt = tarea!.fechaCreacion.toLocal();
        fechaCreacion = DateFormat('dd/MM/yyyy').format(fechaCreacionDt);
        horaCreacion = DateFormat('HH:mm').format(fechaCreacionDt);

        // Formatear fecha de vencimiento
        final DateTime fechaVencimientoDt = tarea!.fechaVencimiento.toLocal();
        fechaVencimiento = DateFormat('dd/MM/yyyy').format(fechaVencimientoDt);
        horaVencimiento = DateFormat('HH:mm').format(fechaVencimientoDt);

        // Obtener la categoría de la tarea desde PrincipalController
        categoria = await _principalController.getCategoriaPorId(
          tarea!.categoriaId,
        );

        // Obtener la lista de la tarea desde PrincipalController
        if (tarea!.listaId != null) {
          final listas = await _principalController.ObtenerListaUsuario();
          lista = listas.firstWhereOrNull((l) => l.id == tarea!.listaId);
        }

        // Obtener etiquetas de la tarea desde PrincipalController
        etiquetas = await _principalController.getEtiquetasPorTarea(tareaId);

        // Obtener la prioridad de la tarea desde PrincipalController
        priori = await _principalController.getPrioridadPorId(
          tarea!.prioridadId,
        );

        // Obtener el estado de la tarea desde PrincipalController
        estado = await _principalController.getEstadoPorId(tarea!.estadoId);

        // Establecer colores basados en prioridad y estado
        if (priori != null) {
          colorPrioridad = obtenerColorPrioridad(tarea!.prioridadId);
        }

        if (estado != null) {
          colorEstado = obtenerColorEstado(tarea!.estadoId);
        }

        // Marcar que los datos ya se cargaron para evitar recargas innecesarias
        datosYaCargados = true;
      } else {}
    } catch (e) {
      print('Error al cargar tarea: $e');
      Get.snackbar(
        'Error',
        'No se pudo cargar la información de la tarea',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Volver atrás en caso de error
      Get.back();
    } finally {
      cargando = false;
      // Notificar específicamente a los widgets con este ID
      update(['tarea_$tareaId']);
    }
  }

  // Método mejorado para eliminar la tarea
  Future<bool> eliminarTarea(int tareaId) async {
    // Mostrar diálogo de confirmación antes de eliminar
    bool confirmar =
        await Get.dialog(
          AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar esta tarea?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;

    if (!confirmar) return false;
    try {
      final resultado = await _tareaService.eliminarTarea(tareaId);

      // Si la eliminación fue exitosa
      if (resultado.status == 200) {
        // Actualizar la lista en PrincipalController
        await _principalController.EliminarTarea(tareaId);
        await ListaItemController.actualizarLista(tarea!.listaId!);

        await _homeController.recargarTodo();
        await _buscadorController.recargarBuscador();
        await _calendarioController.recargarCalendario();

        // Cerrar el modal después de eliminar exitosamente
        Get.back();

        // Mostrar mensaje de éxito
        Get.snackbar(
          'Éxito',
          'Tarea eliminada correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      }

      Get.snackbar(
        'Error',
        'No se pudo eliminar la tarea',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      print('Excepción al eliminar tarea: $e');
      Get.snackbar(
        'Error',
        'No se pudo eliminar la tarea: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      print('Proceso de eliminación finalizado');
    }
  }

  // Método para obtener el color de la prioridad
  Color obtenerColorPrioridad(int prioridadId) {
    switch (prioridadId) {
      case 1:
        return Colors.green; // Baja
      case 2:
        return Colors.yellow; // Media
      case 3:
        return Colors.red; // Alta
      default:
        return Colors.transparent; // Sin color definido
    }
  }

  // Método para obtener el color del estado
  Color obtenerColorEstado(int estadoId) {
    switch (estadoId) {
      case 1:
        return Colors.blue; // Pendiente
      case 2:
        return Colors.green; // En progreso
      case 3:
        return Colors.orange; // Completada
      default:
        return Colors.transparent; // Sin color definido
    }
  }

  // Método para cambiar el estado de la tarea - mantenemos la petición a la API
  Future<bool> cambiarEstadoTarea(int nuevoEstadoId) async {
    if (tarea?.id == null) {
      Get.snackbar(
        'Error',
        'No hay una tarea cargada para actualizar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      final tareaId = tarea!.id;

      // Realizar la petición a la API para actualizar el estado
      final resultado = await _tareaService.actualizarEstadoTarea(
        tareaId!,
        nuevoEstadoId,
      );

      if (resultado.status == 200) {
        // Actualizar el estado en PrincipalController
        estado = await _principalController.getEstadoPorId(nuevoEstadoId);

        // Actualizar el modelo de tarea localmente
        tarea = tarea!.copyWith(estadoId: nuevoEstadoId);

        // Actualizar la tarea en el PrincipalController
        _principalController.EditarTarea(tarea!);

        // Actualizar color del estado
        colorEstado = obtenerColorEstado(nuevoEstadoId);

        // Notificar específicamente a los widgets con este ID
        update(['tarea_$tareaId']);

        // Si se desea actualizar la lista asociada
        if (tarea?.listaId != null) {
          await ListaItemController.actualizarLista(tarea!.listaId!);
        }

        return true;
      }

      Get.snackbar(
        'Error',
        'No se pudo actualizar el estado de la tarea',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      print('Error al cambiar estado de tarea: $e');
      Get.snackbar(
        'Error',
        'Ocurrió un problema al actualizar el estado',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Método para obtener el nombre del estado
  String obtenerNombreEstado() {
    if (estado != null) {
      return estado!.nombre;
    }
    return 'Desconocido';
  }

  // Método para obtener el nombre del estado de una tarea específica - mantenemos la petición a la API
  Future<String> obtenerNombreEstadoPorTareaId(int tareaId) async {
    return _principalController.obtenerNombreEstadoPorTareaId(tareaId);
  }

  // Método para obtener texto de fecha relativa
  String obtenerTextoFechaRelativa(DateTime fecha) {
    final DateTime ahora = DateTime.now().toLocal();
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final DateTime fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);
    final DateTime fechaLocal = fecha.toLocal();

    // Calcular diferencia en días
    final diferencia = fechaSinHora.difference(hoy).inDays;

    // Formatear hora
    final hora = DateFormat('HH:mm').format(fechaLocal);

    switch (diferencia) {
      case 0:
        return 'Hoy, $hora';
      case 1:
        return 'Mañana, $hora';
      case 2:
        return 'Pasado mañana, $hora';
      case -1:
        return 'Ayer, $hora';
      case -2:
        return 'Anteayer, $hora';
      default:
        // Si es una fecha más lejana, mostrar fecha completa con hora
        return '${DateFormat('dd/MM/yyyy').format(fechaLocal)}, $hora';
    }
  }
}
