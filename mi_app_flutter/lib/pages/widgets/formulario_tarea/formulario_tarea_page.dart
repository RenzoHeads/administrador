import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'formulario_tarea_controller.dart';
import '../../../models/lista.dart';
import '../../../models/categoria.dart';
import '../../../models/prioridad.dart';
import '../../../models/etiqueta.dart';
import '../../../models/tarea.dart';

class TaskFormWidget extends StatefulWidget {
  final Tarea? tarea;
  final List<Etiqueta>? etiquetas;
  final Categoria? categoria;
  final Lista? lista;
  final Prioridad? prioridad;
  final bool isEditing;

  TaskFormWidget({
    this.tarea,
    this.etiquetas,
    this.categoria,
    this.lista,
    this.prioridad,
    this.isEditing = false,
  });

  @override
  _TaskFormWidgetState createState() => _TaskFormWidgetState();
}

class _TaskFormWidgetState extends State<TaskFormWidget> {
  late TaskFormController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TaskFormController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditing && widget.tarea != null) {
        // Si estamos editando, inicializamos el formulario con los datos existentes
        controller.initializeForEditing(
          widget.tarea!,
          widget.etiquetas ?? [],
          widget.categoria,
          widget.lista,
          widget.prioridad,
        );
      } else {
        // Si estamos creando, inicializamos el formulario vacío
        controller.initializeForCreation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.cargando.value) {
        return Center(child: CircularProgressIndicator());
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
                          onTap: () => controller.seleccionarHoraVencimiento(),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
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
                      onPressed:
                          () =>
                              widget.isEditing
                                  ? controller.actualizarTarea()
                                  : controller.crearTarea(),
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
                            widget.isEditing ? 'Guardar' : 'Crear',
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
    });
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
