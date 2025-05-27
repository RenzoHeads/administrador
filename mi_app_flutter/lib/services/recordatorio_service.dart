import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/recordatorio.dart';
import '../../configs/contants.dart';
import '../../models/service_http_response.dart';

class RecordatorioService {
  // Crear recordatorio
  Future<ServiceHttpResponse> crearRecordatorio({
    required int tareaId,
    required DateTime fechaHora,
    String? tokenFCM,
    String? mensaje,
  }) async {
    final url = Uri.parse('${BASE_URL}recordatorios/crear');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'tarea_id': tareaId,
          'fecha_hora': fechaHora.toIso8601String(),
          'token_fcm': tokenFCM,
          'mensaje': mensaje,
        }),
      );

      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Recordatorio.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al crear el recordatorio: $e';
    }

    return responseWrapper;
  }

  // Obtener recordatorios por tarea
  Future<ServiceHttpResponse> obtenerRecordatoriosPorTarea(int tareaId) async {
    final url = Uri.parse('${BASE_URL}recordatorios/$tareaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final recordatorios =
              jsonData.map((json) => Recordatorio.fromMap(json)).toList();
          responseWrapper.body = recordatorios;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al obtener los recordatorios: $e';
    }

    return responseWrapper;
  }

  // Actualizar recordatorio
  Future<ServiceHttpResponse> actualizarRecordatorio({
    required int id,
    required int tareaId,
    required DateTime fechaHora,
    String? tokenFCM,
    String? mensaje,
  }) async {
    final url = Uri.parse('${BASE_URL}recordatorios/actualizar');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'id': id,
          'tarea_id': tareaId,
          'fecha_hora': fechaHora.toIso8601String(),
          'token_fcm': tokenFCM,
          'mensaje': mensaje,
        }),
      );

      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Recordatorio.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al actualizar el recordatorio: $e';
    }

    return responseWrapper;
  }

  // Eliminar recordatorio
  Future<ServiceHttpResponse> eliminarRecordatorio(int id) async {
    final url = Uri.parse('${BASE_URL}recordatorios/eliminar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.delete(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        responseWrapper.body = 'Recordatorio eliminado con éxito';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al eliminar el recordatorio: $e';
    }

    return responseWrapper;
  }
}
