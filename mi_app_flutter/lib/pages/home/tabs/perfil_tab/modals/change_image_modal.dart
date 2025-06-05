import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../profile_tab_controller.dart';

class ChangeImageModal {
  static void show(BuildContext context, ProfileTabController controller) {
    final ImagePicker picker = ImagePicker();

    void procesarImagen(XFile? imagen) async {
      if (imagen != null) {
        File file = File(imagen.path);
        final resultado = await controller.subirFotoPerfil(file);
        if (resultado) {
          Navigator.pop(context);
        }
      }
    }

    void seleccionarImagen() async {
      final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);
      procesarImagen(imagen);
    }

    void tomarFoto() async {
      final XFile? foto = await picker.pickImage(source: ImageSource.camera);
      procesarImagen(foto);
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cambiar imagen de perfil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildProfileImagePreview(controller),
              const SizedBox(height: 20),
              _buildImageActionButtons(seleccionarImagen, tomarFoto),
              const SizedBox(height: 20),
              _buildModalButtons(context),
              if (controller.profilePhotoUrl.value.isNotEmpty)
                _buildDeletePhotoButton(controller),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildProfileImagePreview(ProfileTabController controller) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child:
                controller.profilePhotoUrl.value.isNotEmpty
                    ? ClipOval(
                      child: Image.network(
                        controller.profilePhotoUrl.value,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SvgPicture.asset(
                            'assets/icons/icon_user.svg',
                            width: 50,
                            height: 50,
                          );
                        },
                      ),
                    )
                    : Center(
                      child: SvgPicture.asset(
                        'assets/icons/icon_user.svg',
                        width: 50,
                        height: 50,
                      ),
                    ),
          ),
          if (controller.loadingPhoto.value)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
        ],
      ),
    );
  }

  static Widget _buildImageActionButtons(
    VoidCallback seleccionarImagen,
    VoidCallback tomarFoto,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextButton.icon(
            icon: SvgPicture.asset(
              'assets/icons/icon_upload.svg',
              width: 20,
              height: 20,
              color: Colors.black87,
            ),
            label: const Text('Subir imagen'),
            onPressed: seleccionarImagen,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextButton.icon(
            icon: SvgPicture.asset(
              'assets/icons/icon_photo.svg',
              width: 20,
              height: 20,
              color: Colors.black87,
            ),
            label: const Text('Tomar foto'),
            onPressed: tomarFoto,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildModalButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.grey[200],
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.green,
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  static Widget _buildDeletePhotoButton(ProfileTabController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextButton(
        onPressed: () async {
          final resultado = await controller.eliminarFotoPerfil();
          if (resultado) {
            // Usar Get.back() si usas GetX, o Navigator.pop() si prefieres
            // Get.back();
          }
        },
        child: const Center(
          child: Text(
            'Eliminar foto actual',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
