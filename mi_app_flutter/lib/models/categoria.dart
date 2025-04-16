import 'dart:convert';

class Categoria {
  final int? id;
  final String nombre;
  final String color;

  Categoria({
    this.id,
    required this.nombre,
    required this.color,
  });

  // Factory para crear desde un mapa (JSON)
  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nombre: map['nombre'],
      color: map['color'],
    );
  }

  // Método para convertir a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
    };
  }

  // Método para crear una copia del objeto con algunos cambios
  Categoria copyWith({
    int? id,
    String? nombre,
    String? color,
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
    );
  }

  // Método para convertir a JSON
  String toJson() => json.encode(toMap());

  // Factory para crear desde JSON
  factory Categoria.fromJson(String source) => Categoria.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Categoria(id: $id, nombre: $nombre, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Categoria &&
        other.id == id &&
        other.nombre == nombre &&
        other.color == color;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nombre.hashCode ^
        color.hashCode;
  }
}