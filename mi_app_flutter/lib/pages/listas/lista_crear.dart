import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'lista_crear_controler.dart';

class CrearListaPage extends StatelessWidget {
  final CrearListaController controller = Get.put(CrearListaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear nueva lista'),
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
              // Nombre
              _buildSectionTitle('Nombre'),
              TextField(
                controller: controller.nombreController,
                decoration: InputDecoration(
                  hintText: 'Ingrese el nombre de la lista',
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
                  hintText: 'Ingrese la descripción de la lista',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),

              // Selección de color
              _buildSectionTitle('Color'),
              _buildColorSelector(),
              SizedBox(height: 30),

              // Botón Crear Lista
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton(
                  onPressed: () => controller.crearLista(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.colorSeleccionado.value,
                    foregroundColor: _contrastColor(controller.colorSeleccionado.value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'CREAR LISTA',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )),
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

  Widget _buildColorSelector() {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.coloresPredefinidos.length,
        itemBuilder: (context, index) {
          final color = controller.coloresPredefinidos[index];
          return Obx(() {
            final isSelected = controller.colorSeleccionado.value == color;
            return GestureDetector(
              onTap: () => controller.seleccionarColor(color),
              child: Container(
                margin: EdgeInsets.only(right: 12),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: _contrastColor(color),
                      )
                    : null,
              ),
            );
          });
        },
      ),
    );
  }

  Color _contrastColor(Color color) {
    // Calcula si el texto debe ser blanco o negro según el color de fondo
    int d = color.computeLuminance() > 0.5 ? 0 : 255;
    return Color.fromARGB(255, d, d, d);
  }
}