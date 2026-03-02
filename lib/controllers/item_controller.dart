import 'package:get/get.dart';
import 'package:smart_do/models/item_model.dart';
import 'package:smart_do/models/request_models.dart';
import 'package:smart_do/services/api_service.dart';
import 'package:smart_do/services/snackbar_service.dart';
import 'package:smart_do/app/constants/api_endpoints.dart';
import 'package:smart_do/controllers/list_controller.dart';
import 'package:flutter/material.dart';

class ItemController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final SnackbarService _snackbarService = Get.find<SnackbarService>();
  final ListController _listController = Get.find<ListController>();

  // États observables
  final items = <ItemModel>[].obs;
  final isLoading = false.obs;
  final newItemTitle = ''.obs;

  // Form controller pour nouvel item
  final itemController = TextEditingController();

  @override
  void onClose() {
    itemController.dispose();
    super.onClose();
  }

  // Charger les items d'une liste
  void loadItems(int listId) {
    final list = _listController.getListById(listId);
    if (list != null && list.items != null) {
      items.value = list.items!;
    }
  }

  // Créer un item
  Future<void> createItem(int listId) async {
    if (itemController.text.trim().isEmpty) {
      _snackbarService.showError('Le titre est requis');
      return;
    }

    isLoading.value = true;
    final title = itemController.text.trim();

    try {
      final request = CreateItemRequest(listId: listId, title: title);

      final response = await _apiService.post<Map<String, dynamic>>(
        path: ApiEndpoints.items,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        final newItem = ItemModel.fromJson(response.data!['item']);

        // Ajouter à la liste locale
        items.add(newItem);

        // Mettre à jour le compteur dans ListModel
        await _updateListCounters(listId);

        itemController.clear();
        newItemTitle.value = '';

        _snackbarService.showSuccess('Item ajouté');
      }
    } catch (e) {
      _snackbarService.showError('Erreur création item');
    } finally {
      isLoading.value = false;
    }
  }

  // Modifier un item
  Future<void> updateItem(ItemModel item, String newTitle) async {
    if (newTitle.trim().isEmpty) return;

    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        path: ApiEndpoints.updateItem(item.id),
        data: {'title': newTitle.trim()},
      );

      if (response.success && response.data != null) {
        final updatedItem = ItemModel.fromJson(response.data!['item']);

        final index = items.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          items[index] = updatedItem;
        }

        _snackbarService.showSuccess('Item modifié');
      }
    } catch (e) {
      _snackbarService.showError('Erreur modification');
    }
  }

  // Basculer le statut d'un item
  Future<void> toggleItem(ItemModel item) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        path: ApiEndpoints.toggleItem(item.id),
      );

      if (response.success && response.data != null) {
        final updatedItem = ItemModel.fromJson(response.data!['item']);

        // Mettre à jour l'item local
        final index = items.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          items[index] = updatedItem;
        }

        // Mettre à jour les compteurs de la liste
        await _updateListCounters(item.listId);
      }
    } catch (e) {
      _snackbarService.showError('Erreur mise à jour');

      // En cas d'erreur, on revert l'état local
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = item.toggle();
      }
    }
  }

  // Supprimer un item (avec confirmation)
  Future<void> deleteItem(ItemModel item) async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    try {
      final response = await _apiService.delete(
        path: ApiEndpoints.deleteItem(item.id),
      );

      if (response.success) {
        items.removeWhere((i) => i.id == item.id);
        await _updateListCounters(item.listId);
        _snackbarService.showSuccess('Item supprimé');
      }
    } catch (e) {
      _snackbarService.showError('Erreur suppression');
    }
  }

  // Mettre à jour les compteurs de la liste
  Future<void> _updateListCounters(int listId) async {
    final list = _listController.getListById(listId);
    if (list != null) {
      final completedCount = items.where((item) => item.isDone).length;

      final updatedList = list.copyWith(
        totalItems: items.length,
        completedItems: completedCount,
      );

      // Mettre à jour dans ListController
      final index = _listController.lists.indexWhere((l) => l.id == listId);
      if (index != -1) {
        _listController.lists[index] = updatedList;
      }

      // Mettre à jour la liste courante si nécessaire
      if (_listController.currentList.value?.id == listId) {
        _listController.currentList.value = updatedList.copyWith(items: items);
      }

      // Rafraîchir les filtres
      _listController.filterLists();
    }
  }

  // Boîte de dialogue de confirmation
  Future<bool> _showDeleteConfirmation() async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: Text('Confirmation'),
            content: Text('Voulez-vous vraiment supprimer cet item ?'),
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

  // Obtenir les items complétés
  List<ItemModel> get completedItems {
    return items.where((item) => item.isDone).toList();
  }

  // Obtenir les items en cours
  List<ItemModel> get pendingItems {
    return items.where((item) => !item.isDone).toList();
  }

  // Calculer la progression
  double get progress {
    if (items.isEmpty) return 0;
    return completedItems.length / items.length;
  }
}
