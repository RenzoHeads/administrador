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

class _NotificacionPageState extends State<NotificacionPage>
    with WidgetsBindingObserver {
  NotificacionController? _controller;
  bool _isLoading = true;
  Timer? _timer;
  bool _isPageVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarUsuarioYRecordatorios();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Solo actualizar cuando la app esté en primer plano
    if (state == AppLifecycleState.resumed) {
      _isPageVisible = true;
      _startTimer();
    } else {
      _isPageVisible = false;
      _timer?.cancel();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_controller != null && _isPageVisible) {
      _timer = Timer.periodic(Duration(minutes: 5), (_) {
        if (_isPageVisible) {
          _controller!.cargarRecordatoriosDelDia();
        }
      });
    }
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

      // Iniciar el timer para actualizaciones periódicas
      _startTimer();
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
    WidgetsBinding.instance.removeObserver(this);
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
            return RefreshIndicator(
              onRefresh: controller.cargarRecordatoriosDelDia,
              child:
                  controller.recordatorios.isEmpty
                      ? ListView(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height - 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Mostrar diferentes mensajes según el estado
                                  if (controller
                                      .notificacionesDesactivadas) ...[
                                    Icon(
                                      Icons.notifications_off,
                                      color: Colors.orange,
                                      size: 48,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Notificaciones desactivadas',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Has desactivado las notificaciones del sistema',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Ve a tu perfil para activarlas nuevamente',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ] else ...[
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 48,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Todo está en orden',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'No tienes notificaciones pendientes',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 16),
                                  Text(
                                    'Desliza hacia abajo para actualizar',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                      : ListView.builder(
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
