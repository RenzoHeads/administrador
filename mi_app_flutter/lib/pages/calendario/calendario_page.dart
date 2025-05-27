import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import './calendario_controller_page.dart';

class CalendarioPage extends StatelessWidget {
  final CalendarioController controller = Get.put(CalendarioController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            return Text(
                              DateFormat.yMMMM(
                                'es_ES',
                              ).format(controller.focusedDay.value),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: controller.previousMonth,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: controller.nextMonth,
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => TableCalendar(
                      locale: 'es_ES',
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2100),
                      focusedDay: controller.focusedDay.value,
                      selectedDayPredicate:
                          (day) => isSameDay(controller.selectedDay.value, day),
                      onDaySelected: controller.onDaySelected,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      daysOfWeekHeight: 24,
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                        weekendStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      headerVisible: false,
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.green[100],
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        outsideDaysVisible: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final wd = DateFormat.EEEE(
                'es_ES',
              ).format(controller.selectedDay.value);
              final dia = DateFormat(
                'd MMMM, yyyy',
                'es_ES',
              ).format(controller.selectedDay.value);
              final diaCapitalizado =
                  '${wd[0].toUpperCase()}${wd.substring(1)}';

              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$diaCapitalizado $dia',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Obx(() {
              final tareas = controller.tareasDelDia;
              if (tareas.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.toNamed(
                          '/crear-tarea',
                          arguments: controller.selectedDay.value,
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                        size: 28,
                      ),
                      label: const Text(
                        'Agregar tarea',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (_, i) {
                      final t = tareas[i];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.green[50],
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.green,
                          ),
                          title: Text(t.titulo),
                          subtitle: Text(
                            t.descripcion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            DateFormat('HH:mm').format(t.fechaVencimiento),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
