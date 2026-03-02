import 'package:get/get.dart';
import 'package:smart_do/models/stats_model.dart';
import 'package:smart_do/services/api_service.dart';
import 'package:smart_do/services/cache_service.dart';
import 'package:smart_do/services/connectivity_service.dart';
import 'package:smart_do/services/snackbar_service.dart';
import 'package:smart_do/app/constants/api_endpoints.dart';

class StatsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final CacheService _cacheService = Get.find<CacheService>();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  final SnackbarService _snackbarService = Get.find<SnackbarService>();

  // États observables
  final stats = Rx<StatsModel?>(null);
  final isLoading = false.obs;
  final isRefreshing = false.obs;

  // Animation des compteurs
  final animatedValues = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatsWithOffline();
  }

  // Charger les statistiques
  Future<void> loadStatsWithOffline({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      // Vérifier la connexion
      if (!_connectivityService.hasInternet) {
        _loadCachedStats();
        return;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        path: ApiEndpoints.stats,
      );

      if (response.success && response.data != null) {
        final newStats = StatsModel.fromJson(response.data!);
        stats.value = newStats;

        // Initialiser les valeurs animées
        _initAnimatedValues(newStats);

        // Sauvegarder en cache
        await _cacheService.cacheStats(newStats);
      }
    } catch (e) {
      print('❌ Erreur chargement statistiques: $e');
      _loadCachedStats();
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // Initialiser les valeurs pour l'animation
  void _initAnimatedValues(StatsModel stats) {
    animatedValues.clear();
    animatedValues['totalLists'] = stats.summary.totalLists.toDouble();
    animatedValues['totalItems'] = stats.summary.totalItems.toDouble();
    animatedValues['completedItems'] = stats.summary.totalCompletedItems
        .toDouble();
    animatedValues['completionRate'] = stats.summary.completionRate;
    animatedValues['totalShares'] = stats.summary.totalShares.toDouble();
  }

  // Charger depuis le cache
  void _loadCachedStats() {
    final cached = _cacheService.getCachedStats();
    if (cached != null) {
      stats.value = cached;
      _initAnimatedValues(cached);
      _snackbarService.showInfo('Mode hors ligne - Données en cache');
    } else {
      _snackbarService.showError('Aucune donnée en cache');
    }
  }

  // Obtenir le taux de complétion formaté
  String get completionRateFormatted {
    if (stats.value == null) return '0%';
    return '${stats.value!.summary.completionRate.toStringAsFixed(1)}%';
  }

  // Obtenir le nombre total de listes
  int get totalLists => stats.value?.summary.totalLists ?? 0;

  // Obtenir le nombre total d'items
  int get totalItems => stats.value?.summary.totalItems ?? 0;

  // Obtenir le nombre d'items complétés
  int get completedItems => stats.value?.summary.totalCompletedItems ?? 0;

  // Obtenir les stats des listes
  ListsStats? get listsStats => stats.value?.lists;

  // Obtenir les stats des items
  ItemsStats? get itemsStats => stats.value?.items;

  // Obtenir les stats de partage
  SharingStats? get sharingStats => stats.value?.sharing;

  // Obtenir les stats temporelles
  TimelineStats? get timelineStats => stats.value?.timeline;

  // Rafraîchir les stats
  Future<void> refreshStats() async {
    await loadStatsWithOffline(refresh: true);
  }

  // Formater les stats pour les graphiques (à implémenter plus tard)
  List<Map<String, dynamic>> getChartData() {
    if (timelineStats == null) return [];

    return timelineStats!.daily.map((daily) {
      return {
        'date': daily.date,
        'lists': daily.listsCount,
        'completed': daily.completedCount,
      };
    }).toList();
  }

  // Obtenir les stats du mois courant
  Map<String, int> getCurrentMonthStats() {
    if (timelineStats == null) return {};

    final currentMonth =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

    final monthlyStat = timelineStats!.monthly.firstWhere(
      (stat) => stat.month == currentMonth,
      orElse: () =>
          MonthlyStat(month: currentMonth, listsCount: 0, completedCount: 0),
    );

    return {
      'lists': monthlyStat.listsCount,
      'completed': monthlyStat.completedCount,
    };
  }
}
