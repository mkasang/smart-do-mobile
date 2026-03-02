import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_do/models/list_model.dart';
import 'package:smart_do/models/stats_model.dart';
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
    } catch (e) {
      print('Erreur cache lists: $e');
    }
  }

  // Récupérer les listes du cache
  List<ListModel>? getCachedLists() {
    try {
      final cached = _prefs.getString(AppConstants.listsCacheKey);
      if (cached == null) return null;

      final decoded = jsonDecode(cached);
      final timestamp = DateTime.parse(decoded['timestamp']);

      // Vérifier si le cache est encore valide (1 heure)
      if (DateTime.now().difference(timestamp) > AppConstants.cacheValidity) {
        return null;
      }

      final listsData = decoded['data'] as List;
      return listsData.map((data) => ListModel.fromJson(data)).toList();
    } catch (e) {
      print('Erreur lecture cache lists: $e');
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
    } catch (e) {
      print('Erreur cache stats: $e');
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
        return null;
      }

      final statsData = decoded['data'] as Map<String, dynamic>;
      return StatsModel.fromJson(statsData);
    } catch (e) {
      print('Erreur lecture cache stats: $e');
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
    } catch (e) {
      print('Erreur cache list detail: $e');
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
        return null;
      }

      return ListModel.fromJson(decoded['data']);
    } catch (e) {
      print('Erreur lecture cache list detail: $e');
      return null;
    }
  }

  // Nettoyer le cache
  Future<void> clearCache() async {
    try {
      final keys = _prefs.getKeys();
      for (var key in keys) {
        if (key.startsWith('list_') || key.startsWith('stats_')) {
          await _prefs.remove(key);
        }
      }
    } catch (e) {
      print('Erreur clear cache: $e');
    }
  }

  // Supprimer une entrée spécifique
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // Vérifier si des données existent en cache
  bool hasCache(String key) {
    return _prefs.containsKey(key);
  }
}
