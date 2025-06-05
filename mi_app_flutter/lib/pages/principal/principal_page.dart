import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home_page.dart';
import '../calendario/calendario_page.dart';
import '../buscador/buscador_page.dart';
import '../notificaciones/notificacion_page.dart';
import '../widgets/custom_fab.dart';
import 'principal_controller.dart';
import 'barras/custom_top_bar.dart';
import 'barras/custom_bottom_nav_bar.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({Key? key}) : super(key: key);

  @override
  _PrincipalPageState createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _buildBody()),
      floatingActionButton: CustomFAB(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildBody() {
    if (_principalController.isLoading.value) {
      return _buildLoadingState();
    }

    if (_principalController.hasError.value) {
      return _buildErrorState();
    }

    if (!_principalController.datosCargados.value) {
      return _buildLoadingState();
    }

    return _buildMainContent();
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
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

  Widget _buildMainContent() {
    return Column(
      children: [
        CustomTopBar(controller: _principalController),
        Expanded(child: IndexedStack(index: _currentIndex, children: _pages)),
      ],
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _principalController.cambiarPagina(index);
  }
}
