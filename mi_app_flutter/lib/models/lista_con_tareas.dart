import 'lista.dart';
import 'tarea.dart';

class ListaConTareas {
  final Lista lista;
  final List<Tarea> tareas;

  ListaConTareas({required this.lista, required this.tareas});

  factory ListaConTareas.fromMap(Map<String, dynamic> map) {
    // Extraer los datos de la lista desde el mismo nivel del mapa
    final listaMap = Map<String, dynamic>.from(map);
    listaMap.remove(
      'tareas',
    ); // Eliminar tareas para que solo queden los datos de la lista
    return ListaConTareas(
      lista: Lista.fromMap(listaMap),
      tareas:
          (map['tareas'] as List<dynamic>? ?? [])
              .map((e) => Tarea.fromMap(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lista': lista.toMap(),
      'tareas': tareas.map((e) => e.toJson()).toList(),
    };
  }
}
