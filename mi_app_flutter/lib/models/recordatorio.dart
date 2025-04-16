import 'dart:convert';

class Recordatorio {
  final int? id;
  final int tareaId;
  final DateTime fechaHora;

  Recordatorio({
    this.id,
    required this.tareaId,
    required this.fechaHora,
  });

  // Factory para crear desde un mapa (JSON)
  factory Recordatorio.fromMap(Map<String, dynamic> map) {
    return Recordatorio(
      id: map['id'],
      tareaId: map['tarea_id'],
      fechaHora: map['fecha_hora'] != null 
          ? DateTime.parse(map['fecha_hora']) 
          : DateTime.now(),
    );
  }

  // Método para convertir a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tarea_id': tareaId,
      'fecha_hora': fechaHora.toIso8601String(),
    };
  }

  // Método para crear una copia del objeto con algunos cambios
  Recordatorio copyWith({
    int? id,
    int? tareaId,
    DateTime? fechaHora,
  }) {
    return Recordatorio(
      id: id ?? this.id,
      tareaId: tareaId ?? this.tareaId,
      fechaHora: fechaHora ?? this.fechaHora,
    );
  }

  // Método para convertir a JSON
  String toJson() => json.encode(toMap());

  // Factory para crear desde JSON
  factory Recordatorio.fromJson(String source) => Recordatorio.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Recordatorio(id: $id, tareaId: $tareaId, fechaHora: $fechaHora)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recordatorio &&
        other.id == id &&
        other.tareaId == tareaId &&
        other.fechaHora == fechaHora;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tareaId.hashCode ^
        fechaHora.hashCode;
  }
}