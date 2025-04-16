import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ver_tarea_controller.dart';
import '../../models/adjunto.dart';

class VerTareaPage extends StatelessWidget {
    VerTareaPage({Key? key}) : super(key: key);
    
    final VerTareaController controller = Get.put(VerTareaController());

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Obx(() => Text(controller.tarea.value?.titulo ?? 'Detalles de la tarea')),
                actions: [
                    IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: controller.irAEditarTarea,
                        tooltip: 'Editar tarea',
                    ),
                    IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: controller.eliminarTarea,
                        tooltip: 'Eliminar tarea',
                    ),
                ],
            ),
            body: Obx(() {
                if (controller.cargando.value) {
                    return const Center(
                        child: CircularProgressIndicator(),
                    );
                }
                
                if (controller.tarea.value == null) {
                    return const Center(
                        child: Text('No se encontró la tarea'),
                    );
                }
                
                return _construirContenido();
            }),
        );
    }

    Widget _construirContenido() {
        return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Sección de título y datos principales
                    _construirSeccionTitulo(),
                    const SizedBox(height: 24.0),
                    
                    // Sección de detalles
                    _construirSeccionDetalles(),
                    const SizedBox(height: 24.0),
                    
                    // Sección de descripción
                    _construirSeccionDescripcion(),
                    const SizedBox(height: 24.0),
                    
                    // Sección de etiquetas
                    _construirSeccionEtiquetas(),
                    const SizedBox(height: 24.0),
                    
                    // Sección de adjuntos
                    _construirSeccionAdjuntos(),
                ],
            ),
        );
    }

    Widget _construirSeccionTitulo() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Título de la tarea
                Text(
                    controller.tarea.value?.titulo ?? '',
                    style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                    ),
                ),
                const SizedBox(height: 8.0),
                
                // Prioridad y Estado
                Row(
                    children: [
                        // Chip de prioridad
                        Chip(
                            label: Text(
                                'Prioridad: ${controller.tarea.value?.prioridad != null 
                                    ? controller.prioridadToString(controller.tarea.value!.prioridad)
                                    : ''}',
                                style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: controller.obtenerColorPrioridad(),
                        ),
                        const SizedBox(width: 8.0),
                        
                        // Chip de estado
                        Chip(
                            label: Text(
                                'Estado: ${controller.tarea.value?.estado != null 
                                    ? controller.estadoToString(controller.tarea.value!.estado)
                                    : ''}',
                                style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: controller.obtenerColorEstado(),
                        ),
                    ],
                ),
            ],
        );
    }

    Widget _construirSeccionDetalles() {
        return Card(
            elevation: 2.0,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text(
                            'Detalles',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                        const Divider(),
                        
                        // Detalles de la tarea
                        _construirFilaDetalle('Lista', controller.lista.value?.nombre ?? 'No especificada'),
                        _construirFilaDetalle('Categoría', controller.categoria.value?.nombre ?? 'No especificada'),
                        _construirFilaDetalle('Fecha de creación', '${controller.fechaCreacion.value} ${controller.horaCreacion.value}'),
                        _construirFilaDetalle('Fecha de vencimiento', '${controller.fechaVencimiento.value} ${controller.horaVencimiento.value}'),
                    ],
                ),
            ),
        );
    }

    Widget _construirFilaDetalle(String titulo, String valor) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    SizedBox(
                        width: 150,
                        child: Text(
                            '$titulo:',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                    ),
                    Expanded(
                        child: Text(valor),
                    ),
                ],
            ),
        );
    }

    Widget _construirSeccionDescripcion() {
        return Card(
            elevation: 2.0,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text(
                            'Descripción',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                        const Divider(),
                        
                        // Descripción de la tarea
                        Text(
                            controller.tarea.value?.descripcion?.isNotEmpty == true
                                ? controller.tarea.value!.descripcion!
                                : 'Sin descripción',
                            style: const TextStyle(
                                fontSize: 16.0,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    Widget _construirSeccionEtiquetas() {
        return Card(
            elevation: 2.0,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text(
                            'Etiquetas',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                        const Divider(),
                        
                        // Lista de etiquetas
                        controller.etiquetas.isNotEmpty
                            ? Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: controller.etiquetas.map((etiqueta) {
                                        // Convertir el color del string hexadecimal a Color
                                        Color colorEtiqueta = Color(
                                            int.parse((etiqueta.color ?? '#CCCCCC').replaceAll('#', '0xFF'))
                                        );
                                        
                                        return Chip(
                                            label: Text(
                                                etiqueta.nombre ?? '',
                                                style: TextStyle(
                                                    color: _contrasteColor(colorEtiqueta),
                                                ),
                                            ),
                                            backgroundColor: colorEtiqueta,
                                        );
                                    }).toList(),
                                )
                            : const Text('No hay etiquetas asociadas a esta tarea'),
                    ],
                ),
            ),
        );
    }

    Widget _construirSeccionAdjuntos() {
        return Card(
            elevation: 2.0,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text(
                            'Adjuntos',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                        const Divider(),
                        
                        // Lista de adjuntos (ahora usando adjuntosConUrl)
                        controller.adjuntosConUrl.isNotEmpty
                            ? ListView.separated(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: controller.adjuntosConUrl.length,
                                    separatorBuilder: (context, index) => const Divider(),
                                    itemBuilder: (context, index) {
                                        final adjunto = controller.adjuntosConUrl[index];
                                        return _construirItemAdjunto(adjunto);
                                    },
                                )
                            : const Text('No hay archivos adjuntos a esta tarea'),
                    ],
                ),
            ),
        );
    }

    Widget _construirItemAdjunto(Adjunto adjunto) {
        String tipoString = adjunto.tipo?.toString().split('.').last ?? '';
        IconData iconoTipo = _obtenerIconoPorTipo(tipoString);
        
        return ListTile(
            leading: Icon(iconoTipo, size: 36.0),
            title: Text(adjunto.nombre ?? 'Archivo adjunto'),
            subtitle: Text(tipoString != '' ? tipoString : 'Tipo desconocido'),
            trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    // Botón para abrir
                    IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => controller.abrirAdjunto(adjunto),
                        tooltip: 'Abrir',
                    ),
                    // Botón para descargar
                    IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => controller.descargarAdjunto(adjunto),
                        tooltip: 'Descargar',
                    ),
                ],
            ),
            onTap: () => controller.abrirAdjunto(adjunto),
        );
    }

    // Método para obtener el icono según el tipo de archivo
    IconData _obtenerIconoPorTipo(String tipo) {
        if (tipo.contains('image/')) {
            return Icons.image;
        } else if (tipo.contains('application/pdf')) {
            return Icons.picture_as_pdf;
        } else if (tipo.contains('text/')) {
            return Icons.description;
        } else if (tipo.contains('application/vnd.openxmlformats-officedocument.wordprocessingml.document') ||
                             tipo.contains('application/msword')) {
            return Icons.article;
        } else if (tipo.contains('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') ||
                             tipo.contains('application/vnd.ms-excel')) {
            return Icons.table_chart;
        } else if (tipo.contains('audio/')) {
            return Icons.audio_file;
        } else if (tipo.contains('video/')) {
            return Icons.video_file;
        } else {
            return Icons.insert_drive_file;
        }
    }

    // Método para calcular el color de contraste para texto
    Color _contrasteColor(Color backgroundColor) {
        // Calcular la luminancia (0 es negro, 1 es blanco)
        final double luminancia = (0.299 * backgroundColor.red + 
                                                         0.587 * backgroundColor.green + 
                                                         0.114 * backgroundColor.blue) / 255;
        
        // Si el fondo es oscuro, usar texto blanco, si es claro usar texto negro
        return luminancia > 0.5 ? Colors.black : Colors.white;
    }
}