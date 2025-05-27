// tarea_item.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'tarea_detalle_modal.dart';
import 'ver_tarea_controller.dart';

class TareaItem extends StatelessWidget {
  final int tareaId;

  const TareaItem({required this.tareaId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inicializamos el controlador una sola vez con el ID de la tarea
    final controller = Get.put(
      VerTareaController(tareaId: tareaId),
      tag: 'tarea_$tareaId',
      permanent: true, // Mantiene el controlador en memoria
    );

    // Usamos GetBuilder con un ID específico para actualizaciones selectivas
    return GetBuilder<VerTareaController>(
      init: controller,
      tag: 'tarea_$tareaId',
      id: 'tarea_$tareaId', // ID único para actualización específica
      builder: (controller) {
        if (controller.cargando) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.tarea == null) {
          return const SizedBox.shrink();
        }

        final tarea = controller.tarea!;

        // Verificar si la tarea está completada o no
        final bool estaCompletada = tarea.estadoId == 2;
        final Color colorEstado = controller.obtenerColorEstado(tarea.estadoId);

        return GestureDetector(
          onTap: () {
            // Mostrar el modal al hacer tap en el componente
            mostrarDetalleModal(context, controller);
          },
          child: Container(
            width: 350,
            height: 135,
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Checkbox interactivo que cambia entre pendiente y completada
                Container(
                  margin: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      // Alternar entre pendiente (1) y completada (2)
                      final nuevoEstadoId = estaCompletada ? 1 : 2;
                      controller.cambiarEstadoTarea(nuevoEstadoId);
                    },
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircleAvatar(
                        backgroundColor:
                            estaCompletada ? Colors.green : Colors.grey,
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color:
                              estaCompletada
                                  ? Colors.white
                                  : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
                // Contenido de la tarea
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        tarea.titulo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration:
                              estaCompletada
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tarea.descripcion,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          decoration:
                              estaCompletada
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.obtenerTextoFechaRelativa(
                          tarea.fechaCreacion,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          decoration:
                              estaCompletada
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Indicador de estado que no se tacha
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorEstado.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          controller.obtenerNombreEstado(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorEstado,
                            // No se aplica tachado aquí
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Método para mostrar el modal con los detalles de la tarea
  void mostrarDetalleModal(
    BuildContext context,
    VerTareaController controller,
  ) {
    // Desenfocar el teclado antes de mostrar el modal
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => TareaDetalleModal(controller: controller),
    );
  }
}
