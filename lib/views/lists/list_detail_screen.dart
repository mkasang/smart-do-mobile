import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_do/app/routes/app_routes.dart';
import 'package:smart_do/controllers/item_controller.dart';
import 'package:smart_do/controllers/list_controller.dart';
import 'package:smart_do/models/list_model.dart';
import 'package:smart_do/widgets/loading_widgets.dart';

class ListDetailScreen extends GetView<ListController> {
  const ListDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listId = Get.arguments is ListModel
        ? Get.arguments.id
        : Get.arguments as int;

    final itemController = Get.find<ItemController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final list = controller.currentList.value;
          return Text(list?.title ?? 'Détail liste');
        }),
        actions: [
          // Bouton partager
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              Get.toNamed(AppRoutes.shareListWithId(listId));
            },
          ),
          // Bouton supprimer
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => controller.deleteList(listId),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.currentList.value == null) {
          return const ShimmerList();
        }

        final list = controller.currentList.value;
        if (list == null) {
          return const Center(child: Text('Liste non trouvée'));
        }

        // Charger les items dans ItemController
        WidgetsBinding.instance.addPostFrameCallback((_) {
          itemController.loadItems(list.id);
        });

        return Column(
          children: [
            // En-tête avec progression
            _buildHeader(list),

            // Liste des items
            Expanded(child: _buildItemsList(list, itemController)),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(ListModel list) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (list.description != null && list.description!.isNotEmpty) ...[
            Text(list.description!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
          ],

          // Date d'échéance
          if (list.dueDate != null) ...[
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'À faire pour le ${list.formattedDueDate}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Barre de progression
          if (list.type == 'checklist') ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progression: ${(list.progress * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: list.progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          list.progress == 1 ? Colors.green : Colors.blue,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${list.completedItems}/${list.totalItems}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsList(ListModel list, ItemController itemController) {
    return Column(
      children: [
        // Input pour ajouter un item (si checklist)
        if (list.type == 'checklist')
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: itemController.itemController,
                    decoration: InputDecoration(
                      hintText: 'Ajouter un item...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => itemController.createItem(list.id),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => itemController.isLoading.value
                      ? const CircularProgressIndicator()
                      : FloatingActionButton(
                          onPressed: () => itemController.createItem(list.id),
                          mini: true,
                          child: const Icon(Icons.add),
                        ),
                ),
              ],
            ),
          ),

        // Liste des items
        Expanded(
          child: Obx(() {
            if (itemController.isLoading.value &&
                itemController.items.isEmpty) {
              return const ShimmerList();
            }

            if (itemController.items.isEmpty) {
              return const Center(child: Text('Aucun item dans cette liste'));
            }

            return ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: itemController.items.length,
              onReorder: (oldIndex, newIndex) {
                // TODO: Implémenter le réordonnancement si l'API le supporte
              },
              itemBuilder: (context, index) {
                final item = itemController.items[index];
                return _buildItemTile(item, itemController, list.type);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildItemTile(item, ItemController itemController, String listType) {
    return Card(
      key: ValueKey(item.id),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: listType == 'checklist'
            ? Checkbox(
                value: item.isDone,
                onChanged: (_) => itemController.toggleItem(item),
              )
            : const Icon(Icons.circle_outlined),
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.isDone ? TextDecoration.lineThrough : null,
            color: item.isDone ? Colors.grey : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showEditDialog(item, itemController),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => itemController.deleteItem(item),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(item, ItemController itemController) {
    final controller = TextEditingController(text: item.title);

    Get.dialog(
      AlertDialog(
        title: const Text('Modifier l\'item'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nouveau titre'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                itemController.updateItem(item, controller.text.trim());
                Get.back();
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }
}
