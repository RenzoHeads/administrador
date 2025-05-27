import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mi_app_flutter/models/lista_con_tareas.dart';
import 'package:mi_app_flutter/pages/widgets/lista/lista_item_controller.dart';
import '../../services/lista_service.dart';
import '../../services/tarea_service.dart';
import '../principal/principal_controller.dart';
import 'lista_editar.dart';
import '../home/home_controler.dart';
import '../buscador/buscador_controller_page.dart';
import '../calendario/calendario_controller_page.dart';

class ListaDetallePage extends StatefulWidget {
  final int listaId;

  const ListaDetallePage({super.key, required this.listaId});

  @override
  State<ListaDetallePage> createState() => _ListaDetallePageState();
}

class _ListaDetallePageState extends State<ListaDetallePage> {
  final ListaService _listaService = ListaService();
  final TareaService _tareaService = TareaService();
  final HomeController _homeController = Get.find<HomeController>();
  final BuscadorController _buscadorController = Get.find<BuscadorController>();
  final CalendarioController _calendarioController =
      Get.find<CalendarioController>();

  late Future<ListaConTareas?> _futureListaConTareas;

  final PrincipalController _principalController =
      Get.find<PrincipalController>();

  @override
  void initState() {
    super.initState();

    _futureListaConTareas = _fetchListaConTareas();
  }

  Future<ListaConTareas?> _fetchListaConTareas() async {
    final response = await _listaService.obtenerListaConTareas(widget.listaId);

    if (response.status == 200 && response.body is ListaConTareas) {
      return response.body as ListaConTareas;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Obtener datos actuales de la lista
              final data = await _futureListaConTareas;

              if (data == null) return;

              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (context) => SingleChildScrollView(
                      child: EditarListaModal(
                        lista: data.lista,
                        onClose: () => Navigator.pop(context),
                      ),
                    ),
              ).then((result) {
                // Refrescar datos tras edición si hubo cambios
                if (result == true && mounted) {
                  setState(() {
                    _futureListaConTareas = _fetchListaConTareas();
                  });
                }
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF5E9F7A), // Texto verde
              backgroundColor: const Color(0xFFF5F9F7), // Fondo verde claro
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Editar'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: const Color(0xFFFFFFFF),
                      title: const Text(
                        'Eliminar lista',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      content: const Text(
                        '¿Deseas eliminar esta lista y todas las tareas asociadas? Esta acción será permanente.',
                        style: TextStyle(
                          color: Color(0xFF6F7686),
                          fontSize: 16,
                        ),
                      ),
                      actions: [
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF565D6D),
                                  backgroundColor: const Color(0xFFF3F4F6),
                                  shape: const StadiumBorder(),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFFFFFFF),
                                  backgroundColor: const Color(0xFFDE3B40),
                                  shape: const StadiumBorder(),
                                ),
                                child: const Text(
                                  'Eliminar',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              );

              if (confirm == false) return;

              final response = await _listaService.eliminarLista(
                widget.listaId,
              );

              if (response.status != 200 && mounted) {
                Get.snackbar(
                  'Error',
                  response.body['message'],
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
              final tareaIds = response.body['tareas_ids'] as List<int>?;

              await _principalController.EliminarLista(widget.listaId);

              if (tareaIds != null) {
                for (final tareaId in tareaIds) {
                  await _principalController.EliminarTarea(tareaId);
                }
              }
              await _homeController.recargarTodo();
              await _buscadorController.recargarBuscador();
              await _calendarioController.recargarCalendario();

              Get.back(result: true);

              Get.snackbar(
                'Éxito',
                response.body['message'],
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDD3B3F),
              backgroundColor: const Color(0xFFFDF2F2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<ListaConTareas?>(
        future: _futureListaConTareas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No se pudo cargar la lista'));
          }

          final data = snapshot.data;
          final lista = data?.lista;
          final tareas = data?.tareas ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lista?.nombre ?? 'Sin nombre',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                if (tareas.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'Aún no tienes tareas, agrega una',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                if (tareas.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: tareas.length,
                      itemBuilder: (context, index) {
                        final tarea = tareas[index];
                        final bool completada = tarea.estadoId == 2;

                        return Row(
                          children: [
                            // Checkbox circular personalizado
                            GestureDetector(
                              onTap: () async {
                                final nuevoEstadoId =
                                    tarea.estadoId == 1 ? 2 : 1;
                                final response = await _tareaService
                                    .actualizarTarea(
                                      id: tarea.id as int,
                                      usuarioId: lista?.usuarioId as int,
                                      listaId: lista?.id as int,
                                      titulo: tarea.titulo,
                                      descripcion: tarea.descripcion,
                                      fechaCreacion:
                                          tarea.fechaCreacion.toIso8601String(),
                                      fechaVencimiento:
                                          tarea.fechaVencimiento
                                              .toIso8601String(),
                                      categoriaId: tarea.categoriaId,
                                      estadoId: nuevoEstadoId,
                                      prioridadId: tarea.prioridadId,
                                    );
                                if (mounted && response.status == 200) {
                                  setState(() {
                                    _futureListaConTareas =
                                        _fetchListaConTareas();
                                  });
                                } else if (mounted) {
                                  Get.snackbar(
                                    'Error',
                                    'No se pudo actualizar el estado de la tarea',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        completada ? Colors.green : Colors.grey,
                                    width: 2,
                                  ),
                                  color:
                                      completada ? Colors.green : Colors.white,
                                ),
                                child:
                                    completada
                                        ? const Icon(
                                          Icons.check,
                                          size: 18,
                                          color: Colors.white,
                                        )
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 20), // Más separación
                            Expanded(
                              child: Text(
                                tarea.titulo,
                                style: TextStyle(
                                  fontSize: 20,
                                  decoration:
                                      completada
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                  color:
                                      completada ? Colors.grey : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.black,
                                size: 28,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        backgroundColor: const Color(
                                          0xFFFFFFFF,
                                        ),
                                        title: const Text(
                                          'Eliminar tarea',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        content: const Text(
                                          '¿Deseas eliminar esta tarea? Esta acción será permanente.',
                                          style: TextStyle(
                                            color: Color(0xFF6F7686),
                                            fontSize: 16,
                                          ),
                                        ),
                                        actions: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(false),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        const Color(0xFF565D6D),
                                                    backgroundColor:
                                                        const Color(0xFFF3F4F6),
                                                    shape:
                                                        const StadiumBorder(),
                                                  ),
                                                  child: const Text(
                                                    'Cancelar',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(true),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        const Color(0xFFFFFFFF),
                                                    backgroundColor:
                                                        const Color(0xFFDE3B40),
                                                    shape:
                                                        const StadiumBorder(),
                                                  ),
                                                  child: const Text(
                                                    'Eliminar',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                );

                                if (confirm == false) return;

                                // Implementación modificada para evitar dos diálogos
                                final tareaId = tarea.id as int;

                                final response = await _tareaService
                                    .eliminarTarea(tareaId);

                                if (response.status != 200 && mounted) {
                                  Get.snackbar(
                                    'Error',
                                    'No se pudo eliminar la tarea',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );

                                  return;
                                }

                                await _principalController.EliminarTarea(
                                  tareaId,
                                );
                                await ListaItemController.actualizarLista(
                                  widget.listaId,
                                );

                                if (mounted) {
                                  setState(() {
                                    _futureListaConTareas =
                                        _fetchListaConTareas();
                                  });
                                }

                                await _homeController.recargarTodo();
                                await _buscadorController.recargarBuscador();
                                await _calendarioController
                                    .recargarCalendario();

                                Get.snackbar(
                                  'Éxito',
                                  'Tarea eliminada correctamente',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
