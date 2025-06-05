import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ver_tarea_controller.dart';

/// Modal principal que muestra los detalles completos de una tarea
/// Incluye información como título, descripción, fecha, categoría y etiquetas
class TareaDetalleModal extends StatelessWidget {
  final VerTareaController controller;
  final Function? onEliminacionExitosa;

  const TareaDetalleModal({
    required this.controller,
    this.onEliminacionExitosa,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        return true;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: GetBuilder<VerTareaController>(
          init: controller,
          tag: 'tarea_${controller.tareaId}',
          id: 'tarea_${controller.tareaId}',
          builder: (controller) {
            // Widget de carga mientras se obtienen los datos de la tarea
            if (controller.cargando) {
              return _buildLoadingContainer(context);
            }

            // Si no hay tarea disponible, no mostrar nada
            if (controller.tarea == null) {
              return const SizedBox.shrink();
            }

            final tarea = controller.tarea!;
            return _buildModalContent(context, tarea, controller);
          },
        ),
      ),
    );
  }

  /// Contenedor que se muestra mientras se cargan los datos de la tarea
  Widget _buildLoadingContainer(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Cargando...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Contenido principal del modal con toda la información de la tarea
  Widget _buildModalContent(
    BuildContext context,
    dynamic tarea,
    VerTareaController controller,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(tarea, controller),
                  const SizedBox(height: 24),
                  _buildDescripcion(tarea),
                  const SizedBox(height: 24),
                  _buildFechaHorario(controller),
                  const SizedBox(height: 24),
                  _buildCategoria(controller),
                  const SizedBox(height: 24),
                  _buildEtiquetas(controller),
                ],
              ),
            ),
          ),
          _buildBotonesAccion(tarea, controller),
        ],
      ),
    );
  }

  /// Cabecera del modal que muestra el título de la tarea y su prioridad
  /// Incluye el nombre de la tarea y una etiqueta colorizada según la prioridad
  Widget _buildHeader(dynamic tarea, VerTareaController controller) {
    final colorPrioridad = controller.obtenerColorPrioridad(tarea.prioridadId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tarea.titulo,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorPrioridad.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            controller.priori?.nombre ?? 'Sin prioridad',
            style: TextStyle(
              fontSize: 12,
              color: colorPrioridad,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Sección que muestra la descripción detallada de la tarea
  /// Presenta el contenido descriptivo en un formato legible
  Widget _buildDescripcion(dynamic tarea) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Descripción",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(tarea.descripcion, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  /// Widget que muestra la información temporal de la tarea
  /// Incluye fecha de creación y horario de inicio y vencimiento
  Widget _buildFechaHorario(VerTareaController controller) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Fecha",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "${controller.fechaCreacion}",
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                "de ${DateTime.now().year}",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Horario",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "${controller.horaCreacion} - ${controller.horaVencimiento}",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Sección que muestra la categoría asignada a la tarea
  /// Presenta la categoría en una etiqueta con estilo visual distintivo
  Widget _buildCategoria(VerTareaController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Categoría",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            controller.categoria?.nombre ?? 'Trabajo',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Widget que muestra todas las etiquetas asociadas con la tarea
  /// Cada etiqueta se presenta con su color característico en un layout envolvente
  Widget _buildEtiquetas(VerTareaController controller) {
    final etiquetas = controller.etiquetas;

    if (etiquetas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Etiquetas",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              etiquetas.map((etiqueta) {
                Color etiquetaColor;
                try {
                  etiquetaColor = Color(int.parse(etiqueta.color));
                } catch (e) {
                  etiquetaColor = Colors.purple;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: etiquetaColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    etiqueta.nombre,
                    style: TextStyle(
                      fontSize: 12,
                      color: etiquetaColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Sección inferior con botones de acción para editar y eliminar la tarea
  /// Proporciona las opciones principales de gestión de la tarea
  Widget _buildBotonesAccion(dynamic tarea, VerTareaController controller) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Botón para editar la tarea existente
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit, color: Colors.black54),
                label: const Text(
                  "Editar",
                  style: TextStyle(color: Colors.black54),
                ),
                onPressed: () {
                  Get.toNamed(
                    '/editar-tarea',
                    arguments: {
                      'tarea': tarea,
                      'etiquetas': controller.etiquetas,
                      'categoria': controller.categoria,
                      'lista': controller.lista,
                      'prioridad': controller.priori,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          // Botón para eliminar permanentemente la tarea
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(left: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                  "Eliminar",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  try {
                    final eliminacionExitosa = await controller.eliminarTarea(
                      tarea.id!,
                    );

                    if (eliminacionExitosa && onEliminacionExitosa != null) {
                      onEliminacionExitosa!();
                    }
                  } catch (e) {
                    print("Error al eliminar tarea: $e");
                    Get.snackbar(
                      'Error',
                      'No se pudo completar la eliminación: $e',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Método auxiliar para mostrar el modal de detalles
  /// Maneja la presentación del modal con configuraciones específicas
  void mostrarDetalleModal(
    BuildContext context,
    VerTareaController controller,
  ) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => TareaDetalleModal(controller: controller),
    );
  }
}
