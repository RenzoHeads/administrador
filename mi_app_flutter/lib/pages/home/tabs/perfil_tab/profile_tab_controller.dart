// Corrección en ProfileTabController.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/controladorsesion.dart';
import '../../../../services/usuario_service.dart';
import '../../../../services/recordatorio_service.dart';
import '../../../../models/usuario.dart';
import '../../home_controler.dart';
import '../../../principal/principal_controller.dart';

class ProfileTabController extends GetxController {
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();
  final UsuarioService _usuarioService = UsuarioService();
  final RecordatorioService _recordatorioService = RecordatorioService();

  // Obtener el PrincipalController
  final PrincipalController _principalController =
      Get.find<PrincipalController>();

  // Estados para los switches de notificaciones
  final RxBool notificacionesSistema = true.obs;
  final RxBool notificacionesUrgentes = false.obs;

  // Usar las variables del PrincipalController para la foto
  RxString get profilePhotoUrl => _principalController.profilePhotoUrl;
  RxBool get loadingPhoto => _principalController.loadingPhoto;

  @override
  void onInit() {
    super.onInit();
    // Cargar el estado actual de los recordatorios
    cargarEstadoRecordatorios();
  }

  void setHomeController(HomeController controller) {
    // Ya no es necesario mantener referencia al HomeController
  }

  // Este método ahora delega al PrincipalController
  Future<void> forzarRecargaFoto() async {
    await _principalController.forzarRecargaFoto();
  }

  Future<bool> actualizarNombreUsuario(String nuevoNombre) async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario != null && usuario.id != null) {
      try {
        final respuesta = await _usuarioService.updateUserName(
          usuario.id!,
          nuevoNombre,
        );
        if (respuesta != null && respuesta.status == 200) {
          Usuario usuarioActual = _sesion.obtenerUsuarioActual()!;
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

  Future<bool> actualizarCorreoUsuario(String nuevoCorreo) async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario != null && usuario.id != null) {
      try {
        final respuesta = await _usuarioService.updateUserEmail(
          usuario.id!,
          nuevoCorreo,
        );
        if (respuesta != null && respuesta.status == 200) {
          Usuario usuarioActual = _sesion.obtenerUsuarioActual()!;
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

  Future<bool> subirFotoPerfil(File foto) async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario != null && usuario.id != null) {
      try {
        final respuesta = await _usuarioService.uploadProfilePhoto(
          usuario.id!,
          foto,
        );
        if (respuesta != null && respuesta.status == 200) {
          try {
            // Parsear la respuesta para obtener la URL de la imagen
            final Map<String, dynamic> data = json.decode(
              respuesta.body as String,
            );
            if (data.containsKey('imagen_perfil') &&
                data['imagen_perfil'] != null) {
              // Actualizar el usuario en el controlador de sesión con la nueva URL
              Usuario usuarioActualizado = Usuario(
                id: usuario.id,
                nombre: usuario.nombre,
                contrasena: usuario.contrasena,
                email: usuario.email,
                token: usuario.token,
                foto: data['imagen_perfil'],
              );
              await _sesion.actualizarUsuario(usuarioActualizado);

              await forzarRecargaFoto();

              Get.snackbar(
                'Éxito',
                'Foto de perfil actualizada',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              return true;
            }
          } catch (e) {
            print('Error al procesar respuesta de subida de foto: $e');
          }
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

  Future<bool> eliminarFotoPerfil() async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario != null && usuario.id != null) {
      try {
        final respuesta = await _usuarioService.deleteProfilePhoto(usuario.id!);
        if (respuesta != null && respuesta.status == 200) {
          // Actualizar el usuario en el controlador de sesión eliminando la URL
          Usuario usuarioActualizado = Usuario(
            id: usuario.id,
            nombre: usuario.nombre,
            contrasena: usuario.contrasena,
            email: usuario.email,
            token: usuario.token,
            foto: '',
          );
          await _sesion.actualizarUsuario(usuarioActualizado);

          profilePhotoUrl.value = '';

          Get.snackbar(
            'Éxito',
            'Foto de perfil eliminada',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          return true;
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

  // Métodos para manejar los switches de notificaciones
  Future<void> toggleNotificacionesSistema(bool value) async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario?.id == null) return;

    try {
      if (value) {
        // Activar todos los recordatorios del usuario
        final respuesta = await _recordatorioService
            .activarRecordatoriosUsuario(usuario!.id!);

        if (respuesta.status == 200) {
          notificacionesSistema.value = true;

          Get.snackbar(
            'Éxito',
            'Recordatorios del sistema activados',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'No se pudieron activar los recordatorios',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        // Desactivar todos los recordatorios del usuario
        final respuesta = await _recordatorioService
            .desactivarRecordatoriosUsuario(usuario!.id!);

        if (respuesta.status == 200) {
          notificacionesSistema.value = false;
          notificacionesUrgentes.value = false; // También desactivar urgentes

          Get.snackbar(
            'Éxito',
            'Recordatorios del sistema desactivados',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'No se pudieron desactivar los recordatorios',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error al cambiar estado de notificaciones del sistema: $e');
      Get.snackbar(
        'Error',
        'Ocurrió un error al cambiar las notificaciones',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> toggleNotificacionesUrgentes(bool value) async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario?.id == null) return;

    try {
      if (value) {
        // Activar solo recordatorios de prioridad alta
        final respuesta = await _recordatorioService
            .activarRecordatoriosPrioridadAlta(usuario!.id!);

        if (respuesta.status == 200) {
          notificacionesUrgentes.value = true;
          notificacionesSistema.value = true; // También activar sistema

          Get.snackbar(
            'Éxito',
            'Recordatorios urgentes activados',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'No se pudieron activar los recordatorios urgentes',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        // Activar todos los recordatorios (volver al estado normal)
        final respuesta = await _recordatorioService
            .activarRecordatoriosUsuario(usuario!.id!);

        if (respuesta.status == 200) {
          notificacionesUrgentes.value = false;

          Get.snackbar(
            'Éxito',
            'Mostrando todas las notificaciones',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'No se pudo cambiar el filtro de notificaciones',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error al cambiar estado de notificaciones urgentes: $e');
      Get.snackbar(
        'Error',
        'Ocurrió un error al cambiar las notificaciones urgentes',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Método para obtener el estado actual de los recordatorios
  Future<void> cargarEstadoRecordatorios() async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario?.id == null) return;

    try {
      final respuesta = await _recordatorioService
          .obtenerEstadoRecordatoriosUsuario(usuario!.id!);

      if (respuesta.status == 200) {
        final Map<String, dynamic> estado =
            respuesta.body as Map<String, dynamic>;

        // Determinar el estado de los switches basado en la respuesta
        final int recordatoriosActivados =
            estado['recordatorios_activados'] ?? 0;
        final int totalRecordatorios = estado['total_recordatorios'] ?? 0;

        if (totalRecordatorios > 0) {
          // Si hay recordatorios y algunos están activados
          notificacionesSistema.value = recordatoriosActivados > 0;

          // Para notificaciones urgentes, necesitaríamos lógica adicional
          // Por ahora, mantener el estado actual
        }
      }
    } catch (e) {
      print('Error al cargar estado de recordatorios: $e');
    }
  }
}
