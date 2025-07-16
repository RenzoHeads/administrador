import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/recordatorio.dart';
import '../../models/tarea.dart';
import '../principal/principal_controller.dart';
import '../../services/controladorsesion.dart';
import '../home/tabs/perfil_tab/profile_tab_controller.dart';

class NotificacionController extends ChangeNotifier {
  List<Recordatorio> _recordatorios = [];
  List<Recordatorio> _recordatoriosCompletos = []; // Lista completa sin filtrar
  List<Recordatorio> get recordatorios => _recordatorios;

  // Nuevo getter para saber si las notificaciones están desactivadas
  bool get notificacionesDesactivadas =>
      !_profileController.notificacionesSistema.value;

  final int usuarioId; // Id del usuario para filtrar
  final _principalController = Get.find<PrincipalController>();
  final _ctrlSesion = Get.find<ControladorSesionUsuario>();
  final _profileController = Get.find<ProfileTabController>();

  NotificacionController({required this.usuarioId}) {
    // Escuchar cambios en los switches del ProfileTabController
    _profileController.notificacionesSistema.listen(
      (_) => _aplicarFiltrosYNotificar(),
    );
    _profileController.notificacionesUrgentes.listen(
      (_) => _aplicarFiltrosYNotificar(),
    );
  }

  Future<void> cargarRecordatoriosDelDia() async {
    try {
      final uid = _ctrlSesion.usuarioActual.value?.id;

      if (uid == null) {
        _recordatorios = [];
        notifyListeners();
        return;
      }

      // Usar principal controller en lugar de servicio directo
      final todasLasTareas = _principalController.tareas;

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

      _recordatoriosCompletos = tareasHoy;
      _aplicarFiltros();
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

  void _aplicarFiltros() {
    if (!_profileController.notificacionesSistema.value) {
      // Botón 1 desactivado: no mostrar notificaciones
      _recordatorios = [];
      return;
    }

    if (_profileController.notificacionesUrgentes.value) {
      // Botón 2 activado: mostrar solo notificaciones de prioridad alta (prioridadId = 3)
      _filtrarPorPrioridadAlta();
    } else {
      // Botón 2 desactivado: mostrar todas las notificaciones
      _recordatorios = List.from(_recordatoriosCompletos);
    }
  }

  void _aplicarFiltrosYNotificar() {
    _aplicarFiltros();
    notifyListeners();
  }

  Future<void> _filtrarPorPrioridadAlta() async {
    try {
      final todasLasTareas = await _principalController.ObtenerTareasUsuario();

      _recordatorios =
          _recordatoriosCompletos.where((recordatorio) {
            final tarea = todasLasTareas.firstWhereOrNull(
              (t) => t.id == recordatorio.tareaId,
            );
            return tarea?.prioridadId == 3;
          }).toList();
    } catch (e) {
      print('Error al filtrar por prioridad alta: $e');
      _recordatorios = List.from(_recordatoriosCompletos);
    }
  }
}
