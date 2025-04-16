import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controler.dart'; // Corregido el nombre del archivo
import '../../services/controladorsesion.dart';
import 'package:intl/intl.dart';
import '../../models/tarea.dart';
import '../../models/lista.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  final ControladorSesionUsuario sesionControlador = Get.find<ControladorSesionUsuario>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.cargando.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con avatar y botón de recarga
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => controller.navegarAPerfil(),
                      child: Obx(() => CircleAvatar(
                        backgroundImage: controller.profilePhotoUrl.value.isNotEmpty
                            ? NetworkImage(controller.profilePhotoUrl.value)
                            : null,
                        backgroundColor: Colors.grey[300],
                        radius: 20,
                        child: controller.profilePhotoUrl.value.isEmpty
                            ? Text(
                                sesionControlador.usuarioActual.value?.nombre?.isNotEmpty == true
                                  ? sesionControlador.usuarioActual.value!.nombre!.substring(0, 1).toUpperCase()
                                  : "U",
                                style: TextStyle(color: Colors.white),
                              )
                            : null,
                      )),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () => controller.recargarDatos(),
                      tooltip: 'Recargar datos',
                    ),
                  ],
                ),
              ),

              // Título de la sección principal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Obx(() => Text(
                  controller.pestanaSeleccionada.value == 0 ? 'Principal' : 
                  controller.pestanaSeleccionada.value == 1 ? 'Listas' : 'Perfil',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )),
              ),

              // Pestañas personalizadas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    // Pestaña: Tareas
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.cambiarPestana(0),
                        child: Obx(() => Container(
                          decoration: BoxDecoration(
                            color: controller.pestanaSeleccionada.value == 0 
                                ? Colors.green[400] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Text(
                            "Tareas",
                            style: TextStyle(
                              color: controller.pestanaSeleccionada.value == 0 
                                  ? Colors.white : Colors.grey[600],
                              fontWeight: controller.pestanaSeleccionada.value == 0 
                                  ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        )),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Pestaña: Listas
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.cambiarPestana(1),
                        child: Obx(() => Container(
                          decoration: BoxDecoration(
                            color: controller.pestanaSeleccionada.value == 1 
                                ? Colors.green[400] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Text(
                            "Listas",
                            style: TextStyle(
                              color: controller.pestanaSeleccionada.value == 1 
                                  ? Colors.white : Colors.grey[600],
                              fontWeight: controller.pestanaSeleccionada.value == 1 
                                  ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        )),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Pestaña: Perfil
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.cambiarPestana(2),
                        child: Obx(() => Container(
                          decoration: BoxDecoration(
                            color: controller.pestanaSeleccionada.value == 2 
                                ? Colors.green[400] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Text(
                            "Perfil",
                            style: TextStyle(
                              color: controller.pestanaSeleccionada.value == 2 
                                  ? Colors.white : Colors.grey[600],
                              fontWeight: controller.pestanaSeleccionada.value == 2 
                                  ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido según la pestaña seleccionada
              Obx(() {
                switch (controller.pestanaSeleccionada.value) {
                  case 0:
                    return _buildTareasView();
                  case 1:
                    return _buildListasView();
                  case 2:
                    return _buildPerfilView();
                  default:
                    return _buildTareasView();
                }
              }),
            ],
          ),
        );
      }),

      // Botón flotante para agregar tarea o lista
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.task, color: Colors.green),
                    title: Text('Agregar tarea'),
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed('/crear-tarea');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.list, color: Colors.green),
                    title: Text('Agregar lista'),
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed('/crear-lista');
                    },
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Barra de navegación inferior
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  controller.pestanaSeleccionada.value = 0;
                }
              ),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () {}
              ),
              SizedBox(width: 40), // espacio para el FAB
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {}
              ),
              IconButton(
                icon: Icon(Icons.notifications_none),
                onPressed: () {}
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vista de Tareas
  Widget _buildTareasView() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fecha actual
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Hoy, ${DateFormat('d').format(DateTime.now())} de ${DateFormat('MMMM', 'es_ES').format(DateTime.now())}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          SizedBox(height: 16),
          
          // Lista de tareas del día con Debug
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tareas encontradas: ${controller.tareasDeHoy.length}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: 8),
          
          // Lista de tareas del día
          Expanded(
            child: Obx(() {
              if (controller.tareasDeHoy.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'No hay tareas para hoy',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.tareasDeHoy.length,
                  itemBuilder: (context, index) {
                    final tarea = controller.tareasDeHoy[index];
                    return _buildTareaItem(tarea);
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar cada tarea
  Widget _buildTareaItem(Tarea tarea) {
    return InkWell(
      onTap: () {
        // Redirigir a la página de ver tarea
        Get.toNamed('/ver-tarea', arguments: {'tareaId': tarea.id});
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Checkbox(
                  value: false,
                  onChanged: (value) {
                    // Lógica para marcar completada
                  },
                  activeColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Contenido de la tarea
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tarea.titulo ?? 'Sin título',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: false
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if ((tarea.descripcion ?? '').isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        tarea.descripcion ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                    SizedBox(height: 4),
                    if (tarea.fechaVencimiento != null) 
                      Text(
                        'Hoy, ${DateFormat('HH:mm').format(tarea.fechaVencimiento)}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vista de Listas
  Widget _buildListasView() {
    return Expanded(
      child: Obx(() {
        if (controller.listas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt, size: 48, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No hay listas disponibles',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        } else {
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.listas.length,
            itemBuilder: (context, index) {
              final lista = controller.listas[index];
              return _buildListaItem(lista);
            },
          );
        }
      }),
    );
  }

  // Widget para mostrar cada lista
  Widget _buildListaItem(Lista lista) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 5,
        offset: Offset(0, 2),
        ),
      ],
      ),
      child: ListTile(
      title: Text(
        lista.nombre ?? 'Sin nombre',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: FutureBuilder<int>(
        future: controller.obtenerCantidadTareasPorLista(lista.id ?? 0),
        builder: (context, snapshot) {
          final cantidad = snapshot.data ?? 0;
          return Text(
        '$cantidad ${cantidad == 1 ? 'tarea' : 'tareas'}',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
          );
        },
      ),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        // Navegar a detalles de la lista
        Get.toNamed('/detalles-lista', arguments: lista.id);
      },
      ),
        );
      }


  // Vista de Perfil
  Widget _buildPerfilView() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => CircleAvatar(
              backgroundImage: controller.profilePhotoUrl.value.isNotEmpty
                  ? NetworkImage(controller.profilePhotoUrl.value)
                  : null,
              backgroundColor: Colors.grey[300],
              radius: 50,
              child: controller.profilePhotoUrl.value.isEmpty
                  ? Text(
                      sesionControlador.usuarioActual.value?.nombre?.isNotEmpty == true
                        ? sesionControlador.usuarioActual.value!.nombre!.substring(0, 1).toUpperCase()
                        : "U",
                      style: TextStyle(color: Colors.white, fontSize: 32),
                    )
                  : null,
            )),
            SizedBox(height: 16),
            Text(
              sesionControlador.usuarioActual.value?.nombre ?? "Usuario",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.navegarAPerfil(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Ver perfil completo',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}