import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../models/adjunto.dart';
import '../../configs/contants.dart';
import '../../models/service_http_response.dart';

class AdjuntoService {
  // Subir adjunto para una tarea
  Future<ServiceHttpResponse> subirAdjunto(int tareaId, File file) async {
    final url = Uri.parse('${BASE_URL}adjuntos/subir');
    final responseWrapper = ServiceHttpResponse();

    try {
      // Obtener el nombre del archivo y determinar su tipo MIME
      String fileName = file.path.split('/').last;
      String mimeType = _getMimeType(fileName);
      
      // Crear la solicitud multipart
      var request = http.MultipartRequest('POST', url);
      
      // Añadir los parámetros
      request.fields['tarea_id'] = tareaId.toString();
      
      // Añadir el archivo
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
      
      // Enviar la solicitud
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      responseWrapper.status = response.statusCode;
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        responseWrapper.body = Adjunto.fromMap(jsonData['adjunto']);
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al subir el adjunto: $e';
    }

    return responseWrapper;
  }

  // Crear adjunto (con ruta existente)
  Future<ServiceHttpResponse> crearAdjunto({
    required int tareaId,
    required String nombre,
    required String ruta,
    required String tipo,
  }) async {
    final url = Uri.parse('${BASE_URL}adjuntos/crear');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tarea_id': tareaId,
          'nombre': nombre,
          'ruta': ruta,
          'tipo': tipo,
        }),
      );

      responseWrapper.status = response.statusCode;
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        responseWrapper.body = Adjunto.fromMap(jsonData['adjunto']);
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al crear el adjunto: $e';
    }

    return responseWrapper;
  }

  // Obtener adjuntos por tarea
  Future<ServiceHttpResponse> obtenerAdjuntosPorTarea(int tareaId, {bool incluirUrls = false}) async {
    final url = Uri.parse('${BASE_URL}adjuntos/tarea/$tareaId${incluirUrls ? '?incluir_urls=true' : ''}');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final adjuntos = jsonData.map((json) => Adjunto.fromMap(json)).toList();
          responseWrapper.body = adjuntos;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener los adjuntos: $e';
    }

    return responseWrapper;
  }

  // Eliminar adjunto
  Future<ServiceHttpResponse> eliminarAdjunto(int id) async {
    final url = Uri.parse('${BASE_URL}adjuntos/eliminar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.delete(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200 || response.statusCode == 207) {
        responseWrapper.body = 'Adjunto eliminado con éxito';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al eliminar el adjunto: $e';
    }

    return responseWrapper;
  }

  // Actualizar adjunto
  Future<ServiceHttpResponse> actualizarAdjunto({
    required int id,
    String? nombre,
    String? tipo,
  }) async {
    final url = Uri.parse('${BASE_URL}adjuntos/actualizar/$id');
    final responseWrapper = ServiceHttpResponse();
    
    // Construir solo los campos que se van a actualizar
    Map<String, dynamic> updateData = {};
    if (nombre != null) updateData['nombre'] = nombre;
    if (tipo != null) updateData['tipo'] = tipo;

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );

      responseWrapper.status = response.statusCode;
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        responseWrapper.body = Adjunto.fromMap(jsonData['adjunto']);
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al actualizar el adjunto: $e';
    }

    return responseWrapper;
  }

  // Obtener URL con SAS para un adjunto específico
  Future<ServiceHttpResponse> obtenerUrlAdjunto(int id, {int expiraEn = 60}) async {
    final url = Uri.parse('${BASE_URL}adjuntos/$id/url?expira_en=$expiraEn');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        responseWrapper.body = jsonData;
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener la URL del adjunto: $e';
    }

    return responseWrapper;
  }

  // Método auxiliar para determinar el tipo MIME basado en la extensión del archivo
  String _getMimeType(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream'; // Tipo genérico para archivos binarios
    }
  }
}