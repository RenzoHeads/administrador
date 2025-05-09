import 'package:flutter/material.dart';
import '../../pages/widgets/formulario_tarea/formulario_tarea_page.dart';

class CrearTareaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Tarea'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: TaskFormWidget(isEditing: false),
    );
  }
}
