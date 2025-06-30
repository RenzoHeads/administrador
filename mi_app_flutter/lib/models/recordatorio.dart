import 'dart:convert';

class Recordatorio {
  final int? id;
  final int tareaId;
  final DateTime fechaHora;
  final String? tokenFCM;
  final String? mensaje;
  final bool activado;

  Recordatorio({
    this.id,
    required this.tareaId,
    required this.fechaHora,
    this.tokenFCM,
    this.mensaje,
    this.activado = true,
  });

  // Factory para crear desde un mapa (JSON)
  factory Recordatorio.fromMap(Map<String, dynamic> map) {
    return Recordatorio(
      id: map['id'],
      tareaId: map['tarea_id'],
      fechaHora:
          map['fecha_hora'] != null
              ? DateTime.parse(map['fecha_hora'])
              : DateTime.now(),
      tokenFCM: map['token_fcm'],
      mensaje: map['mensaje'],
      activado: map['activado'] ?? true,
    );
  }

  // Método para convertir a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tarea_id': tareaId,
      'fecha_hora': fechaHora.toIso8601String(),
      'token_fcm': tokenFCM,
      'mensaje': mensaje,
      'activado': activado,
    };
  }

  // Método para crear una copia del objeto con algunos cambios
  Recordatorio copyWith({
    int? id,
    int? tareaId,
    DateTime? fechaHora,
    String? tokenFCM,
    String? mensaje,
    bool? activado,
  }) {
    return Recordatorio(
      id: id ?? this.id,
      tareaId: tareaId ?? this.tareaId,
      fechaHora: fechaHora ?? this.fechaHora,
      tokenFCM: tokenFCM ?? this.tokenFCM,
      mensaje: mensaje ?? this.mensaje,
      activado: activado ?? this.activado,
    );
  }

  // Método para convertir a JSON
  String toJson() => json.encode(toMap());

  // Factory para crear desde JSON
  factory Recordatorio.fromJson(String source) =>
      Recordatorio.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Recordatorio(id: $id, tareaId: $tareaId, fechaHora: $fechaHora, tokenFCM: $tokenFCM, mensaje: $mensaje, activado: $activado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recordatorio &&
        other.id == id &&
        other.tareaId == tareaId &&
        other.fechaHora == fechaHora &&
        other.tokenFCM == tokenFCM &&
        other.mensaje == mensaje &&
        other.activado == activado;
  }
}
