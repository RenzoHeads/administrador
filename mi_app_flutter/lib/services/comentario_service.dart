import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/comentario.dart';
import '../../configs/contants.dart';
import '../../models/service_http_response.dart';

class ComentarioService {
  // Crear comentario
  Future<ServiceHttpResponse> crearComentario({
    required int tareaId,
    required String texto,
  }) async {
    final url = Uri.parse('${BASE_URL}comentarios/crear');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tarea_id': tareaId,
          'texto': texto,
        }),
      );

      responseWrapper.status = response.statusCode;
      
      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Comentario.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al crear el comentario: $e';
    }

    return responseWrapper;
  }

  // Obtener comentarios por tarea
  Future<ServiceHttpResponse> obtenerComentariosPorTarea(int tareaId) async {
    final url = Uri.parse('${BASE_URL}comentarios/$tareaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final comentarios = jsonData.map((json) => Comentario.fromMap(json)).toList();
          responseWrapper.body = comentarios;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener los comentarios: $e';
    }

    return responseWrapper;
  }

  // Actualizar comentario
  Future<ServiceHttpResponse> actualizarComentario({
    required int id,
    required int tareaId,
    required String texto,
  }) async {
    final url = Uri.parse('${BASE_URL}comentarios/actualizar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tarea_id': tareaId,
          'texto': texto,
        }),
      );

      responseWrapper.status = response.statusCode;
      
      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Comentario.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al actualizar el comentario: $e';
    }

    return responseWrapper;
  }

  // Eliminar comentario
  Future<ServiceHttpResponse> eliminarComentario(int id) async {
    final url = Uri.parse('${BASE_URL}comentarios/eliminar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.delete(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        responseWrapper.body = 'Comentario eliminado con éxito';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al eliminar el comentario: $e';
    }

    return responseWrapper;
  }
}