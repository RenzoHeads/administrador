import 'package:get/get.dart';

import '../../models/tarea.dart';
import '../../services/controladorsesion.dart';
import '../principal/principal_controller.dart';

class CalendarioController extends GetxController {
  final focusedDay = DateTime.now().obs;
  final selectedDay = DateTime.now().obs;
  final tareasDelDia = <Tarea>[].obs;

  final _ctrlSesion = Get.find<ControladorSesionUsuario>();
  final _principalController = Get.find<PrincipalController>();

  @override
  void onInit() {
    super.onInit();
    _loadTareasDelDia(selectedDay.value);
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
    _loadTareasDelDia(selected);
  }

  void previousMonth() {
    focusedDay.value = DateTime(
      focusedDay.value.year,
      focusedDay.value.month - 1,
      1,
    );
  }

  void nextMonth() {
    focusedDay.value = DateTime(
      focusedDay.value.year,
      focusedDay.value.month + 1,
      1,
    );
  }

  // Función de recarga para actualizar el calendario
  Future<void> recargarCalendario() async {
    await _loadTareasDelDia(selectedDay.value);
  }

  Future<void> _loadTareasDelDia(DateTime day) async {
    final uid = _ctrlSesion.usuarioActual.value?.id;
    if (uid == null) return;

    // Usar principal controller en lugar de servicio directo
    final todasLasTareas = await _principalController.ObtenerTareasUsuario();

    // Crear rango del día seleccionado en hora local
    DateTime diaInicio = DateTime(day.year, day.month, day.day);
    DateTime diaFin = diaInicio.add(Duration(days: 1));

    tareasDelDia.value =
        todasLasTareas.where((tarea) {
          // Convertir la fecha de creación a hora local antes de filtrar
          final fechaCreacionLocal = tarea.fechaCreacion.toLocal();
          return fechaCreacionLocal.isAfter(diaInicio) &&
              fechaCreacionLocal.isBefore(diaFin);
        }).toList();
  }
}
