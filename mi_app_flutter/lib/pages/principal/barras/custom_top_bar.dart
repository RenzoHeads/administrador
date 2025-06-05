import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../principal_controller.dart';

class CustomTopBar extends StatelessWidget {
  final PrincipalController controller;

  const CustomTopBar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _buildDecoration(),
      child: SafeArea(
        child: Obx(() => _buildContent()),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: Colors.grey[100],
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 0,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (controller.currentPageIndex.value == 0) {
      return _buildHomeLayout();
    } else {
      return _buildOtherPagesLayout();
    }
  }

  Widget _buildHomeLayout() {
    return Row(
      children: [
        _buildTitle(),
        _buildAvatar(),
        const SizedBox(width: 12),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildOtherPagesLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPageTitle(),
        _buildAvatar(),
      ],
    );
  }

  Widget _buildTitle() {
    return Expanded(
      child: Text(
        controller.tituloActual,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Text(
      controller.tituloActual,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _onAvatarTapped,
      child: Stack(
        children: [
          _buildAvatarImage(),
          if (controller.loadingPhoto.value) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    return CircleAvatar(
      backgroundImage: controller.profilePhotoUrl.value.isNotEmpty
          ? NetworkImage(controller.profilePhotoUrl.value)
          : null,
      backgroundColor: Colors.grey[300],
      radius: 20,
      child: controller.profilePhotoUrl.value.isEmpty
          ? _buildAvatarText()
          : null,
    );
  }

  Widget _buildAvatarText() {
    final userName = controller.sesionController.usuarioActual.value?.nombre;
    final initial = userName?.isNotEmpty == true 
        ? userName!.substring(0, 1).toUpperCase()
        : "U";

    return Text(
      initial,
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () => controller.cerrarSesionCompleta(),
      tooltip: 'Cerrar sesión',
    );
  }

  void _onAvatarTapped() {
    print('URL actual de la foto: ${controller.profilePhotoUrl.value}');
  }
}