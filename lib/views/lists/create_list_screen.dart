import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_do/controllers/list_controller.dart';
import 'package:smart_do/models/request_models.dart';
import 'package:smart_do/services/snackbar_service.dart';

class CreateListScreen extends GetView<ListController> {
  const CreateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final type = 'checklist'.obs;
    final dueDate = Rx<DateTime?>(null);
    final dueTime = Rx<String?>(null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle liste'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => controller.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                : TextButton(
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) {
                        Get.find<SnackbarService>().showError(
                          'Le titre est requis',
                        );
                        return;
                      }

                      final request = CreateListRequest(
                        title: titleController.text.trim(),
                        type: type.value,
                        description:
                            descriptionController.text.trim().isNotEmpty
                            ? descriptionController.text.trim()
                            : null,
                        dueDate: dueDate.value,
                        dueTime: dueTime.value,
                      );

                      await controller.createList(request);
                    },
                    child: const Text(
                      'Créer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            const Text(
              'Titre',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Ex: Courses hebdomadaires',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Type de liste
            const Text(
              'Type de liste',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Checklist',
                      icon: Icons.checklist_rounded,
                      isSelected: type.value == 'checklist',
                      onTap: () => type.value = 'checklist',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Simple',
                      icon: Icons.list_alt_rounded,
                      isSelected: type.value == 'simple',
                      onTap: () => type.value = 'simple',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              'Description (optionnelle)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ajouter une description...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date d'échéance
            const Text(
              'Date d\'échéance (optionnelle)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _buildDatePicker(
                date: dueDate.value,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  dueDate.value = date;
                },
                onClear: () => dueDate.value = null,
              ),
            ),
            const SizedBox(height: 16),

            // Heure d'échéance
            if (dueDate.value != null) ...[
              const Text(
                'Heure d\'échéance (optionnelle)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Obx(
                () => _buildTimePicker(
                  time: dueTime.value,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      dueTime.value =
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
                    }
                  },
                  onClear: () => dueTime.value = null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Get.theme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Get.theme.primaryColor : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey[700]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required DateTime? date,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.calendar_today), onPressed: onTap),
          Expanded(
            child: Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Sélectionner une date',
            ),
          ),
          if (date != null)
            IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String? time,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.access_time), onPressed: onTap),
          Expanded(
            child: Text(
              time != null ? time.substring(0, 5) : 'Sélectionner une heure',
            ),
          ),
          if (time != null)
            IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
        ],
      ),
    );
  }
}
