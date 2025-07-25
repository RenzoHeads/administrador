import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/tarea.dart';

import '../../configs/contants.dart';
import '../../models/service_http_response.dart';
import 'auth_service.dart';

class TareaService {
  // Parte del servicio de tareas que necesita ser corregido

  Future<ServiceHttpResponse> obtenerTareasPorUsuario(int usuarioId) async {
    final url = Uri.parse('${BASE_URL}tareas/$usuarioId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(url, headers: headers);

      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final tareas = jsonData.map((json) => Tarea.fromMap(json)).toList();
          responseWrapper.body = tareas;
        } catch (e) {
          responseWrapper.status = 500;
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else if (response.statusCode == 404) {
        responseWrapper.status = 404;
        responseWrapper.body = []; // Lista vacía cuando no hay tareas
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener tareas: $e';
    }

    return responseWrapper;
  }

  // Crear tarea con etiquetas
  Future<ServiceHttpResponse> crearTareaConEtiquetas({
    required int usuarioId,
    required int listaId,
    required String titulo,
    required String descripcion,
    required String fechaCreacion,
    required String fechaVencimiento,
    required int categoriaId,
    required int estadoId,
    required int prioridadId,
    required List<int> etiquetas,
  }) async {
    final url = Uri.parse('${BASE_URL}tareas/crear_con_etiquetas');
    final responseWrapper = ServiceHttpResponse();

    try {
      Map<String, dynamic> payload = {
        'usuario_id': usuarioId,
        'lista_id': listaId,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha_creacion': fechaCreacion,
        'fecha_vencimiento': fechaVencimiento,
        'categoria_id': categoriaId,
        'estado_id': estadoId,
        'prioridad_id': prioridadId,
        'etiquetas': etiquetas,
      };

      final headers = await AuthService.getAuthHeaders();

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      responseWrapper.status = response.statusCode;
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Tarea.fromMap(jsonData);
        } else {
          responseWrapper.body =
              'Tarea creada con éxito, pero sin datos retornados';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e, stackTrace) {
      print('Error en crearTareaConEtiquetas: $e');
      print('Stack trace: $stackTrace');
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al crear la tarea con etiquetas: $e';
    }

    return responseWrapper;
  }

  // Actualizar tarea con etiquetas
  Future<ServiceHttpResponse> actualizarTareaConEtiquetas({
    required int id,
    required int usuarioId,
    required int listaId,
    required String titulo,
    required String descripcion,
    required String fechaCreacion,
    required String fechaVencimiento,
    required int categoriaId,
    required int estadoId,
    required int prioridadId,
    required List<int> etiquetas,
  }) async {
    final url = Uri.parse('${BASE_URL}tareas/$id/actualizar_con_etiquetas');
    final responseWrapper = ServiceHttpResponse();

    try {
      Map<String, dynamic> payload = {
        'usuario_id': usuarioId,
        'lista_id': listaId,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha_creacion': fechaCreacion,
        'fecha_vencimiento': fechaVencimiento,
        'categoria_id': categoriaId,
        'estado_id': estadoId,
        'prioridad_id': prioridadId,
        'etiquetas': etiquetas,
      };

      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      responseWrapper.status = response.statusCode;
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        responseWrapper.body = Tarea.fromMap(jsonData);
      } else if (response.statusCode == 404) {
        responseWrapper.body = 'Tarea no encontrada';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al actualizar la tarea con etiquetas: $e';
    }

    return responseWrapper;
  }

  // Servicio corregido para eliminar tarea
  Future<ServiceHttpResponse> eliminarTarea(int id) async {
    final url = Uri.parse('${BASE_URL}tareas/eliminar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      print('Enviando solicitud DELETE a: $url'); // Log para debug
      final headers = await AuthService.getAuthHeaders();
      final response = await http.delete(url, headers: headers);

      responseWrapper.status = response.statusCode;
      print(
        'Respuesta recibida: ${response.statusCode} - ${response.body}',
      ); // Log para debug

      if (response.statusCode == 200) {
        // Manejo seguro del cuerpo de la respuesta
        try {
          // Intentar decodificar como JSON primero
          final jsonData = json.decode(response.body);
          responseWrapper.body =
              jsonData[1] ?? jsonData['mensaje'] ?? response.body;
        } catch (e) {
          // Si no es JSON, usar el cuerpo de la respuesta como texto plano
          print('No se pudo decodificar como JSON: $e');
          responseWrapper.body = response.body;
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      print('Error en solicitud HTTP: $e'); // Log detallado
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al eliminar la tarea: $e';
    }

    return responseWrapper;
  }

  // Actualizar estado de tarea
  Future<ServiceHttpResponse> actualizarEstadoTarea(
    int tareaId,
    int estadoId,
  ) async {
    final url = Uri.parse('${BASE_URL}tareas/estado/$tareaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({'estado_id': estadoId}),
      );

      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Tarea.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar la respuesta: $e';
        }
      } else if (response.statusCode == 404) {
        final errorData = json.decode(response.body);
        responseWrapper.body = 'Error: ${errorData['error'] ?? response.body}';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al actualizar el estado de la tarea: $e';
    }

    return responseWrapper;
  }
}
