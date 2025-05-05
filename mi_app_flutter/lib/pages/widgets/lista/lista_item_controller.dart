import 'package:get/get.dart';
import '../../../models/lista.dart';
import '../../../services/lista_service.dart';

class ListaItemController extends GetxController {
  final int listaId;
  final ListaService _listasService = ListaService();

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
    // No hay suscripciones a eventos aquí, se manejan en el widget
  }

  Future<void> cargarDatos() async {
    isLoading.value = true;

    try {
      // Carga los datos de la lista
      final listaResponse = await _listasService.obtenerListaPorId(listaId);
      if (listaResponse.status == 200 && listaResponse.body is Lista) {
        lista.value = listaResponse.body;
      }

      // Carga la cantidad de tareas
      final tareasResponse = await _listasService.obtenerCantidadTareasPorLista(
        listaId,
      );
      if (tareasResponse.status == 200 && tareasResponse.body is int) {
        totalTareas.value = tareasResponse.body;
      }

      // Carga la cantidad de tareas pendientes
      final tareasPendientesResponse = await _listasService
          .obtenerCantidadTareasPendientesPorLista(listaId);
      if (tareasPendientesResponse.status == 200 &&
          tareasPendientesResponse.body is int) {
        tareasPendientes.value = tareasPendientesResponse.body;
      }
    } catch (e) {
      print('Error al cargar datos del ítem de lista $listaId: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
