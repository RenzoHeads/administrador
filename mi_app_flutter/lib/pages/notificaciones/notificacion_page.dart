import 'package:flutter/material.dart';
import 'package:get/get.dart';


class NotificacionPage extends StatelessWidget {
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
        automaticallyImplyLeading: false, // Quita la flecha de retroceso
      ),
      body: Center(
        child: Text('Contenido de Notificacion'),
      ),
      // La barra de navegación con el índice 1 seleccionado (Calendario)
      
    );
  }
}