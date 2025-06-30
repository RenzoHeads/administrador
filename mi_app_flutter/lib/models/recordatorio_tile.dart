import 'package:flutter/material.dart';
import '../../models/recordatorio.dart'; // Ajusta la ruta si es necesario

class RecordatorioTile extends StatelessWidget {
  final Recordatorio recordatorio;

  const RecordatorioTile({Key? key, required this.recordatorio})
    : super(key: key);

  /// Método para obtener texto de fecha relativa local
  String _obtenerTextoFechaRelativa(DateTime fecha) {
    final DateTime ahora = DateTime.now().toLocal();
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final DateTime fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);
    final DateTime fechaLocal = fecha.toLocal();

    // Calcular diferencia en días
    final diferencia = fechaSinHora.difference(hoy).inDays;

    // Formatear hora
    final hora =
        '${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}';

    switch (diferencia) {
      case 0:
        return 'Hoy, $hora';
      case 1:
        return 'Mañana, $hora';
      case 2:
        return 'Pasado mañana, $hora';
      case -1:
        return 'Ayer, $hora';
      case -2:
        return 'Anteayer, $hora';
      default:
        // Para fechas más lejanas, mostrar en formato relativo
        if (diferencia > 0) {
          return 'En $diferencia días, $hora';
        } else {
          return 'Hace ${diferencia.abs()} días, $hora';
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Convierte la fecha recibida a la zona local del dispositivo
    final localDate = recordatorio.fechaHora.toLocal();

    // Usar el mismo formato relativo que TareaItem
    final fechaTexto = _obtenerTextoFechaRelativa(localDate);

    // Formatea solo la hora para el lado derecho
    final horaTexto = TimeOfDay.fromDateTime(localDate).format(context);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(Icons.notifications_active, color: Colors.green),
        title: Text(recordatorio.mensaje ?? 'Sin descripción'),
        subtitle: Text(fechaTexto),
        trailing: Text(
          horaTexto,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
