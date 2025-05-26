import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/lista.dart';
import 'lista_editar_controler.dart';

class EditarListaModal extends StatelessWidget {
  final EditarListaController controller = Get.put(EditarListaController());
  final Lista lista;
  final VoidCallback? onClose;

  EditarListaModal({Key? key, required this.lista, this.onClose})
    : super(key: key) {
    controller.inicializarDesdeLista(lista);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          if (controller.cargando.value) {
            return Container(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Text(
                      'Editar lista',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: onClose ?? () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              _buildSectionTitle('Nombre'),
              TextField(
                controller: controller.nombreController,
                decoration: InputDecoration(
                  hintText: 'Ingrese el nombre de la lista',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              SizedBox(height: 16),
              _buildSectionTitle('Descripción'),
              TextField(
                controller: controller.descripcionController,
                decoration: InputDecoration(
                  hintText: 'Ingrese la descripción de la lista',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              _buildSectionTitle('Color'),
              _buildColorSelector(),
              SizedBox(height: 20),
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
                          borderRadius: BorderRadius.circular(8),
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
                      onPressed: () => controller.actualizarLista(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.colorSeleccionado.value,
                        foregroundColor: _contrastColor(
                          controller.colorSeleccionado.value,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Actualizar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          );
        }),
      ),
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
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ]
                          : [],
                ),
                child:
                    isSelected
                        ? Icon(Icons.check, color: _contrastColor(color))
                        : null,
              ),
            );
          });
        },
      ),
    );
  }

  Color _contrastColor(Color color) {
    int d = color.computeLuminance() > 0.5 ? 0 : 255;
    return Color.fromARGB(255, d, d, d);
  }
}
