import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ver_tarea_controller.dart';

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
    // Usar WillPopScope para manejar el cierre del modal
    return WillPopScope(
      onWillPop: () async {
        // Ocultar teclado antes de cerrar
        FocusScope.of(context).unfocus();
        return true;
      },
      child: GestureDetector(
        onTap: () {
          // Desenfocar el teclado cuando se toca fuera del contenido
          FocusScope.of(context).unfocus();
        },
        child: GetBuilder<VerTareaController>(
          init: controller,
          tag: 'tarea_${controller.tareaId}',
          id: 'tarea_${controller.tareaId}',
          builder: (controller) {
            if (controller.cargando) {
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (controller.tarea == null) {
              return const SizedBox.shrink();
            }

            final tarea = controller.tarea!;

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
                          _Header(tarea: tarea, controller: controller),
                          const SizedBox(height: 24),
                          _Descripcion(tarea: tarea),
                          const SizedBox(height: 24),
                          _FechaHorario(controller: controller),
                          const SizedBox(height: 24),
                          _Categoria(controller: controller),
                          const SizedBox(height: 24),
                          _Etiquetas(controller: controller),
                        ],
                      ),
                    ),
                  ),
                  _BotonesAccion(
                    tarea: tarea,
                    controller: controller,
                    onEliminacionExitosa: onEliminacionExitosa,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

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
      isDismissible: true,
      enableDrag: true,
      builder: (context) => TareaDetalleModal(controller: controller),
    );
  }
}

class _Header extends StatelessWidget {
  final dynamic tarea;
  final VerTareaController controller;

  const _Header({required this.tarea, required this.controller});

  @override
  Widget build(BuildContext context) {
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
}

class _Descripcion extends StatelessWidget {
  final dynamic tarea;

  const _Descripcion({required this.tarea});

  @override
  Widget build(BuildContext context) {
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
}

class _FechaHorario extends StatelessWidget {
  final VerTareaController controller;

  const _FechaHorario({required this.controller});

  @override
  Widget build(BuildContext context) {
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
}

class _Categoria extends StatelessWidget {
  final VerTareaController controller;

  const _Categoria({required this.controller});

  @override
  Widget build(BuildContext context) {
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
}

class _Etiquetas extends StatelessWidget {
  final VerTareaController controller;

  const _Etiquetas({required this.controller});

  @override
  Widget build(BuildContext context) {
    final etiquetas = controller.etiquetas;
    return etiquetas.isEmpty
        ? const SizedBox.shrink()
        : Column(
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
}

class _BotonesAccion extends StatelessWidget {
  final dynamic tarea;
  final VerTareaController controller;
  final Function? onEliminacionExitosa;

  const _BotonesAccion({
    required this.tarea,
    required this.controller,
    this.onEliminacionExitosa,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
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

                    // Solo ejecutar el callback si existe y la eliminación fue exitosa
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
}
