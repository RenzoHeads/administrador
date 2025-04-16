import 'dart:convert';

class TareaEtiqueta {
  final int tareaId;
  final int etiquetaId;

  TareaEtiqueta({
    required this.tareaId,
    required this.etiquetaId,
  });

  Map<String, dynamic> toJson() {
    return {
      'tareaId': tareaId,
      'etiquetaId': etiquetaId,
    };
  }

  factory TareaEtiqueta.fromMap(Map<String, dynamic> map) {
    return TareaEtiqueta(
      tareaId: map['tareaId'],
      etiquetaId: map['etiquetaId'],
    );
  }
  
  factory TareaEtiqueta.fromJson(String jsonString) {
    Map<String, dynamic> map = json.decode(jsonString);
    return TareaEtiqueta.fromMap(map);
  }
}