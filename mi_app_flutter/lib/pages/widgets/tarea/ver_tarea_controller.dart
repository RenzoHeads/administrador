// =============== ver_tarea_controller.dart (modificado) ===============
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
import '../../widgets/lista/lista_item_controller.dart';
import '../../home/home_controler.dart';

class VerTareaController extends GetxController {
  final TareaService _tareaService = TareaService();
  final CategoriaService _categoriaService = CategoriaService();
  final ListaService _listaService = ListaService();
  final EtiquetaService _etiquetaService = EtiquetaService();
  final PrioridadService _prioridadService = PrioridadService();
  final EstadoService _estadoService = EstadoService();
  final HomeController _homeController = Get.find<HomeController>();

  // Variables observables (ya no son RxBool, son valores simples)
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
      false; // Nueva bandera para controlar si ya se cargaron datos

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
  static void actualizarTarea(int tareaId) {
    // Buscar el controlador por su tag único
    final String tag = 'tarea_$tareaId';
    if (Get.isRegistered<VerTareaController>(tag: tag)) {
      final controller = Get.find<VerTareaController>(tag: tag);
      controller.cargarTarea(tareaId);
    }
  }

  // Cargar todos los datos de la tarea
  Future<void> cargarTarea(int tareaId) async {
    try {
      if (cargando) return; // Evitar múltiples cargas simultáneas

      cargando = true;
      // Notificar solo a los widgets con ID específico
      update(['tarea_$tareaId']);

      // 1. Cargar datos básicos de la tarea
      final resultadoTarea = await _tareaService.obtenerTareaPorId(tareaId);

      print('Resultado tarea: ${resultadoTarea.body}');
      if (resultadoTarea.status == 200 && resultadoTarea.body is Tarea) {
        tarea = resultadoTarea.body;
        print('Tarea cargada: $tarea');

        // Formatear fechas
        if (tarea != null) {
          // Formatear fecha de creación
          final DateTime fechaCreacionDt = tarea!.fechaCreacion.toLocal();
          fechaCreacion = DateFormat('dd/MM/yyyy').format(fechaCreacionDt);
          horaCreacion = DateFormat('HH:mm').format(fechaCreacionDt);

          // Formatear fecha de vencimiento
          final DateTime fechaVencimientoDt = tarea!.fechaVencimiento.toLocal();
          fechaVencimiento = DateFormat(
            'dd/MM/yyyy',
          ).format(fechaVencimientoDt);
          horaVencimiento = DateFormat('HH:mm').format(fechaVencimientoDt);

          // Cargar la categoría de la tarea
          final resultadoCategoria = await _categoriaService
              .obtenerCategoriaPorTareaId(tarea!.categoriaId);
          if (resultadoCategoria.status == 200 &&
              resultadoCategoria.body is Categoria) {
            categoria = resultadoCategoria.body;
          }

          // Cargar la lista de la tarea
          final resultadoLista = await _listaService.obtenerListaPorId(
            tarea!.listaId!,
          );
          if (resultadoLista.status == 200 && resultadoLista.body is Lista) {
            lista = resultadoLista.body;
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
          etiquetas = listaEtiquetas;
        } else if (resultadoEtiquetas.status == 404) {
          // Lista vacía en caso de no encontrar etiquetas
          etiquetas = [];
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
            .obtenerPrioridadPorId(tarea!.prioridadId);
        if (resultadoPrioridad.status == 200 &&
            resultadoPrioridad.body is Prioridad) {
          priori = resultadoPrioridad.body;
        }

        // Cargar el estado de la tarea
        final resultadoEstado = await _estadoService.obtenerEstadoPorId(
          tarea!.estadoId,
        );
        if (resultadoEstado.status == 200 && resultadoEstado.body is Estado) {
          estado = resultadoEstado.body;
        }

        // Marcar que los datos ya se cargaron para evitar recargas innecesarias
        datosYaCargados = true;
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
      cargando = false;
      // Notificar específicamente a los widgets con este ID
      update(['tarea_$tareaId']);
    }
  }

  // Método para actualizar selectivamente solo ciertos datos
  Future<void> actualizarDatos() async {
    if (tarea?.id == null) return;

    try {
      // Actualizar estado de la tarea sin recargar todo
      final resultadoTarea = await _tareaService.obtenerTareaPorId(tarea!.id!);
      if (resultadoTarea.status == 200 && resultadoTarea.body is Tarea) {
        tarea = resultadoTarea.body;

        // Actualizar el estado si cambió
        final resultadoEstado = await _estadoService.obtenerEstadoPorId(
          tarea!.estadoId,
        );
        if (resultadoEstado.status == 200 && resultadoEstado.body is Estado) {
          estado = resultadoEstado.body;
        }

        // Notificar específicamente a los widgets con este ID
        update(['tarea_$tareaId']);
      }
    } catch (e) {
      print('Error al actualizar datos: $e');
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
        // Notificar a los widgets que escuchan este controller
        if (tarea?.listaId != null) {
          ListaItemController.actualizarLista(tarea!.listaId!);
        }
        _homeController.cargarTareasDelUsuario();
        // Usar el nuevo método estático para acceder al controlador
        // y eliminar la tarea visualmente

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
        return Colors
            .green; // En progreso (cambiado a verde para indicar completa)
      case 3:
        return Colors.orange; // Completada (cambiado a naranja)
      default:
        return Colors.transparent; // Sin color definido
    }
  }

  // Método para cambiar el estado de la tarea
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
      final tareaId = tarea?.id;
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
          estado = resultadoEstado.body;

          // Actualizar el modelo de tarea
          tarea = tarea!.copyWith(estadoId: nuevoEstadoId);

          // Notificar específicamente a los widgets con este ID
          update(['tarea_$tareaId']);

          // Si se desea actualizar la lista asociada
          if (tarea?.listaId != null) {
            ListaItemController.actualizarLista(tarea!.listaId!);
          }
          // Recargar tareas del usuario
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

  // Método para obtener el nombre del estado
  String obtenerNombreEstado() {
    if (estado != null) {
      return estado!.nombre;
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
