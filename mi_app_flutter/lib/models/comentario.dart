import 'dart:convert';

class Comentario {
  final int? id;
  final int tareaId;
  final String texto;
  final DateTime fechaCreacion;

  Comentario({
    this.id,
    required this.tareaId,
    required this.texto,
    DateTime? fechaCreacion,
  }) : this.fechaCreacion = fechaCreacion ?? DateTime.now();

  // Factory para crear desde un mapa (JSON)
  factory Comentario.fromMap(Map<String, dynamic> map) {
    return Comentario(
      id: map['id'],
      tareaId: map['tarea_id'],
      texto: map['texto'],
      fechaCreacion:
          map['fecha_creacion'] != null
              ? DateTime.parse(map['fecha_creacion'])
              : DateTime.now(),
    );
  }

  // Método para convertir a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tarea_id': tareaId,
      'texto': texto,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  // Método para crear una copia del objeto con algunos cambios
  Comentario copyWith({
    int? id,
    int? tareaId,
    String? texto,
    DateTime? fechaCreacion,
  }) {
    return Comentario(
      id: id ?? this.id,
      tareaId: tareaId ?? this.tareaId,
      texto: texto ?? this.texto,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  // Método para convertir a JSON
  String toJson() => json.encode(toMap());

  // Factory para crear desde JSON
  factory Comentario.fromJson(String source) =>
      Comentario.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Comentario(id: $id, tareaId: $tareaId, texto: $texto, fechaCreacion: $fechaCreacion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comentario &&
        other.id == id &&
        other.tareaId == tareaId &&
        other.texto == texto &&
        other.fechaCreacion == fechaCreacion;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tareaId.hashCode ^
        texto.hashCode ^
        fechaCreacion.hashCode;
  }
}
