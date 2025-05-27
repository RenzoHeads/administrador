import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/etiqueta.dart';
import '../../configs/contants.dart';
import '../../models/service_http_response.dart';

class EtiquetaService {
  // Crear etiqueta
  Future<ServiceHttpResponse> crearEtiqueta({
    required String nombre,
    required String color,
  }) async {
    final url = Uri.parse('${BASE_URL}etiquetas/crear');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'nombre': nombre, 'color': color}),
      );

      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Etiqueta.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al crear la etiqueta: $e';
    }

    return responseWrapper;
  }

  // Actualizar etiqueta
  Future<ServiceHttpResponse> actualizarEtiqueta({
    required int id,
    required String nombre,
    required String color,
  }) async {
    final url = Uri.parse('${BASE_URL}etiquetas/actualizar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'nombre': nombre, 'color': color}),
      );

      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Etiqueta.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al actualizar la etiqueta: $e';
    }

    return responseWrapper;
  }

  // Eliminar etiqueta
  Future<ServiceHttpResponse> eliminarEtiqueta(int id) async {
    final url = Uri.parse('${BASE_URL}etiquetas/eliminar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.delete(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        responseWrapper.body = 'Etiqueta eliminada con éxito';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al eliminar la etiqueta: $e';
    }

    return responseWrapper;
  }

  // Obtener etiqueta por nombre
  Future<ServiceHttpResponse> obtenerEtiquetaPorNombre(String nombre) async {
    final url = Uri.parse('${BASE_URL}etiquetas/obtener/$nombre');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Etiqueta.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener la etiqueta: $e';
    }

    return responseWrapper;
  }

  // Obtener etiqueta por ID
  Future<ServiceHttpResponse> obtenerEtiquetaPorId(int id) async {
    final url = Uri.parse('${BASE_URL}etiquetas/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Etiqueta.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener la etiqueta: $e';
    }

    return responseWrapper;
  }

  // Obtener etiquetas de una tarea
  Future<ServiceHttpResponse> obtenerEtiquetasDeTarea(int tareaId) async {
    final url = Uri.parse('${BASE_URL}tareas/$tareaId/etiquetas');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          if (jsonData is List) {
            responseWrapper.body =
                jsonData.map((json) => Etiqueta.fromMap(json)).toList();
          } else {
            responseWrapper.body = 'Error: Respuesta no es una lista';
          }
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else if (response.statusCode == 404) {
        responseWrapper.body =
            []; // Lista vacía en caso de no encontrar etiquetas
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener las etiquetas: $e';
    }

    return responseWrapper;
  }
}
