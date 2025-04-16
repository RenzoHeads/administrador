import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../home/home_controler.dart';
import '../../models/tarea.dart';
import '../../models/categoria.dart';
import '../../models/etiqueta.dart';
import '../../models/adjunto.dart';
import '../../models/tareaetiqueta.dart';
import '../../models/lista.dart'; // Asegúrate de importar la clase Lista
import '../../models/enums.dart'; // Importamos enums directamente
import '../../services/tarea_service.dart';
import '../../services/adjunto_service.dart';
import '../../services/etiqueta_service.dart';
import '../../services/controladorsesion.dart';

class VerTareaController extends GetxController {
  final TareaService _tareaService = TareaService();
  final AdjuntoService _adjuntoService = AdjuntoService();
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();
  
  // Variables observables
  RxBool cargando = false.obs;
  RxBool editando = false.obs;
  Rx<Tarea?> tarea = Rx<Tarea?>(null);
  Rx<Categoria?> categoria = Rx<Categoria?>(null);
  Rx<Lista?> lista = Rx<Lista?>(null); // Añadido lista observable
  RxList<Etiqueta> etiquetas = <Etiqueta>[].obs;
  RxList<Adjunto> adjuntos = <Adjunto>[].obs;
  RxList<Adjunto> adjuntosConUrl = <Adjunto>[].obs;

  // Formateo de fechas
  RxString fechaCreacion = ''.obs;
  RxString horaCreacion = ''.obs;
  RxString fechaVencimiento = ''.obs;
  RxString horaVencimiento = ''.obs;
  
  // Constructor con ID de tarea opcional
  VerTareaController({int? tareaId}) {
    if (tareaId != null) {
      cargarTarea(tareaId);
    }
  }

@override
void onInit() {
  super.onInit();
  // Verificar si argumentos es un entero directamente o un mapa con clave tareaId
  if (Get.arguments != null) {
    if (Get.arguments is int) {
      cargarTarea(Get.arguments);
    } else if (Get.arguments is Map && Get.arguments['tareaId'] != null) {
      cargarTarea(Get.arguments['tareaId']);
    }
  }
}
  // Cargar todos los datos de la tarea
  Future<void> cargarTarea(int tareaId) async {
    try {
      cargando.value = true;
      
      // 1. Cargar datos básicos de la tarea
      final resultadoTarea = await _tareaService.obtenerTareaPorId(tareaId);
      if (resultadoTarea.status == 200 && resultadoTarea.body is Tarea) {
        tarea.value = resultadoTarea.body;
        
        // Formatear fechas
        if (tarea.value != null) {
          // Formatear fecha de creación
          if (tarea.value!.fechaCreacion != null) {
            final DateTime fechaCreacionDt = tarea.value!.fechaCreacion;
            fechaCreacion.value = DateFormat('dd/MM/yyyy').format(fechaCreacionDt);
            horaCreacion.value = DateFormat('HH:mm').format(fechaCreacionDt);
          }
          
          // Formatear fecha de vencimiento
          if (tarea.value!.fechaVencimiento != null) {
            final DateTime fechaVencimientoDt = tarea.value!.fechaVencimiento;
            fechaVencimiento.value = DateFormat('dd/MM/yyyy').format(fechaVencimientoDt);
            horaVencimiento.value = DateFormat('HH:mm').format(fechaVencimientoDt);
          }
          
          // Cargar la categoría de la tarea
          if (tarea.value!.categoriaId != null) {
            // Aquí deberías cargar la categoría usando el categoriaId
            // Por ahora dejamos categoria.value como null
          }
          
          // Cargar la lista de la tarea
          if (tarea.value!.listaId != null) {
            // Aquí deberías cargar la lista usando el listaId
            // Por ahora dejamos lista.value como null
          }
        }
        
        // 2. Cargar etiquetas de la tarea
        final resultadoEtiquetas = await _tareaService.obtenerEtiquetasPorTarea(tareaId);
        if (resultadoEtiquetas.status == 200 && resultadoEtiquetas.body is List) {
          List<dynamic> tareaEtiquetas = resultadoEtiquetas.body;
          // Extraer solo las etiquetas
          List<Etiqueta> listaEtiquetas = [];
          
          for (var te in tareaEtiquetas) {
            if (te is TareaEtiqueta && te.etiquetaId != null) {
              // Aquí deberías obtener la etiqueta basada en el etiquetaId
              // O si TareaEtiqueta ya contiene la etiqueta completa, extraerla
              // Para este ejemplo, asumimos que cada TareaEtiqueta tiene un campo etiqueta
              // Si no lo tiene, necesitarías hacer una llamada adicional para obtener la etiqueta
              
              // Ejemplo si tienes un campo etiqueta en TareaEtiqueta:
              // if (te.etiqueta != null) {
              //   listaEtiquetas.add(te.etiqueta!);
              // }
              
              // O si necesitas cargar la etiqueta:
              // var etiqueta = await _etiquetaService.obtenerEtiquetaPorId(te.etiquetaId!);
              // if (etiqueta != null) {
              //   listaEtiquetas.add(etiqueta);
              // }
            }
          }
          
          etiquetas.assignAll(listaEtiquetas);
        }
        
        // 3. Cargar adjuntos de la tarea
        final resultadoAdjuntos = await _adjuntoService.obtenerAdjuntosPorTarea(tareaId);
        if (resultadoAdjuntos.status == 200 && resultadoAdjuntos.body is List<Adjunto>) {
          adjuntos.assignAll(resultadoAdjuntos.body);
          
          // Cargar URLs de acceso para los adjuntos
          for (var adjunto in adjuntos) {
            if (adjunto.id != null) {
              final resultadoUrl = await _adjuntoService.obtenerUrlAdjunto(adjunto.id!, expiraEn: 3600);
              if (resultadoUrl.status == 200 && resultadoUrl.body is Map) {
                final Map<String, dynamic> urlData = resultadoUrl.body;
                if (urlData.containsKey('url')) {
                  // Creamos una copia del adjunto con la URL actualizada
                  Adjunto adjuntoConUrl = adjunto.copyWith(url: urlData['url']);
                  adjuntosConUrl.add(adjuntoConUrl);
                }
              }
            }
          }
        }
      } else {
        Get.snackbar(
          'Error',
          'No se pudo cargar la tarea',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        // Volver atrás si no se puede cargar la tarea
        Get.back();
      }
    } catch (e) {
      print('Error al cargar tarea: $e');
      Get.snackbar(
        'Error',
        'No se pudo cargar la información de la tarea',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Volver atrás en caso de error
      Get.back();
    } finally {
      cargando.value = false;
    }
  }

  // Método para obtener el color de prioridad
  Color obtenerColorPrioridad() {
    if (tarea.value == null || tarea.value!.prioridad == null) {
      return Colors.grey;
    }
    
    // Convertir enum a string para hacer la comparación
    String prioridadStr = prioridadToString(tarea.value!.prioridad);
    
    switch (prioridadStr.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Método auxiliar para convertir Prioridad a String
  String prioridadToString(Prioridad prioridad) {
    // Extrae solo el nombre del enum (sin el nombre de la clase)
    return prioridad.toString().split('.').last;
  }

  // Método para obtener el color de estado
  Color obtenerColorEstado() {
    if (tarea.value == null || tarea.value!.estado == null) {
      return Colors.grey;
    }
    
    // Convertir enum a string para hacer la comparación
    String estadoStr = estadoToString(tarea.value!.estado);
    
    switch (estadoStr.toLowerCase()) {
      case 'pendiente':
        return Colors.blue;
      case 'en_progreso':
        return Colors.amber;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Método auxiliar para convertir Estado a String
  String estadoToString(Estado estado) {
    // Extrae solo el nombre del enum (sin el nombre de la clase)
    return estado.toString().split('.').last;
  }

  // Método para abrir un adjunto
  Future<void> abrirAdjunto(Adjunto adjunto) async {
    if (adjunto.url != null && adjunto.url!.isNotEmpty) {
      final Uri url = Uri.parse(adjunto.url!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'No se puede abrir el archivo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'No hay URL disponible para este adjunto',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Método para descargar un adjunto (opcional)
  Future<void> descargarAdjunto(Adjunto adjunto) async {
    try {
      if (adjunto.url != null && adjunto.url!.isNotEmpty) {
        cargando.value = true;
        
        // Crear directorio temporal para descargar
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/${adjunto.nombre}';
        
        // Descargar el archivo
        final response = await http.get(Uri.parse(adjunto.url!));
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        // Informar al usuario
        Get.snackbar(
          'Éxito',
          'Archivo descargado correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Abrir el archivo
        final Uri uri = Uri.file(filePath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      }
    } catch (e) {
      print('Error al descargar adjunto: $e');
      Get.snackbar(
        'Error',
        'No se pudo descargar el archivo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      cargando.value = false;
    }
  }

  // Método para obtener el tipo de archivo como string
  String tipoArchivoToString(TipoArchivo tipo) {
    return tipo.toString().split('.').last;
  }

  // Método para ir a la pantalla de edición de tarea
  void irAEditarTarea() {
    if (tarea.value != null && tarea.value!.id != null) {
      Get.toNamed(
        '/editar-tarea',
        arguments: {'tareaId': tarea.value!.id},
      )?.then((_) {
        // Recargar los datos de la tarea después de editar
        if (tarea.value != null && tarea.value!.id != null) {
          cargarTarea(tarea.value!.id!);
        }
      });
    }
  }

  // Método para eliminar la tarea
  Future<void> eliminarTarea() async {
    try {
      if (tarea.value != null && tarea.value!.id != null) {
        final confirmar = await Get.dialog<bool>(
          AlertDialog(
            title: Text('Eliminar tarea'),
            content: Text('¿Estás seguro de que deseas eliminar esta tarea? Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        
        if (confirmar == true) {
          cargando.value = true;
          
          // Eliminar adjuntos primero
          for (var adjunto in adjuntos) {
            if (adjunto.id != null) {
              await _adjuntoService.eliminarAdjunto(adjunto.id!);
            }
          }
          
          // Eliminar la tarea
          final resultado = await _tareaService.eliminarTarea(tarea.value!.id!);
          
          if (resultado.status == 200) {
            Get.snackbar(
              'Éxito',
              'Tarea eliminada correctamente',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            
            // Actualizar HomeController si está disponible
            if (Get.isRegistered<HomeController>()) {
              final homeController = Get.find<HomeController>();
              homeController.recargarDatos();
            }
            
            // Volver a la pantalla anterior
            Get.back();
          } else {
            Get.snackbar(
              'Error',
              'No se pudo eliminar la tarea',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      }
    } catch (e) {
      print('Error al eliminar tarea: $e');
      Get.snackbar(
        'Error',
        'No se pudo eliminar la tarea',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      cargando.value = false;
    }
  }
}