import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../models/lista.dart';
import '../../models/tarea.dart';
import '../../configs/contants.dart';
import '../../models/service_http_response.dart';
import 'auth_service.dart';

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
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
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

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al crear la lista: $e';
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
      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(
        url,
        headers: headers,
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

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
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
      final headers = await AuthService.getAuthHeaders();
      final response = await http.delete(url, headers: headers);

      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        // Verificar si el response body tiene contenido antes de decodificar
        if (response.body.isNotEmpty) {
          try {
            final messageResponse = jsonDecode(response.body);
            responseWrapper.body = {
              'message':
                  messageResponse['message'] ?? 'Lista eliminada correctamente',
              'tareas_ids':
                  (messageResponse['tareas_ids'] as List?)
                      ?.map((e) => e as int)
                      .toList(),
            };
          } catch (e) {
            // Si hay error al decodificar JSON pero el status es 200, considerarlo exitoso
            responseWrapper.body = {
              'message': 'Lista eliminada correctamente',
              'tareas_ids': <int>[],
            };
          }
        } else {
          // Si el response body está vacío pero el status es 200, considerarlo exitoso
          responseWrapper.body = {
            'message': 'Lista eliminada correctamente',
            'tareas_ids': <int>[],
          };
        }
      } else {
        // Para otros status codes, intentar decodificar el mensaje de error
        try {
          final messageResponse = jsonDecode(response.body);
          responseWrapper.body = messageResponse;
        } catch (e) {
          responseWrapper.body = 'Error: ${response.body}';
        }
      }

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al eliminar la lista: $e';
    }

    return responseWrapper;
  }

  Future<ServiceHttpResponse> generarListaIA({
    required String prompt,
    required int usuarioId,
  }) async {
    final url = Uri.parse('${BASE_URL}listas/generar_ia');
    final responseWrapper = ServiceHttpResponse();
    try {
      final headers = await AuthService.getAuthHeaders();
      // Agregar headers específicos para UTF-8
      headers['Accept'] = 'application/json; charset=UTF-8';

      final response = await http.post(
        url,
        headers: headers,
        body: utf8.encode(
          jsonEncode({'prompt': prompt, 'usuario_id': usuarioId}),
        ),
      );
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          // Decodificar correctamente la respuesta con UTF-8
          final String responseBody = utf8.decode(response.bodyBytes);
          final dynamic jsonData = json.decode(responseBody);

          // Mapear la lista
          final listaData = jsonData['lista'];
          final lista = Lista.fromMap(listaData);

          // Mapear las tareas
          final tareasData = jsonData['tareas'] ?? [];
          final tareas =
              (tareasData as List)
                  .map((tareaMap) => Tarea.fromMap(tareaMap))
                  .toList();

          responseWrapper.body = {'lista': lista, 'tareas': tareas};
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        final String errorBody = utf8.decode(response.bodyBytes);
        responseWrapper.body = 'Error: $errorBody';
      }

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al generar la lista con IA: $e';
    }

    return responseWrapper;
  }
}
