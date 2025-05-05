import 'package:flutter/material.dart';


class BuscadorPage extends StatelessWidget {
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscador'),
        automaticallyImplyLeading: false, // Quita la flecha de retroceso
      ),
      body: Center(
        child: Text('Contenido del Buscador'),
      ),
      // La barra de navegación con el índice 1 seleccionado (Calendario)
      
    );
  }
}