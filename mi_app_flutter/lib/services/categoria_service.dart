import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/categoria.dart';
import '../../configs/contants.dart';
import '../../models/service_http_response.dart';

class CategoriaService {
  // Crear categoría
  Future<ServiceHttpResponse> crearCategoria({
    required String nombre,
    required String color,
  }) async {
    final url = Uri.parse('${BASE_URL}categorias/crear');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'nombre': nombre, 'color': color}),
      );

      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Categoria.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al crear la categoría: $e';
    }

    return responseWrapper;
  }

  // Obtener todas las categorías
  Future<ServiceHttpResponse> obtenerCategorias() async {
    final url = Uri.parse('${BASE_URL}categorias');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final categorias =
              jsonData.map((json) => Categoria.fromMap(json)).toList();
          responseWrapper.body = categorias;
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener las categorías: $e';
    }

    return responseWrapper;
  }

  // Actualizar categoría
  Future<ServiceHttpResponse> actualizarCategoria({
    required int id,
    required String nombre,
    required String color,
  }) async {
    final url = Uri.parse('${BASE_URL}categorias/actualizar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'nombre': nombre, 'color': color}),
      );

      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Categoria.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al actualizar la categoría: $e';
    }

    return responseWrapper;
  }

  // Eliminar categoría
  Future<ServiceHttpResponse> eliminarCategoria(int id) async {
    final url = Uri.parse('${BASE_URL}categorias/eliminar/$id');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.delete(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        responseWrapper.body = 'Categoría eliminada con éxito';
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al eliminar la categoría: $e';
    }

    return responseWrapper;
  }

  //Creame este servicio
  // Obtener categoría por ID de tarea
  Future<ServiceHttpResponse> obtenerCategoriaPorTareaId(int tareaId) async {
    final url = Uri.parse('${BASE_URL}categorias/tarea/$tareaId');
    final responseWrapper = ServiceHttpResponse();

    try {
      final response = await http.get(url);
      responseWrapper.status = response.statusCode;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          responseWrapper.body = Categoria.fromMap(jsonData);
        } catch (e) {
          responseWrapper.body = 'Error al procesar el JSON: $e';
        }
      } else {
        responseWrapper.body = 'Error: ${response.body}';
      }
    } catch (e) {
      responseWrapper.status = 500;
      responseWrapper.body = 'Ocurrió un error al obtener la categoría: $e';
    }

    return responseWrapper;
  }
}
