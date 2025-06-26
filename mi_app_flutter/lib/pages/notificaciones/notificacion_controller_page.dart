import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/recordatorio.dart';
import '../../configs/contants.dart';
import '../../services/auth_service.dart';

class NotificacionController extends ChangeNotifier {
  List<Recordatorio> _recordatorios = [];
  List<Recordatorio> get recordatorios => _recordatorios;

  final int usuarioId; // Id del usuario para filtrar

  NotificacionController({required this.usuarioId});

  Future<void> cargarRecordatoriosDelDia() async {
    try {
      // Verificar si hay token antes de hacer la petición
      final token = await AuthService.getJwtToken();
      if (token == null || token.isEmpty) {
        _recordatorios = [];
        notifyListeners();
        return;
      }

      final headers = await AuthService.getAuthHeaders();
      final url = '${BASE_URL}tareas/$usuarioId';
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        DateTime hoy = DateTime.now();
        DateTime hoyInicio = DateTime(hoy.year, hoy.month, hoy.day);
        DateTime hoyFin = hoyInicio.add(Duration(days: 1));

        List<Recordatorio> tareasHoy = [];

        for (var tareaJson in data) {
          // La fecha_vencimiento viene en formato "YYYY-MM-DD HH:MM:SS"
          String fechaVencStr = tareaJson['fecha_creacion'];
          DateTime fechaVenc = DateTime.parse(fechaVencStr).toLocal();

          // Filtrar solo tareas que vencen hoy
          if (fechaVenc.isAfter(hoyInicio) && fechaVenc.isBefore(hoyFin)) {
            tareasHoy.add(
              Recordatorio(
                id: tareaJson['id'],
                tareaId: tareaJson['id'],
                fechaHora: fechaVenc,
                mensaje: tareaJson['titulo'] ?? 'Sin título',
              ),
            );
          }
        }

        _recordatorios = tareasHoy;
        notifyListeners();
      } else if (response.statusCode == 401) {
        AuthService.handleUnauthorized();
        _recordatorios = [];
        notifyListeners();
      } else {
        _recordatorios = [];
        notifyListeners();
      }
    } catch (e) {
      _recordatorios = [];
      notifyListeners();
    }
  }

  //metodo para recargar pagina desde cualquier lugar
  Future<void> recargarNotificaciones() async {
    await cargarRecordatoriosDelDia();
  }
}
