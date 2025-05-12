import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/etiqueta.dart';
import '../../models/tarea.dart';
import '../../models/estado.dart';
import '../../models/categoria.dart';
import '../../models/prioridad.dart';
import '../../configs/contants.dart';
import '../../models/service_http_response.dart';

class InicioService {
  // InicioService - Método corregido
  Future<ServiceHttpResponse> fetchCompleteDatosUsuario(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('${BASE_URL}usuarios/$usuarioId/datos_completos'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Convertir tareas correctamente
        final List<Tarea> tareas =
            (data['tareas'] as List? ?? [])
                .map((t) => Tarea.fromMap(t as Map<String, dynamic>))
                .toList();

        // Convertir listas utilizando solo los datos JSON sin intentar pasarlos como objetos Lista
        final List<dynamic> listasData = data['listas'] as List? ?? [];

        // El problema estaba aquí - no devolvemos objetos Lista sino los datos JSON
        // para que el controlador pueda hacer la conversión
        final List<Map<String, dynamic>> etiquetasPorTarea =
            (data['etiquetas_por_tarea'] as List? ?? []).map((item) {
              return {
                'tarea_id': item['tarea_id'],
                'etiquetas':
                    (item['etiquetas'] as List? ?? [])
                        .map((e) => Etiqueta.fromMap(e as Map<String, dynamic>))
                        .toList(),
              };
            }).toList();

        final Map<String, dynamic> datosReferencia =
            data['datos_referencia'] ?? {};

        final List<Prioridad> prioridades =
            (datosReferencia['prioridades'] as List? ?? [])
                .map((p) => Prioridad.fromMap(p as Map<String, dynamic>))
                .toList();

        final List<Estado> estados =
            (datosReferencia['estados'] as List? ?? [])
                .map((e) => Estado.fromMap(e as Map<String, dynamic>))
                .toList();

        final List<Categoria> categorias =
            (datosReferencia['categorias'] as List? ?? [])
                .map((c) => Categoria.fromMap(c as Map<String, dynamic>))
                .toList();

        return ServiceHttpResponse(
          status: 200,
          body: {
            'tareas': tareas,
            'listas': listasData, // Devolvemos los datos sin convertir
            'etiquetasPorTarea': etiquetasPorTarea,
            'datosReferencia': {
              'prioridades': prioridades,
              'estados': estados,
              'categorias': categorias,
            },
          },
        );
      } else if (response.statusCode == 404) {
        return ServiceHttpResponse(
          status: 404,
          body: {'message': 'No se encontraron datos para este usuario'},
        );
      } else {
        return ServiceHttpResponse(
          status: response.statusCode,
          body: {'message': 'Error al obtener datos: ${response.statusCode}'},
        );
      }
    } catch (e) {
      return ServiceHttpResponse(
        status: 500,
        body: {'message': 'Error de conexión: ${e.toString()}'},
      );
    }
  }
}
