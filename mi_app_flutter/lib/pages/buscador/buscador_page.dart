import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/tarea/tarea_item.dart';
import '../widgets/lista/lista_item.dart';
import 'buscador_controller_page.dart';

class BuscadorPage extends StatelessWidget {
  final BuscadorController controller = Get.put(BuscadorController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  hintText: 'Buscar tareas o listas',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: Obx(
                    () =>
                        controller.textoBusqueda.value.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                controller.actualizarTextoBusqueda('');
                              },
                            )
                            : const SizedBox.shrink(),
                  ),
                ),
                onChanged: controller.actualizarTextoBusqueda,
              ),
            ),
          ),

          // Indicador de carga
          Obx(
            () =>
                controller.cargando.value
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox(),
          ),

          // Resultados
          Expanded(
            child: Obx(() {
              final tareas =
                  controller.ListaTareasBusqueda.where(
                    (t) => t.id != null,
                  ).toList();
              final listas =
                  controller.ListaListasBusqueda.where(
                    (l) => l.id != null,
                  ).toList();

              if (tareas.isEmpty &&
                  listas.isEmpty &&
                  !controller.cargando.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'No se han encontrado resultados',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Intenta con una búsqueda diferente',
                        style: TextStyle(color: Colors.black45),
                      ),
                      SizedBox(height: 24),
                      Icon(Icons.more_horiz, size: 28, color: Colors.black26),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (tareas.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0, bottom: 8),
                      child: Text(
                        'Tareas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...tareas.map(
                      (tarea) => TareaItem(
                        key: ValueKey(tarea.id),
                        tareaId: tarea.id!,
                      ),
                    ),
                  ],
                  if (listas.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 24.0, bottom: 8),
                      child: Text(
                        'Listas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...listas.map(
                      (lista) => ListaItemWidget(
                        key: ValueKey(lista.id),
                        listaId: lista.id!,
                        onTap: () {
                          print('Lista seleccionada: ${lista.id}');
                        },
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
