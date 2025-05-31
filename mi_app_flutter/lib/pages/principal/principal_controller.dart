import 'package:get/get.dart';
import '../../services/inicio_service.dart';
import '../../models/tarea.dart';
import '../../models/etiqueta.dart';
import '../../models/estado.dart';
import '../../models/categoria.dart';
import '../../models/prioridad.dart';
import '../../models/service_http_response.dart';
import '../../services/controladorsesion.dart';
import '../../models/lista.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/usuario_service.dart';

class PrincipalController extends GetxController {
  final InicioService _inicioService = InicioService();
  final ControladorSesionUsuario _sesionController =
      Get.find<ControladorSesionUsuario>();
  final UsuarioService _usuarioService = UsuarioService();

  // Getter público para acceder al controlador de sesión
  ControladorSesionUsuario get sesionController => _sesionController;

  // Variables observables para almacenar datos
  var tareas = <Tarea>[].obs;
  var listas = <Lista>[].obs;
  var etiquetasPorTarea = <Map<String, dynamic>>[].obs;
  var prioridades = <Prioridad>[].obs;
  var estados = <Estado>[].obs;
  var categorias = <Categoria>[].obs;

  // Estado de carga
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var datosCargados = false.obs;

  // Variables para la barra superior
  RxString profilePhotoUrl = RxString('');
  RxBool loadingPhoto = true.obs;
  RxInt currentPageIndex = 0.obs;

  // Títulos de las páginas
  final List<String> pageTitles = [
    'Principal',
    'Calendario',
    'Buscador',
    'Notificaciones',
  ];
  @override
  void onInit() {
    super.onInit();
    cargarDatosUsuario();
    cargarFotoPerfil();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        'Notificación recibida en primer plano: ${message.notification?.title}',
      );
      // Aquí puedes mostrar un alert, snackbar, etc.
    });
  }

  Future<void> cargarDatosUsuario() async {
    try {
      isLoading(true);
      hasError(false);
      datosCargados(false);

      final usuarioId = _sesionController.usuarioActual.value?.id;

      if (usuarioId != null) {
        final ServiceHttpResponse response = await _inicioService
            .fetchCompleteDatosUsuario(usuarioId);

        if (response.status == 200 && response.body is Map<String, dynamic>) {
          final data = response.body as Map<String, dynamic>;

          // Ya vienen como objetos
          tareas.value = data['tareas'] as List<Tarea>;
          etiquetasPorTarea.value =
              data['etiquetasPorTarea'] as List<Map<String, dynamic>>;

          // Listas vienen como datos JSON sin parsear, aquí hacemos la conversión correcta
          final listasData = data['listas'] as List<dynamic>;
          listas.value =
              listasData
                  .map(
                    (listaJson) =>
                        Lista.fromMap(listaJson as Map<String, dynamic>),
                  )
                  .toList();

          final datosReferencia =
              data['datosReferencia'] as Map<String, dynamic>;
          prioridades.value = datosReferencia['prioridades'] as List<Prioridad>;
          estados.value = datosReferencia['estados'] as List<Estado>;
          categorias.value = datosReferencia['categorias'] as List<Categoria>;

          print('Datos cargados correctamente');
          print('Tareas: ${tareas.length}');
          print('Listas: ${listas.length}');
          print('Etiquetas por tarea: ${etiquetasPorTarea.length}');
          print('Prioridades: ${prioridades.length}');

          // Marcar que los datos están cargados
          datosCargados(true);
        } else {
          hasError(true);
          if (response.body is Map<String, dynamic> &&
              (response.body as Map<String, dynamic>).containsKey('message')) {
            errorMessage(
              (response.body as Map<String, dynamic>)['message'].toString(),
            );
          } else {
            errorMessage('Error en la respuesta del servidor');
          }
        }
      } else {
        hasError(true);
        errorMessage('No se ha identificado un usuario válido');
      }
    } catch (e) {
      hasError(true);
      errorMessage('Error al cargar datos: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // Método para refrescar los datos
  Future<void> refreshData() async {
    await cargarDatosUsuario();
  }

  // Métodos para obtener datos específicos
  Future<List<Tarea>> getTareasUsuario() async {
    return tareas;
  }

  Future<List<Etiqueta>> getEtiquetasPorTarea(int tareaId) async {
    final etiquetasMap = etiquetasPorTarea.firstWhereOrNull(
      (element) => element['tarea_id'] == tareaId,
    );

    if (etiquetasMap == null) {
      return [];
    }

    return (etiquetasMap['etiquetas'] as List<dynamic>).cast<Etiqueta>();
  }

  // Métodos para datos de referencia
  Future<Estado?> getEstadoPorId(int estadoId) async {
    return estados.firstWhereOrNull((estado) => estado.id == estadoId);
  }

  Future<Categoria?> getCategoriaPorId(int categoriaId) async {
    return categorias.firstWhereOrNull(
      (categoria) => categoria.id == categoriaId,
    );
  }

  Future<Prioridad?> getPrioridadPorId(int prioridadId) async {
    return prioridades.firstWhereOrNull(
      (prioridad) => prioridad.id == prioridadId,
    );
  }

  Future<void> EliminarTarea(int tareaId) async {
    tareas.removeWhere((tarea) => tarea.id == tareaId);
  }

  Future<void> AgregarTarea(Tarea tarea) async {
    tareas.add(tarea);
  }

  Future<void> EditarTarea(Tarea tarea) async {
    int index = tareas.indexWhere((t) => t.id == tarea.id);
    if (index != -1) {
      tareas[index] = tarea;
    }
  }

  Future<void> ActualizarEtiquetasPorTarea(
    int tareaId,
    List<Etiqueta> etiquetas,
  ) async {
    etiquetasPorTarea.removeWhere((element) => element['tarea_id'] == tareaId);
    etiquetasPorTarea.add({'tarea_id': tareaId, 'etiquetas': etiquetas});
  }

  Future<void> AgregarEtiquetasPorTarea(
    int tareaId,
    List<Etiqueta> etiquetas,
  ) async {
    etiquetasPorTarea.add({'tarea_id': tareaId, 'etiquetas': etiquetas});
  }

  Future<void> EliminarTareasPorLista(int listaId) async {
    tareas.removeWhere((tarea) => tarea.listaId == listaId);
  }

  Future<void> EliminarLista(int listaId) async {
    listas.removeWhere((lista) => lista.id == listaId);
  }

  Future<void> AgregarLista(Lista lista) async {
    listas.add(lista);
  }

  Future<void> EditarLista(Lista lista) async {
    int index = listas.indexWhere((l) => l.id == lista.id);
    if (index != -1) {
      listas[index] = lista;
    }
  }

  Future<int> ObtenerTareasPorLista(int listaId) async {
    return tareas.where((tarea) => tarea.listaId == listaId).length;
  }

  Future<int> ObtenerTareasPendientesPorLista(int listaId) async {
    return tareas
        .where((tarea) => tarea.listaId == listaId && tarea.estadoId == 1)
        .length;
  }

  Future<List<Lista>> ObtenerListaUsuario() async {
    return listas;
  }

  Future<Map<String, dynamic>?> ObtenerListaConTareas(int listaId) async {
    final lista = listas.firstWhereOrNull((l) => l.id == listaId);

    if (lista == null) {
      return null;
    }

    final tareasDeLista = tareas.where((t) => t.listaId == listaId).toList();

    return {'lista': lista, 'tareas': tareasDeLista};
  }

  Future<List<Categoria>> ObtenerCategoriasUsuario() async {
    return categorias;
  }

  Future<List<Estado>> ObtenerEstadosUsuario() async {
    return estados;
  }

  Future<List<Prioridad>> ObtenerPrioridadesUsuario() async {
    return prioridades;
  }

  Future<Tarea> ObtenerTareaPorId(int tareaId) async {
    return tareas.firstWhereOrNull((tarea) => tarea.id == tareaId)!;
  }

  Future<String> ObtenerNombreEstadoPorId(int estadoId) async {
    return estados
            .firstWhereOrNull((estado) => estado.id == estadoId)
            ?.nombre ??
        '';
  }

  Future<String> obtenerNombreEstadoPorTareaId(int tareaId) async {
    final tarea = await ObtenerTareaPorId(tareaId);
    return ObtenerNombreEstadoPorId(tarea.estadoId);
  }

  Future<List<Tarea>> ObtenerTareasUsuario() async {
    return tareas;
  }

  // Método para cambiar el índice de la página actual
  void cambiarPagina(int index) {
    currentPageIndex.value = index;
  }

  // Método para obtener el título de la página actual
  String get tituloActual =>
      pageTitles[currentPageIndex
          .value]; // Métodos para manejar la foto de perfil
  Future<void> cargarFotoPerfil() async {
    final usuario = _sesionController.usuarioActual.value;
    if (usuario != null && usuario.id != null) {
      try {
        loadingPhoto.value = true;
        profilePhotoUrl.value = '';

        if (usuario.foto != null && usuario.foto!.isNotEmpty) {
          profilePhotoUrl.value = usuario.foto!;
          print(
            'Foto de perfil cargada desde sesión: ${profilePhotoUrl.value}',
          );
        } else {
          print(
            'No hay foto de perfil en la sesión, cargando desde servidor...',
          );
          final response = await _usuarioService.getProfilePhotoUrl(
            usuario.id!,
          );

          if (response != null &&
              response.status == 200 &&
              response.body != null) {
            final fotoData = response.body as Map<String, dynamic>;
            final nuevaUrl = fotoData['url_foto'] ?? '';

            if (nuevaUrl.isNotEmpty) {
              profilePhotoUrl.value = nuevaUrl;
              print('Foto de perfil cargada desde servidor: $nuevaUrl');
            } else {
              print('No se encontró foto de perfil en el servidor');
            }
          }
        }
      } catch (e) {
        print('Error al cargar foto de perfil: $e');
      } finally {
        loadingPhoto.value = false;
      }
    }
  }

  Future<void> forzarRecargaFoto() async {
    loadingPhoto.value = true;
    profilePhotoUrl.value = '';
    await cargarFotoPerfil();
  }

  //Verificar si hay tareas en una lista por su id , eliminar las tareas de esa lista y la lista tambien
  Future<bool> verificarYEliminarListaConTareas(int listaId) async {
    final tareasEnLista = tareas.where((t) => t.listaId == listaId).toList();
    if (tareasEnLista.isNotEmpty) {
      // Eliminar las tareas de la lista
      tareas.removeWhere((t) => t.listaId == listaId);
      // Eliminar la lista
      listas.removeWhere((l) => l.id == listaId);
      return true;
    }
    return false;
  }

  // Método para cerrar la sesión
  void cerrarSesionCompleta() {
    _sesionController.cerrarSesion();
    Get.offAllNamed('/sign-in');
  }
}
