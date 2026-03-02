import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:smart_do/models/calendar_model.dart';
import 'package:smart_do/services/api_service.dart';
import 'package:smart_do/services/snackbar_service.dart';
import 'package:smart_do/app/constants/api_endpoints.dart';

class CalendarController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final SnackbarService _snackbarService = Get.find<SnackbarService>();

  // États observables
  final calendarData = Rx<CalendarData?>(null);
  final isLoading = false.obs;
  final selectedDate = DateTime.now().obs;
  final focusedDate = DateTime.now().obs;

  // Format du calendrier
  final calendarFormat = CalendarFormat.month.obs;

  // Événements par date (pour marquage)
  final events = <DateTime, List<CalendarList>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadCalendarData();
  }

  // Charger les données du calendrier
  Future<void> loadCalendarData() async {
    isLoading.value = true;

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        path: ApiEndpoints.calendar,
        queryParams: {'date': _formatDate(selectedDate.value)},
      );

      if (response.success && response.data != null) {
        calendarData.value = CalendarData.fromJson(response.data!);
        _updateEvents();
      }
    } catch (e) {
      _snackbarService.showError('Erreur chargement calendrier');
    } finally {
      isLoading.value = false;
    }
  }

  // Charger les données pour une date spécifique
  Future<void> loadDateData(DateTime date) async {
    selectedDate.value = date;
    await loadCalendarData();
  }

  // Changer la date sélectionnée
  void onDateSelected(DateTime date) {
    selectedDate.value = date;
    loadDateData(date);
  }

  // Changer le mois affiché
  void onPageChanged(DateTime date) {
    focusedDate.value = date;
  }

  // Changer le format du calendrier
  void toggleFormat() {
    if (calendarFormat.value == CalendarFormat.month) {
      calendarFormat.value = CalendarFormat.week;
    } else if (calendarFormat.value == CalendarFormat.week) {
      calendarFormat.value = CalendarFormat.twoWeeks;
    } else {
      calendarFormat.value = CalendarFormat.month;
    }
  }

  // Mettre à jour les événements pour le marquage
  void _updateEvents() {
    if (calendarData.value == null) return;

    events.clear();

    // Grouper les listes par date
    for (var list in calendarData.value!.lists) {
      // Utiliser la date courante puisque l'API retourne les listes pour une date spécifique
      final date = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
      );

      if (!events.containsKey(date)) {
        events[date] = [];
      }
      events[date]!.add(list);
    }
  }

  // Obtenir les listes pour une date spécifique
  List<CalendarList> getListsForDate(DateTime date) {
    return events[date] ?? [];
  }

  // Vérifier si une date a des événements
  bool hasEvents(DateTime date) {
    return events.containsKey(date) && events[date]!.isNotEmpty;
  }

  // Formater une date pour l'API
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Obtenir le titre du mois
  String get monthTitle {
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '${months[focusedDate.value.month - 1]} ${focusedDate.value.year}';
  }

  // Navigation mois précédent
  void previousMonth() {
    final newDate = DateTime(
      focusedDate.value.year,
      focusedDate.value.month - 1,
      1,
    );
    focusedDate.value = newDate;
  }

  // Navigation mois suivant
  void nextMonth() {
    final newDate = DateTime(
      focusedDate.value.year,
      focusedDate.value.month + 1,
      1,
    );
    focusedDate.value = newDate;
  }
}
