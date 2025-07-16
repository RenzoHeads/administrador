import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/recordatorio.dart';
import '../../configs/contants.dart';
import '../../models/service_http_response.dart';
import 'auth_service.dart';

class RecordatorioService {
  // Crear recordatorio
  Future<ServiceHttpResponse> crearRecordatorio({
    required int tareaId,
    required DateTime fechaHora,
    String? tokenFCM,
    String? mensaje,
    bool activado = true,
  }) async {
    final url = Uri.parse('${BASE_URL}recordatorios/crear');
    final responseWrapper = ServiceHttpResponse();

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'tarea_id': tareaId,
          'fecha_hora': fechaHora.toIso8601String(),
          'token_fcm': tokenFCM,
          'mensaje': mensaje,
          'activado': activado,
        }),
      );

      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          if (jsonData['success'] == true && jsonData['recordatorio'] != null) {
            responseWrapper.body = Recordatorio.fromMap(
              jsonData['recordatorio'],
            );
          } else {
            responseWrapper.body = jsonData['message'] ?? 'Recordatorio creado';
          }
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
      responseWrapper.body = 'Ocurrió un error al crear el recordatorio: $e';
    }

    return responseWrapper;
  }

  // Obtener recordatorios por tarea
  Future<ServiceHttpResponse> obtenerRecordatoriosPorTarea(int tareaId) async {
    final url = Uri.parse('${BASE_URL}recordatorios/$tareaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(url, headers: headers);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          if (jsonData['success'] == true &&
              jsonData['recordatorios'] != null) {
            final List<dynamic> recordatoriosData = jsonData['recordatorios'];
            final recordatorios =
                recordatoriosData
                    .map((json) => Recordatorio.fromMap(json))
                    .toList();
            responseWrapper.body = recordatorios;
          } else {
            responseWrapper.body = [];
          }
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else if (response.statusCode == 404) {
        responseWrapper.body = [];
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al obtener los recordatorios: $e';
    }

    return responseWrapper;
  }

  // Obtener recordatorios por tarea específica (nuevo endpoint)
  Future<ServiceHttpResponse> obtenerRecordatoriosDeUnaTarea(
    int tareaId,
  ) async {
    final url = Uri.parse('${BASE_URL}recordatorios/tarea/$tareaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(url, headers: headers);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          if (jsonData['success'] == true &&
              jsonData['recordatorios'] != null) {
            final List<dynamic> recordatoriosData = jsonData['recordatorios'];
            final recordatorios =
                recordatoriosData
                    .map((json) => Recordatorio.fromMap(json))
                    .toList();
            responseWrapper.body = recordatorios;
          } else {
            responseWrapper.body = [];
          }
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else if (response.statusCode == 404) {
        responseWrapper.body = [];
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }

      AuthService.handleHttpResponse(response);
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
    bool? activado,
  }) async {
    final url = Uri.parse('${BASE_URL}recordatorios/actualizar');
    final responseWrapper = ServiceHttpResponse();

    try {
      final headers = await AuthService.getAuthHeaders();
      final Map<String, dynamic> body = {
        'id': id,
        'tarea_id': tareaId,
        'fecha_hora': fechaHora.toIso8601String(),
        'token_fcm': tokenFCM,
        'mensaje': mensaje,
      };

      if (activado != null) {
        body['activado'] = activado;
      }

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          if (jsonData['success'] == true && jsonData['recordatorio'] != null) {
            responseWrapper.body = Recordatorio.fromMap(
              jsonData['recordatorio'],
            );
          } else {
            responseWrapper.body =
                jsonData['message'] ?? 'Recordatorio actualizado';
          }
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
      final headers = await AuthService.getAuthHeaders();
      final response = await http.delete(url, headers: headers);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body =
              jsonData['message'] ?? 'Recordatorio eliminado con éxito';
        } catch (e) {
          responseWrapper.body = 'Recordatorio eliminado con éxito';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }

      // Manejar respuesta de autenticación
      AuthService.handleHttpResponse(response);
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al eliminar el recordatorio: $e';
    }

    return responseWrapper;
  }

  // Desactivar todos los recordatorios del usuario
  Future<ServiceHttpResponse> desactivarRecordatoriosUsuario(
    int usuarioId,
  ) async {
    final url = Uri.parse(
      '${BASE_URL}recordatorios/desactivar-usuario/$usuarioId',
    );
    final responseWrapper = ServiceHttpResponse();

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(url, headers: headers);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = {
            'success': jsonData['success'],
            'message': jsonData['message'],
            'recordatorios_afectados': jsonData['recordatorios_afectados'],
          };
        } catch (e) {
          responseWrapper.body = 'Recordatorios desactivados correctamente';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }

      AuthService.handleHttpResponse(response);
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al desactivar los recordatorios: $e';
    }

    return responseWrapper;
  }

  // Activar todos los recordatorios del usuario
  Future<ServiceHttpResponse> activarRecordatoriosUsuario(int usuarioId) async {
    final url = Uri.parse(
      '${BASE_URL}recordatorios/activar-usuario/$usuarioId',
    );
    final responseWrapper = ServiceHttpResponse();

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(url, headers: headers);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = {
            'success': jsonData['success'],
            'message': jsonData['message'],
            'recordatorios_afectados': jsonData['recordatorios_afectados'],
          };
        } catch (e) {
          responseWrapper.body = 'Recordatorios activados correctamente';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }

      AuthService.handleHttpResponse(response);
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al activar los recordatorios: $e';
    }

    return responseWrapper;
  }

  // Activar recordatorios de prioridad alta
  Future<ServiceHttpResponse> activarRecordatoriosPrioridadAlta(
    int usuarioId,
  ) async {
    final url = Uri.parse(
      '${BASE_URL}recordatorios/activar-prioridad-alta/$usuarioId',
    );
    final responseWrapper = ServiceHttpResponse();

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(url, headers: headers);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = {
            'success': jsonData['success'],
            'message': jsonData['message'],
            'recordatorios_afectados': jsonData['recordatorios_afectados'],
          };
        } catch (e) {
          responseWrapper.body =
              'Recordatorios de prioridad alta activados correctamente';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }

      AuthService.handleHttpResponse(response);
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al activar los recordatorios de prioridad alta: $e';
    }

    return responseWrapper;
  }

  // Obtener estado de recordatorios del usuario
  Future<ServiceHttpResponse> obtenerEstadoRecordatoriosUsuario(
    int usuarioId,
  ) async {
    final url = Uri.parse('${BASE_URL}recordatorios/estado-usuario/$usuarioId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(url, headers: headers);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = {
            'success': jsonData['success'],
            'recordatorios_activados': jsonData['recordatorios_activados'],
            'recordatorios_desactivados':
                jsonData['recordatorios_desactivados'],
            'total_recordatorios': jsonData['total_recordatorios'],
          };
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }

      AuthService.handleHttpResponse(response);
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al obtener el estado de los recordatorios: $e';
    }

    return responseWrapper;
  }

  // Eliminar recordatorios de lista
  Future<ServiceHttpResponse> eliminarRecordatoriosLista(int listaId) async {
    final url = Uri.parse('${BASE_URL}recordatorios/eliminar-lista/$listaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.delete(url, headers: headers);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = {
            'success': jsonData['success'],
            'message': jsonData['message'],
            'recordatorios_eliminados': jsonData['recordatorios_eliminados'],
            'lista_id': jsonData['lista_id'],
          };
        } catch (e) {
          responseWrapper.body =
              'Recordatorios de la lista eliminados correctamente';
        }
      } else if (response.statusCode == 404) {
        responseWrapper.body = 'Lista no encontrada';
      } else if (response.statusCode == 403) {
        responseWrapper.body = 'No tienes permisos para acceder a esta lista';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }

      AuthService.handleHttpResponse(response);
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al eliminar los recordatorios de la lista: $e';
    }

    return responseWrapper;
  }
}
