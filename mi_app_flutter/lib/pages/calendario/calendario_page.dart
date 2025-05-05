import 'package:flutter/material.dart';

// Página de Calendario
class CalendarioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario'),
        automaticallyImplyLeading: false, // Quita la flecha de retroceso
      ),
      body: Center(child: Text('Contenido del Calendario')),

      // La barra de navegación con el índice 1 seleccionado (Calendario)
    );
  }
}
