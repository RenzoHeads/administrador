import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'lista_item_controller.dart';

class ListaItemWidget extends StatelessWidget {
  final int listaId;
  final Color? backgroundColor;
  final Function()? onTap;
  final bool showArrow;

  const ListaItemWidget({
    required this.listaId,
    this.backgroundColor,
    this.onTap,
    this.showArrow = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inicializamos el controlador con el ID de la lista
    final controller = Get.put(
      ListaItemController(listaId),
      tag: 'lista_$listaId',
    );

    // Ya no usamos ever para suscribirnos a eventos
    // El controlador ahora se actualizará mediante llamadas directas

    return GetBuilder<ListaItemController>(
      init: controller,
      tag: 'lista_$listaId',
      id: 'lista_$listaId', // ID único para actualización específica
      builder: (controller) {
        if (controller.isLoading.value) {
          return Container(
            height: 83,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.lista.value == null) {
          return const SizedBox.shrink();
        }

        final lista = controller.lista.value!;
        final color = _getColorFromHex(lista.color);

        return Container(
          height: 83, // Altura fija
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: backgroundColor ?? color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lista.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                flex: 4,
                                child: Text(
                                  '${controller.totalTareas.value} tareas',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 1,
                                height: 14,
                                color: Colors.black26,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                flex: 6,
                                child: Text(
                                  '${controller.tareasPendientes.value} pendientes',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (showArrow)
                      const Icon(
                        Icons.chevron_right,
                        size: 28,
                        color: Colors.black54,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Convierte string hexadecimal a Color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
