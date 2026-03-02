import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_do/controllers/share_controller.dart';

class ShareListScreen extends GetView<ShareController> {
  const ShareListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listId = Get.arguments as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partager la liste'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            controller.resetSelection();
            Get.back();
          },
        ),
        actions: [
          Obx(
            () => controller.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                : TextButton(
                    onPressed: () => controller.shareList(listId),
                    child: const Text(
                      'Partager',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sélection de permission
          _buildPermissionSelector(),

          // Recherche utilisateur
          _buildSearchField(),

          // Résultats de recherche
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.searchResults.isEmpty) {
                return const Center(
                  child: Text('Recherchez un utilisateur à partager'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final user = controller.searchResults[index];
                  return _buildUserTile(user);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Permission',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildPermissionChip(
                    label: 'Lecture seule',
                    value: 'read',
                    selected: controller.selectedPermission.value == 'read',
                    icon: Icons.visibility,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPermissionChip(
                    label: 'Modification',
                    value: 'edit',
                    selected: controller.selectedPermission.value == 'edit',
                    icon: Icons.edit,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionChip({
    required String label,
    required String value,
    required bool selected,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => controller.setPermission(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Get.theme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Get.theme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un utilisateur...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(
            () => controller.isSearching.value
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const SizedBox(),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildUserTile(user) {
    return Obx(
      () => Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: controller.isUserSelected(user.id)
            ? Get.theme.primaryColor.withOpacity(0.1)
            : null,
        child: ListTile(
          leading: CircleAvatar(child: Text(user.name[0].toUpperCase())),
          title: Text(user.name),
          subtitle: Text(user.email),
          trailing: controller.isUserSelected(user.id)
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
          onTap: () => controller.selectUser(user.id),
        ),
      ),
    );
  }
}
