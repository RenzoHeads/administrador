import 'dart:convert';

// Clase Tarea con manejo de valores nulos
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

  @override
  String toString() {
    return 'Tarea{id: $id, titulo: $titulo, fechaCreacion: $fechaCreacion, fechaVencimiento: $fechaVencimiento, prioridadId: $prioridadId, estadoId: $estadoId, listaId: $listaId}';
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

  factory Tarea.fromMap(Map<String, dynamic> map) {
    // Manejo seguro de los campos que podrían ser nulos
    return Tarea(
      id: map['id'] is int ? map['id'] : null,
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fechaCreacion: _parseDateTime(
        map['fecha_creacion'] ?? map['fechaCreacion'],
      ),
      fechaVencimiento: _parseDateTime(
        map['fecha_vencimiento'] ?? map['fechaVencimiento'],
      ),
      prioridadId: _parseInt(map['prioridad_id'] ?? map['prioridadId']),
      estadoId: _parseInt(map['estado_id'] ?? map['estadoId']),
      categoriaId: _parseInt(map['categoria_id'] ?? map['categoriaId']),
      usuarioId: _parseInt(map['usuario_id'] ?? map['usuarioId']),
      listaId:
          map['lista_id'] is int
              ? map['lista_id']
              : (map['listaId'] is int ? map['listaId'] : null),
    );
  }

  // Ayudante para parseo seguro de DateTime
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  // Ayudante para parseo seguro de int
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return 0;
    }
  }

  factory Tarea.fromJson(dynamic source) {
    if (source is String) {
      // Si es una cadena JSON, primero la convertimos a Map
      return Tarea.fromMap(json.decode(source));
    } else if (source is Map<String, dynamic>) {
      // Si ya es un Map, lo usamos directamente
      return Tarea.fromMap(source);
    } else {
      // Si no es ni String ni Map, lanzamos una excepción
      throw FormatException('Formato de datos no válido para Tarea: $source');
    }
  }

  // Método para crear una copia con algunas propiedades modificadas
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
