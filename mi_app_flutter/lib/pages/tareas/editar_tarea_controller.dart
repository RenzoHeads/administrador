import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../models/categoria.dart';
import '../../models/etiqueta.dart';
import '../../models/lista.dart';
import '../../models/tarea.dart';
import '../../services/tarea_service.dart';
import '../../services/etiqueta_service.dart';
import '../../services/categoria_service.dart';
import '../../services/lista_service.dart';
import '../../services/controladorsesion.dart';
import '../../models/prioridad.dart';
import '../../services/prioridad_service.dart';
import '../../pages/widgets/eventos_controlador.dart';

class EditarTareaController extends GetxController {
  final TareaService _tareaService = TareaService();
  final EtiquetaService _etiquetaService = EtiquetaService();
  final CategoriaService _categoriaService = CategoriaService();
  final ListaService _listaService = ListaService();
  final ControladorSesionUsuario _sesion = Get.find<ControladorSesionUsuario>();
  final PrioridadService _prioridadService = PrioridadService();

  // TextEditingControllers
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  final etiquetaController = TextEditingController();

  // Variables observables
  RxBool cargando = false.obs;
  RxList<Lista> listas = <Lista>[].obs;
  RxList<Categoria> categorias = <Categoria>[].obs;
  RxList<Prioridad> prioridades = <Prioridad>[].obs;
  RxList<Etiqueta> etiquetas = <Etiqueta>[].obs;
  RxList<Etiqueta> etiquetasSeleccionadas = <Etiqueta>[].obs;
  RxList<File> archivosSeleccionados = <File>[].obs;
  Rx<Prioridad?> priori = Rx<Prioridad?>(null);
  // Tarea actual
  Rx<Tarea?> tarea = Rx<Tarea?>(null);
  Rx<Categoria?> categoria = Rx<Categoria?>(null);
  Rx<Lista?> lista = Rx<Lista?>(null);
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

  @override
  void onInit() {
    super.onInit();
    cargarDatos();
  }

  @override
  void onClose() {
    tituloController.dispose();
    descripcionController.dispose();
    etiquetaController.dispose();
    super.onClose();
  }

  // Cargar todos los datos de la tarea
  Future<void> cargarTarea(int tareaId) async {
    try {
      cargando.value = true;

      // 1. Cargar datos básicos de la tarea
      final resultadoTarea = await _tareaService.obtenerTareaPorId(tareaId);

      if (resultadoTarea.status == 200 && resultadoTarea.body is Tarea) {
        tarea.value = resultadoTarea.body;

        // Formatear fechas

        if (tarea.value != null) {
          // Cargar la categoría de la tarea
          final resultadoCategoria = await _categoriaService
              .obtenerCategoriaPorTareaId(tarea.value!.categoriaId);
          if (resultadoCategoria.status == 200 &&
              resultadoCategoria.body is Categoria) {
            categoria.value = resultadoCategoria.body;
          }

          // Cargar la lista de la tarea
          final resultadoLista = await _listaService.obtenerListaPorId(
            tarea.value!.listaId!,
          );
          if (resultadoLista.status == 200 && resultadoLista.body is Lista) {
            lista.value = resultadoLista.body;
          }
        }

        // 2. Cargar etiquetas de la tarea
        final resultadoEtiquetas = await _etiquetaService
            .obtenerEtiquetasDeTarea(tareaId);

        // Verificar si el resultado es una lista de etiquetas
        print('Resultado etiquetas: ${resultadoEtiquetas.body}');
        if (resultadoEtiquetas.status == 200 &&
            resultadoEtiquetas.body is List) {
          // Directamente asignar la lista de Etiqueta objetos
          List<Etiqueta> listaEtiquetas = resultadoEtiquetas.body;
          etiquetas.assignAll(listaEtiquetas);
        } else if (resultadoEtiquetas.status == 404) {
          // Lista vacía en caso de no encontrar etiquetas
          etiquetas.clear();
        } else {
          Get.snackbar(
            'Error',
            'No se pudieron cargar las etiquetas',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }

        //Cargar la prioridad de la tarea
        final resultadoPrioridad = await _prioridadService
            .obtenerPrioridadPorId(tarea.value!.prioridadId);
        if (resultadoPrioridad.status == 200 &&
            resultadoPrioridad.body is Prioridad) {
          priori.value = resultadoPrioridad.body;
        }
      } else {
        Get.snackbar(
          'Error',
          'No se pudo cargar la tarea',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        // Volver atrás si no se puede cargar la tarea
        Get.back();
      }
    } catch (e) {
      print('Error al cargar tarea: $e');
      Get.snackbar(
        'Error',
        'No se pudo cargar la información de la tarea',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Volver atrás en caso de error
      Get.back();
    } finally {
      cargando.value = false;
    }
  }

  void actualizarTextoFechaHora() {
    // Formato de fecha de creación
    fechaCreacionText.value = DateFormat(
      'dd/MM/yyyy',
    ).format(fechaCreacion.value);

    // Formato de hora de creación
    final horaC = horaCreacion.value.hour.toString().padLeft(2, '0');
    final minutoC = horaCreacion.value.minute.toString().padLeft(2, '0');
    horaCreacionText.value = '$horaC:$minutoC';

    // Formato de hora de vencimiento
    final horaV = horaVencimiento.value.hour.toString().padLeft(2, '0');
    final minutoV = horaVencimiento.value.minute.toString().padLeft(2, '0');
    horaVencimientoText.value = '$horaV:$minutoV';
  }

  Future<void> cargarDatos() async {
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

  // Método para seleccionar la hora de vencimiento
  Future<void> seleccionarHoraVencimiento() async {
    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: Get.context!,
      initialTime: horaVencimiento.value,
    );

    if (horaSeleccionada != null) {
      // Validar que la hora seleccionada no sea antes de la hora de creación
      int horaSeleccionadaMinutos =
          horaSeleccionada.hour * 60 + horaSeleccionada.minute;
      int horaCreacionMinutos =
          horaCreacion.value.hour * 60 + horaCreacion.value.minute;

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

      horaVencimiento.value = horaSeleccionada;
      actualizarTextoFechaHora();
    }
  }

  // Métodos para fecha y hora de creación
  Future<void> seleccionarFechaCreacion() async {
    final DateTime ahora = DateTime.now();
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: Get.context!,
      initialDate:
          fechaCreacion.value.isBefore(ahora) ? ahora : fechaCreacion.value,
      firstDate: ahora, // Prohibir fechas antes de la fecha actual
      lastDate: DateTime(2100),
    );

    if (fechaSeleccionada != null) {
      fechaCreacion.value = fechaSeleccionada;
      actualizarTextoFechaHora();
    }
  }

  Future<void> seleccionarHoraCreacion() async {
    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: Get.context!,
      initialTime: horaCreacion.value,
    );

    if (horaSeleccionada != null) {
      horaCreacion.value = horaSeleccionada;

      // Si la hora de vencimiento es anterior a la nueva hora de creación,
      // actualizamos la hora de vencimiento para que sea igual a la de creación
      int horaVencimientoMinutos =
          horaVencimiento.value.hour * 60 + horaVencimiento.value.minute;
      int nuevaHoraCreacionMinutos =
          horaSeleccionada.hour * 60 + horaSeleccionada.minute;

      if (horaVencimientoMinutos < nuevaHoraCreacionMinutos) {
        horaVencimiento.value = horaSeleccionada;
      }

      actualizarTextoFechaHora();
    }
  }

  // Obtener fecha/hora completa de vencimiento
  DateTime obtenerFechaHoraVencimientoCompleta() {
    return DateTime(
      fechaCreacion.value.year, // Usa la misma fecha que la de creación
      fechaCreacion.value.month,
      fechaCreacion.value.day,
      horaVencimiento.value.hour, // Solo la hora puede ser diferente
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

  void eliminarEtiqueta(Etiqueta etiqueta) {
    etiquetasSeleccionadas.remove(etiqueta);
  }

  Future<void> actualizarTarea() async {
    if (tarea.value == null) {
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

      // Actualizar la tarea
      final resultadoTarea = await _tareaService.actualizarTarea(
        id: tarea.value!.id!,
        usuarioId: usuario.id!,
        listaId: listaSeleccionada.value!.id!,
        titulo: tituloController.text,
        descripcion: descripcionController.text,
        fechaCreacion: fechaCreacionFormateada,
        fechaVencimiento: fechaVencimientoFormateada,
        categoriaId: categoriaSeleccionada.value!.id!,
        estadoId: tarea.value!.estadoId, // Mantener el estado actual
        prioridadId: prioridadSeleccionada.value!.id!,
      );

      if (resultadoTarea.status != 200 || !(resultadoTarea.body is Tarea)) {
        throw Exception('No se pudo actualizar la tarea');
      }

      final Tarea tareaActualizada = resultadoTarea.body;

      // Eliminar todas las etiquetas actuales de la tarea
      for (var tareaEtiqueta in etiquetas) {
        if (tareaEtiqueta.id != null) {
          await _tareaService.eliminarTareaEtiqueta(tareaEtiqueta.id!);
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

      // Recargar datos
      EventosControlador.solicitarRecarga();

      // Return updated task data to previous screen
      Get.back(result: true);
    } catch (e, stackTrace) {
      print('Error al actualizar la tarea: $e');
      print('Stack trace: $stackTrace');
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
