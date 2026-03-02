import 'package:get/get.dart';
import 'package:smart_do/models/list_model.dart';
import 'package:smart_do/models/request_models.dart';
import 'package:smart_do/services/api_service.dart';
import 'package:smart_do/services/cache_service.dart';
import 'package:smart_do/services/connectivity_service.dart';
import 'package:smart_do/services/snackbar_service.dart';
import 'package:smart_do/app/constants/api_endpoints.dart';
import 'package:smart_do/app/routes/app_routes.dart';
import 'package:flutter/material.dart';

class ListController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final CacheService _cacheService = Get.find<CacheService>();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  final SnackbarService _snackbarService = Get.find<SnackbarService>();

  // États observables
  final lists = <ListModel>[].obs;
  final activeLists = <ListModel>[].obs;
  final completedLists = <ListModel>[].obs;
  final sharedLists = <ListModel>[].obs;
  final currentList = Rx<ListModel?>(null);

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final searchQuery = ''.obs;

  // Pagination
  var currentPage = 1;
  var totalPages = 1;
  var hasNextPage = false;

  @override
  void onInit() {
    super.onInit();
    loadLists();

    // Debounce pour la recherche
    debounce(
      searchQuery,
      (_) => searchLists(),
      time: const Duration(milliseconds: 500),
    );
  }

  // Charger toutes les listes
  Future<void> loadLists({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      // Vérifier la connexion
      if (!_connectivityService.hasInternet) {
        _loadCachedLists();
        return;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        path: ApiEndpoints.lists,
        queryParams: {
          'page': currentPage,
          'limit': 10,
          'search': searchQuery.value.isNotEmpty ? searchQuery.value : null,
        },
      );

      if (response.success && response.data != null) {
        final listsData = response.data!['lists'] as List;
        final pagination = response.data!['pagination'] as Map<String, dynamic>;

        final newLists = listsData
            .map((item) => ListModel.fromJson(item as Map<String, dynamic>))
            .toList();

        // Mettre à jour la pagination
        totalPages = pagination['total_pages'] as int;
        hasNextPage = pagination['has_next'] as bool;

        if (refresh || currentPage == 1) {
          lists.value = newLists;
        } else {
          lists.addAll(newLists);
        }

        // Filtrer les listes
        filterLists();

        // Sauvegarder en cache
        await _cacheService.cacheLists(lists);
      }
    } catch (e) {
      _snackbarService.showError('Erreur lors du chargement des listes');
      _loadCachedLists();
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
    }
  }

  // Charger les listes avec gestion offline
  Future<void> loadListsWithOffline({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      // Vérifier la connexion
      if (!_connectivityService.hasInternet) {
        _loadCachedLists();
        _snackbarService.showInfo('Mode hors ligne - Données en cache');
        return;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        path: ApiEndpoints.lists,
        queryParams: {
          'page': currentPage,
          'limit': 10,
          'search': searchQuery.value.isNotEmpty ? searchQuery.value : null,
        },
      );

      if (response.success && response.data != null) {
        final listsData = response.data!['lists'] as List;
        final pagination = response.data!['pagination'] as Map<String, dynamic>;

        final newLists = listsData
            .map((item) => ListModel.fromJson(item as Map<String, dynamic>))
            .toList();

        // Mettre à jour la pagination
        totalPages = pagination['total_pages'] as int;
        hasNextPage = pagination['has_next'] as bool;

        if (refresh || currentPage == 1) {
          lists.value = newLists;
        } else {
          lists.addAll(newLists);
        }

        // Filtrer les listes
        filterLists();

        // Sauvegarder en cache
        await _cacheService.cacheLists(lists);

        // Si c'est la première page, on a des données fraîches
        if (currentPage == 1) {
          _snackbarService.showSuccess('Listes mises à jour');
        }
      }
    } catch (e) {
      print('❌ Erreur chargement listes: $e');
      // En cas d'erreur, essayer le cache
      final cached = _cacheService.getCachedLists();
      if (cached != null) {
        lists.value = cached;
        filterLists();
        _snackbarService.showInfo('Mode hors ligne - Données en cache');
      } else {
        _snackbarService.showError('Impossible de charger les listes');
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
    }
  }

  // Charger les listes partagées avec offline
  Future<void> loadSharedListsWithOffline() async {
    try {
      if (!_connectivityService.hasInternet) {
        final cached = _cacheService.getCachedSharedLists();
        if (cached != null) {
          sharedLists.value = cached;
          _snackbarService.showInfo('Mode hors ligne - Données en cache');
        }
        return;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        path: ApiEndpoints.sharedLists,
      );

      if (response.success && response.data != null) {
        final listsData = response.data!['shared_lists'] as List;
        sharedLists.value = listsData
            .map((item) => ListModel.fromJson(item as Map<String, dynamic>))
            .toList();

        // Sauvegarder en cache
        await _cacheService.cacheSharedLists(sharedLists);
      }
    } catch (e) {
      print('❌ Erreur chargement listes partagées: $e');
      final cached = _cacheService.getCachedSharedLists();
      if (cached != null) {
        sharedLists.value = cached;
        _snackbarService.showInfo('Mode hors ligne - Données en cache');
      }
    }
  }

  // Charger le détail d'une liste avec offline
  Future<void> loadListDetailWithOffline(int listId) async {
    isLoading.value = true;
    currentList.value = null;

    try {
      if (!_connectivityService.hasInternet) {
        final cached = _cacheService.getCachedListDetail(listId);
        if (cached != null) {
          currentList.value = cached;
          _snackbarService.showInfo('Mode hors ligne - Données en cache');
        } else {
          _snackbarService.showError('Aucune donnée en cache pour cette liste');
        }
        return;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        path: ApiEndpoints.listDetail(listId),
      );

      if (response.success && response.data != null) {
        final listData = response.data!['list'] as Map<String, dynamic>;
        final items = response.data!['items'] as List?;
        final sharedWith = response.data!['shared_with'] as List?;

        // Ajouter les items et partages à la liste
        final fullListData = Map<String, dynamic>.from(listData);
        if (items != null) fullListData['items'] = items;
        if (sharedWith != null) fullListData['shared_with'] = sharedWith;

        currentList.value = ListModel.fromJson(fullListData);

        // Sauvegarder en cache
        await _cacheService.cacheListDetail(listId, currentList.value!);
      }
    } catch (e) {
      print('❌ Erreur chargement détail liste: $e');
      final cached = _cacheService.getCachedListDetail(listId);
      if (cached != null) {
        currentList.value = cached;
        _snackbarService.showInfo('Mode hors ligne - Données en cache');
      } else {
        _snackbarService.showError('Erreur chargement détail liste');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Rafraîchir les listes avec offline
  Future<void> refreshListsWithOffline() async {
    await loadListsWithOffline(refresh: true);
    await loadSharedListsWithOffline();
  }

  // Charger les listes partagées
  Future<void> loadSharedLists() async {
    try {
      if (!_connectivityService.hasInternet) {
        _snackbarService.showInfo('Mode hors ligne - Données en cache');
        return;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        path: ApiEndpoints.sharedLists,
      );

      if (response.success && response.data != null) {
        final listsData = response.data!['shared_lists'] as List;
        sharedLists.value = listsData
            .map((item) => ListModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _snackbarService.showError('Erreur chargement listes partagées');
    }
  }

  // Charger le détail d'une liste
  Future<void> loadListDetail(int listId) async {
    isLoading.value = true;
    currentList.value = null;

    try {
      if (!_connectivityService.hasInternet) {
        final cached = _cacheService.getCachedListDetail(listId);
        if (cached != null) {
          currentList.value = cached;
          _snackbarService.showInfo('Mode hors ligne - Données en cache');
        }
        return;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        path: ApiEndpoints.listDetail(listId),
      );

      if (response.success && response.data != null) {
        final listData = response.data!['list'] as Map<String, dynamic>;
        final items = response.data!['items'] as List?;
        final sharedWith = response.data!['shared_with'] as List?;

        // Ajouter les items et partages à la liste
        final fullListData = Map<String, dynamic>.from(listData);
        if (items != null) fullListData['items'] = items;
        if (sharedWith != null) fullListData['shared_with'] = sharedWith;

        currentList.value = ListModel.fromJson(fullListData);

        // Sauvegarder en cache
        await _cacheService.cacheListDetail(listId, currentList.value!);
      }
    } catch (e) {
      _snackbarService.showError('Erreur chargement détail liste');
    } finally {
      isLoading.value = false;
    }
  }

  // Créer une liste
  Future<void> createList(CreateListRequest request) async {
    isLoading.value = true;

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        path: ApiEndpoints.lists,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        final newList = ListModel.fromJson(response.data!['list']);
        lists.insert(0, newList);
        filterLists();

        _snackbarService.showSuccess('Liste créée avec succès');
        Get.back();
      }
    } catch (e) {
      _snackbarService.showError('Erreur création liste');
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour une liste
  Future<void> updateList(int listId, UpdateListRequest request) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        path: ApiEndpoints.listDetail(listId),
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        final updatedList = ListModel.fromJson(response.data!['list']);

        // Mettre à jour dans la liste principale
        final index = lists.indexWhere((list) => list.id == listId);
        if (index != -1) {
          lists[index] = updatedList;
        }

        // Mettre à jour la liste courante
        if (currentList.value?.id == listId) {
          currentList.value = updatedList;
        }

        filterLists();
        _snackbarService.showSuccess('Liste mise à jour');
      }
    } catch (e) {
      _snackbarService.showError('Erreur mise à jour');
    }
  }

  // Supprimer une liste (avec confirmation)
  Future<void> deleteList(int listId) async {
    // Afficher la confirmation
    final confirmed = await _showDeleteConfirmation('liste');
    if (!confirmed) return;

    try {
      final response = await _apiService.delete(
        path: ApiEndpoints.listDetail(listId),
      );

      if (response.success) {
        lists.removeWhere((list) => list.id == listId);
        filterLists();

        _snackbarService.showSuccess('Liste supprimée');

        // Retourner à l'écran précédent si on est sur le détail
        if (Get.currentRoute == AppRoutes.listDetail) {
          Get.back();
        }
      }
    } catch (e) {
      _snackbarService.showError('Erreur suppression');
    }
  }

  // Dupliquer une liste
  Future<void> duplicateList(int listId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        path: ApiEndpoints.duplicateList(listId),
      );

      if (response.success && response.data != null) {
        final newList = ListModel.fromJson(response.data!['list']);
        lists.insert(0, newList);
        filterLists();

        _snackbarService.showSuccess('Liste dupliquée');
      }
    } catch (e) {
      _snackbarService.showError('Erreur duplication');
    }
  }

  // Rechercher des listes
  void searchLists() {
    loadLists(refresh: true);
  }

  // Charger plus de listes (pagination)
  Future<void> loadMoreLists() async {
    if (!hasNextPage || isLoadingMore.value) return;

    currentPage++;
    isLoadingMore.value = true;
    await loadLists();
  }

  // Rafraîchir les listes
  Future<void> refreshLists() async {
    await loadLists(refresh: true);
    await loadSharedLists();
  }

  // Filtrer les listes par statut
  void filterLists() {
    activeLists.value = lists.where((list) => list.isActive).toList();
    completedLists.value = lists.where((list) => list.isCompleted).toList();
  }

  // Charger les listes depuis le cache
  void _loadCachedLists() {
    final cached = _cacheService.getCachedLists();
    if (cached != null) {
      lists.value = cached;
      filterLists();
      _snackbarService.showInfo('Mode hors ligne - Données en cache');
    }
  }

  // Boîte de dialogue de confirmation
  Future<bool> _showDeleteConfirmation(String item) async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: Text('Confirmation'),
            content: Text('Voulez-vous vraiment supprimer cette $item ?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Mettre à jour la requête de recherche
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Obtenir une liste par ID
  ListModel? getListById(int id) {
    try {
      return lists.firstWhere((list) => list.id == id);
    } catch (e) {
      return null;
    }
  }
}
