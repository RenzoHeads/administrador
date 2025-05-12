class Tarea {
  int? id;
  final String titulo;
  final String descripcion;
  final DateTime fechaCreacion;
  final DateTime fechaVencimiento;
  final int prioridadId;
  final int estadoId;
  final int categoriaId;
  final int usuarioId;
  final int? listaId;

  Tarea({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaCreacion,
    required this.fechaVencimiento,
    required this.prioridadId,
    required this.estadoId,
    required this.categoriaId,
    required this.usuarioId,
    this.listaId,
  });

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: parseNullableInt(map['id']),
      titulo: map['titulo']?.toString() ?? 'Sin título',
      descripcion: map['descripcion']?.toString() ?? '',
      fechaCreacion: parseDateTime(map['fecha_creacion']),
      fechaVencimiento: parseDateTime(map['fecha_vencimiento']),
      prioridadId: parseInt(map['prioridad_id'], defaultValue: 1),
      estadoId: parseInt(map['estado_id'], defaultValue: 1),
      categoriaId: parseInt(map['categoria_id'], defaultValue: 1),
      usuarioId: parseInt(map['usuario_id'], defaultValue: 0),
      listaId: parseNullableInt(map['lista_id']),
    );
  }

  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    try {
      return int.parse(value.toString());
    } catch (_) {
      return defaultValue;
    }
  }

  static int? parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    try {
      return int.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  static DateTime parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento.toIso8601String(),
      'prioridad_id': prioridadId,
      'estado_id': estadoId,
      'categoria_id': categoriaId,
      'usuario_id': usuarioId,
      'lista_id': listaId,
    };
  }

  Tarea copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    DateTime? fechaCreacion,
    DateTime? fechaVencimiento,
    int? prioridadId,
    int? estadoId,
    int? categoriaId,
    int? usuarioId,
    int? listaId,
  }) {
    return Tarea(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      prioridadId: prioridadId ?? this.prioridadId,
      estadoId: estadoId ?? this.estadoId,
      categoriaId: categoriaId ?? this.categoriaId,
      usuarioId: usuarioId ?? this.usuarioId,
      listaId: listaId ?? this.listaId,
    );
  }
}
