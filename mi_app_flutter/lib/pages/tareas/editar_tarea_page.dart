import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/lista.dart';
import '../../../models/categoria.dart';
import '../../../models/prioridad.dart';
import '../../../models/etiqueta.dart';
import '../../../models/tarea.dart';
import '../../pages/widgets/formulario_tarea/formulario_tarea_page.dart';

class EditarTareaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Recuperar parámetros enviados a través de Get.arguments
    final Tarea tarea = Get.arguments['tarea'];
    final List<Etiqueta> etiquetas = Get.arguments['etiquetas'] ?? [];
    final Categoria? categoria = Get.arguments['categoria'];
    final Lista? lista = Get.arguments['lista'];
    final Prioridad? prioridad = Get.arguments['prioridad'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Tarea'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: TaskFormWidget(
        tarea: tarea,
        etiquetas: etiquetas,
        categoria: categoria,
        lista: lista,
        prioridad: prioridad,
        isEditing: true,
      ),
    );
  }
}
