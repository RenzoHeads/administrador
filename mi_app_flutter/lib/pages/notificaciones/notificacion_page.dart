import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notificacion_controller_page.dart';
import '../../models/recordatorio_tile.dart';

class NotificacionPage extends StatefulWidget {
  @override
  State<NotificacionPage> createState() => _NotificacionPageState();
}

class _NotificacionPageState extends State<NotificacionPage> {
  NotificacionController? _controller;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioYRecordatorios();
  }

  Future<void> _cargarUsuarioYRecordatorios() async {
    final prefs = await SharedPreferences.getInstance();
    final int? usuarioId = prefs.getInt('usuario_id');

    if (usuarioId != null) {
      final controller = NotificacionController(usuarioId: usuarioId);
      await controller.cargarRecordatoriosDelDia();
      setState(() {
        _controller = controller;
        _isLoading = false;
      });

      _timer = Timer.periodic(Duration(seconds: 10), (_) {
        controller.cargarRecordatoriosDelDia();
      });
    } else {
      // Sin sesión iniciada
      setState(() {
        _isLoading = false;
        _controller = null;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Estado 1: Cargando
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Notificaciones'),
          automaticallyImplyLeading: false,
        ),
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: _buildBottomNavBar(),
      );
    }

    // Estado 2: No logueado
    if (_controller == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Notificaciones'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sesión requerida', style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      );
    }

    // Estado 3: Sesión válida, tenemos controller
    return ChangeNotifierProvider.value(
      value: _controller!,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notificaciones'),
          automaticallyImplyLeading: false,
        ),
        body: Consumer<NotificacionController>(
          builder: (context, controller, _) {
            if (controller.recordatorios.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Todo está en orden',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('No tienes notificaciones pendientes'),
                    SizedBox(height: 8),
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: controller.cargarRecordatoriosDelDia,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: controller.recordatorios.length,
                itemBuilder: (context, index) {
                  return RecordatorioTile(
                      recordatorio: controller.recordatorios[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: 'Calendario'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Notificaciones'),
      ],
    );
  }
}
