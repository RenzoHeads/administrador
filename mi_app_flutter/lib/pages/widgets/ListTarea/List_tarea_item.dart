// =============== TareasGridWidget.dart ===============
import 'package:flutter/material.dart';
import '../../../pages/widgets/tarea/tarea_item.dart';
import '../../../models/tarea.dart';

class TareasGridWidget extends StatelessWidget {
  final List<Tarea> tareas;
  final Function(int) onTap;

  const TareasGridWidget({Key? key, required this.tareas, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tareas.isEmpty) {
      return const Center(child: Text('No hay tareas disponibles'));
    }

    // Sort tasks by creation time
    final sortedTareas = List<Tarea>.from(tareas)
      ..sort((a, b) => a.fechaCreacion.compareTo(b.fechaCreacion));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sortedTareas.length,
      itemBuilder: (context, index) {
        final tarea = sortedTareas[index];
        return TareaItem(key: ValueKey(tarea.id), tareaId: tarea.id!);
      },
    );
  }
}
