import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/lista.dart';
import '../../../models/categoria.dart';
import '../../../models/prioridad.dart';
import '../../../models/etiqueta.dart';
import '../../../models/tarea.dart';
import '../../../services/tarea_service.dart';
import '../../../services/etiqueta_service.dart';
import '../../../services/categoria_service.dart';
import '../../../services/lista_service.dart';
import '../../../services/controladorsesion.dart';
import '../../../services/prioridad_service.dart';
import '../../widgets/tarea/ver_tarea_controller.dart';
import '../../home/home_controler.dart';

class TaskFormController extends GetxController {
  final TareaService _tareaService = TareaService();
  final EtiquetaService _etiquetaService = EtiquetaService();
  final CategoriaService _categoriaService = CategoriaService();
  final ListaService _listaService = ListaService();
  final PrioridadService _prioridadService = PrioridadService();
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();
  final HomeController _homeController = Get.find<HomeController>();

  // TextEditingControllers
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  final etiquetaController = TextEditingController();

  // Variables observables
  RxBool cargando = false.obs;
  RxList<Lista> listas = <Lista>[].obs;
  RxList<Categoria> categorias = <Categoria>[].obs;
  RxList<Prioridad> prioridades = <Prioridad>[].obs;
  RxList<Etiqueta> etiquetasSeleccionadas = <Etiqueta>[].obs;

  // Selecciones
  Rx<Lista?> listaSeleccionada = Rx<Lista?>(null);
  Rx<Categoria?> categoriaSeleccionada = Rx<Categoria?>(null);
  Rx<Prioridad?> prioridadSeleccionada = Rx<Prioridad?>(null);

  // Fechas y horas
  Rx<DateTime> fechaCreacion = DateTime.now().obs;
  Rx<TimeOfDay> horaCreacion = TimeOfDay.now().obs;
  Rx<TimeOfDay> horaVencimiento = TimeOfDay.now().obs;

  // Fechas formateadas para la UI
  RxString fechaCreacionText = ''.obs;
  RxString horaCreacionText = ''.obs;
  RxString horaVencimientoText = ''.obs;

  // ID de la tarea para edición
  RxInt tareaId = RxInt(-1);

  // Modo edición o creación
  RxBool isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    cargarDatosBasicos();
    actualizarTextoFechaHora();
  }

  @override
  void onClose() {
    tituloController.dispose();
    descripcionController.dispose();
    etiquetaController.dispose();
    super.onClose();
  }

  // Inicializa el formulario para crear una nueva tarea
  void initializeForCreation() {
    isEditing.value = false;
    tareaId.value = -1;

    // Limpiar campos
    tituloController.text = '';
    descripcionController.text = '';
    etiquetaController.text = '';

    // Inicializar fechas
    fechaCreacion.value = DateTime.now();
    horaCreacion.value = TimeOfDay.now();

    // Establecer la hora de vencimiento una hora después
    final now = DateTime.now();
    horaVencimiento.value = TimeOfDay(
      hour: (now.hour + 1) % 24,
      minute: now.minute,
    );

    // Limpiar selecciones
    etiquetasSeleccionadas.clear();
    listaSeleccionada.value = null;
    categoriaSeleccionada.value = null;
    prioridadSeleccionada.value = null;

    // Inicializar valores de fecha/hora mostrados
    actualizarTextoFechaHora();
  }

  // Inicializa el formulario para editar una tarea existente
  void initializeForEditing(
    Tarea tarea,
    List<Etiqueta> etiquetas,
    Categoria? categoria,
    Lista? lista,
    Prioridad? prioridad,
  ) {
    isEditing.value = true;
    tareaId.value = tarea.id ?? -1;

    // Establecer datos de la tarea
    tituloController.text = tarea.titulo;
    descripcionController.text = tarea.descripcion;

    // Convertir fechas a hora local
    DateTime fechaCreacionLocal = tarea.fechaCreacion.toLocal();
    DateTime fechaVencimientoLocal = tarea.fechaVencimiento.toLocal();

    // Establecer fecha y horas
    fechaCreacion.value = fechaCreacionLocal;
    horaCreacion.value = TimeOfDay(
      hour: fechaCreacionLocal.hour,
      minute: fechaCreacionLocal.minute,
    );

    horaVencimiento.value = TimeOfDay(
      hour: fechaVencimientoLocal.hour,
      minute: fechaVencimientoLocal.minute,
    );

    // Establecer etiquetas seleccionadas
    etiquetasSeleccionadas.assignAll(etiquetas);

    // Esperar a que se carguen los datos básicos antes de establecer las selecciones
    ever(cargando, (loading) {
      if (!loading) {
        // Establecer lista si está disponible
        if (lista != null && listas.isNotEmpty) {
          listaSeleccionada.value = listas.firstWhere(
            (l) => l.id == lista.id,
            orElse: () => listas.first,
          );
        }

        // Establecer categoría si está disponible
        if (categoria != null && categorias.isNotEmpty) {
          categoriaSeleccionada.value = categorias.firstWhere(
            (c) => c.id == categoria.id,
            orElse: () => categorias.first,
          );
        }

        // Establecer prioridad si está disponible
        if (prioridad != null && prioridades.isNotEmpty) {
          prioridadSeleccionada.value = prioridades.firstWhere(
            (p) => p.id == prioridad.id,
            orElse: () => prioridades.first,
          );
        }
      }
    });

    // Actualizar valores de fecha/hora mostrados
    actualizarTextoFechaHora();
  }

  // Cargar datos básicos necesarios para el formulario
  Future<void> cargarDatosBasicos() async {
    try {
      cargando.value = true;

      // Cargar listas del usuario
      final usuario = _sesion.usuarioActual.value;
      if (usuario != null && usuario.id != null) {
        final resultadoListas = await _listaService.obtenerListasPorUsuario(
          usuario.id!,
        );
        if (resultadoListas.status == 200 &&
            resultadoListas.body is List<Lista>) {
          listas.assignAll(resultadoListas.body);
        }
      }

      // Cargar categorías
      final resultadoCategorias = await _categoriaService.obtenerCategorias();
      if (resultadoCategorias.status == 200 &&
          resultadoCategorias.body is List<Categoria>) {
        categorias.assignAll(resultadoCategorias.body);
      }

      // Cargar prioridades
      final resultadoPrioridades = await _prioridadService.obtenerPrioridades();
      if (resultadoPrioridades.status == 200 &&
          resultadoPrioridades.body is List<Prioridad>) {
        prioridades.assignAll(resultadoPrioridades.body);
      }
    } catch (e) {
      print('Error al cargar datos básicos: $e');
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

  void actualizarTextoFechaHora() {
    // Format creation date
    fechaCreacionText.value = DateFormat(
      'dd/MM/yyyy',
    ).format(fechaCreacion.value);

    // Format creation time
    final horaC = horaCreacion.value.hour.toString().padLeft(2, '0');
    final minutoC = horaCreacion.value.minute.toString().padLeft(2, '0');
    horaCreacionText.value = '$horaC:$minutoC';

    // Format completion time
    final horaV = horaVencimiento.value.hour.toString().padLeft(2, '0');
    final minutoV = horaVencimiento.value.minute.toString().padLeft(2, '0');
    horaVencimientoText.value = '$horaV:$minutoV';
  }

  // Método para seleccionar fecha de creación
  Future<void> seleccionarFechaCreacion() async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: Get.context!,
      initialDate: fechaCreacion.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (fechaSeleccionada != null) {
      // Keep the same time but update the date
      fechaCreacion.value = DateTime(
        fechaSeleccionada.year,
        fechaSeleccionada.month,
        fechaSeleccionada.day,
        fechaCreacion.value.hour,
        fechaCreacion.value.minute,
      );

      // Update text display
      actualizarTextoFechaHora();
    }
  }

  // Método para seleccionar hora de creación
  Future<void> seleccionarHoraCreacion() async {
    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: Get.context!,
      initialTime: horaCreacion.value,
    );

    if (horaSeleccionada != null) {
      // Actualizar la hora
      horaCreacion.value = horaSeleccionada;

      // Si la hora de vencimiento es menor que la nueva hora de creación,
      // actualizarla para que sea igual a la hora de creación
      final minCreacion = horaSeleccionada.hour * 60 + horaSeleccionada.minute;
      final minVencimiento =
          horaVencimiento.value.hour * 60 + horaVencimiento.value.minute;

      if (minVencimiento < minCreacion) {
        horaVencimiento.value = horaSeleccionada;
      }

      // Actualizar textos
      actualizarTextoFechaHora();
    }
  }

  // Método para seleccionar hora de vencimiento
  Future<void> seleccionarHoraVencimiento() async {
    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: Get.context!,
      initialTime: horaVencimiento.value,
    );

    if (horaSeleccionada != null) {
      // Validar que la hora seleccionada no sea anterior a la hora de creación
      final minCreacion =
          horaCreacion.value.hour * 60 + horaCreacion.value.minute;
      final minSeleccionada =
          horaSeleccionada.hour * 60 + horaSeleccionada.minute;

      if (minSeleccionada < minCreacion) {
        Get.snackbar(
          'Error',
          'La hora de vencimiento no puede ser anterior a la hora de creación',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Actualizar la hora de vencimiento
      horaVencimiento.value = horaSeleccionada;

      // Actualizar texto
      actualizarTextoFechaHora();
    }
  }

  // Obtener fecha/hora completa de vencimiento
  DateTime obtenerFechaHoraVencimientoCompleta() {
    return DateTime(
      fechaCreacion.value.year,
      fechaCreacion.value.month,
      fechaCreacion.value.day,
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

  // Método para agregar una etiqueta
  Future<void> agregarEtiqueta() async {
    String nombreEtiqueta = etiquetaController.text.trim();
    if (nombreEtiqueta.isEmpty) return;

    try {
      // Verificar si la etiqueta ya existe
      final resultado = await _etiquetaService.obtenerEtiquetaPorNombre(
        nombreEtiqueta,
      );

      Etiqueta etiqueta;
      if (resultado.status == 200 && resultado.body is Etiqueta) {
        // La etiqueta existe
        etiqueta = resultado.body;
      } else {
        // La etiqueta no existe, crear una nueva
        final String colorAleatorio =
            '#${(DateTime.now().millisecondsSinceEpoch % 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
        final resultadoCreacion = await _etiquetaService.crearEtiqueta(
          nombre: nombreEtiqueta,
          color: colorAleatorio,
        );

        if (resultadoCreacion.status != 200 ||
            !(resultadoCreacion.body is Etiqueta)) {
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

  // Eliminar una etiqueta de la lista de seleccionadas
  void eliminarEtiqueta(Etiqueta etiqueta) {
    etiquetasSeleccionadas.remove(etiqueta);
  }

  // Método para crear una nueva tarea
  Future<void> crearTarea() async {
    // Validar que se hayan completado los campos obligatorios
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

    if (prioridadSeleccionada.value == null) {
      Get.snackbar(
        'Error',
        'Debe seleccionar una prioridad',
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
      final fechaCreacionFormateada = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(fechaCreacionCompleta);

      final fechaVencimientoCompleta = obtenerFechaHoraVencimientoCompleta();
      final fechaVencimientoFormateada = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(fechaVencimientoCompleta);

      // Crear la tarea
      final resultadoTarea = await _tareaService.crearTarea(
        usuarioId: usuario.id!,
        listaId: listaSeleccionada.value!.id!,
        titulo: tituloController.text,
        descripcion: descripcionController.text,
        fechaCreacion: fechaCreacionFormateada,
        fechaVencimiento: fechaVencimientoFormateada,
        categoriaId: categoriaSeleccionada.value!.id!,
        estadoId: 1, // Estado inicial (1 = Pendiente)
        prioridadId: prioridadSeleccionada.value!.id!,
      );

      if (resultadoTarea.status != 200 || !(resultadoTarea.body is Tarea)) {
        throw Exception('No se pudo crear la tarea');
      }

      final Tarea tareaCreada = resultadoTarea.body;

      // Agregar etiquetas a la tarea
      if (etiquetasSeleccionadas.isNotEmpty) {
        for (var etiqueta in etiquetasSeleccionadas) {
          if (etiqueta.id != null) {
            await _tareaService.crearTareaEtiqueta(
              tareaCreada.id!,
              etiqueta.id!,
            );
          }
        }
      }

      // Recargar datos en el homeController
      _homeController.cargarListasDelUsuario();
      _homeController.cargarTareasDelUsuario();

      // Volver a la pantalla anterior con resultado exitoso
      Get.back(result: true);

      // Mostrar mensaje de éxito
      Get.snackbar(
        'Éxito',
        'Tarea creada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error al crear tarea: $e');
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

  // Método para actualizar una tarea existente
  Future<void> actualizarTarea() async {
    if (tareaId.value == -1) {
      Get.snackbar(
        'Error',
        'No hay una tarea seleccionada para editar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

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

    if (prioridadSeleccionada.value == null) {
      Get.snackbar(
        'Error',
        'Debe seleccionar una prioridad',
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
      final fechaCreacionFormateada = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(fechaCreacionCompleta);

      final fechaVencimientoCompleta = obtenerFechaHoraVencimientoCompleta();
      final fechaVencimientoFormateada = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(fechaVencimientoCompleta);

      // Primero obtener la información actual de la tarea para preservar el estadoId
      final resultadoTareaActual = await _tareaService.obtenerTareaPorId(
        tareaId.value,
      );
      if (resultadoTareaActual.status != 200 ||
          !(resultadoTareaActual.body is Tarea)) {
        throw Exception('No se pudo obtener la información actual de la tarea');
      }

      final Tarea tareaActual = resultadoTareaActual.body;

      // Actualizar la tarea
      final resultadoTarea = await _tareaService.actualizarTarea(
        id: tareaId.value,
        usuarioId: usuario.id!,
        listaId: listaSeleccionada.value!.id!,
        titulo: tituloController.text,
        descripcion: descripcionController.text,
        fechaCreacion: fechaCreacionFormateada,
        fechaVencimiento: fechaVencimientoFormateada,
        categoriaId: categoriaSeleccionada.value!.id!,
        estadoId: tareaActual.estadoId, // Mantener el estado actual
        prioridadId: prioridadSeleccionada.value!.id!,
      );

      if (resultadoTarea.status != 200 || !(resultadoTarea.body is Tarea)) {
        throw Exception('No se pudo actualizar la tarea');
      }

      final Tarea tareaActualizada = resultadoTarea.body;

      // Obtener etiquetas actuales de la tarea
      final resultadoEtiquetas = await _etiquetaService.obtenerEtiquetasDeTarea(
        tareaId.value,
      );
      List<Etiqueta> etiquetasActuales = [];
      if (resultadoEtiquetas.status == 200 &&
          resultadoEtiquetas.body is List<Etiqueta>) {
        etiquetasActuales = resultadoEtiquetas.body;
      }

      // Eliminar todas las etiquetas actuales de la tarea
      for (var etiqueta in etiquetasActuales) {
        if (etiqueta.id != null) {
          await _tareaService.eliminarTareaEtiqueta(
            tareaActualizada.id!,
            etiqueta.id!,
          );
        }
      }

      // Agregar las nuevas etiquetas seleccionadas
      if (etiquetasSeleccionadas.isNotEmpty) {
        for (var etiqueta in etiquetasSeleccionadas) {
          if (etiqueta.id != null) {
            await _tareaService.crearTareaEtiqueta(
              tareaActualizada.id!,
              etiqueta.id!,
            );
          }
        }
      }

      // Actualizar datos en el VerTareaController si está en uso
      VerTareaController.actualizarTarea(tareaActualizada.id!);

      // Recargar datos en el homeController
      _homeController.cargarListasDelUsuario();
      _homeController.cargarTareasDelUsuario();

      // Volver a la pantalla anterior con resultado exitoso
      Get.back(result: true);

      // Mostrar mensaje de éxito
      Get.snackbar(
        'Éxito',
        'Tarea actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error al actualizar tarea: $e');
      Get.snackbar(
        'Error',
        'No se pudo actualizar la tarea: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      cargando.value = false;
    }
  }
}
