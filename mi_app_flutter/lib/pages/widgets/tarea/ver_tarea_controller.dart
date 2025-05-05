import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/tarea.dart';
import '../../../models/categoria.dart';
import '../../../models/etiqueta.dart';
import '../../../models/lista.dart';
import '../../../services/tarea_service.dart';
import '../../../services/etiqueta_service.dart';
import '../../../models/prioridad.dart';
import '../../../models/estado.dart';
import '../../../services/prioridad_service.dart';
import '../../../services/estado_service.dart';
import '../../../services/categoria_service.dart';
import '../../../services/lista_service.dart';
import '../../../pages/widgets/eventos_controlador.dart';

class VerTareaController extends GetxController {
  final TareaService _tareaService = TareaService();
  final CategoriaService _categoriaService = CategoriaService();
  final ListaService _listaService = ListaService();
  final EtiquetaService _etiquetaService = EtiquetaService();
  final PrioridadService _prioridadService = PrioridadService();
  final EstadoService _estadoService = EstadoService();

  // Variables observables
  RxBool cargando = false.obs;
  RxBool editando = false.obs;
  Rx<Tarea?> tarea = Rx<Tarea?>(null);
  Rx<Categoria?> categoria = Rx<Categoria?>(null);
  Rx<Lista?> lista = Rx<Lista?>(null);
  RxList<Etiqueta> etiquetas = <Etiqueta>[].obs;
  Rx<Prioridad?> priori = Rx<Prioridad?>(null);
  Rx<Estado?> estado = Rx<Estado?>(null);
  Color colorPrioridad = Colors.transparent; // Color de prioridad
  Color colorEstado = Colors.transparent; // Color de estado

  // Formateo de fechas
  RxString fechaCreacion = ''.obs;
  RxString horaCreacion = ''.obs;
  RxString fechaVencimiento = ''.obs;
  RxString horaVencimiento = ''.obs;

  // Constructor con ID de tarea opcional
  VerTareaController({int? tareaId}) {
    if (tareaId != null) {
      cargarTarea(tareaId);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Verificar si argumentos es un entero directamente o un mapa con clave tareaId
    if (Get.arguments != null) {
      if (Get.arguments is int) {
        cargarTarea(Get.arguments);
      } else if (Get.arguments is Map && Get.arguments['tareaId'] != null) {
        cargarTarea(Get.arguments['tareaId']);
      }
    }
  }

  //metodo para recargar la tarea
  void recargarTarea(tareaId) {
    cargarTarea(tareaId);
  }

  // Cargar todos los datos de la tarea
  Future<void> cargarTarea(int tareaId) async {
    try {
      cargando.value = true;

      // 1. Cargar datos básicos de la tarea
      final resultadoTarea = await _tareaService.obtenerTareaPorId(tareaId);

      if (resultadoTarea.status == 200 && resultadoTarea.body is Tarea) {
        tarea.value = resultadoTarea.body;
        print('Tarea cargada: ${tarea.value}');

        // Formatear fechas
        if (tarea.value != null) {
          // Formatear fecha de creación
          final DateTime fechaCreacionDt = tarea.value!.fechaCreacion.toLocal();
          fechaCreacion.value = DateFormat(
            'dd/MM/yyyy',
          ).format(fechaCreacionDt);
          horaCreacion.value = DateFormat('HH:mm').format(fechaCreacionDt);

          // Formatear fecha de vencimiento
          final DateTime fechaVencimientoDt =
              tarea.value!.fechaVencimiento.toLocal();
          fechaVencimiento.value = DateFormat(
            'dd/MM/yyyy',
          ).format(fechaVencimientoDt);
          horaVencimiento.value = DateFormat(
            'HH:mm',
          ).format(fechaVencimientoDt);

          // Cargar la categoría de la tarea
          final resultadoCategoria = await _categoriaService
              .obtenerCategoriaPorTareaId(tarea.value!.categoriaId);
          if (resultadoCategoria.status == 200 &&
              resultadoCategoria.body is Categoria) {
            categoria.value = resultadoCategoria.body;
          }

          // Cargar la lista de la tarea
          final resultadoLista = await _listaService.obtenerListaPorId(
            tarea.value!.listaId!,
          );
          if (resultadoLista.status == 200 && resultadoLista.body is Lista) {
            lista.value = resultadoLista.body;
          }
        }

        // 2. Cargar etiquetas de la tarea
        final resultadoEtiquetas = await _etiquetaService
            .obtenerEtiquetasDeTarea(tareaId);

        // Verificar si el resultado es una lista de etiquetas
        print('Resultado etiquetas: ${resultadoEtiquetas.body}');
        if (resultadoEtiquetas.status == 200 &&
            resultadoEtiquetas.body is List) {
          // Directamente asignar la lista de Etiqueta objetos
          List<Etiqueta> listaEtiquetas = resultadoEtiquetas.body;
          etiquetas.assignAll(listaEtiquetas);
        } else if (resultadoEtiquetas.status == 404) {
          // Lista vacía en caso de no encontrar etiquetas
          etiquetas.clear();
        } else {
          Get.snackbar(
            'Error',
            'No se pudieron cargar las etiquetas',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }

        //Cargar la prioridad de la tarea
        final resultadoPrioridad = await _prioridadService
            .obtenerPrioridadPorId(tarea.value!.prioridadId);
        if (resultadoPrioridad.status == 200 &&
            resultadoPrioridad.body is Prioridad) {
          priori.value = resultadoPrioridad.body;
        }

        // Cargar el estado de la tarea
        final resultadoEstado = await _estadoService.obtenerEstadoPorId(
          tarea.value!.estadoId,
        );
        if (resultadoEstado.status == 200 && resultadoEstado.body is Estado) {
          estado.value = resultadoEstado.body;
        }
      } else {
        Get.snackbar(
          'Error',
          'No se pudo cargar la tarea',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        // Volver atrás si no se puede cargar la tarea
        Get.back();
      }
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
      cargando.value = false;
    }
  }

  // Método mejorado para eliminar la tarea
  Future<bool> eliminarTarea(int tareaId) async {
    // Mostrar diálogo de confirmación antes de eliminar
    bool confirmar =
        await Get.dialog(
          AlertDialog(
            title: Text('Confirmar eliminación'),
            content: Text('¿Estás seguro de que deseas eliminar esta tarea?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
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
        // Notificar a otros controladores para que recarguen sus datos
        EventosControlador.solicitarRecarga();
        // O si prefieres notificar a un controlador específico:
        // EventosControlador.solicitarRecargaControlador('home_controller');

        return true;
      }

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

  //Metodo para obtener el color de la prioridad
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

  //Metodo para obtener el color del estado
  Color obtenerColorEstado(int estadoId) {
    switch (estadoId) {
      case 1:
        return Colors.blue; // Pendiente
      case 2:
        return Colors.orange; // En progreso
      case 3:
        return Colors.green; // Completada
      default:
        return Colors.transparent; // Sin color definido
    }
  }

  // Método para cambiar el estado de la tarea
  Future<bool> cambiarEstadoTarea(int nuevoEstadoId) async {
    if (tarea.value?.id == null) {
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
      final tareaId = tarea.value?.id;
      if (tareaId == null) {
        Get.snackbar(
          'Error',
          'No hay una tarea cargada para actualizar',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final resultado = await _tareaService.actualizarEstadoTarea(
        tareaId,
        nuevoEstadoId,
      );

      if (resultado.status == 200) {
        // Actualizar el estado local
        final resultadoEstado = await _estadoService.obtenerEstadoPorId(
          nuevoEstadoId,
        );
        if (resultadoEstado.status == 200 && resultadoEstado.body is Estado) {
          estado.value = resultadoEstado.body;

          // Actualizar el modelo de tarea
          tarea.value = tarea.value!.copyWith(estadoId: nuevoEstadoId);

          return true;
        }
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

  //Metodo para obtener el nombre de estado
  // Método para obtener el nombre del estado
  String obtenerNombreEstado() {
    if (estado.value != null) {
      return estado.value!.nombre;
    }
    return 'Desconocido';
  }

  // Método para obtener el nombre del estado de una tarea específica
  Future<String> obtenerNombreEstadoPorTareaId(int tareaId) async {
    try {
      final resultado = await _tareaService.obtenerEstadoTarea(tareaId);

      if (resultado.status == 200 && resultado.body != null) {
        // Extraer el nombre del estado de la respuesta
        final data = resultado.body;
        if (data is Map<String, dynamic>) {
          return data['nombre'] ?? 'Desconocido';
        }
      }

      return 'Desconocido';
    } catch (e) {
      print('Error al obtener nombre de estado: $e');
      return 'Error';
    }
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
