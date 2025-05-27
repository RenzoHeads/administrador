import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/tarea.dart';
import '../../models/lista.dart';
import '../principal/principal_controller.dart';

class BuscadorController extends GetxController {
  final PrincipalController _principal = Get.find<PrincipalController>();

  final tareasEncontradas = <Tarea>[].obs;
  final todasLasTareas = <Tarea>[].obs;
  final listasEncontradas = <Lista>[].obs;
  final todasLasListas = <Lista>[].obs;

  final cargando = false.obs;
  final textoBusqueda = ''.obs;

  final TextEditingController buscadorController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    ever(_principal.datosCargados, (bool cargados) {
      if (cargados) {
        cargarTodasLasListasYtareas();
      }
    });

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

  Future<void> cargarTodasLasListasYtareas() async {
    todasLasTareas.assignAll(_principal.tareas);
    todasLasListas.assignAll(_principal.listas);
    tareasEncontradas.assignAll(todasLasTareas);
    listasEncontradas.assignAll(todasLasListas);
  }

  Future<void> buscarTareas(String texto) async {
    if (texto.isEmpty) {
      tareasEncontradas.assignAll(todasLasTareas);
      listasEncontradas.assignAll(todasLasListas);
      return;
    }

    cargando.value = true;
    try {
      final tareasFiltradas =
          todasLasTareas
              .where(
                (t) => t.titulo.toLowerCase().contains(texto.toLowerCase()),
              )
              .toList();
      final listasFiltradas =
          todasLasListas
              .where(
                (l) => l.nombre.toLowerCase().contains(texto.toLowerCase()),
              )
              .toList();

      tareasEncontradas.assignAll(tareasFiltradas);
      listasEncontradas.assignAll(listasFiltradas);
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

  void actualizarTextoBusqueda(String texto) {
    textoBusqueda.value = texto;
    buscadorController.text = texto;
    if (texto.isEmpty) {
      tareasEncontradas.assignAll(todasLasTareas);
      listasEncontradas.assignAll(todasLasListas);
    }
  }

  List<Tarea> get ListaTareasBusqueda => tareasEncontradas.toList();
  List<Lista> get ListaListasBusqueda => listasEncontradas.toList();

  Future<void> recargarBuscador() async {
    await cargarTodasLasListasYtareas();
  }
}
