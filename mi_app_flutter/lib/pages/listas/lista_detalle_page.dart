import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/lista_service.dart';
import '../../services/tarea_service.dart';
import '../principal/principal_controller.dart';
import '../home/home_controler.dart';
import '../buscador/buscador_controller_page.dart';
import '../widgets/lista/lista_item_controller.dart';
import '../../models/lista.dart';
import 'lista_editar.dart';

class ListaDetallePage extends StatefulWidget {
  final int listaId;

  const ListaDetallePage({Key? key, required this.listaId}) : super(key: key);

  @override
  State<ListaDetallePage> createState() => _ListaDetallePageState();
}

class _ListaDetallePageState extends State<ListaDetallePage> {
  final ListaService _listaService = ListaService();
  final TareaService _tareaService = TareaService();
  late Future<Map<String, dynamic>?> _futureLista;

  final HomeController _homeController = Get.find<HomeController>();
  final PrincipalController _principalController =
      Get.find<PrincipalController>();
  final BuscadorController _buscadorController = Get.find<BuscadorController>();

  @override
  void initState() {
    super.initState();
    _futureLista = _fetchLista();
  }

  Future<Map<String, dynamic>?> _fetchLista() async {
    final response = await _listaService.obtenerListaConTareas(widget.listaId);
    if (response.status == 200 && response.body is Map) {
      return Map<String, dynamic>.from(response.body);
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
              final listaData = await _futureLista;
              if (listaData == null) return;
              final lista = Lista(
                id: listaData['id'],
                usuarioId: listaData['usuario_id'],
                nombre: listaData['nombre'],
                descripcion: listaData['descripcion'],
                color: listaData['color'],
              );
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (context) => SingleChildScrollView(
                      child: EditarListaModal(
                        lista: lista,
                        onClose: () => Navigator.pop(context),
                      ),
                    ),
              );
              // Refrescar datos tras edición
              if (mounted) {
                setState(() {
                  _futureLista = _fetchLista();
                });
              }
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
                      title: const Text('Eliminar lista'),
                      content: const Text(
                        '¿Deseas eliminar esta lista y todas las tareas asociadas? Esta acción será permanente.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(
                              0xFFDD3B3F,
                            ), // Texto rojo
                            backgroundColor: const Color(
                              0xFFFDF2F2,
                            ), // Fondo rojo claro
                          ),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                final response = await _listaService.eliminarLista(
                  widget.listaId,
                );
                if (mounted) {
                  if (response.status == 200) {
                    await _principalController.EliminarLista(widget.listaId);

                    await _homeController.recargarTodo(); // Recargar listas

                    Get.back(result: true); // Volver a la lista de listas

                    Get.snackbar(
                      'Éxito',
                      'Lista eliminada correctamente',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } else {
                    Get.snackbar(
                      'Error',
                      'Error al eliminar la lista',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDD3B3F), // Texto rojo
              backgroundColor: const Color(0xFFFDF2F2), // Fondo rojo claro
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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _futureLista,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No se pudo cargar la lista'));
          }
          final lista = snapshot.data!;
          final tareas = (lista['tareas'] ?? []) as List<dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lista['nombre'] ?? 'Sin nombre',
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
                        final tarea = tareas[index] as Map<String, dynamic>;
                        final bool completada = tarea['estado_id'] == 2;
                        return Row(
                          children: [
                            // Checkbox circular personalizado
                            GestureDetector(
                              onTap: () async {
                                final tareaId = tarea['id'];
                                final nuevoEstadoId =
                                    tarea['estado_id'] == 1 ? 2 : 1;
                                final response = await _tareaService
                                    .actualizarTarea(
                                      id: tareaId,
                                      usuarioId: lista['usuario_id'],
                                      listaId: lista['id'],
                                      titulo: tarea['titulo'],
                                      descripcion: tarea['descripcion'],
                                      fechaCreacion: tarea['fecha_creacion'],
                                      fechaVencimiento:
                                          tarea['fecha_vencimiento'],
                                      categoriaId: tarea['categoria_id'],
                                      estadoId: nuevoEstadoId,
                                      prioridadId: tarea['prioridad_id'],
                                    );
                                if (mounted && response.status == 200) {
                                  setState(() {
                                    _futureLista = _fetchLista();
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
                                tarea['titulo'] ?? 'Sin título',
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
                                        title: const Text('Eliminar tarea'),
                                        content: const Text(
                                          '¿Deseas eliminar esta tarea? Esta acción será permanente.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm == true) {
                                  final tareaId = tarea['id'];
                                  final response = await _tareaService
                                      .eliminarTarea(tareaId);
                                  if (mounted) {
                                    if (response.status == 200) {
                                      await _principalController.EliminarTarea(
                                        tareaId,
                                      );
                                      await ListaItemController.actualizarLista(
                                        widget.listaId,
                                      );

                                      await _homeController.recargarTodo();

                                      await _buscadorController
                                          .recargarBuscador();

                                      setState(() {
                                        _futureLista = _fetchLista();
                                      });
                                      Get.snackbar(
                                        'Éxito',
                                        'Tarea eliminada correctamente',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        'Error al eliminar la tarea',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  }
                                }
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
