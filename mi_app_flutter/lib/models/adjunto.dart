
import 'dart:convert';
import 'enums.dart';


class Adjunto {
  final int? id;
  final int tareaId;
  final String nombre;
  final String ruta;
  final TipoArchivo tipo;
  final String? url; // Campo opcional para la URL SAS

  Adjunto({
    this.id,
    required this.tareaId,
    required this.nombre,
    required this.ruta,
    required this.tipo,
    this.url,
  });

  // Factory para crear desde un mapa (JSON)
  factory Adjunto.fromMap(Map<String, dynamic> map) {
    return Adjunto(
      id: map['id'],
      tareaId: map['tarea_id'],
      nombre: map['nombre'],
      ruta: map['ruta'],
      tipo: _tipoArchivoFromString(map['tipo']),
      url: map['url'],
    );
  }

  // Método para convertir a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tarea_id': tareaId,
      'nombre': nombre,
      'ruta': ruta,
      'tipo': tipo.toString().split('.').last,
      'url': url,
    };
  }

  // Método para crear una copia del objeto con algunos cambios
  Adjunto copyWith({
    int? id,
    int? tareaId,
    String? nombre,
    String? ruta,
    TipoArchivo? tipo,
    String? url,
  }) {
    return Adjunto(
      id: id ?? this.id,
      tareaId: tareaId ?? this.tareaId,
      nombre: nombre ?? this.nombre,
      ruta: ruta ?? this.ruta,
      tipo: tipo ?? this.tipo,
      url: url ?? this.url,
    );
  }

  // Método para convertir a JSON
  String toJson() => json.encode(toMap());

  // Factory para crear desde JSON
  factory Adjunto.fromJson(String source) => Adjunto.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Adjunto(id: $id, tareaId: $tareaId, nombre: $nombre, ruta: $ruta, tipo: $tipo, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Adjunto &&
        other.id == id &&
        other.tareaId == tareaId &&
        other.nombre == nombre &&
        other.ruta == ruta &&
        other.tipo == tipo &&
        other.url == url;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tareaId.hashCode ^
        nombre.hashCode ^
        ruta.hashCode ^
        tipo.hashCode ^
        url.hashCode;
  }

  // Método auxiliar para convertir de string a enum TipoArchivo
  static TipoArchivo _tipoArchivoFromString(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'IMAGEN':
        return TipoArchivo.IMAGEN;
      case 'DOCUMENTO':
        return TipoArchivo.DOCUMENTO;
      case 'AUDIO':
        return TipoArchivo.AUDIO;
      case 'VIDEO':
        return TipoArchivo.VIDEO;
      default:
        return TipoArchivo.OTRO;
    }
  }
}