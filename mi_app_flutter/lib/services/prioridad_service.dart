import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prioridad.dart';
import '../configs/contants.dart';
import '../models/service_http_response.dart';

class PrioridadService {
  // Obtener todas las prioridades
  Future<ServiceHttpResponse> obtenerPrioridades() async {
    final url = Uri.parse('${BASE_URL}prioridades');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final prioridades =
              jsonData.map((json) => Prioridad.fromMap(json)).toList();
          responseWrapper.body = prioridades;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener las prioridades: $e';
    }

    return responseWrapper;
  }

  // Obtener una prioridad por ID
  Future<ServiceHttpResponse> obtenerPrioridadPorId(int id) async {
    final url = Uri.parse('${BASE_URL}prioridades/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final dynamic jsonData = json.decode(response.body);
          final prioridad = Prioridad.fromMap(jsonData);
          responseWrapper.body = prioridad;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else if (response.statusCode == 404) {
        responseWrapper.body = 'Prioridad no encontrada';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener la prioridad: $e';
    }

    return responseWrapper;
  }
}
