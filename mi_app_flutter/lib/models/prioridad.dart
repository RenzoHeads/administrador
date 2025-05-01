import 'dart:convert';

class Prioridad {
    final int? id;
    final String nombre;

    Prioridad({
        this.id,
        required this.nombre,
    });

    // Factory para crear desde un mapa (JSON)
    factory Prioridad.fromMap(Map<String, dynamic> map) {
        return Prioridad(
            id: map['id'],
            nombre: map['nombre'],
        );
    }

    // Método para convertir a mapa
    Map<String, dynamic> toMap() {
        return {
            'id': id,
            'nombre': nombre,
        };
    }

    // Método para crear una copia del objeto con algunos cambios
    Prioridad copyWith({
        int? id,
        String? nombre,
    }) {
        return Prioridad(
            id: id ?? this.id,
            nombre: nombre ?? this.nombre,
        );
    }

    // Método para convertir a JSON
    String toJson() => json.encode(toMap());

    // Factory para crear desde JSON
    factory Prioridad.fromJson(String source) => Prioridad.fromMap(json.decode(source));

    @override
    String toString() {
        return 'Prioridad(id: $id, nombre: $nombre)';
    }

    @override
    bool operator ==(Object other) {
        if (identical(this, other)) return true;
        return other is Prioridad &&
                other.id == id &&
                other.nombre == nombre;
    }

    @override
    int get hashCode {
        return id.hashCode ^ nombre.hashCode;
    }
}