import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../home/home_controler.dart';
import '../../models/categoria.dart';
import '../../models/etiqueta.dart';
import '../../models/lista.dart';
import '../../models/tarea.dart';
import '../../models/adjunto.dart';
import '../../models/tareaetiqueta.dart';
import '../../services/tarea_service.dart';
import '../../services/etiqueta_service.dart';
import '../../services/categoria_service.dart';
import '../../services/adjunto_service.dart';
import '../../services/lista_service.dart';
import '../../services/controladorsesion.dart';

class CrearTareaController extends GetxController {
  final HomeController _homeController = Get.find<HomeController>();
  final TareaService _tareaService = TareaService();
  final EtiquetaService _etiquetaService = EtiquetaService();
  final CategoriaService _categoriaService = CategoriaService();
  final AdjuntoService _adjuntoService = AdjuntoService();
  final ListaService _listaService = ListaService();
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();
  final ImagePicker _imagePicker = ImagePicker();

  // TextEditingControllers
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  final etiquetaController = TextEditingController();

  // Variables observables
  RxBool cargando = false.obs;
  RxList<Lista> listas = <Lista>[].obs;
  RxList<Categoria> categorias = <Categoria>[].obs;
  RxList<String> prioridades = <String>[].obs;
  RxList<String> estados = <String>[].obs;
  RxList<Etiqueta> etiquetas = <Etiqueta>[].obs;
  RxList<Etiqueta> etiquetasSeleccionadas = <Etiqueta>[].obs;
  RxList<File> archivosSeleccionados = <File>[].obs;
  RxList<Adjunto> adjuntosSubidos = <Adjunto>[].obs;

  // Selecciones
  Rx<Lista?> listaSeleccionada = Rx<Lista?>(null);
  Rx<Categoria?> categoriaSeleccionada = Rx<Categoria?>(null);
  Rx<String?> prioridadSeleccionada = Rx<String?>(null);
  Rx<String?> estadoSeleccionado = Rx<String?>(null);
  
  // Fechas de vencimiento
  Rx<DateTime> fechaVencimiento = DateTime.now().obs;
  Rx<TimeOfDay> horaVencimiento = TimeOfDay.now().obs;
  
  // Fechas de creación
  Rx<DateTime> fechaCreacion = DateTime.now().obs;
  Rx<TimeOfDay> horaCreacion = TimeOfDay.now().obs;
  
  // Fechas formateadas para la UI
  RxString fechaVencimientoText = ''.obs;
  RxString horaVencimientoText = ''.obs;
  RxString fechaCreacionText = ''.obs;
  RxString horaCreacionText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    cargarDatos();
    actualizarTextoFechaHora();
  }

  @override
  void onClose() {
    tituloController.dispose();
    descripcionController.dispose();
    etiquetaController.dispose();
    super.onClose();
  }

  void actualizarTextoFechaHora() {
    // Formato de fecha de vencimiento
    fechaVencimientoText.value = DateFormat('dd/MM/yyyy').format(fechaVencimiento.value);
    
    // Formato de hora de vencimiento
    final horaV = horaVencimiento.value.hour.toString().padLeft(2, '0');
    final minutoV = horaVencimiento.value.minute.toString().padLeft(2, '0');
    horaVencimientoText.value = '$horaV:$minutoV';
    
    // Formato de fecha de creación
    fechaCreacionText.value = DateFormat('dd/MM/yyyy').format(fechaCreacion.value);
    
    // Formato de hora de creación
    final horaC = horaCreacion.value.hour.toString().padLeft(2, '0');
    final minutoC = horaCreacion.value.minute.toString().padLeft(2, '0');
    horaCreacionText.value = '$horaC:$minutoC';
  }

  Future<void> cargarDatos() async {
    try {
      cargando.value = true;
      
      // Cargar listas del usuario
      final usuario = _sesion.usuarioActual.value;
      if (usuario != null && usuario.id != null) {
        final resultadoListas = await _listaService.obtenerListasPorUsuario(usuario.id!);
        if (resultadoListas.status == 200 && resultadoListas.body is List<Lista>) {
          listas.assignAll(resultadoListas.body);
          if (listas.isNotEmpty) {
            listaSeleccionada.value = listas.first;
          }
        }
      }

      // Cargar categorías
      final resultadoCategorias = await _categoriaService.obtenerCategorias();
      if (resultadoCategorias.status == 200 && resultadoCategorias.body is List<Categoria>) {
        categorias.assignAll(resultadoCategorias.body);
      }

      // Cargar prioridades
      final resultadoPrioridades = await _tareaService.obtenerPrioridadesTareas();
      if (resultadoPrioridades.status == 200 && resultadoPrioridades.body is List) {
        List<dynamic> data = resultadoPrioridades.body;
        prioridades.assignAll(data.map((e) => e.toString()).toList());
        if (prioridades.isNotEmpty) {
          prioridadSeleccionada.value = prioridades.first;
        }
      }

      // Cargar estados
      final resultadoEstados = await _tareaService.obtenerEstadosTareas();
      if (resultadoEstados.status == 200 && resultadoEstados.body is List) {
        List<dynamic> data = resultadoEstados.body;
        estados.assignAll(data.map((e) => e.toString()).toList());
        if (estados.isNotEmpty) {
          estadoSeleccionado.value = estados.first;
        }
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      Get.snackbar(
        'Error',
        'No se pudieron cargar los datos necesarios',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      cargando.value = false;
    }
  }

// Métodos para fecha y hora de vencimiento
Future<void> seleccionarFecha() async {
  final DateTime? fechaSeleccionada = await showDatePicker(
    context: Get.context!,
    initialDate: fechaVencimiento.value,
    firstDate: fechaCreacion.value, // No puede ser antes de la fecha de creación
    lastDate: DateTime(2100),
  );
  
  if (fechaSeleccionada != null) {
    fechaVencimiento.value = fechaSeleccionada;
    actualizarTextoFechaHora();
  }
}

  Future<void> seleccionarHora() async {
    // No puede ser antes de la hora de creación

    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: Get.context!,
      initialTime: horaVencimiento.value,
    );
    
    if (horaSeleccionada != null) {
      // Validar que la hora seleccionada no sea antes de la hora de creación
      // si es el mismo día
      if (fechaVencimiento.value.year == fechaCreacion.value.year &&
          fechaVencimiento.value.month == fechaCreacion.value.month &&
          fechaVencimiento.value.day == fechaCreacion.value.day) {
        
        int horaSeleccionadaMinutos = horaSeleccionada.hour * 60 + horaSeleccionada.minute;
        int horaCreacionMinutos = horaCreacion.value.hour * 60 + horaCreacion.value.minute;
        
        if (horaSeleccionadaMinutos < horaCreacionMinutos) {
          Get.snackbar(
            'Error',
            'La hora de vencimiento no puede ser anterior a la hora de creación',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }
      
      horaVencimiento.value = horaSeleccionada;
      actualizarTextoFechaHora();
    }
  }

  // Métodos para fecha y hora de creación
// Métodos para fecha y hora de creación
Future<void> seleccionarFechaCreacion() async {
  final DateTime ahora = DateTime.now();
  final DateTime? fechaSeleccionada = await showDatePicker(
    context: Get.context!,
    initialDate: fechaCreacion.value.isBefore(ahora) ? ahora : fechaCreacion.value,
    firstDate: ahora, // No puede ser antes de ahora
    lastDate: fechaVencimiento.value, // No puede ser después de la fecha de vencimiento
  );
  
  if (fechaSeleccionada != null) {
    fechaCreacion.value = fechaSeleccionada;
    actualizarTextoFechaHora();
  }
}

  Future<void> seleccionarHoraCreacion() async {
    // No puede ser antes de ahora
     // No puede ser después de la hora de vencimiento
    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: Get.context!,
      initialTime: horaCreacion.value.isBefore(TimeOfDay.now()) ? TimeOfDay.now() : horaCreacion.value,
    );
    
    if (horaSeleccionada != null) {
      horaCreacion.value = horaSeleccionada;
      actualizarTextoFechaHora();
    }
  }

  // Obtener fecha/hora completa de vencimiento
  DateTime obtenerFechaHoraVencimientoCompleta() {
    return DateTime(
      fechaVencimiento.value.year,
      fechaVencimiento.value.month,
      fechaVencimiento.value.day,
      horaVencimiento.value.hour,
      horaVencimiento.value.minute,
    );
  }

  // Obtener fecha/hora completa de creación
  DateTime obtenerFechaHoraCreacionCompleta() {
    return DateTime(
      fechaCreacion.value.year,
      fechaCreacion.value.month,
      fechaCreacion.value.day,
      horaCreacion.value.hour,
      horaCreacion.value.minute,
    );
  }

  // Nueva implementación para seleccionar imagen desde la galería
  Future<void> seleccionarImagen() async {
    try {
      final XFile? imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      
      if (imagen != null) {
        archivosSeleccionados.add(File(imagen.path));
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      Get.snackbar(
        'Error',
        'No se pudo seleccionar la imagen',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Nueva implementación para tomar una foto con la cámara
  Future<void> tomarFoto() async {
    try {
      final XFile? foto = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      
      if (foto != null) {
        archivosSeleccionados.add(File(foto.path));
      }
    } catch (e) {
      print('Error al tomar foto: $e');
      Get.snackbar(
        'Error',
        'No se pudo tomar la foto',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Método para mostrar opciones al usuario
  void mostrarOpcionesArchivo() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecciona una opción',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Seleccionar desde galería'),
              onTap: () {
                Get.back();
                seleccionarImagen();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Tomar foto'),
              onTap: () {
                Get.back();
                tomarFoto();
              },
            ),
            ListTile(
              leading: Icon(Icons.note_add),
              title: Text('Crear texto simple'),
              onTap: () {
                Get.back();
                crearArchivoTexto();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Método para crear un archivo de texto simple
  Future<void> crearArchivoTexto() async {
    TextEditingController textController = TextEditingController();
    TextEditingController nombreController = TextEditingController(text: 'nota_${DateTime.now().millisecondsSinceEpoch}.txt');
    
    await Get.dialog(
      AlertDialog(
        title: Text('Crear archivo de texto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre del archivo'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: textController,
              decoration: InputDecoration(labelText: 'Contenido'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.isNotEmpty && nombreController.text.isNotEmpty) {
                try {
                  // Obtener directorio temporal
                  final directory = await getTemporaryDirectory();
                  final String fileName = nombreController.text.endsWith('.txt') 
                      ? nombreController.text 
                      : '${nombreController.text}.txt';
                  final File file = File('${directory.path}/$fileName');
                  
                  // Escribir en el archivo
                  await file.writeAsString(textController.text);
                  
                  // Añadir el archivo a la lista
                  archivosSeleccionados.add(file);
                  
                  Get.back();
                  Get.snackbar(
                    'Éxito',
                    'Archivo de texto creado correctamente',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  print('Error al crear archivo de texto: $e');
                  Get.snackbar(
                    'Error',
                    'No se pudo crear el archivo de texto',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Este método reemplaza el original agregarArchivo
  Future<void> agregarArchivo() async {
    mostrarOpcionesArchivo();
  }

  void eliminarArchivo(int index) {
    if (index >= 0 && index < archivosSeleccionados.length) {
      archivosSeleccionados.removeAt(index);
    }
  }

  Future<void> agregarEtiqueta() async {
    String nombreEtiqueta = etiquetaController.text.trim();
    if (nombreEtiqueta.isEmpty) return;
    
    try {
      // Verificar si la etiqueta ya existe
      final resultado = await _etiquetaService.obtenerEtiquetaPorNombre(nombreEtiqueta);
      
      Etiqueta etiqueta;
      if (resultado.status == 200 && resultado.body is Etiqueta) {
        // La etiqueta existe
        etiqueta = resultado.body;
      } else {
        // La etiqueta no existe, crear una nueva
        final String colorAleatorio = '#${(DateTime.now().millisecondsSinceEpoch % 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
        final resultadoCreacion = await _etiquetaService.crearEtiqueta(
          nombre: nombreEtiqueta,
          color: colorAleatorio,
        );
        
        if (resultadoCreacion.status != 200 || !(resultadoCreacion.body is Etiqueta)) {
          throw Exception('No se pudo crear la etiqueta');
        }
        
        etiqueta = resultadoCreacion.body;
      }
      
      // Verificar si la etiqueta ya está seleccionada
      if (!etiquetasSeleccionadas.any((e) => e.id == etiqueta.id)) {
        etiquetasSeleccionadas.add(etiqueta);
      }
      
      // Limpiar el campo
      etiquetaController.clear();
    } catch (e) {
      print('Error al agregar etiqueta: $e');
      Get.snackbar(
        'Error',
        'No se pudo agregar la etiqueta',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void eliminarEtiqueta(Etiqueta etiqueta) {
    etiquetasSeleccionadas.remove(etiqueta);
  }

 
  

  Future<void> crearTarea() async {
    if (tituloController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'El título es obligatorio',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (listaSeleccionada.value == null) {
      Get.snackbar(
        'Error',
        'Debe seleccionar una lista',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (categoriaSeleccionada.value == null) {
      Get.snackbar(
        'Error',
        'Debe seleccionar una categoría',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      cargando.value = true;
      final usuario = _sesion.usuarioActual.value;
      if (usuario == null || usuario.id == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Formatear fechas para la API
      final fechaCreacionCompleta = obtenerFechaHoraCreacionCompleta();
      final fechaCreacionFormateada = DateFormat('yyyy-MM-dd HH:mm:ss').format(fechaCreacionCompleta);
      final fechaVencimientoCompleta = obtenerFechaHoraVencimientoCompleta();
      final fechaVencimientoFormateada = DateFormat('yyyy-MM-dd HH:mm:ss').format(fechaVencimientoCompleta);

      // Crear la tarea
      final resultadoTarea = await _tareaService.crearTarea(
        usuarioId: usuario.id!,
        listaId: listaSeleccionada.value!.id!,
        titulo: tituloController.text,
        descripcion: descripcionController.text,
        fechaCreacion: fechaCreacionFormateada,
        fechaVencimiento: fechaVencimientoFormateada,
        prioridad: prioridadSeleccionada.value ?? 'Media',
        estado: estadoSeleccionado.value ?? 'Pendiente',
        categoriaId: categoriaSeleccionada.value!.id!,
      );

      if (resultadoTarea.status != 200 || !(resultadoTarea.body is Tarea)) {
        throw Exception('No se pudo crear la tarea');
      }

      final Tarea tareaCreada = resultadoTarea.body;

      // Agregar etiquetas
      for (var etiqueta in etiquetasSeleccionadas) {
        await _tareaService.crearTareaEtiqueta(tareaCreada.id!, etiqueta.id!);
      }

      // Subir adjuntos
      for (var archivo in archivosSeleccionados) {
        await _adjuntoService.subirAdjunto(tareaCreada.id!, archivo);
      }
          // Option 1: Pass refresh parameter to the route
      
    
      //recargar datos
      _homeController.recargarDatos();
      // Navegar a la pantalla de tareas
      Get.offNamed('/home', arguments: {'refresh': true});
      Get.snackbar(
        'Éxito',
        'Tarea creada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error al crear la tarea: $e');
      Get.snackbar(
        'Error',
        'No se pudo crear la tarea: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      cargando.value = false;
    }
  }
}