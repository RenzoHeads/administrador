import 'dart:convert';

class Estado {
  final int? id;
  final String nombre;

  Estado({this.id, required this.nombre});

  // Factory para crear desde un mapa (JSON)
  factory Estado.fromMap(Map<String, dynamic> map) {
    return Estado(id: map['id'], nombre: map['nombre']);
  }

  // Método para convertir a mapa
  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre};
  }

  // Método para crear una copia del objeto con algunos cambios
  Estado copyWith({int? id, String? nombre}) {
    return Estado(id: id ?? this.id, nombre: nombre ?? this.nombre);
  }

  // Método para convertir a JSON
  String toJson() => json.encode(toMap());

  // Factory para crear desde JSON
  factory Estado.fromJson(String source) => Estado.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Estado(id: $id, nombre: $nombre)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Estado && other.id == id && other.nombre == nombre;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nombre.hashCode;
  }
}
