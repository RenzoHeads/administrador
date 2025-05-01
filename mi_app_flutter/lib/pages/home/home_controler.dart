import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/lista.dart';
import '../../models/tarea.dart';
import '../../services/lista_service.dart';
import '../../services/tarea_service.dart';
import '../../services/controladorsesion.dart';
import '../../services/usuario_service.dart';

class HomeController extends GetxController {
  final ListaService _listaService = ListaService();
  final TareaService _tareaService = TareaService();
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();
  final UsuarioService _usuarioService = UsuarioService();

  RxList<Tarea> tareas = <Tarea>[].obs;
  RxList<Tarea> tareasDeHoy = <Tarea>[].obs;
  RxList<Lista> listas = <Lista>[].obs;
  
  // Mapa para almacenar la cantidad de tareas por lista
  final RxMap<int, int> cantidadTareasPorLista = <int, int>{}.obs;
  
  RxBool cargando = true.obs;
  RxString profilePhotoUrl = RxString('');
  RxBool loadingPhoto = true.obs;
  
  RxInt pestanaSeleccionada = 0.obs;
  
  // Para la fecha actual
  RxString fechaActual = ''.obs;
  // Variables para evitar recargas innecesarias
  bool _tareasCargadas = false;
  bool _listasCargadas = false;
  bool _fotoCargada = false;

  @override
  void onInit() {
    super.onInit();
    cargarFechaActual();
    _cargarDatosIniciales();
  }

  void _cargarDatosIniciales() {
    if (!_tareasCargadas) {
      cargarTareasDelUsuario();
      _tareasCargadas = true;
    }
    if (!_listasCargadas) {
      cargarListasDelUsuario();
      _listasCargadas = true;
    }
    if (!_fotoCargada) {
      cargarFotoPerfil();
      _fotoCargada = true;
    }
  }

  void cargarFechaActual() {
    try {
      final now = DateTime.now();
      final formatter = DateFormat('EEEE, d MMMM', 'es_ES');
      String fecha = formatter.format(now);
      // Capitalizar primera letra
      fecha = fecha.substring(0, 1).toUpperCase() + fecha.substring(1);
      fechaActual.value = fecha;
      print("Fecha actual cargada: ${fechaActual.value}");
    } catch (e) {
      print("Error al cargar fecha: $e");
      // Fallback simple si hay error con el formato
      fechaActual.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }
  
  void cambiarPestana(int index) {
    pestanaSeleccionada.value = index;
  }

  void cargarTareasDelUsuario() async {
    final usuario = _sesion.usuarioActual.value;
    print("Iniciando carga de tareas de hoy para usuario: ${usuario?.id}");

    if (usuario != null && usuario.id != null) {
      try {
        cargando.value = true;
        
        // Cargar solo tareas de hoy desde el servidor
        final resultadoHoy = await _tareaService.obtenerTareasHoyPorUsuario(usuario.id!);
        
        // Procesar tareas de hoy
        if (resultadoHoy.status == 200) {
          List<Tarea> tareasTemporales = [];
          
          if (resultadoHoy.body is List) {
            final List<dynamic> lista = resultadoHoy.body as List;
            
            for (var item in lista) {
              if (item is Tarea) {
                tareasTemporales.add(item);
              }
            }
          } else if (resultadoHoy.body is String) {
            try {
              final List<dynamic> jsonData = json.decode(resultadoHoy.body as String);
              
              for (var item in jsonData) {
                final tarea = Tarea.fromMap(item);
                tareasTemporales.add(tarea);
              }
            } catch (e) {
              print("Error al procesar el JSON de tareas de hoy: $e");
            }
          }
          
          // Ordenar tareas por hora (de menor a mayor)
          tareasTemporales.sort((a, b) {
            if (a.fechaCreacion == null || b.fechaCreacion == null) {
              return 0;
            }
            final horaA = a.fechaCreacion!.hour;
            final horaB = b.fechaCreacion!.hour;
            return horaA.compareTo(horaB);
          });
          
          // Actualizar la lista observable con las tareas ordenadas
          tareasDeHoy.clear();
          tareasDeHoy.addAll(tareasTemporales);
          
          print("Tareas de hoy cargadas y ordenadas: ${tareasDeHoy.length}");
        } else {
          print("Error al obtener tareas de hoy: ${resultadoHoy.body}");
        }
        
      } catch (e) {
        print('Error al cargar tareas: $e');
      } finally {
        cargando.value = false;
      }
    } else {
      print("No hay usuario activo para cargar tareas");
      cargando.value = false;
    }
  }

  void cargarListasDelUsuario() async {
    final usuario = _sesion.usuarioActual.value;
    print("Iniciando carga de listas para usuario: ${usuario?.id}");

    if (usuario != null && usuario.id != null) {
      try {
        final resultado = await _listaService.obtenerListasPorUsuario(usuario.id!);
        
        if (resultado.status == 200) {
          // Verificar si el body es una lista de objetos o un string
          if (resultado.body is List) {
            // La respuesta ya es una lista de objetos Lista
            final List<dynamic> lista = resultado.body as List;
            listas.clear(); // Limpiamos la lista actual
            
            for (var item in lista) {
              if (item is Lista) {
                listas.add(item);
              }
            }
          } else if (resultado.body is String) {
            // Intentar parsear el string a JSON y luego a objetos Lista
            try {
              final List<dynamic> jsonData = json.decode(resultado.body as String);
              listas.clear(); // Limpiamos la lista actual
              
              for (var item in jsonData) {
                final lista = Lista.fromMap(item);
                listas.add(lista);
              }
            } catch (e) {
              print("Error al procesar el JSON de listas: $e");
            }
          }
          
          print("Listas cargadas: ${listas.length}");
          
          // Una vez que tenemos las listas, cargamos la cantidad de tareas para cada una
          cargarCantidadTareasPorListas();
        } else {
          print("Error al obtener listas: ${resultado.body}");
        }
      } catch (e) {
        print('Error al cargar listas: $e');
      }
    } else {
      print("No hay usuario activo para cargar listas");
    }
  }
  
  // Método para cargar la cantidad de tareas para todas las listas de una vez
  void cargarCantidadTareasPorListas() async {
    for (var lista in listas) {
      if (lista.id != null) {
        try {
          final cantidad = await _obtenerCantidadTareasPorLista(lista.id!);
          cantidadTareasPorLista[lista.id!] = cantidad;
        } catch (e) {
          print('Error al cargar cantidad de tareas para lista ${lista.id}: $e');
          cantidadTareasPorLista[lista.id!] = 0;
        }
      }
    }
  }
  
  // Método interno para obtener la cantidad de tareas por lista
  Future<int> _obtenerCantidadTareasPorLista(int listaId) async {
    try {
      final resultado = await _listaService.obtenerCantidadTareasPorLista(listaId);
      
      if (resultado.status == 200) {
        return resultado.body is int ? resultado.body : 0;
      } else {
        print("Error al obtener cantidad de tareas: ${resultado.body}");
        return 0;
      }
    } catch (e) {
      print('Error al obtener cantidad de tareas: $e');
      return 0;
    }
  }
  
  // Método público para obtener la cantidad de tareas por lista
  int getCantidadTareasPorLista(int listaId) {
    return cantidadTareasPorLista[listaId] ?? 0;
  }
  
  // Método para actualizar la cantidad de tareas de una lista específica
  Future<void> actualizarCantidadTareasPorLista(int listaId) async {
    try {
      final cantidad = await _obtenerCantidadTareasPorLista(listaId);
      cantidadTareasPorLista[listaId] = cantidad;
    } catch (e) {
      print('Error al actualizar cantidad de tareas para lista $listaId: $e');
    }
  }

  void cargarFotoPerfil() async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario != null && usuario.id != null) {
      try {
        loadingPhoto.value = true;
        final respuesta = await _usuarioService.getProfilePhotoUrl(usuario.id!);
        
        if (respuesta != null && respuesta.status == 200) {
          // Parseamos la respuesta JSON para obtener la URL
          if (respuesta.body is String) {
            try {
              final Map<String, dynamic> data = json.decode(respuesta.body as String);
              
              if (data.containsKey('url')) {
                profilePhotoUrl.value = data['url'];
                print("URL de foto cargada: ${profilePhotoUrl.value}");
              } else {
                print("Respuesta no contiene URL: $data");
              }
            } catch (e) {
              print("Error al parsear JSON de foto: $e");
            }
          } else {
            print("Respuesta de foto no es un string: ${respuesta.body}");
          }
        } else {
          print("Error al obtener la foto de perfil: ${respuesta?.body}");
          // Dejamos la URL vacía, para que la UI muestre un avatar por defecto
          profilePhotoUrl.value = '';
        }
      } catch (e) {
        print('Error al cargar foto de perfil: $e');
        profilePhotoUrl.value = '';
      } finally {
        loadingPhoto.value = false;
      }
    }
  }
  
  // Método para recargar la foto de perfil, útil después de actualizar
  void recargarFotoPerfil() {
    profilePhotoUrl.value = '';
    loadingPhoto.value = true;
    cargarFotoPerfil();
  }
  
  // Método para recargar todos los datos
  void recargarDatos() {
    cargarTareasDelUsuario();
    cargarListasDelUsuario(); // Esto también recargará las cantidades de tareas
    cargarFotoPerfil();
  }
  
  // Método para navegar a la página de perfil
  void navegarAPerfil() {
    Get.toNamed('/perfil');
  }
  
  // Método para crear nueva tarea
  void crearNuevaTarea() {
    // Implementar lógica para crear nueva tarea
    Get.toNamed('/nueva-tarea');
  }

  Color colorDesdeString(String colorString, {int alpha = 80}) {
    try {
      String hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        // Agregar opacidad personalizada
        return Color(int.parse('0x${alpha.toRadixString(16).padLeft(2, '0')}$hex'));
      } else if (hex.length == 8) {
        // Ya incluye opacidad, se respeta
        return Color(int.parse('0x$hex'));
      }
    } catch (_) {}
    return Colors.white; // fallback
  }

  // Método para cerrar la sesión
  void cerrarSesionCompleta() {
    _sesion.cerrarSesion();
    Get.offAllNamed('/sign-in');
  }
}