import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/controladorsesion.dart';
import '../../../../services/usuario_service.dart';
import '../../../../models/usuario.dart';

class ProfileTabController extends GetxController {
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();
  final UsuarioService _usuarioService = UsuarioService();

  RxString profilePhotoUrl = RxString('');
  RxBool loadingPhoto = true.obs;

  @override
  void onInit() {
    super.onInit();
    cargarFotoPerfil();
  }

  Future<void> cargarFotoPerfil() async {
    final usuario = _sesion.usuarioActual.value;
    if (usuario != null && usuario.id != null) {
      try {
        loadingPhoto.value = true;
        final respuesta = await _usuarioService.getProfilePhotoUrl(usuario.id!);

        if (respuesta != null && respuesta.status == 200) {
          if (respuesta.body is String) {
            try {
              final Map<String, dynamic> data = json.decode(
                respuesta.body as String,
              );
              if (data.containsKey('url')) {
                final String url = data['url'];

                profilePhotoUrl.value = url;
              } else {
                print('No se encontró URL en la respuesta'); // Debug
                profilePhotoUrl.value = '';
              }
            } catch (e) {
              print("Error al parsear JSON de foto: $e");
              profilePhotoUrl.value = '';
            }
          } else {
            print(
              'Respuesta no es String: ${respuesta.body.runtimeType}',
            ); // Debug
            profilePhotoUrl.value = '';
          }
        } else {
          print(
            'Respuesta nula o status no 200: ${respuesta?.status}',
          ); // Debug
          profilePhotoUrl.value = '';
        }
      } catch (e) {
        print('Error al cargar foto de perfil: $e');
        profilePhotoUrl.value = '';
      } finally {
        loadingPhoto.value = false;
      }
    } else {
      print('Usuario no encontrado o ID nulo'); // Debug
      profilePhotoUrl.value = '';
      loadingPhoto.value = false;
    }
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
          await cargarFotoPerfil();
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
