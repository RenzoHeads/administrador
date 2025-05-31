import 'package:get/get.dart';
import '../../../models/lista.dart';
import '../../principal/principal_controller.dart'; // Importamos el PrincipalController

class ListaItemController extends GetxController {
  final int listaId;
  final PrincipalController _principalController =
      Get.find<PrincipalController>();

  // Variables observables
  final Rx<Lista?> lista = Rx<Lista?>(null);
  final RxInt totalTareas = 0.obs;
  final RxInt tareasPendientes = 0.obs;
  final RxBool isLoading = true.obs;

  ListaItemController(this.listaId);

  @override
  void onInit() {
    super.onInit();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    isLoading.value = true;

    try {
      // Obtener la lista desde el PrincipalController
      final listas = await _principalController.ObtenerListaUsuario();
      final listaEncontrada = listas.firstWhereOrNull(
        (lista) => lista.id == listaId,
      );
      if (listaEncontrada != null) {
        lista.value = listaEncontrada;
      }

      // Obtener la cantidad total de tareas desde el PrincipalController
      totalTareas.value = await _principalController.ObtenerTareasPorLista(
        listaId,
      );

      // Obtener la cantidad de tareas pendientes desde el PrincipalController
      tareasPendientes.value =
          await _principalController.ObtenerTareasPendientesPorLista(listaId);
    } catch (e) {
      print('Error al cargar datos del ítem de lista $listaId: $e');
    } finally {
      isLoading.value = false;

      // Notifica explícitamente a los widgets que escuchan por este ID específico
      update(['lista_$listaId']);
    }
  }

  // Método estático para actualizar una lista específica desde cualquier lugar
  static Future<void> actualizarLista(int? listaId) async {
    if (listaId != null) {
      final String tag = 'lista_$listaId';
      if (Get.isRegistered<ListaItemController>(tag: tag)) {
        final controller = Get.find<ListaItemController>(tag: tag);
        await controller.cargarDatos();
      }
    }
  }

  //Metodo para eliminar una lista específica desde cualquier lugar y que se destruya
  static Future<void> eliminarLista(int? listaId) async {
    if (listaId != null) {
      final String tag = 'lista_$listaId';
      if (Get.isRegistered<ListaItemController>(tag: tag)) {
        Get.delete<ListaItemController>(tag: tag);
      }
    }
  }
}
