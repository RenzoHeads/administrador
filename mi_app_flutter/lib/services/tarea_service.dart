import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/tarea.dart';
import '../../models/tareaetiqueta.dart';
import '../../configs/contants.dart';
import '../../models/service_http_response.dart';

class TareaService {
  // Parte del servicio de tareas que necesita ser corregido

  Future<ServiceHttpResponse> obtenerTareasPorUsuario(int usuarioId) async {
    final url = Uri.parse('${BASE_URL}tareas/$usuarioId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
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

      print('Payload: ${jsonEncode(payload)}');

      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

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

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
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
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al actualizar la tarea con etiquetas: $e';
    }

    return responseWrapper;
  }

  // Buscar tareas por título para un usuario
  Future<ServiceHttpResponse> buscarTareasPorTitulo(
    int usuarioId,
    String titulo,
  ) async {
    final url = Uri.parse('${BASE_URL}tareas/buscar/$usuarioId/$titulo');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
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
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al buscar tareas por título: $e';
    }

    return responseWrapper;
  }

  // Obtener tareas por lista
  Future<ServiceHttpResponse> obtenerTareasPorLista(int listaId) async {
    final url = Uri.parse('${BASE_URL}tareas/lista/$listaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final tareas = jsonData.map((json) => Tarea.fromMap(json)).toList();
          responseWrapper.body = tareas;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener tareas: $e';
    }

    return responseWrapper;
  }

  // Obtener tareas por etiqueta
  Future<ServiceHttpResponse> obtenerTareasPorEtiqueta(int etiquetaId) async {
    final url = Uri.parse('${BASE_URL}tareas/etiqueta/$etiquetaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final tareas = jsonData.map((json) => Tarea.fromMap(json)).toList();
          responseWrapper.body = tareas;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener tareas: $e';
    }

    return responseWrapper;
  }

  // Obtener tarea por ID
  Future<ServiceHttpResponse> obtenerTareaPorId(int tareaId) async {
    final url = Uri.parse('${BASE_URL}tareas/obtener/$tareaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Tarea.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener la tarea: $e';
    }

    return responseWrapper;
  }

  Future<ServiceHttpResponse> crearTarea({
    required int usuarioId,
    required int listaId,
    required String titulo,
    required String descripcion,
    required String fechaCreacion,
    required String fechaVencimiento,
    required int categoriaId,
    required int estadoId,
    required int prioridadId,
  }) async {
    final url = Uri.parse('${BASE_URL}tareas/crear');
    final responseWrapper = ServiceHttpResponse();

    try {
      // Crear el mapa de datos explícitamente
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
      };

      // Imprimir el payload para depuración
      print('Payload que se enviará: ${jsonEncode(payload)}');

      // Asegúrate de que los encabezados estén correctos
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

      // Enviar la solicitud
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      print(
        'Respuesta del servidor (código ${response.statusCode}): ${response.body}',
      );

      responseWrapper.status = response.statusCode;
      if (response.statusCode == 200) {
        // Verificar que la respuesta no esté vacía
        if (response.body.isNotEmpty) {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Tarea.fromMap(jsonData);
        } else {
          print('Advertencia: El servidor devolvió un cuerpo vacío');
          // Crea una tarea ficticia con los datos enviados
          responseWrapper.body = Tarea(
            titulo: titulo,
            descripcion: descripcion,
            fechaCreacion: DateTime.parse(fechaCreacion),
            fechaVencimiento: DateTime.parse(fechaVencimiento),
            prioridadId: prioridadId,
            estadoId: estadoId,
            categoriaId: categoriaId,
            usuarioId: usuarioId,
            listaId: listaId,
          );
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e, stackTrace) {
      print('Error en crearTarea: $e');
      print('Stack trace: $stackTrace');
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al crear la tarea: $e';
    }

    return responseWrapper;
  }

  // Actualizar tarea
  Future<ServiceHttpResponse> actualizarTarea({
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
  }) async {
    final url = Uri.parse('${BASE_URL}tareas/actualizar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': usuarioId,
          'lista_id': listaId,
          'titulo': titulo,
          'descripcion': descripcion,
          'fecha_creacion': fechaCreacion,
          'fecha_vencimiento': fechaVencimiento,
          'categoria_id': categoriaId,
          'estado_id': estadoId,
          'prioridad_id': prioridadId,
        }),
      );

      responseWrapper.status = response.statusCode;
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        responseWrapper.body = Tarea.fromMap(jsonData);
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al actualizar la tarea: $e';
    }

    return responseWrapper;
  }

  // Servicio corregido para eliminar tarea
  Future<ServiceHttpResponse> eliminarTarea(int id) async {
    final url = Uri.parse('${BASE_URL}tareas/eliminar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      print('Enviando solicitud DELETE a: $url'); // Log para debug
      final response = await http.delete(url);
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
    } catch (e) {
      print('Error en solicitud HTTP: $e'); // Log detallado
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al eliminar la tarea: $e';
    }

    return responseWrapper;
  }

  // Crear etiqueta para tarea
  Future<ServiceHttpResponse> crearTareaEtiqueta(
    int tareaId,
    int etiquetaId,
  ) async {
    final url = Uri.parse('${BASE_URL}tareaetiqueta/$tareaId/$etiquetaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // No body needed as IDs are in the URL path
      );

      responseWrapper.status = response.statusCode;
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        responseWrapper.body = TareaEtiqueta.fromMap(jsonData);
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al crear la etiqueta para la tarea: $e';
    }

    return responseWrapper;
  }

  // Obtener etiquetas de una tarea
  Future<ServiceHttpResponse> obtenerEtiquetasPorTarea(int tareaId) async {
    final url = Uri.parse('${BASE_URL}tareaetiqueta/$tareaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final tareaEtiquetas =
              jsonData.map((json) => TareaEtiqueta.fromMap(json)).toList();
          responseWrapper.body = tareaEtiquetas;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener las etiquetas: $e';
    }

    return responseWrapper;
  }

  // Actualizar etiqueta de tarea
  Future<ServiceHttpResponse> actualizarTareaEtiqueta(
    int id,
    int tareaId,
    int etiquetaId,
  ) async {
    final url = Uri.parse('${BASE_URL}tareaetiqueta/actualizar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tarea_id': tareaId, 'etiqueta_id': etiquetaId}),
      );

      responseWrapper.status = response.statusCode;
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        responseWrapper.body = TareaEtiqueta.fromMap(jsonData);
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al actualizar la etiqueta: $e';
    }

    return responseWrapper;
  }

  Future<ServiceHttpResponse> eliminarTareaEtiqueta(
    int tareaId,
    int etiquetaId,
  ) async {
    final url = Uri.parse('${BASE_URL}tareaetiqueta/$tareaId/$etiquetaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.delete(url);

      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        responseWrapper.body = 'Etiqueta eliminada de la tarea';
      } else if (response.statusCode == 404) {
        responseWrapper.body = 'Relación entre tarea y etiqueta no encontrada';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al eliminar la etiqueta: $e';
    }

    return responseWrapper;
  }

  // Obtener tareas que inician hoy para un usuario
  Future<ServiceHttpResponse> obtenerTareasHoyPorUsuario(int usuarioId) async {
    final url = Uri.parse('${BASE_URL}tareas/hoy/$usuarioId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final tareas = jsonData.map((json) => Tarea.fromMap(json)).toList();
          responseWrapper.body = tareas;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al obtener las tareas de hoy: $e';
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
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
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
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al actualizar el estado de la tarea: $e';
    }

    return responseWrapper;
  }

  // Obtener estado de una tarea
  Future<ServiceHttpResponse> obtenerEstadoTarea(int tareaId) async {
    final url = Uri.parse('${BASE_URL}tareas/estado/$tareaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = jsonData;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body =
          'Ocurrió un error al obtener el estado de la tarea: $e';
    }

    return responseWrapper;
  }
}
