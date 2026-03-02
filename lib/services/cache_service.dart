import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_do/models/list_model.dart';
import 'package:smart_do/models/stats_model.dart';
import 'package:smart_do/models/calendar_model.dart';
import 'package:smart_do/app/constants/app_constants.dart';

class CacheService extends GetxService {
  late SharedPreferences _prefs;

  Future<CacheService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Sauvegarder les listes
  Future<void> cacheLists(List<ListModel> lists) async {
    try {
      final listsJson = lists.map((list) => list.toJson()).toList();
      final encoded = jsonEncode({
        'data': listsJson,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _prefs.setString(AppConstants.listsCacheKey, encoded);
      print('📦 Listes sauvegardées en cache: ${lists.length} listes');
    } catch (e) {
      print('❌ Erreur cache lists: $e');
    }
  }

  // Récupérer les listes du cache
  List<ListModel>? getCachedLists() {
    try {
      final cached = _prefs.getString(AppConstants.listsCacheKey);
      if (cached == null) {
        print('📦 Aucune liste en cache');
        return null;
      }

      final decoded = jsonDecode(cached);
      final timestamp = DateTime.parse(decoded['timestamp']);

      // Vérifier si le cache est encore valide (1 heure)
      final now = DateTime.now();
      final cacheAge = now.difference(timestamp);

      print(
        '📦 Cache listes: age=${cacheAge.inMinutes}min, valide=${cacheAge <= AppConstants.cacheValidity}',
      );

      if (cacheAge > AppConstants.cacheValidity) {
        print('📦 Cache listes expiré');
        return null;
      }

      final listsData = decoded['data'] as List;
      return listsData.map((data) => ListModel.fromJson(data)).toList();
    } catch (e) {
      print('❌ Erreur lecture cache lists: $e');
      return null;
    }
  }

  // Sauvegarder les statistiques
  Future<void> cacheStats(StatsModel stats) async {
    try {
      final encoded = jsonEncode({
        'data': stats.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _prefs.setString(AppConstants.statsCacheKey, encoded);
      print('📦 Stats sauvegardées en cache');
    } catch (e) {
      print('❌ Erreur cache stats: $e');
    }
  }

  // Récupérer les stats du cache
  StatsModel? getCachedStats() {
    try {
      final cached = _prefs.getString(AppConstants.statsCacheKey);
      if (cached == null) return null;

      final decoded = jsonDecode(cached);
      final timestamp = DateTime.parse(decoded['timestamp']);

      if (DateTime.now().difference(timestamp) > AppConstants.cacheValidity) {
        print('📦 Cache stats expiré');
        return null;
      }

      final statsData = decoded['data'] as Map<String, dynamic>;
      return StatsModel.fromJson(statsData);
    } catch (e) {
      print('❌ Erreur lecture cache stats: $e');
      return null;
    }
  }

  // Sauvegarder une liste spécifique
  Future<void> cacheListDetail(int listId, ListModel list) async {
    try {
      final key = 'list_detail_$listId';
      final encoded = jsonEncode({
        'data': list.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _prefs.setString(key, encoded);
      print('📦 Détail liste $listId sauvegardé en cache');
    } catch (e) {
      print('❌ Erreur cache list detail: $e');
    }
  }

  // Récupérer une liste spécifique du cache
  ListModel? getCachedListDetail(int listId) {
    try {
      final key = 'list_detail_$listId';
      final cached = _prefs.getString(key);
      if (cached == null) return null;

      final decoded = jsonDecode(cached);
      final timestamp = DateTime.parse(decoded['timestamp']);

      if (DateTime.now().difference(timestamp) > AppConstants.cacheValidity) {
        print('📦 Cache détail liste $listId expiré');
        return null;
      }

      return ListModel.fromJson(decoded['data']);
    } catch (e) {
      print('❌ Erreur lecture cache list detail: $e');
      return null;
    }
  }

  // Sauvegarder les données du calendrier
  Future<void> cacheCalendarData(DateTime date, CalendarData data) async {
    try {
      final key = 'calendar_${_formatDate(date)}';
      final encoded = jsonEncode({
        'data': data.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _prefs.setString(key, encoded);
      print('📦 Données calendrier pour ${_formatDate(date)} sauvegardées');
    } catch (e) {
      print('❌ Erreur cache calendrier: $e');
    }
  }

  // Récupérer les données du calendrier du cache
  CalendarData? getCachedCalendarData(DateTime date) {
    try {
      final key = 'calendar_${_formatDate(date)}';
      final cached = _prefs.getString(key);
      if (cached == null) return null;

      final decoded = jsonDecode(cached);
      final timestamp = DateTime.parse(decoded['timestamp']);

      if (DateTime.now().difference(timestamp) > AppConstants.cacheValidity) {
        print('📦 Cache calendrier pour ${_formatDate(date)} expiré');
        return null;
      }

      return CalendarData.fromJson(decoded['data']);
    } catch (e) {
      print('❌ Erreur lecture cache calendrier: $e');
      return null;
    }
  }

  // Sauvegarder les listes partagées
  Future<void> cacheSharedLists(List<ListModel> lists) async {
    try {
      final listsJson = lists.map((list) => list.toJson()).toList();
      final encoded = jsonEncode({
        'data': listsJson,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _prefs.setString('shared_lists_cache', encoded);
      print('📦 Listes partagées sauvegardées en cache');
    } catch (e) {
      print('❌ Erreur cache shared lists: $e');
    }
  }

  // Récupérer les listes partagées du cache
  List<ListModel>? getCachedSharedLists() {
    try {
      final cached = _prefs.getString('shared_lists_cache');
      if (cached == null) return null;

      final decoded = jsonDecode(cached);
      final timestamp = DateTime.parse(decoded['timestamp']);

      if (DateTime.now().difference(timestamp) > AppConstants.cacheValidity) {
        print('📦 Cache listes partagées expiré');
        return null;
      }

      final listsData = decoded['data'] as List;
      return listsData.map((data) => ListModel.fromJson(data)).toList();
    } catch (e) {
      print('❌ Erreur lecture cache shared lists: $e');
      return null;
    }
  }

  // Vérifier si des données existent en cache
  bool hasCache(String key) {
    return _prefs.containsKey(key);
  }

  // Obtenir l'âge du cache en minutes
  int? getCacheAge(String key) {
    try {
      final cached = _prefs.getString(key);
      if (cached == null) return null;

      final decoded = jsonDecode(cached);
      final timestamp = DateTime.parse(decoded['timestamp']);
      return DateTime.now().difference(timestamp).inMinutes;
    } catch (e) {
      return null;
    }
  }

  // Nettoyer tout le cache
  Future<void> clearAllCache() async {
    try {
      final keys = _prefs.getKeys();
      for (var key in keys) {
        if (key.startsWith('list_') ||
            key.startsWith('stats_') ||
            key.startsWith('calendar_') ||
            key.contains('cache')) {
          await _prefs.remove(key);
        }
      }
      print('📦 Cache nettoyé');
    } catch (e) {
      print('❌ Erreur clear cache: $e');
    }
  }

  // Supprimer une entrée spécifique
  Future<void> remove(String key) async {
    await _prefs.remove(key);
    print('📦 Cache supprimé: $key');
  }

  // Formater une date pour les clés de cache
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
