import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../home/home_page.dart';
import '../calendario/calendario_page.dart';
import '../buscador/buscador_page.dart';
import '../notificaciones/notificacion_page.dart';
import '../widgets/custom_fab.dart';
import 'principal_controller.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({Key? key}) : super(key: key);

  @override
  _PrincipalPageState createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  // Inicializar el controlador principal
  final PrincipalController _principalController = Get.put(
    PrincipalController(),
  );
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CalendarioPage(),
    BuscadorPage(),
    NotificacionPage(),
  ];
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Actualizar el índice de página en el controlador
    _principalController.cambiarPagina(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (_principalController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_principalController.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error al cargar datos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(_principalController.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _principalController.refreshData(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        } // Solo mostrar el contenido cuando los datos estén cargados
        if (!_principalController.datosCargados.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Barra superior dinámica
            _buildTopBar(),
            // Contenido de las páginas
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _pages),
            ),
          ],
        );
      }),
      floatingActionButton: CustomFAB(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  // Método para construir la barra superior dinámica
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          // Layout diferente para Home (índice 0)
          if (_principalController.currentPageIndex.value == 0) {
            return Row(
              children: [
                // Título
                Expanded(
                  child: Text(
                    _principalController.tituloActual,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Avatar
                GestureDetector(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            _principalController
                                    .profilePhotoUrl
                                    .value
                                    .isNotEmpty
                                ? NetworkImage(
                                  _principalController.profilePhotoUrl.value,
                                )
                                : null,
                        backgroundColor: Colors.grey[300],
                        radius: 20,
                        child:
                            _principalController.profilePhotoUrl.value.isEmpty
                                ? Text(
                                  _principalController
                                              .sesionController
                                              .usuarioActual
                                              .value
                                              ?.nombre
                                              .isNotEmpty ==
                                          true
                                      ? _principalController
                                          .sesionController
                                          .usuarioActual
                                          .value!
                                          .nombre
                                          .substring(0, 1)
                                          .toUpperCase()
                                      : "U",
                                  style: const TextStyle(color: Colors.white),
                                )
                                : null,
                      ),
                      if (_principalController.loadingPhoto.value)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    print(
                      'URL actual de la foto: ${_principalController.profilePhotoUrl.value}',
                    );
                  },
                ),
                const SizedBox(width: 12),
                // Botón de cerrar sesión
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _principalController.cerrarSesionCompleta(),
                  tooltip: 'Cerrar sesión',
                ),
              ],
            );
          } else {
            // Layout para otras páginas: Título - Foto
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Título de la página actual
                Text(
                  _principalController.tituloActual,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Avatar
                GestureDetector(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            _principalController
                                    .profilePhotoUrl
                                    .value
                                    .isNotEmpty
                                ? NetworkImage(
                                  _principalController.profilePhotoUrl.value,
                                )
                                : null,
                        backgroundColor: Colors.grey[300],
                        radius: 20,
                        child:
                            _principalController.profilePhotoUrl.value.isEmpty
                                ? Text(
                                  _principalController
                                              .sesionController
                                              .usuarioActual
                                              .value
                                              ?.nombre
                                              .isNotEmpty ==
                                          true
                                      ? _principalController
                                          .sesionController
                                          .usuarioActual
                                          .value!
                                          .nombre
                                          .substring(0, 1)
                                          .toUpperCase()
                                      : "U",
                                  style: const TextStyle(color: Colors.white),
                                )
                                : null,
                      ),
                      if (_principalController.loadingPhoto.value)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    print(
                      'URL actual de la foto: ${_principalController.profilePhotoUrl.value}',
                    );
                  },
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    this.currentIndex = 0,
    required this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/icon_home.svg',
                color: currentIndex == 0 ? Colors.green : Colors.grey,
                width: 24,
                height: 24,
              ),
              onPressed: () => onTap(0),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/icon_calendar.svg',
                color: currentIndex == 1 ? Colors.green : Colors.grey,
                width: 24,
                height: 24,
              ),
              onPressed: () => onTap(1),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/icon_search.svg',
                color: currentIndex == 2 ? Colors.green : Colors.grey,
                width: 24,
                height: 24,
              ),
              onPressed: () => onTap(2),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/icon_bell.svg',
                color: currentIndex == 3 ? Colors.green : Colors.grey,
                width: 24,
                height: 24,
              ),
              onPressed: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}
