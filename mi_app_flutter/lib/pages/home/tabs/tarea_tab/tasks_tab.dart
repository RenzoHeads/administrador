import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'task_tab_controller.dart';
import '../../../widgets/ListTarea/List_tarea_item.dart';

class TasksTab extends StatelessWidget {
  final TaskTabController controller = Get.find<TaskTabController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fecha actual
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Hoy, ${DateFormat('d').format(DateTime.now())} de ${DateFormat('MMMM', 'es_ES').format(DateTime.now())}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        SizedBox(height: 16),

        // Lista de tareas del día con Debug
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(
            () => Text(
              'Tareas encontradas: ${controller.tareasDeHoy.length}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ),
        SizedBox(height: 8),

        // Lista de tareas del día
        Expanded(
          child: Obx(() {
            if (controller.tareasDeHoy.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay tareas para hoy',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            } else {
              return TareasGridWidget(
                tareas: controller.tareasDeHoy,
                onTap: (id) {
                  print('Tarea seleccionada: $id');
                },
              );
            }
          }),
        ),
      ],
    );
  }
}
