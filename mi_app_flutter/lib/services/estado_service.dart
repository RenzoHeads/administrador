import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estado.dart';
import '../configs/contants.dart';
import '../models/service_http_response.dart';

class EstadoService {
  // Obtener todos los estados
  Future<ServiceHttpResponse> obtenerEstados() async {
    final url = Uri.parse('${BASE_URL}estados');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final estados = jsonData.map((json) => Estado.fromMap(json)).toList();
          responseWrapper.body = estados;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener los estados: $e';
    }

    return responseWrapper;
  }

  // Obtener un estado por su ID
  Future<ServiceHttpResponse> obtenerEstadoPorId(int id) async {
    final url = Uri.parse('${BASE_URL}estados/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final dynamic jsonData = json.decode(response.body);
          final estado = Estado.fromMap(jsonData);
          responseWrapper.body = estado;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else if (response.statusCode == 404) {
        responseWrapper.body = 'Estado no encontrado';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener el estado: $e';
    }

    return responseWrapper;
  }
}
