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
import '../../../services/controladorsesion.dart';

import '../../widgets/tarea/ver_tarea_controller.dart';
import '../../home/home_controler.dart';
import '../../principal/principal_controller.dart';
import '../../widgets/lista/lista_item_controller.dart';
import '../../buscador/buscador_controller_page.dart';

class TaskFormController extends GetxController {
  final TareaService _tareaService = TareaService();
  final EtiquetaService _etiquetaService = EtiquetaService();
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();
  final HomeController _homeController = Get.find<HomeController>();
  final PrincipalController _principalController =
      Get.find<PrincipalController>();
  final BuscadorController _buscadorController = Get.find<BuscadorController>();

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
        final resultadoListas =
            await _principalController.ObtenerListaUsuario();

        listas.assignAll(resultadoListas);
      }

      // Cargar categorías
      final resultadoCategorias =
          await _principalController.ObtenerCategoriasUsuario();

      categorias.assignAll(resultadoCategorias);

      // Cargar prioridades
      final resultadoPrioridades =
          await _principalController.ObtenerPrioridadesUsuario();

      prioridades.assignAll(resultadoPrioridades);
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

      // Extraer IDs de etiquetas
      final List<int> etiquetasIds =
          etiquetasSeleccionadas
              .where((etiqueta) => etiqueta.id != null)
              .map((etiqueta) => etiqueta.id!)
              .toList();

      // Crear la tarea con etiquetas en una sola operación
      final resultadoTarea = await _tareaService.crearTareaConEtiquetas(
        usuarioId: usuario.id!,
        listaId: listaSeleccionada.value!.id!,
        titulo: tituloController.text,
        descripcion: descripcionController.text,
        fechaCreacion: fechaCreacionFormateada,
        fechaVencimiento: fechaVencimientoFormateada,
        categoriaId: categoriaSeleccionada.value!.id!,
        estadoId: 1, // Estado inicial (1 = Pendiente)
        prioridadId: prioridadSeleccionada.value!.id!,
        etiquetas: etiquetasIds,
      );

      if (resultadoTarea.status != 200) {
        throw Exception('No se pudo crear la tarea');
      }

      Tarea bodyTarea = resultadoTarea.body as Tarea;
      Tarea tareita = Tarea(
        id: bodyTarea.id,
        titulo: tituloController.text,
        descripcion: descripcionController.text,
        fechaCreacion: fechaCreacionCompleta,
        fechaVencimiento: fechaVencimientoCompleta,
        prioridadId: prioridadSeleccionada.value!.id!,
        estadoId: 1,
        categoriaId: categoriaSeleccionada.value!.id!,
        usuarioId: usuario.id!,
        listaId: listaSeleccionada.value!.id!,
      );

      await _principalController.AgregarTarea(tareita);
      await ListaItemController.actualizarLista(tareita.listaId!);
      // Recargar datos en el homeController
      await _principalController.AgregarEtiquetasPorTarea(
        tareita.id!,
        etiquetasSeleccionadas,
      );

      await _homeController.recargarTodo();
      await _buscadorController.recargarBuscador();
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

      Tarea tareita = await _principalController.ObtenerTareaPorId(
        tareaId.value,
      );

      // Extraer IDs de etiquetas
      final List<int> etiquetasIds =
          etiquetasSeleccionadas
              .where((etiqueta) => etiqueta.id != null)
              .map((etiqueta) => etiqueta.id!)
              .toList();

      // Actualizar la tarea con etiquetas en una sola operación
      final resultadoTarea = await _tareaService.actualizarTareaConEtiquetas(
        id: tareaId.value,
        usuarioId: usuario.id!,
        listaId: listaSeleccionada.value!.id!,
        titulo: tituloController.text,
        descripcion: descripcionController.text,
        fechaCreacion: fechaCreacionFormateada,
        fechaVencimiento: fechaVencimientoFormateada,
        categoriaId: categoriaSeleccionada.value!.id!,
        estadoId: tareita.estadoId, // Mantener el estado actual
        prioridadId: prioridadSeleccionada.value!.id!,
        etiquetas: etiquetasIds,
      );

      if (resultadoTarea.status != 200) {
        throw Exception('No se pudo actualizar la tarea');
      }
      Tarea tareitae = resultadoTarea.body as Tarea;

      Tarea tareaActualizada = Tarea(
        id: tareitae.id,
        titulo: tituloController.text,
        descripcion: descripcionController.text,
        fechaCreacion: fechaCreacionCompleta,
        fechaVencimiento: fechaVencimientoCompleta,
        prioridadId: prioridadSeleccionada.value!.id!,
        estadoId: tareita.estadoId, // Mantener el estado actual
        categoriaId: categoriaSeleccionada.value!.id!,
        usuarioId: usuario.id!,
        listaId: listaSeleccionada.value!.id!,
      );

      // Actualizar datos en el VerTareaController si está en uso
      await _principalController.EditarTarea(tareaActualizada);

      await _principalController.ActualizarEtiquetasPorTarea(
        tareaActualizada.id!,
        etiquetasSeleccionadas,
      );
      await ListaItemController.actualizarLista(tareaActualizada.listaId!);
      await VerTareaController.actualizarTarea(tareaId.value);
      await _homeController.recargarTodo();
      await _buscadorController.recargarBuscador();

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
