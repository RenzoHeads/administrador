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
        }

        // Solo mostrar el contenido cuando los datos estén cargados
        if (!_principalController.datosCargados.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return IndexedStack(index: _currentIndex, children: _pages);
      }),
      floatingActionButton: CustomFAB(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
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
