import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controler.dart';
import '../../../models/lista.dart';
import '../../widgets/lista/lista_item.dart';

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
    return ListaItemWidget(
      listaId: lista.id!, // Asegúrate de que el ID no sea nulo
      onTap: () {
        // Aquí puedes navegar a la pantalla de detalle de la lista
        Get.toNamed('/lista/detalle/${lista.id}');
      },
    );
  }
}
