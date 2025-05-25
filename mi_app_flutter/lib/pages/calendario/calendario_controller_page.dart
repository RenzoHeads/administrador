import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/tarea.dart';
import '../../services/tarea_service.dart';
import '../../services/controladorsesion.dart';

class CalendarioController extends GetxController {
  final focusedDay = DateTime.now().obs;
  final selectedDay = DateTime.now().obs;
  final tareasDelDia = <Tarea>[].obs;

  final _ctrlSesion = Get.find<ControladorSesionUsuario>();

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
    focusedDay.value = DateTime(focusedDay.value.year, focusedDay.value.month - 1, 1);
  }

  void nextMonth() {
    focusedDay.value = DateTime(focusedDay.value.year, focusedDay.value.month + 1, 1);
  }

  Future<void> _loadTareasDelDia(DateTime day) async {
    final uid = _ctrlSesion.usuarioActual.value?.id;
    if (uid == null) return;
    final resp = await TareaService().obtenerTareasPorUsuario(uid);
    if (resp.status == 200 && resp.body is List<Tarea>) {
      final todas = resp.body as List<Tarea>;
      tareasDelDia.value = todas.where((t) {
        final f = t.fechaVencimiento;
        return f.year == day.year && f.month == day.month && f.day == day.day;
      }).toList();
    } else {
      tareasDelDia.clear();
    }
  }
}
