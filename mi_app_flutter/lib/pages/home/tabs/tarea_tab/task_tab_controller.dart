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
    tareasDeHoy.value =
        todasLasTareas.where((tarea) {
          final fechaLimite = tarea.fechaCreacion;
          return fechaLimite.year == DateTime.now().year &&
              fechaLimite.month == DateTime.now().month &&
              fechaLimite.day == DateTime.now().day;
        }).toList();
  }
}
