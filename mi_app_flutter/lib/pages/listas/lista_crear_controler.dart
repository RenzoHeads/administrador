import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home_controler.dart';
import '../../models/lista.dart';
import '../../services/lista_service.dart';
import '../../services/controladorsesion.dart';

class CrearListaController extends GetxController {
  final ListaService _listaService = ListaService();
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();
  final HomeController _homeController = Get.find<HomeController>();
  // TextEditingControllers
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();

  // Variables observables
  RxBool cargando = false.obs;
  Rx<Color> colorSeleccionado =
      Color(0xFF4CAF50).obs; // Color verde por defecto

  // Lista de colores predefinidos
  final List<Color> coloresPredefinidos = [
    Color(0xFF4CAF50), // Verde
    Color(0xFF2196F3), // Azul
    Color(0xFFF44336), // Rojo
    Color(0xFFFF9800), // Naranja
    Color(0xFF9C27B0), // Púrpura
    Color(0xFF795548), // Marrón
    Color(0xFF607D8B), // Gris azulado
    Color(0xFFE91E63), // Rosa
    Color(0xFF009688), // Verde azulado
    Color(0xFFFFEB3B), // Amarillo
  ];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    nombreController.dispose();
    descripcionController.dispose();
    super.onClose();
  }

  void seleccionarColor(Color color) {
    colorSeleccionado.value = color;
  }

  // Convertir Color a formato hexadecimal
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  Future<void> crearLista() async {
    if (nombreController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'El nombre de la lista es obligatorio',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      cargando.value = true;
      final usuario = _sesion.usuarioActual.value;
      if (usuario == null || usuario.id == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Formatear fechas para la API
      final colorHex = _colorToHex(colorSeleccionado.value);

      // Crear la lista
      final resultado = await _listaService.crearLista(
        usuarioId: usuario.id!,
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        color: colorHex,
      );

      if (resultado.status != 200 || !(resultado.body is Lista)) {
        throw Exception('No se pudo crear la lista');
      }

      // Recargar datos
      _homeController.recargarDatos();

      Get.back(result: true);

      Get.snackbar(
        'Éxito',
        'Lista creada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error al crear la lista: $e');
      Get.snackbar(
        'Error',
        'No se pudo crear la lista: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      cargando.value = false;
    }
  }
}
