import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/recordatorio.dart';
import '../../models/tarea.dart';
import '../principal/principal_controller.dart';
import '../../services/controladorsesion.dart';

class NotificacionController extends ChangeNotifier {
  List<Recordatorio> _recordatorios = [];
  List<Recordatorio> get recordatorios => _recordatorios;

  final int usuarioId; // Id del usuario para filtrar
  final _principalController = Get.find<PrincipalController>();
  final _ctrlSesion = Get.find<ControladorSesionUsuario>();

  NotificacionController({required this.usuarioId});

  Future<void> cargarRecordatoriosDelDia() async {
    try {
      final uid = _ctrlSesion.usuarioActual.value?.id;
      if (uid == null) {
        _recordatorios = [];
        notifyListeners();
        return;
      }

      // Usar principal controller en lugar de servicio directo
      final todasLasTareas = await _principalController.ObtenerTareasUsuario();

      // Obtener fecha y hora actual en hora local
      final DateTime ahora = DateTime.now().toLocal();
      final DateTime hoyInicio = DateTime(ahora.year, ahora.month, ahora.day);
      final DateTime hoyFin = hoyInicio.add(Duration(days: 1));

      List<Recordatorio> tareasHoy = [];

      for (Tarea tarea in todasLasTareas) {
        // Convertir la fecha de creación a hora local
        final fechaCreacionLocal = tarea.fechaCreacion.toLocal();

        // Filtrar solo tareas creadas hoy que aún no han pasado su hora
        if (fechaCreacionLocal.isAfter(hoyInicio) &&
            fechaCreacionLocal.isBefore(hoyFin) &&
            fechaCreacionLocal.isAfter(ahora)) {
          tareasHoy.add(
            Recordatorio(
              id: tarea.id!,
              tareaId: tarea.id!,
              fechaHora: fechaCreacionLocal,
              mensaje: tarea.titulo,
            ),
          );
        }
      }

      // Ordenar la lista por fecha de creación (más próximas primero)
      tareasHoy.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

      _recordatorios = tareasHoy;
      notifyListeners();
    } catch (e) {
      print('Error al cargar recordatorios: $e');
      _recordatorios = [];
      notifyListeners();
    }
  }

  //metodo para recargar pagina desde cualquier lugar
  Future<void> recargarNotificaciones() async {
    await cargarRecordatoriosDelDia();
  }
}
