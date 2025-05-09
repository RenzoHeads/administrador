import '../../services/tarea_service.dart';
import '../../models/tarea.dart';
import '../../services/controladorsesion.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class BuscadorController extends GetxController {
  final TareaService _tareaService = TareaService();
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();

  // Variables reactivas
  final tareasEncontradas = <Tarea>[].obs;
  final todasLasTareas = <Tarea>[].obs;
  final cargando = false.obs;
  final textoBusqueda = ''.obs;

  // Controlador para el campo de texto
  final TextEditingController buscadorController = TextEditingController();

  // Timer para el debounce
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    cargarTodasLasTareas();

    // Listener para el texto de búsqueda con debounce
    ever(textoBusqueda, (_) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        buscarTareas(textoBusqueda.value);
      });
    });
  }

  @override
  void onClose() {
    buscadorController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  // Cargar todas las tareas del usuario
  Future<void> cargarTodasLasTareas() async {
    cargando.value = true;
    try {
      final usuario = _sesion.usuarioActual.value;
      if (usuario?.id == null) {
        Get.snackbar(
          'Error',
          'No hay usuario activo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
        cargando.value = false;
        return;
      }

      final response = await _tareaService.obtenerTareasPorUsuario(
        usuario!.id!,
      );

      print('Response: ${response.status}');

      if (response.status == 200 && response.body is List) {
        // Asignar las tareas obtenidas
        todasLasTareas.assignAll(response.body as List<Tarea>);
        tareasEncontradas.assignAll(todasLasTareas);
      } else if (response.status == 404) {
        // No hay tareas - configurar listas vacías
        todasLasTareas.clear();
        tareasEncontradas.clear();
        Get.snackbar(
          'Información',
          'No tienes tareas registradas aún',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue[300],
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else if (response.body is String &&
          (response.body as String).contains('Error al procesar el JSON')) {
        // Error específico de procesamiento JSON
        Get.snackbar(
          'Error',
          'Problema al procesar los datos recibidos',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
      } else {
        // Otro tipo de error
        Get.snackbar(
          'Error',
          'No se pudieron cargar las tareas',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar tareas: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    } finally {
      cargando.value = false;
    }
  }

  // Buscar tareas por título
  Future<void> buscarTareas(String texto) async {
    if (texto.isEmpty) {
      // Si el texto está vacío, mostrar todas las tareas
      tareasEncontradas.assignAll(todasLasTareas);
      return;
    }

    cargando.value = true;
    try {
      final usuario = _sesion.usuarioActual.value;
      if (usuario?.id == null) {
        Get.snackbar(
          'Error',
          'No hay usuario activo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
        cargando.value = false;
        return;
      }

      final response = await _tareaService.buscarTareasPorTitulo(
        usuario!.id!,
        texto,
      );

      if (response.status == 200 && response.body is List) {
        // Asignar las tareas encontradas
        final tareas = response.body as List<Tarea>;
        tareasEncontradas.assignAll(tareas);

        if (tareas.isEmpty) {
          Get.snackbar(
            'Información',
            'No se encontraron tareas con ese título',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue[300],
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      } else if (response.status == 404) {
        // Si no se encontraron tareas, mostrar lista vacía
        tareasEncontradas.clear();
        Get.snackbar(
          'Información',
          'No se encontraron tareas con ese título',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue[300],
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else if (response.body is String &&
          (response.body as String).contains('Error al procesar el JSON')) {
        // Error específico de procesamiento JSON
        Get.snackbar(
          'Error',
          'Problema al procesar los datos recibidos',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
      } else {
        // Otro tipo de error pero mantener datos existentes
        Get.snackbar(
          'Error',
          'No se pudieron obtener resultados de búsqueda',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error en la búsqueda: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    } finally {
      cargando.value = false;
    }
  }

  // Actualizar texto de búsqueda
  void actualizarTextoBusqueda(String texto) {
    textoBusqueda.value = texto;
    buscadorController.text = texto;
    if (texto.isEmpty) {
      // Restablece la lista a todas las tareas cuando se borra el texto
      tareasEncontradas.assignAll(todasLasTareas);
    }
  }

  // Getter para lista de tareas encontrada (versión no reactiva)
  List<Tarea> get ListaTareasBusqueda => tareasEncontradas.toList();
}
