import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notificacion_controller_page.dart';
import '../../models/recordatorio_tile.dart';
import '../../services/controladorsesion.dart';
import 'package:get/get.dart';

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
    final ControladorSesionUsuario _sesionController =
        Get.find<ControladorSesionUsuario>();

    final int? usuarioId = _sesionController.usuarioActual.value?.id;

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
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Estado 2: No logueado
    if (_controller == null) {
      return Scaffold(
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
      );
    } // Estado 3: Sesión válida, tenemos controller
    return ChangeNotifierProvider.value(
      value: _controller!,
      child: Scaffold(
        body: Consumer<NotificacionController>(
          builder: (context, controller, _) {
            if (controller.recordatorios.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Todo está en orden',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                    recordatorio: controller.recordatorios[index],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
