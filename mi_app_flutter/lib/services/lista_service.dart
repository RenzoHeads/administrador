import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/lista.dart';
import '../../configs/contants.dart';
import '../../models/service_http_response.dart';

class ListaService {
  // Crear lista
  Future<ServiceHttpResponse> crearLista({
    required int usuarioId,
    required String nombre,
    required String descripcion,
    required String color,
  }) async {
    final url = Uri.parse('${BASE_URL}listas/crear');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': usuarioId,
          'nombre': nombre,
          'descripcion': descripcion,
          'color': color,
        }),
      );

      responseWrapper.status = response.statusCode;
      
      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Lista.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al crear la lista: $e';
    }

    return responseWrapper;
  }

  // Obtener listas por usuario
  Future<ServiceHttpResponse> obtenerListasPorUsuario(int usuarioId) async {
    final url = Uri.parse('${BASE_URL}listas/$usuarioId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final listas = jsonData.map((json) => Lista.fromMap(json)).toList();
          responseWrapper.body = listas;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener las listas: $e';
    }

    return responseWrapper;
  }

  // Actualizar lista
  Future<ServiceHttpResponse> actualizarLista({
    required int id,
    required int usuarioId,
    required String nombre,
    required String descripcion,
    required String color,
  }) async {
    final url = Uri.parse('${BASE_URL}listas/actualizar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': usuarioId,
          'nombre': nombre,
          'descripcion': descripcion,
          'color': color,
        }),
      );

      responseWrapper.status = response.statusCode;
      
      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Lista.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al actualizar la lista: $e';
    }

    return responseWrapper;
  }

  // Eliminar lista
  Future<ServiceHttpResponse> eliminarLista(int id) async {
    final url = Uri.parse('${BASE_URL}listas/eliminar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.delete(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        responseWrapper.body = 'Lista eliminada con éxito';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al eliminar la lista: $e';
    }

    return responseWrapper;
  }
  // Obtener cantidad de tareas por lista
  Future<ServiceHttpResponse> obtenerCantidadTareasPorLista(int listaId) async {
    final url = Uri.parse('${BASE_URL}listas/cantidad_tareas/$listaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = jsonData['cantidad_tareas'];
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener la cantidad de tareas: $e';
    }

    return responseWrapper;
  }
}