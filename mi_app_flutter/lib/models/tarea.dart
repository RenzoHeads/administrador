import 'dart:convert';

// Clase Tarea
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
    return 'Tarea{id: $id, titulo: $titulo,fechaCreacion: $fechaCreacion ,fechaVencimiento: $fechaVencimiento, prioridadId: $prioridadId, estadoId: $estadoId, listaId: $listaId}';
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
    return Tarea(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      fechaCreacion: DateTime.parse(map['fecha_creacion'] ?? map['fechaCreacion']),
      fechaVencimiento: DateTime.parse(map['fecha_vencimiento'] ?? map['fechaVencimiento']),
      prioridadId: map['prioridad_id'] ?? map['prioridadId'],
      estadoId: map['estado_id'] ?? map['estadoId'],
      categoriaId: map['categoria_id'] ?? map['categoriaId'],
      usuarioId: map['usuario_id'] ?? map['usuarioId'],
      listaId: map['lista_id'] ?? map['listaId'],
    );
  }
  
  factory Tarea.fromJson(String jsonString) {
    Map<String, dynamic> map = json.decode(jsonString);
    return Tarea.fromMap(map);
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
