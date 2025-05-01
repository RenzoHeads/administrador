import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controler.dart';
import '../../../models/lista.dart';

class ListsTab extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.listas.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.list_alt, size: 48, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'No hay listas disponibles',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        );
      } else {
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.listas.length,
          itemBuilder: (context, index) {
            final lista = controller.listas[index];
            return _buildListaItem(lista);
          },
        );
      }
    });
  }

  Widget _buildListaItem(Lista lista) {
    if (lista.id == null) return SizedBox.shrink();

    final int cantidadTareas = controller.cantidadTareasPorLista[lista.id!] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: controller.colorDesdeString(lista.color ?? 'FFFFFF'),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          lista.nombre ?? 'Sin nombre',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$cantidadTareas ${cantidadTareas == 1 ? 'tarea' : 'tareas'}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Get.toNamed('/detalles-lista', arguments: lista.id);
        },
      ),
    );
  }
}
