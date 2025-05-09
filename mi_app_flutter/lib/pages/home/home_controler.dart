import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/lista.dart';
import '../../models/tarea.dart';
import '../../services/lista_service.dart';
import '../../services/tarea_service.dart';
import '../../services/controladorsesion.dart';
import '../../services/usuario_service.dart';
import '../../models/usuario.dart';
import '../../pages/widgets/eventos_controlador.dart';

class HomeController extends GetxController {
  final ListaService _listaService = ListaService();
  final TareaService _tareaService = TareaService();
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();
  final UsuarioService _usuarioService = UsuarioService();
  final String controladorId = 'listas';
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
    _suscribirseAEventos();
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

  // Método para suscribirse a eventos
  void _suscribirseAEventos() {
    // Observar eventos de recarga general
    ever(EventosControlador.recargarDatosEvento, (_) {
      recargarDatos();
    });

    // Observar eventos de recarga específicos para este controlador
    ever(EventosControlador.recargarControladorEvento, (mapa) {
      if (mapa.containsKey(controladorId) && mapa[controladorId] == true) {
        //Recargamos las listas
        cargarListasDelUsuario();
        // Reseteamos el flag para evitar recargas innecesarias
        EventosControlador.recargarControladorEvento[controladorId] = false;
      }
    });
  }

  void cargarFechaActual() {
    try {
      final now = DateTime.now();
      final formatter = DateFormat('EEEE, d MMMM', 'es_ES');
      String fecha = formatter.format(now);
      // Capitalizar primera letra
      fecha = fecha.substring(0, 1).toUpperCase() + fecha.substring(1);
      fechaActual.value = fecha;
    } catch (e) {
      // Fallback simple si hay error con el formato
      fechaActual.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  void cambiarPestana(int index) {
    pestanaSeleccionada.value = index;
  }

  // Convertida a Future<void> para permitir await
  Future<void> cargarTareasDelUsuario() async {
    final usuario = _sesion.usuarioActual.value;

    if (usuario != null && usuario.id != null) {
      try {
        cargando.value = true;

        // Cargar solo tareas de hoy desde el servidor
        final resultadoHoy = await _tareaService.obtenerTareasHoyPorUsuario(
          usuario.id!,
        );

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
              final List<dynamic> jsonData = json.decode(
                resultadoHoy.body as String,
              );

              for (var item in jsonData) {
                final tarea = Tarea.fromMap(item);
                tareasTemporales.add(tarea);
              }
            } catch (e) {
              print("Error al procesar el JSON de tareas de hoy: $e");
            }
          }

          // Actualizar la lista observable con las tareas ordenadas
          tareasDeHoy.clear();
          tareasDeHoy.addAll(tareasTemporales);

          print("Tareas de hoy cargadas y ordenadas: ${tareasDeHoy.length}");
          //Imprime los nombres de las tareas de hoy
          for (var tarea in tareasDeHoy) {
            print("Tarea de hoy: ${tarea.titulo}");
          }
        } else {
          // Manejar el caso en que no se obtienen tareas
          tareasDeHoy.clear();
          print(
            "No se encontraron tareas de hoy para el usuario: ${usuario.id}",
          );
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

  // Convertida a Future<void> para permitir await
  Future<void> cargarListasDelUsuario() async {
    final usuario = _sesion.usuarioActual.value;
    print("Iniciando carga de listas para usuario: ${usuario?.id}");

    if (usuario != null && usuario.id != null) {
      try {
        final resultado = await _listaService.obtenerListasPorUsuario(
          usuario.id!,
        );

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
              final List<dynamic> jsonData = json.decode(
                resultado.body as String,
              );
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
          await cargarCantidadTareasPorListas();
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

  // Convertida a Future<void> para permitir await
  Future<void> cargarCantidadTareasPorListas() async {
    for (var lista in listas) {
      if (lista.id != null) {
        try {
          final cantidad = await _obtenerCantidadTareasPorLista(lista.id!);
          cantidadTareasPorLista[lista.id!] = cantidad;
        } catch (e) {
          print(
            'Error al cargar cantidad de tareas para lista ${lista.id}: $e',
          );
          cantidadTareasPorLista[lista.id!] = 0;
        }
      }
    }
  }

  // Método interno para obtener la cantidad de tareas por lista
  Future<int> _obtenerCantidadTareasPorLista(int listaId) async {
    try {
      final resultado = await _listaService.obtenerCantidadTareasPorLista(
        listaId,
      );

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

  // Convertida a Future<void> para permitir await
  Future<void> cargarFotoPerfil() async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario != null && usuario.id != null) {
      try {
        loadingPhoto.value = true;
        final respuesta = await _usuarioService.getProfilePhotoUrl(usuario.id!);

        if (respuesta != null && respuesta.status == 200) {
          // Parseamos la respuesta JSON para obtener la URL
          if (respuesta.body is String) {
            try {
              final Map<String, dynamic> data = json.decode(
                respuesta.body as String,
              );

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

  // Convertida a Future<void> para permitir await
  Future<void> recargarFotoPerfil() async {
    profilePhotoUrl.value = '';
    loadingPhoto.value = true;
    await cargarFotoPerfil();
  }

  // Convertido a Future<void> para permitir await
  Future<void> recargarDatos() async {
    try {
      // Indicar que estamos cargando datos
      cargando.value = true;

      // Reiniciar las banderas de control para forzar la recarga
      _tareasCargadas = false;
      _listasCargadas = false;
      _fotoCargada = false;

      print("Iniciando recarga completa de datos...");

      // Cargar los datos en orden, esperando que cada operación termine
      await cargarTareasDelUsuario();
      print("Tareas recargadas correctamente");

      await cargarListasDelUsuario();
      print("Listas recargadas correctamente");

      await cargarFotoPerfil();
      print("Foto de perfil recargada correctamente");

      // Actualizar las banderas para indicar que los datos están cargados
      _tareasCargadas = true;
      _listasCargadas = true;
      _fotoCargada = true;

      print("Recarga de datos completada exitosamente");
    } catch (e) {
      print('Error durante la recarga de datos: $e');
      // Notificar el error
      Get.snackbar(
        'Error',
        'No se pudieron recargar todos los datos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      // Asegurarse de que el estado de carga se restablezca
      cargando.value = false;
    }
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
        return Color(
          int.parse('0x${alpha.toRadixString(16).padLeft(2, '0')}$hex'),
        );
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

  // Método para actualizar el nombre del usuario actual
  Future<bool> actualizarNombreUsuario(String nuevoNombre) async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario != null && usuario.id != null) {
      try {
        final respuesta = await _usuarioService.updateUserName(
          usuario.id!,
          nuevoNombre,
        );
        if (respuesta != null && respuesta.status == 200) {
          // Actualizar el nombre en el usuario actual
          // Actualizar el correo en el usuario actual
          Usuario usuarioActual = _sesion.obtenerUsuarioActual()!;

          // Crear un nuevo usuario con el nombre actualizado
          Usuario usuarioActualizado = Usuario(
            id: usuarioActual.id,
            nombre: nuevoNombre,
            contrasena: usuarioActual.contrasena,
            email: usuarioActual.email,
            token: usuarioActual.token,
            foto: usuarioActual.foto,
          );

          _sesion.actualizarUsuario(usuarioActualizado);
          Get.snackbar(
            'Éxito',
            'Nombre actualizado correctamente',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          return true;
        } else {
          Get.snackbar(
            'Error',
            'No se pudo actualizar el nombre',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print('Error al actualizar nombre: $e');
        Get.snackbar(
          'Error',
          'Ocurrió un error al actualizar el nombre',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
    return false;
  }

  // Método para actualizar el correo del usuario actual
  Future<bool> actualizarCorreoUsuario(String nuevoCorreo) async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario != null && usuario.id != null) {
      try {
        final respuesta = await _usuarioService.updateUserEmail(
          usuario.id!,
          nuevoCorreo,
        );
        if (respuesta != null && respuesta.status == 200) {
          // Actualizar el correo en el usuario actual
          Usuario usuarioActual = _sesion.obtenerUsuarioActual()!;

          // Crear un nuevo usuario con el nombre actualizado
          Usuario usuarioActualizado = Usuario(
            id: usuarioActual.id,
            nombre: usuarioActual.nombre,
            contrasena: usuarioActual.contrasena,
            email: nuevoCorreo,
            token: usuarioActual.token,
            foto: usuarioActual.foto,
          );

          _sesion.actualizarUsuario(usuarioActualizado);
          Get.snackbar(
            'Éxito',
            'Correo actualizado correctamente',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          return true;
        } else {
          Get.snackbar(
            'Error',
            'No se pudo actualizar el correo',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print('Error al actualizar correo: $e');
        Get.snackbar(
          'Error',
          'Ocurrió un error al actualizar el correo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
    return false;
  }

  // Método para subir una nueva foto de perfil
  Future<bool> subirFotoPerfil(File foto) async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario != null && usuario.id != null) {
      try {
        final respuesta = await _usuarioService.uploadProfilePhoto(
          usuario.id!,
          foto,
        );
        if (respuesta != null && respuesta.status == 200) {
          // Recargar la foto de perfil para mostrar la nueva
          await recargarFotoPerfil();
          Get.snackbar(
            'Éxito',
            'Foto de perfil actualizada',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          return true;
        } else {
          Get.snackbar(
            'Error',
            'No se pudo subir la foto de perfil',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print('Error al subir foto: $e');
        Get.snackbar(
          'Error',
          'Ocurrió un error al subir la foto',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
    return false;
  }

  // Método para eliminar la foto de perfil
  Future<bool> eliminarFotoPerfil() async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario != null && usuario.id != null) {
      try {
        final respuesta = await _usuarioService.deleteProfilePhoto(usuario.id!);
        if (respuesta != null && respuesta.status == 200) {
          // Limpiar la URL de la foto y recargar
          profilePhotoUrl.value = '';
          await cargarFotoPerfil();
          Get.snackbar(
            'Éxito',
            'Foto de perfil eliminada',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          return true;
        } else {
          Get.snackbar(
            'Error',
            'No se pudo eliminar la foto de perfil',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print('Error al eliminar foto: $e');
        Get.snackbar(
          'Error',
          'Ocurrió un error al eliminar la foto',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
    return false;
  }
}
