import 'dart:convert';
import 'enums.dart';


// Clase Tarea
class Tarea {
  int? id;
  final String titulo;
  final String descripcion;
  final DateTime fechaCreacion;
  final DateTime fechaVencimiento;
  final Prioridad prioridad;
  final Estado estado;
  final int categoriaId;
  final int usuarioId;
  final int? listaId;  // Añadido campo lista_id que estaba faltando

  Tarea({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaCreacion,
    required this.fechaVencimiento,
    required this.prioridad,
    required this.estado,
    required this.categoriaId,
    required this.usuarioId,
    this.listaId,  // Opcional ya que podría ser null
  });

  @override
  String toString() {
    return 'Tarea{id: $id, titulo: $titulo, fechaVencimiento: $fechaVencimiento, prioridad: $prioridad, estado: $estado, listaId: $listaId}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento.toIso8601String(),
      'prioridad': prioridad.toString().split('.').last,
      'estado': estado.toString().split('.').last,
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
      prioridad: _mapStringToPrioridad(map['prioridad']),
      estado: _mapStringToEstado(map['estado']),
      categoriaId: map['categoria_id'] ?? map['categoriaId'],
      usuarioId: map['usuario_id'] ?? map['usuarioId'],
      listaId: map['lista_id'] ?? map['listaId'],
    );
  }
  
  factory Tarea.fromJson(String jsonString) {
    Map<String, dynamic> map = json.decode(jsonString);
    return Tarea.fromMap(map);
  }

  // Métodos auxiliares para mapear strings a enums
  static Prioridad _mapStringToPrioridad(String? value) {
    if (value == null) return Prioridad.MEDIA; // Valor por defecto
    
    try {
      return Prioridad.values.firstWhere(
        (e) => e.toString().split('.').last == value,
      );
    } catch (e) {
      return Prioridad.MEDIA; // Valor por defecto si hay error
    }
  }

  static Estado _mapStringToEstado(String? value) {
    if (value == null) return Estado.PENDIENTE; // Valor por defecto
    
    try {
      return Estado.values.firstWhere(
        (e) => e.toString().split('.').last == value,
      );
    } catch (e) {
      return Estado.PENDIENTE; // Valor por defecto si hay error
    }
  }

  // Método para crear una copia con algunas propiedades modificadas
  Tarea copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    DateTime? fechaCreacion,
    DateTime? fechaVencimiento,
    Prioridad? prioridad,
    Estado? estado,
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
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      categoriaId: categoriaId ?? this.categoriaId,
      usuarioId: usuarioId ?? this.usuarioId,
      listaId: listaId ?? this.listaId,
    );
  }
}