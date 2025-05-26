import 'package:flutter/material.dart';
import '../../models/recordatorio.dart';  // Ajusta la ruta si es necesario
import 'package:intl/intl.dart';

class RecordatorioTile extends StatelessWidget {
  final Recordatorio recordatorio;

  const RecordatorioTile({Key? key, required this.recordatorio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1️⃣ Convierte la fecha recibida a la zona local del dispositivo
    final localDate = recordatorio.fechaHora.toLocal();

    // 2️⃣ Formatea la fecha completa (día/mes/año y hora)
    final fechaTexto = DateFormat('dd/MM/yyyy, HH:mm').format(localDate);

    // 3️⃣ Formatea solo la hora para el lado derecho
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
