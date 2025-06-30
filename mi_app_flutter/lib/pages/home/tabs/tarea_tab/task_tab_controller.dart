import 'package:get/get.dart';
import '../../../../models/tarea.dart';
import '../../home_controler.dart';

class TaskTabController extends GetxController {
  HomeController? _homeController;
  RxList<Tarea> tareasDeHoy = <Tarea>[].obs;

  void setHomeController(HomeController controller) {
    _homeController = controller;
    cargarTareas();
  }

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> cargarTareas() async {
    if (_homeController == null) return;

    final todasLasTareas = await _homeController!.obtenerTareasUsuario();

    // Obtener fecha actual en hora local
    DateTime hoy = DateTime.now();
    DateTime hoyInicio = DateTime(hoy.year, hoy.month, hoy.day);
    DateTime hoyFin = hoyInicio.add(Duration(days: 1));

    tareasDeHoy.value =
        todasLasTareas.where((tarea) {
          // Convertir la fecha de creación a hora local antes de filtrar
          final fechaCreacionLocal = tarea.fechaCreacion.toLocal();
          return fechaCreacionLocal.isAfter(hoyInicio) &&
              fechaCreacionLocal.isBefore(hoyFin);
        }).toList();
  }
}
