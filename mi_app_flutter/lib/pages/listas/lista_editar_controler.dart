import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/lista.dart';
import '../../services/lista_service.dart';
import '../../services/controladorsesion.dart';
import '../../pages/principal/principal_controller.dart';
import '../widgets/lista/lista_item_controller.dart';

class EditarListaController extends GetxController {
  final ListaService _listaService = ListaService();
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();
  final PrincipalController _principalController =
      Get.find<PrincipalController>();

  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  Rx<Color> colorSeleccionado = Color(0xFF4CAF50).obs;
  RxBool cargando = false.obs;

  late Lista listaOriginal;

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
  void inicializarDesdeLista(Lista lista) {
    listaOriginal = lista;
    nombreController.text = lista.nombre;
    descripcionController.text = lista.descripcion;
    colorSeleccionado.value = _colorFromHex(lista.color);
  }

  void seleccionarColor(Color color) {
    colorSeleccionado.value = color;
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    return Color(int.parse(hexColor, radix: 16));
  }

  Future<void> actualizarLista() async {
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
      final colorHex = _colorToHex(colorSeleccionado.value);
      final resultado = await _listaService.actualizarLista(
        id: listaOriginal.id!,
        usuarioId: usuario.id!,
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        color: colorHex,
      );
      if (resultado.status == 200 && resultado.body is Lista) {
        await _principalController.EditarLista(resultado.body as Lista);

        // Actualizar el ListaItemController específico para esta lista
        await ListaItemController.actualizarLista(listaOriginal.id!);

        Get.back(result: true);
        Get.snackbar(
          'Éxito',
          'Lista actualizada correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(
          'Error en la respuesta del servidor: ${resultado.body}',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la lista: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      cargando.value = false;
    }
  }

  @override
  void onClose() {
    nombreController.dispose();
    descripcionController.dispose();
    super.onClose();
  }
}
