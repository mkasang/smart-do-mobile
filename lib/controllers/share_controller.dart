import 'package:get/get.dart';
import 'package:smart_do/models/request_models.dart';
import 'package:smart_do/services/api_service.dart';
import 'package:smart_do/services/snackbar_service.dart';
import 'package:smart_do/app/constants/api_endpoints.dart';
import 'package:smart_do/controllers/list_controller.dart';
import 'package:flutter/material.dart';

class ShareController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final SnackbarService _snackbarService = Get.find<SnackbarService>();
  final ListController _listController = Get.find<ListController>();

  // États observables
  final searchResults = <UserSearchResult>[].obs;
  final isLoading = false.obs;
  final isSearching = false.obs;
  final selectedUserId = Rx<int?>(null);
  final selectedPermission = 'read'.obs;

  // Contrôleur pour la recherche
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    // Debounce pour la recherche utilisateur (500ms)
    debounce(
      searchController as RxInterface<Object?>,
      (_) => searchUsers(),
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Rechercher des utilisateurs
  Future<void> searchUsers() async {
    final query = searchController.text.trim();

    if (query.isEmpty || query.length < 2) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        path: ApiEndpoints.userSearch,
        queryParams: {'query': query},
      );

      if (response.success && response.data != null) {
        final usersData = response.data!['users'] as List;
        searchResults.value = usersData
            .map(
              (user) => UserSearchResult.fromJson(user as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (e) {
      _snackbarService.showError('Erreur recherche utilisateurs');
    } finally {
      isSearching.value = false;
    }
  }

  // Partager une liste
  Future<void> shareList(int listId) async {
    if (selectedUserId.value == null) {
      _snackbarService.showError('Sélectionnez un utilisateur');
      return;
    }

    isLoading.value = true;

    try {
      final request = ShareListRequest(
        userId: selectedUserId.value!,
        permission: selectedPermission.value,
      );

      final response = await _apiService.post<Map<String, dynamic>>(
        path: ApiEndpoints.shareList(listId),
        data: request.toJson(),
      );

      if (response.success) {
        _snackbarService.showSuccess('Liste partagée avec succès');

        // Recharger le détail de la liste
        await _listController.loadListDetail(listId);

        Get.back();
      }
    } catch (e) {
      _snackbarService.showError('Erreur partage liste');
    } finally {
      isLoading.value = false;
    }
  }

  // Retirer un partage (avec confirmation)
  Future<void> removeShare(int listId, int userId) async {
    final confirmed = await _showRemoveConfirmation();
    if (!confirmed) return;

    try {
      final response = await _apiService.delete(
        path: ApiEndpoints.removeShare(listId, userId),
      );

      if (response.success) {
        _snackbarService.showSuccess('Partage retiré');
        await _listController.loadListDetail(listId);
      }
    } catch (e) {
      _snackbarService.showError('Erreur retrait partage');
    }
  }

  // Boîte de dialogue de confirmation
  Future<bool> _showRemoveConfirmation() async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: Text('Confirmation'),
            content: Text('Voulez-vous vraiment retirer ce partage ?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Retirer'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Sélectionner un utilisateur
  void selectUser(int userId) {
    selectedUserId.value = userId;
  }

  // Changer la permission
  void setPermission(String permission) {
    selectedPermission.value = permission;
  }

  // Réinitialiser la sélection
  void resetSelection() {
    selectedUserId.value = null;
    selectedPermission.value = 'read';
    searchController.clear();
    searchResults.clear();
  }

  // Obtenir le nom de la permission
  String getPermissionName(String permission) {
    return permission == 'edit' ? 'Modification' : 'Lecture seule';
  }

  // Vérifier si l'utilisateur est déjà sélectionné
  bool isUserSelected(int userId) {
    return selectedUserId.value == userId;
  }
}
