// Corrección en HomeController.dart
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/lista.dart';
import '../../models/tarea.dart';

import '../../pages/principal/principal_controller.dart';
import '../home/tabs/tarea_tab/task_tab_controller.dart';
import '../home/tabs/lista_tab/lista_tab_controller.dart';
import '../home/tabs/perfil_tab/profile_tab_controller.dart';

class HomeController extends GetxController {
  final PrincipalController _principalController =
      Get.find<PrincipalController>();

  // Controladores de los tabs
  late final TaskTabController taskController;
  late final ListaTabController listaController;
  late final ProfileTabController profileController;

  RxList<Tarea> tareasDeHoy = <Tarea>[].obs;
  RxList<Lista> listas = <Lista>[].obs;

  RxBool cargando = true.obs;

  RxInt pestanaSeleccionada = 0.obs;

  // Para la fecha actual
  RxString fechaActual = ''.obs;

  // Subtítulo dinámico según la pestaña seleccionada
  String get subtituloActual {
    switch (pestanaSeleccionada.value) {
      case 0:
        return 'Tareas';
      case 1:
        return 'Objetivos';
      case 2:
        return 'Configuración';
      default:
        return 'Tareas';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _inicializarControladores();
    cargarFechaActual();
    _cargarDatosIniciales();
  }

  void _inicializarControladores() {
    taskController = Get.put(TaskTabController());
    listaController = Get.put(ListaTabController());
    profileController = Get.put(ProfileTabController());

    taskController.setHomeController(this);
    listaController.setHomeController(this);
    profileController.setHomeController(this);
  }

  void _cargarDatosIniciales() async {
    cargando(true);
    try {
      cargarHome();
    } finally {
      cargando(false);
    }
  }

  void cargarFechaActual() {
    try {
      final now = DateTime.now();
      final formatter = DateFormat('EEEE, d MMMM', 'es_ES');
      String fecha = formatter.format(now);
      // Capitalizar primera letra
      fecha = fecha.substring(0, 1).toUpperCase() + fecha.substring(1);
      fechaActual.value = fecha;
    } catch (e) {
      // Fallback simple si hay error con el formato
      fechaActual.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  void cambiarPestana(int index) {
    pestanaSeleccionada.value = index;
  }

  void cargarHome() {
    ever(_principalController.datosCargados, (bool cargados) {
      if (cargados) {
        recargarTodo();
      }
    });
  }

  Future<void> recargarTodo() async {
    cargando(true);
    try {
      await taskController.cargarTareas();
      await listaController.cargarListas();
    } finally {
      cargando(false);
    }
  }

  Future<void> recargarFotoPerfil() async {
    await _principalController.forzarRecargaFoto();
  }

  Color colorDesdeString(String colorString, {int alpha = 80}) {
    try {
      String hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        // Agregar opacidad personalizada
        return Color(
          int.parse('0x${alpha.toRadixString(16).padLeft(2, '0')}$hex'),
        );
      } else if (hex.length == 8) {
        // Ya incluye opacidad, se respeta
        return Color(int.parse('0x$hex'));
      }
    } catch (_) {}
    return Colors.white; // fallback
  }

  // Método para cerrar la sesión
  void cerrarSesionCompleta() {
    _principalController.cerrarSesionCompleta();
  }

  // Métodos para obtener datos del PrincipalController
  Future<List<Tarea>> obtenerTareasUsuario() async {
    return await _principalController.ObtenerTareasUsuario();
  }

  Future<List<Lista>> obtenerListaUsuario() async {
    return await _principalController.ObtenerListaUsuario();
  }
}
