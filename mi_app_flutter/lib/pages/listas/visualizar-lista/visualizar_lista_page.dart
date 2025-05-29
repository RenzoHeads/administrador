import 'package:flutter/material.dart';
import '../lista_editar.dart';
import 'visualizar_lista_controller.dart';

class VisualizarListaPage extends StatefulWidget {
  final int listaId;
  const VisualizarListaPage({super.key, required this.listaId});

  @override
  State<VisualizarListaPage> createState() => _VisualizarListaPageState();
}

class _VisualizarListaPageState extends State<VisualizarListaPage> {
  late VisualizarListaController _controller;
  late Future<Map<String, dynamic>?> _datos;

  @override
  void initState() {
    super.initState();
    _controller = VisualizarListaController(widget.listaId);
    _datos = _controller.obtenerListaConTareas();
  }

  void _refrescarDatos() {
    setState(() {
      _datos = _controller.obtenerListaConTareas();
    });
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
              final data = await _datos;
              if (data == null) return;
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (context) => SingleChildScrollView(
                      child: EditarListaModal(
                        lista: data['lista'],
                        onClose: () => Navigator.pop(context),
                      ),
                    ),
              ).then((result) {
                if (result == true && mounted) {
                  _refrescarDatos();
                }
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF5E9F7A),
              backgroundColor: const Color(0xFFF5F9F7),
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
              if (confirm == true) {
                final exito = await _controller.eliminarLista();
                if (exito && mounted) {
                  Navigator.of(context).pop(true);
                }
              }
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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _datos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No se pudo cargar la lista'));
          }
          final data = snapshot.data;
          final lista = data?['lista'];
          final tareas = data?['tareas'] ?? [];
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
                            GestureDetector(
                              onTap: () async {
                                final nuevoEstadoId =
                                    tarea.estadoId == 1 ? 2 : 1;
                                final exito = await _controller
                                    .actualizarEstadoTarea(
                                      tarea,
                                      nuevoEstadoId,
                                    );
                                if (exito && mounted) _refrescarDatos();
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
                            const SizedBox(width: 20),
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
                              icon: const Icon(
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
                                if (confirm == true) {
                                  await _controller.eliminarTarea(tarea.id);
                                  if (mounted) _refrescarDatos();
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
