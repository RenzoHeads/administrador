import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'lista_tab_controller.dart';
import '../../../widgets/ListLista/List_lista_item.dart';

class ListsTab extends StatelessWidget {
  final ListaTabController controller = Get.find<ListaTabController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.cargando.value) {
        return Center(child: CircularProgressIndicator());
      }

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
        return ListasGridWidget(listas: controller.listas, onTap: (index) {});
      }
    });
  }
}
