import '../../models/tarea.dart';
import '../../services/controladorsesion.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../principal/principal_controller.dart';

class BuscadorController extends GetxController {
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();
  final PrincipalController _principal = Get.find<PrincipalController>();

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
    ever(_principal.datosCargados, (bool cargados) {
      if (cargados) {
        cargarTodasLasTareas();
      }
    });
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
    final tareas = _principal.tareas;
    todasLasTareas.assignAll(tareas);
    // Actualizar también tareasEncontradas cuando se cargan los datos
    tareasEncontradas.assignAll(todasLasTareas);
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
      final buscando =
          _principal.tareas
              .where((tarea) => tarea.titulo.contains(texto))
              .toList();
      tareasEncontradas.assignAll(buscando);
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

  //Recargar tareas
  Future<void> recargarBuscador() async {
    await cargarTodasLasTareas();
  }
}
