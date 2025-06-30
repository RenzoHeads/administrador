// tarea_item.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'tarea_detalle_modal.dart';
import 'ver_tarea_controller.dart';

/// Widget que representa un elemento individual de tarea en la lista
/// Muestra información básica de la tarea y permite interactuar con ella
class TareaItem extends StatelessWidget {
  final int tareaId;

  const TareaItem({required this.tareaId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inicializamos el controlador una sola vez con el ID de la tarea
    final controller = Get.put(
      VerTareaController(tareaId: tareaId),
      tag: 'tarea_$tareaId',
      permanent: true, // Mantiene el controlador en memoria
    );

    // Usamos GetBuilder con un ID específico para actualizaciones selectivas
    return GetBuilder<VerTareaController>(
      init: controller,
      tag: 'tarea_$tareaId',
      id: 'tarea_$tareaId', // ID único para actualización específica
      builder: (controller) {
        // Widget de carga mientras se obtienen los datos
        if (controller.cargando) {
          return _buildLoadingWidget();
        }

        // Si no hay tarea disponible, no mostrar nada
        if (controller.tarea == null) {
          return const SizedBox.shrink();
        }

        final tarea = controller.tarea!;
        final bool estaCompletada = tarea.estadoId == 2;
        final Color colorEstado = controller.obtenerColorEstado(tarea.estadoId);

        return _buildTareaCard(
          context,
          controller,
          tarea,
          estaCompletada,
          colorEstado,
        );
      },
    );
  }

  /// Widget de carga que se muestra mientras se obtienen los datos de la tarea
  Widget _buildLoadingWidget() {
    return Container(
      width: 350,
      height: 135,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  /// Método para obtener texto de fecha relativa local
  String _obtenerTextoFechaRelativa(DateTime fecha) {
    final DateTime ahora = DateTime.now().toLocal();
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final DateTime fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);
    final DateTime fechaLocal = fecha.toLocal();

    // Calcular diferencia en días
    final diferencia = fechaSinHora.difference(hoy).inDays;

    // Formatear hora
    final hora =
        '${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}';

    switch (diferencia) {
      case 0:
        return 'Hoy, $hora';
      case 1:
        return 'Mañana, $hora';
      case 2:
        return 'Pasado mañana, $hora';
      case -1:
        return 'Ayer, $hora';
      case -2:
        return 'Anteayer, $hora';
      default:
        // Para fechas más lejanas, mostrar en formato relativo
        if (diferencia > 0) {
          return 'En $diferencia días, $hora';
        } else {
          return 'Hace ${diferencia.abs()} días, $hora';
        }
    }
  }

  /// Tarjeta principal que contiene toda la información de la tarea
  /// Incluye checkbox, contenido y es clickeable para mostrar detalles
  Widget _buildTareaCard(
    BuildContext context,
    VerTareaController controller,
    dynamic tarea,
    bool estaCompletada,
    Color colorEstado,
  ) {
    return GestureDetector(
      onTap: () {
        // Mostrar el modal al hacer tap en el componente
        _mostrarDetalleModal(context, controller);
      },
      child: Container(
        width: 350,
        height: 135,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildCheckbox(controller, estaCompletada),
            _buildTareaContent(controller, tarea, estaCompletada, colorEstado),
          ],
        ),
      ),
    );
  }

  /// Checkbox circular interactivo que permite alternar el estado de la tarea
  /// Cambia entre pendiente (gris) y completada (verde con check)
  Widget _buildCheckbox(VerTareaController controller, bool estaCompletada) {
    return Container(
      margin: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: () {
          // Alternar entre pendiente (1) y completada (2)
          final nuevoEstadoId = estaCompletada ? 1 : 2;
          controller.cambiarEstadoTarea(nuevoEstadoId);
        },
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircleAvatar(
            backgroundColor: estaCompletada ? Colors.green : Colors.grey,
            child: Icon(
              Icons.check,
              size: 16,
              color: estaCompletada ? Colors.white : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  /// Contenido principal de la tarea que muestra título, descripción, fecha y estado
  /// Aplica efectos visuales según el estado de completado de la tarea
  Widget _buildTareaContent(
    VerTareaController controller,
    dynamic tarea,
    bool estaCompletada,
    Color colorEstado,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildTitulo(tarea, estaCompletada),
          const SizedBox(height: 4),
          _buildDescripcion(tarea, estaCompletada),
          const SizedBox(height: 4),
          _buildFecha(controller, tarea, estaCompletada),
          const SizedBox(height: 10),
          _buildIndicadorEstado(controller, colorEstado),
        ],
      ),
    );
  }

  /// Título de la tarea con estilo adaptativo según su estado
  /// Se tacha cuando la tarea está completada
  Widget _buildTitulo(dynamic tarea, bool estaCompletada) {
    return Text(
      tarea.titulo,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        decoration: estaCompletada ? TextDecoration.lineThrough : null,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Descripción de la tarea con texto secundario
  /// Se tacha cuando la tarea está completada
  Widget _buildDescripcion(dynamic tarea, bool estaCompletada) {
    return Text(
      tarea.descripcion,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
        decoration: estaCompletada ? TextDecoration.lineThrough : null,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Fecha de creación en formato relativo (ej: "hace 2 días")
  /// Se tacha cuando la tarea está completada
  Widget _buildFecha(
    VerTareaController controller,
    dynamic tarea,
    bool estaCompletada,
  ) {
    // Convertir la fecha de creación a hora local para mostrar correctamente
    final fechaCreacionLocal = tarea.fechaCreacion.toLocal();
    final textoFechaCreacion = _obtenerTextoFechaRelativa(fechaCreacionLocal);

    return Text(
      textoFechaCreacion,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[500],
        decoration: estaCompletada ? TextDecoration.lineThrough : null,
      ),
    );
  }

  /// Indicador visual del estado actual de la tarea
  /// No se tacha independientemente del estado de completado
  Widget _buildIndicadorEstado(
    VerTareaController controller,
    Color colorEstado,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorEstado.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        controller.obtenerNombreEstado(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorEstado,
          // No se aplica tachado aquí
        ),
      ),
    );
  }

  /// Método auxiliar para mostrar el modal con los detalles completos de la tarea
  /// Maneja la presentación del modal con configuraciones específicas
  void _mostrarDetalleModal(
    BuildContext context,
    VerTareaController controller,
  ) {
    // Desenfocar el teclado antes de mostrar el modal
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => TareaDetalleModal(controller: controller),
    );
  }
}
