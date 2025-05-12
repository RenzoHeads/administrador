import 'package:get/get.dart';
import '../../../../models/lista.dart';
import '../../home_controler.dart';

class ListaTabController extends GetxController {
  HomeController? _homeController;
  RxList<Lista> listas = <Lista>[].obs;
  RxBool cargando = true.obs;

  void setHomeController(HomeController controller) {
    _homeController = controller;
    cargarListas();
  }

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> cargarListas() async {
    if (_homeController == null) return;

    cargando(true);
    try {
      listas.value = await _homeController!.obtenerListaUsuario();
    } finally {
      cargando(false);
    }
  }
}
