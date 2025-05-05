import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'editar_tarea_controller.dart';
import '../../models/lista.dart';
import '../../models/categoria.dart';
import '../../models/prioridad.dart';

class EditarTareaPage extends StatefulWidget {
  final int tareaId;

  EditarTareaPage({required this.tareaId});

  @override
  _EditarTareaPageState createState() => _EditarTareaPageState();
}

class _EditarTareaPageState extends State<EditarTareaPage> {
  late EditarTareaController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(EditarTareaController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.cargarTarea(widget.tareaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar tarea',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.cargando.value) {
          return Center(child: CircularProgressIndicator());
        }

        // Solo cargar los datos del formulario cuando la tarea esté disponible
        if (controller.tarea.value != null) {
          _cargarDatosEnFormulario();
        } else {
          // Si no hay tarea, mostrar un mensaje o un loader adicional
          return Center(child: Text('Cargando información de la tarea...'));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                _buildFieldLabel('Título'),
                _buildTextField(
                  controller: controller.tituloController,
                  hintText: 'Ingresa el título',
                  prefixIcon: 'assets/icons/icon_letterT.svg',
                ),
                SizedBox(height: 20),

                // Fecha
                _buildFieldLabel('Fecha'),
                InkWell(
                  onTap: () => controller.seleccionarFechaCreacion(),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/icon_calendaria_tarea.svg',
                          width: 20,
                          height: 20,
                          color: Colors.black,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => Text(
                              controller.fechaCreacionText.value,
                              style: TextStyle(
                                color:
                                    controller.fechaCreacionText.value.isEmpty
                                        ? Colors.grey[400]
                                        : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Horas
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Hora Inicio'),
                          InkWell(
                            onTap: () => controller.seleccionarHoraCreacion(),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/icon_fecha_tarea.svg',
                                    width: 20,
                                    height: 20,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Obx(
                                      () => Text(
                                        controller.horaCreacionText.value,
                                        style: TextStyle(
                                          color:
                                              controller
                                                      .horaCreacionText
                                                      .value
                                                      .isEmpty
                                                  ? Colors.grey[400]
                                                  : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Hora Fin'),
                          InkWell(
                            onTap:
                                () => controller.seleccionarHoraVencimiento(),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/icon_fecha_tarea.svg',
                                    width: 20,
                                    height: 20,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Obx(
                                      () => Text(
                                        controller.horaVencimientoText.value,
                                        style: TextStyle(
                                          color:
                                              controller
                                                      .horaVencimientoText
                                                      .value
                                                      .isEmpty
                                                  ? Colors.grey[400]
                                                  : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Prioridad
                _buildFieldLabel('Prioridad'),
                _buildDropdownPrioridades(),
                SizedBox(height: 20),

                // Descripción
                _buildFieldLabel('Descripción'),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: controller.descripcionController,
                    maxLines: 4,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Etiquetas
                _buildFieldLabel('Etiquetas'),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: controller.etiquetaController,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: 'Ingrese las etiquetas',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      height: 50,
                      width: 50,
                      child: ElevatedButton(
                        onPressed: () => controller.agregarEtiqueta(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/icon_crear_tarea.svg',
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _buildEtiquetasSeleccionadas(),
                SizedBox(height: 20),

                // Lista
                _buildFieldLabel('Lista'),
                _buildDropdownListas(),
                SizedBox(height: 20),

                // Categorías
                _buildFieldLabel('Categorías'),
                _buildDropdownCategorias(),
                SizedBox(height: 40),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.actualizarTarea(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Guardar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _cargarDatosEnFormulario() {
    // Solo cargar los datos si no se han cargado ya o cuando se actualiza la tarea
    if (controller.tarea.value != null) {
      final tarea = controller.tarea.value!;

      // Establecer título y descripción
      controller.tituloController.text = tarea.titulo;
      controller.descripcionController.text = tarea.descripcion;

      // Establecer lista
      if (controller.lista.value != null && controller.listas.isNotEmpty) {
        controller.listaSeleccionada.value = controller.listas.firstWhere(
          (lista) => lista.id == controller.lista.value!.id,
          orElse: () => controller.listas.first,
        );
      }

      // Establecer categoría
      if (controller.categoria.value != null &&
          controller.categorias.isNotEmpty) {
        controller.categoriaSeleccionada.value = controller.categorias
            .firstWhere(
              (cat) => cat.id == controller.categoria.value!.id,
              orElse: () => controller.categorias.first,
            );
      }

      // Establecer prioridad
      if (controller.priori.value != null &&
          controller.prioridades.isNotEmpty) {
        controller.prioridadSeleccionada.value = controller.prioridades
            .firstWhere(
              (p) => p.id == controller.priori.value!.id,
              orElse: () => controller.prioridades.first,
            );
      }

      // Limpiar etiquetas actuales y cargar etiquetas seleccionadas
      controller.etiquetasSeleccionadas.clear();
      if (controller.etiquetas.isNotEmpty) {
        controller.etiquetasSeleccionadas.assignAll(controller.etiquetas);
      }
    }
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[500],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? prefixIcon,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (prefixIcon != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 8.0),
              child: SvgPicture.asset(
                prefixIcon,
                width: 20,
                height: 20,
                color: Colors.black,
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownPrioridades() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<Prioridad>(
            value: controller.prioridadSeleccionada.value,
            isExpanded: true,
            hint: Text(
              'Seleccione la prioridad',
              style: TextStyle(color: Colors.grey[400]),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.black),
            items:
                controller.prioridades.map((Prioridad prioridad) {
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
                        Text(
                          prioridad.nombre,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (Prioridad? newValue) {
              controller.prioridadSeleccionada.value = newValue;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownListas() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<Lista>(
            value: controller.listaSeleccionada.value,
            isExpanded: true,
            hint: Text(
              'Seleccione una lista',
              style: TextStyle(color: Colors.grey[400]),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.black),
            items:
                controller.listas.map((Lista lista) {
                  return DropdownMenuItem<Lista>(
                    value: lista,
                    child: Text(
                      lista.nombre,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
            onChanged: (Lista? newValue) {
              controller.listaSeleccionada.value = newValue;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownCategorias() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<Categoria>(
            value: controller.categoriaSeleccionada.value,
            isExpanded: true,
            hint: Text(
              'Seleccione una categoría',
              style: TextStyle(color: Colors.grey[400]),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.black),
            items:
                controller.categorias.map((Categoria categoria) {
                  return DropdownMenuItem<Categoria>(
                    value: categoria,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(
                              int.parse(
                                (categoria.color).replaceAll('#', '0xFF'),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          categoria.nombre,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (Categoria? newValue) {
              controller.categoriaSeleccionada.value = newValue;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEtiquetasSeleccionadas() {
    return Obx(() {
      if (controller.etiquetasSeleccionadas.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'No hay etiquetas seleccionadas',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        );
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            controller.etiquetasSeleccionadas.map((etiqueta) {
              final color = Color(
                int.parse((etiqueta.color).replaceAll('#', '0xFF')),
              );

              return Chip(
                label: Text(
                  etiqueta.nombre,
                  style: TextStyle(
                    color: _contrastColor(color),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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

  Color _getPrioridadColor(Prioridad prioridad) {
    String nombre = prioridad.nombre.toLowerCase();
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

  Color _contrastColor(Color color) {
    // Calcula si el texto debe ser blanco o negro según el color de fondo
    int d = color.computeLuminance() > 0.5 ? 0 : 255;
    return Color.fromARGB(255, d, d, d);
  }
}
