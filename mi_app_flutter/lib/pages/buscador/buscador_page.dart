import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/ListTarea/List_tarea_item.dart';
import 'buscador_controller_page.dart';

class BuscadorPage extends StatelessWidget {
  final BuscadorController controller = Get.put(BuscadorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscador de Tareas'),
        automaticallyImplyLeading: false, // Quita la flecha de retroceso
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: controller.buscadorController,
                decoration: InputDecoration(
                  hintText: 'Buscar tareas...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: Obx(
                    () =>
                        controller.textoBusqueda.value.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                controller.buscadorController.clear();
                                controller.actualizarTextoBusqueda('');
                              },
                            )
                            : SizedBox(),
                  ),
                ),
                onChanged: (value) {
                  controller.actualizarTextoBusqueda(value);
                },
              ),
            ),
          ),

          // Indicador de carga
          Obx(
            () =>
                controller.cargando.value
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(),
          ),

          // Lista de tareas
          Expanded(
            child: Obx(() {
              if (controller.tareasEncontradas.isEmpty &&
                  !controller.cargando.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        controller.textoBusqueda.value.isEmpty
                            ? 'No tienes tareas registradas'
                            : 'No se encontraron tareas',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TareasGridWidget(
                  tareas: controller.ListaTareasBusqueda,
                  onTap: (id) {
                    // Maneja la acción al tocar una tarea
                    print('Tarea seleccionada: $id');
                    // Aquí podrías navegar a la página de detalle de la tarea
                    // Get.toNamed('/detalle-tarea/$id');
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
