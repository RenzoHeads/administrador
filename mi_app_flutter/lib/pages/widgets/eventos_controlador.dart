import 'package:get/get.dart';

// Clase para manejar los eventos entre controladores
class EventosControlador {
  // Stream único para eventos de recarga
  static final RxString recargarDatosEvento = RxString('');

  // Stream para eventos específicos para controladores concretos (por ID)
  static final RxMap<String, bool> recargarControladorEvento =
      <String, bool>{}.obs;

  // Método para solicitar recarga general de datos
  static void solicitarRecarga() {
    // Enviamos la hora actual como string para forzar un cambio en el valor
    recargarDatosEvento.value = DateTime.now().toString();
  }

  // Método para solicitar recarga de un controlador específico
  static void solicitarRecargaControlador(String controladorId) {
    // Cambiamos el valor del mapa para indicar que se debe recargar
    recargarControladorEvento[controladorId] = true;
  }

  // Dispara un evento para recargar específicamente las listas
  static void recargarListas() {
    print('Solicitando recarga de todas las listas');
    solicitarRecargaControlador('listas');
  }

  // Método para limpiar todos los eventos
  static void limpiarEventos() {
    recargarControladorEvento.clear();
  }
}
