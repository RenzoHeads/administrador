// Corrección en ProfileTabController.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/controladorsesion.dart';
import '../../../../services/usuario_service.dart';
import '../../../../models/usuario.dart';
import '../../home_controler.dart';

class ProfileTabController extends GetxController {
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();
  final UsuarioService _usuarioService = UsuarioService();
  HomeController? _homeController;

  RxString profilePhotoUrl = RxString('');
  RxBool loadingPhoto = true.obs;
  // Agregamos esta bandera para controlar si ya se cargó la foto
  RxBool _fotoYaCargada = false.obs;

  @override
  void onInit() {
    super.onInit();
    // No cargamos la foto aquí, esperamos a que setHomeController sea llamado
  }

  void setHomeController(HomeController controller) {
    _homeController = controller;
    // Solo cargamos la foto si aún no se ha cargado
    if (!_fotoYaCargada.value) {
      cargarFotoPerfil();
    }
  }

  Future<void> cargarFotoPerfil() async {
    // Si ya estamos cargando o ya cargamos, no hacemos nada
    if (_fotoYaCargada.value) {
      return;
    }

    final usuario = _sesion.usuarioActual.value;
    if (usuario != null) {
      try {
        loadingPhoto.value = true;
        profilePhotoUrl.value = ''; // Limpiar la URL actual

        // Obtener la URL directamente del controlador de sesión
        if (usuario.foto != null && usuario.foto!.isNotEmpty) {
          profilePhotoUrl.value = usuario.foto!;
          print(
            'Foto de perfil cargada desde sesión: ${profilePhotoUrl.value}',
          );
        } else {
          print('No hay foto de perfil en la sesión');
          profilePhotoUrl.value = '';
        }
      } catch (e) {
        print('Error al cargar foto de perfil: $e');
        profilePhotoUrl.value = '';
      } finally {
        loadingPhoto.value = false;
        _fotoYaCargada.value = true;

        // Notificar al HomeController sobre el cambio
        if (_homeController != null) {
          _homeController!.profilePhotoUrl.value = profilePhotoUrl.value;
          _homeController!.loadingPhoto.value = loadingPhoto.value;
        }
      }
    } else {
      print('Usuario no encontrado');
      profilePhotoUrl.value = '';
      loadingPhoto.value = false;
    }
  }

  // Este método ahora sólo fuerza una recarga cuando es necesario
  Future<void> forzarRecargaFoto() async {
    _fotoYaCargada.value = false; // Reseteamos la bandera
    await cargarFotoPerfil(); // Cargamos de nuevo
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

              forzarRecargaFoto();

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
          _fotoYaCargada.value = false;

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
}
