import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../home_controler.dart';
import '../../../models/tarea.dart';

class TasksTab extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    // Quitar el Expanded exterior
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
          child: Text(
            'Tareas encontradas: ${controller.tareasDeHoy.length}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                    Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'No hay tareas para hoy',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.tareasDeHoy.length,
                itemBuilder: (context, index) {
                  final tarea = controller.tareasDeHoy[index];
                  return _buildTareaItem(tarea);
                },
              );
            }
          }),
        ),
      ],
    );
  }

  // Widget para mostrar cada tarea
  Widget _buildTareaItem(Tarea tarea) {
    return InkWell(
      onTap: () {
        // Redirigir a la página de ver tarea
        Get.toNamed('/ver-tarea', arguments: {'tareaId': tarea.id});
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Checkbox(
                  value: false,
                  onChanged: (value) {
                    // Lógica para marcar completada
                  },
                  activeColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Contenido de la tarea
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tarea.titulo ?? 'Sin título',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: false
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if ((tarea.descripcion ?? '').isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        tarea.descripcion ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                    SizedBox(height: 4),
                    if (tarea.fechaVencimiento != null) 
                      Text(
                        'Hoy, ${DateFormat('HH:mm').format(tarea.fechaCreacion)}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}