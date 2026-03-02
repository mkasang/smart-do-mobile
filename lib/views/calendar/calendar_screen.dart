import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_do/models/calendar_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:smart_do/controllers/calendar_controller.dart';
import 'package:smart_do/app/routes/app_routes.dart';
import 'package:smart_do/widgets/loading_widgets.dart';

class CalendarScreen extends GetView<CalendarController> {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.view_module_rounded),
            onPressed: controller.toggleFormat,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.calendarData.value == null) {
          return const ShimmerList();
        }

        return Column(
          children: [
            // Calendrier
            _buildCalendar(),

            // Liste des tâches du jour
            Expanded(child: _buildDailyTasks()),
          ],
        );
      }),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: controller.focusedDate.value,
          selectedDayPredicate: (day) =>
              isSameDay(controller.selectedDate.value, day),
          calendarFormat: controller.calendarFormat.value,
          onDaySelected: (selectedDay, focusedDay) {
            controller.onDateSelected(selectedDay);
          },
          onPageChanged: (focusedDay) {
            controller.onPageChanged(focusedDay);
          },
          onFormatChanged: (format) {
            controller.calendarFormat.value = format;
          },
          eventLoader: (day) => controller.getListsForDate(day),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Get.theme.primaryColor,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Get.theme.primaryColor,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
      ),
    );
  }

  Widget _buildDailyTasks() {
    if (controller.calendarData.value == null) {
      return const Center(child: Text('Aucune donnée'));
    }

    final data = controller.calendarData.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec statistiques
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Tâches du ${data.date.day}/${data.date.month}/${data.date.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${data.stats.totalLists} liste(s)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        // Liste des tâches groupées par heure
        Expanded(child: _buildGroupedTasks(data)),
      ],
    );
  }

  Widget _buildGroupedTasks(CalendarData data) {
    // Récupérer toutes les clés et les trier
    final timeSlots = data.groupedByHour.keys.toList();

    // Trier les heures (en mettant "Sans heure" à la fin)
    timeSlots.sort((a, b) {
      if (a == 'Sans heure') return 1;
      if (b == 'Sans heure') return -1;
      return a.compareTo(b);
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = timeSlots[index];
        final lists = data.groupedByHour[timeSlot]!;
        return _buildTimeSlot(timeSlot, lists);
      },
    );
  }

  Widget _buildTimeSlot(String time, List lists) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...lists.map((list) => _buildTaskTile(list)).toList(),
      ],
    );
  }

  Widget _buildTaskTile(list) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: list.isPersonal
                ? Colors.blue.withOpacity(0.1)
                : Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            list.isPersonal ? Icons.person : Icons.people,
            color: list.isPersonal ? Colors.blue : Colors.purple,
          ),
        ),
        title: Text(list.title),
        subtitle: Row(
          children: [
            if (list.isShared) Text('Partagé par ${list.ownerName} • '),
            Text('${list.completedItems}/${list.totalItems}'),
          ],
        ),
        trailing: list.type == 'checklist'
            ? Container(
                padding: const EdgeInsets.all(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(
                        value: list.progress,
                        strokeWidth: 2,
                      ),
                    ),
                    Text(
                      '${(list.progress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              )
            : null,
        onTap: () {
          Get.toNamed(AppRoutes.listDetailWithId(list.id));
        },
      ),
    );
  }
}
