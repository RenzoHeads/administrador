import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'crear_tarea_controller.dart';
import '../../models/lista.dart';
import '../../models/categoria.dart';
import '../../models/estado.dart';
import '../../models/prioridad.dart';

class CrearTareaPage extends StatelessWidget {
  final CrearTareaController controller = Get.put(CrearTareaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear nueva tarea'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.cargando.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              _buildSectionTitle('Título'),
              TextField(
                controller: controller.tituloController,
                decoration: InputDecoration(
                  hintText: 'Ingrese el título de la tarea',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 20),

              // Descripción
              _buildSectionTitle('Descripción'),
              TextField(
                controller: controller.descripcionController,
                decoration: InputDecoration(
                  hintText: 'Ingrese la descripción de la tarea',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),

              // Lista
              _buildSectionTitle('Lista'),
              _buildDropdownListas(),
              SizedBox(height: 20),

              // Categoría
              _buildSectionTitle('Categoría'),
              _buildDropdownCategorias(),
              SizedBox(height: 20),
               // Fecha de creación
                _buildSectionTitle('Fecha de creación'),
                Row(
                children: [
                  Expanded(
                  child: InkWell(
                    onTap: () => controller.seleccionarFechaCreacion(),
                    child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Obx(() => Text(controller.fechaCreacionText.value)),
                      Icon(Icons.calendar_today, color: Colors.green),
                      ],
                    ),
                    ),
                  ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                  child: InkWell(
                    onTap: () => controller.seleccionarHoraCreacion(),
                    child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Obx(() => Text(controller.horaCreacionText.value)),
                      Icon(Icons.access_time, color: Colors.green),
                      ],
                    ),
                    ),
                  ),
                  ),
                ],
                ),
                SizedBox(height: 20),

                // Fecha de vencimiento
                _buildSectionTitle('Fecha de vencimiento'),
                Row(
                children: [
                  Expanded(
                  child: InkWell(
                    onTap: () => controller.seleccionarFecha(),
                    child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Obx(() => Text(controller.fechaVencimientoText.value)),
                      Icon(Icons.calendar_today, color: Colors.green),
                      ],
                    ),
                    ),
                  ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                  child: InkWell(
                    onTap: () => controller.seleccionarHora(),
                    child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Obx(() => Text(controller.horaVencimientoText.value)),
                      Icon(Icons.access_time, color: Colors.green),
                      ],
                    ),
                    ),
                  ),
                  ),
                ],
                ),
                SizedBox(height: 20),
                
               
              
              // Prioridad
              _buildSectionTitle('Prioridad'),
              _buildDropdownPrioridades(),
              SizedBox(height: 20),

              // Estado
              _buildSectionTitle('Estado'),
              _buildDropdownEstados(),
              SizedBox(height: 20),

              // Etiquetas
              _buildSectionTitle('Etiquetas'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.etiquetaController,
                      decoration: InputDecoration(
                        hintText: 'Ingrese una etiqueta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => controller.agregarEtiqueta(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _buildEtiquetasSeleccionadas(),
              SizedBox(height: 20),

              // Adjuntos - SECCIÓN ACTUALIZADA
              _buildSectionTitle('Adjuntar archivos'),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.mostrarOpcionesArchivo(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: Icon(Icons.attach_file),
                      label: Text('Adjuntar archivos'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _buildArchivosSeleccionados(),
              SizedBox(height: 20),

              // Botón Crear Tarea
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => controller.crearTarea(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'CREAR TAREA',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildDropdownListas() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(() => DropdownButton<Lista>(
        value: controller.listaSeleccionada.value,
        isExpanded: true,
        underline: SizedBox(),
        hint: Text('Seleccione una lista'),
        items: controller.listas.map((Lista lista) {
          return DropdownMenuItem<Lista>(
            value: lista,
            child: Text(lista.nombre ?? 'Sin nombre'),
          );
        }).toList(),
        onChanged: (Lista? newValue) {
          controller.listaSeleccionada.value = newValue;
        },
      )),
    );
  }

  Widget _buildDropdownCategorias() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(() => DropdownButton<Categoria>(
        value: controller.categoriaSeleccionada.value,
        isExpanded: true,
        underline: SizedBox(),
        hint: Text('Seleccione una categoría'),
        items: controller.categorias.map((Categoria categoria) {
          return DropdownMenuItem<Categoria>(
            value: categoria,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(int.parse(
                      (categoria.color ?? '#CCCCCC').replaceAll('#', '0xFF')
                    )),
                  ),
                ),
                SizedBox(width: 8),
                Text(categoria.nombre ?? 'Sin nombre'),
              ],
            ),
          );
        }).toList(),
        onChanged: (Categoria? newValue) {
          controller.categoriaSeleccionada.value = newValue;
        },
      )),
    );
  }

Widget _buildDropdownPrioridades() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Obx(() => DropdownButton<Prioridad>(
      value: controller.prioridadSeleccionada.value,
      isExpanded: true,
      underline: SizedBox(),
      hint: Text('Seleccione una prioridad'),
      items: controller.prioridades.map((Prioridad prioridad) {
        return DropdownMenuItem<Prioridad>(
          value: prioridad,
          child: Row(
            children: [
              Icon(
                Icons.flag,
                color: _getPrioridadColor(prioridad),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(prioridad.nombre ?? 'Sin nombre'),
            ],
          ),
        );
      }).toList(),
      onChanged: (Prioridad? newValue) {
        controller.prioridadSeleccionada.value = newValue;
      },
    )),
  );
}

Color _getPrioridadColor(Prioridad prioridad) {
  String nombre = prioridad.nombre?.toLowerCase() ?? '';
  switch (nombre) {
    case 'alta':
      return Colors.red;
    case 'media':
      return Colors.orange;
    case 'baja':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

Widget _buildDropdownEstados() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Obx(() => DropdownButton<Estado>(
      value: controller.estadoSeleccionado.value,
      isExpanded: true,
      underline: SizedBox(),
      hint: Text('Seleccione un estado'),
      items: controller.estados.map((Estado estado) {
        return DropdownMenuItem<Estado>(
          value: estado,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getEstadoColor(estado),
                ),
              ),
              Text(estado.nombre ?? 'Sin nombre'),
            ],
          ),
        );
      }).toList(),
      onChanged: (Estado? newValue) {
        controller.estadoSeleccionado.value = newValue;
      },
    )),
  );
}

Color _getEstadoColor(Estado estado) {
  String nombre = estado.nombre?.toLowerCase() ?? '';
  switch (nombre) {
    case 'pendiente':
      return Colors.grey;
    case 'en progreso':
      return Colors.blue;
    case 'completado':
      return Colors.green;
    case 'cancelado':
      return Colors.red;
    default:
      return Colors.grey.shade400;
  }
}

  Widget _buildEtiquetasSeleccionadas() {
    return Obx(() {
      if (controller.etiquetasSeleccionadas.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'No hay etiquetas seleccionadas',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.etiquetasSeleccionadas.map((etiqueta) {
          final color = Color(int.parse(
            (etiqueta.color ?? '#CCCCCC').replaceAll('#', '0xFF')
          ));
          
          return Chip(
            label: Text(
              etiqueta.nombre ?? '',
              style: TextStyle(
                color: _contrastColor(color),
                fontSize: 12,
              ),
            ),
            backgroundColor: color,
            deleteIcon: Icon(
              Icons.close,
              size: 16,
              color: _contrastColor(color),
            ),
            onDeleted: () => controller.eliminarEtiqueta(etiqueta),
          );
        }).toList(),
      );
    });
  }

  Color _contrastColor(Color color) {
    // Calcula si el texto debe ser blanco o negro según el color de fondo
    int d = color.computeLuminance() > 0.5 ? 0 : 255;
    return Color.fromARGB(255, d, d, d);
  }

  // Widget para mostrar archivos seleccionados - ACTUALIZADO
  Widget _buildArchivosSeleccionados() {
    return Obx(() {
      if (controller.archivosSeleccionados.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'No hay archivos seleccionados',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: controller.archivosSeleccionados.length,
        itemBuilder: (context, index) {
          final file = controller.archivosSeleccionados[index];
          final fileName = path.basename(file.path);
          final extension = path.extension(file.path).toLowerCase();
          
          // Determinar el ícono adecuado basado en la extensión
          IconData iconData;
          if (extension == '.jpg' || extension == '.jpeg' || extension == '.png') {
            iconData = Icons.image;
          } else if (extension == '.pdf') {
            iconData = Icons.picture_as_pdf;
          } else if (extension == '.doc' || extension == '.docx') {
            iconData = Icons.description;
          } else if (extension == '.xls' || extension == '.xlsx') {
            iconData = Icons.table_chart;
          } else if (extension == '.txt') {
            iconData = Icons.text_snippet;
          } else {
            iconData = Icons.insert_drive_file;
          }

          // Vista previa para imágenes
          Widget? previewWidget;
          if (extension == '.jpg' || extension == '.jpeg' || extension == '.png') {
            try {
              previewWidget = ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  file,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              );
            } catch (e) {
              // Si hay algún error al cargar la imagen, usamos el ícono
              previewWidget = Icon(iconData, color: Colors.grey.shade700, size: 40);
            }
          } else {
            previewWidget = Icon(iconData, color: Colors.grey.shade700, size: 40);
          }

          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                previewWidget,
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _getFileSize(file),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => controller.eliminarArchivo(index),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // Método para obtener el tamaño del archivo de forma legible
  String _getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Tamaño desconocido';
    }
  }
}