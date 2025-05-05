import 'dart:convert';

class Lista {
  final int? id;
  final int usuarioId;
  final String nombre;
  final String descripcion;
  final String color;

  Lista({
    this.id,
    required this.usuarioId,
    required this.nombre,
    required this.descripcion,
    required this.color,
  });

  // Factory para crear desde un mapa (JSON)
  factory Lista.fromMap(Map<String, dynamic> map) {
    return Lista(
      id: map['id'],
      usuarioId: map['usuario_id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      color: map['color'],
    );
  }

  // Método para convertir a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nombre': nombre,
      'descripcion': descripcion,
      'color': color,
    };
  }

  // Método para crear una copia del objeto con algunos cambios
  Lista copyWith({
    int? id,
    int? usuarioId,
    String? nombre,
    String? descripcion,
    String? color,
  }) {
    return Lista(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      color: color ?? this.color,
    );
  }

  // Método para convertir a JSON
  String toJson() => json.encode(toMap());

  // Factory para crear desde JSON
  factory Lista.fromJson(String source) => Lista.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Lista(id: $id, usuarioId: $usuarioId, nombre: $nombre, descripcion: $descripcion, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lista &&
        other.id == id &&
        other.usuarioId == usuarioId &&
        other.nombre == nombre &&
        other.descripcion == descripcion &&
        other.color == color;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        usuarioId.hashCode ^
        nombre.hashCode ^
        descripcion.hashCode ^
        color.hashCode;
  }
}
