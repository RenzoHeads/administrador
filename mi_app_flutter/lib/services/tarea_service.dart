import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/tarea.dart';
import '../../models/tareaetiqueta.dart';
import '../../configs/contants.dart';
import '../../models/service_http_response.dart';

class TareaService {
  // Obtener tareas por usuario
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

  // Crear tarea
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
      final response = await http.post(
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

  // Eliminar tarea
  Future<ServiceHttpResponse> eliminarTarea(int id) async {
    final url = Uri.parse('${BASE_URL}tareas/eliminar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.delete(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        responseWrapper.body = 'Tarea eliminada con éxito';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al eliminar la tarea: $e';
    }

    return responseWrapper;
  }

  

  // Crear etiqueta para tarea
  Future<ServiceHttpResponse> crearTareaEtiqueta(
    int tareaId, 
    int etiquetaId
  ) async {
    final url = Uri.parse('${BASE_URL}tareaetiqueta/crear');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tarea_id': tareaId,
          'etiqueta_id': etiquetaId,
        }),
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
      responseWrapper.body = 'Ocurrió un error al crear la etiqueta para la tarea: $e';
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
          final tareaEtiquetas = jsonData.map((json) => TareaEtiqueta.fromMap(json)).toList();
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
    int etiquetaId
  ) async {
    final url = Uri.parse('${BASE_URL}tareaetiqueta/actualizar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tarea_id': tareaId,
          'etiqueta_id': etiquetaId,
        }),
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

  // Eliminar etiqueta de tarea
  Future<ServiceHttpResponse> eliminarTareaEtiqueta(int id) async {
    final url = Uri.parse('${BASE_URL}tareaetiqueta/eliminar/$id');
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
      responseWrapper.body = 'Ocurrió un error al obtener las tareas de hoy: $e';
    }

    return responseWrapper;
  }

  // Actualizar estado de tarea
  Future<ServiceHttpResponse> actualizarEstadoTarea(int tareaId, int estadoId) async {
    final url = Uri.parse('${BASE_URL}tareas/estado/$tareaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'estado': estadoId,
        }),
      );

      responseWrapper.status = response.statusCode;
      if (response.statusCode == 200) {
        responseWrapper.body = 'Estado actualizado';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al actualizar el estado de la tarea: $e';
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
      responseWrapper.body = 'Ocurrió un error al obtener el estado de la tarea: $e';
    }

    return responseWrapper;
  }
}