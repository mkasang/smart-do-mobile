import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_do/controllers/profile_controller.dart';
import 'package:smart_do/widgets/loading_widgets.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(controller.isEditing.value ? Icons.close : Icons.edit),
              onPressed: controller.isEditing.value
                  ? controller.cancelEdit
                  : controller.enableEdit,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.user.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Photo de profil
              _buildProfileHeader(user),
              const SizedBox(height: 32),

              // Formulaire
              _buildProfileForm(user),
              const SizedBox(height: 32),

              // Actions
              _buildActions(),
              const SizedBox(height: 16),

              // Version
              const Text(
                'Smart Do - Version 1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(user) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
              child: Text(
                user.name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 40,
                  color: Get.theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: user.plan == 'premium'
                      ? Colors.amber
                      : Colors.grey[400],
                  child: Icon(
                    user.plan == 'premium'
                        ? Icons.star_rounded
                        : Icons.person_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          controller.accountType,
          style: TextStyle(
            color: user.plan == 'premium' ? Colors.amber : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          controller.userSince,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProfileForm(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Nom
            TextFormField(
              controller: controller.nameController,
              enabled: controller.isEditing.value,
              decoration: InputDecoration(
                labelText: 'Nom complet',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: !controller.isEditing.value,
                fillColor: !controller.isEditing.value
                    ? Colors.grey[100]
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: controller.emailController,
              enabled: controller.isEditing.value,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: !controller.isEditing.value,
                fillColor: !controller.isEditing.value
                    ? Colors.grey[100]
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Plan
            ListTile(
              leading: const Icon(Icons.workspace_premium_rounded),
              title: const Text('Plan'),
              subtitle: Text(user.plan == 'premium' ? 'Premium' : 'Gratuit'),
              trailing: user.plan != 'premium'
                  ? TextButton(
                      onPressed: () {
                        // TODO: Rediriger vers upgrade premium
                      },
                      child: const Text('Passer à Premium'),
                    )
                  : const Icon(Icons.check_circle, color: Colors.green),
            ),
            const Divider(),

            // Date d'inscription
            ListTile(
              leading: const Icon(Icons.calendar_today_rounded),
              title: const Text('Membre depuis'),
              subtitle: Text(
                user.createdAt != null
                    ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                    : 'Nouvel utilisateur',
              ),
            ),

            // Bouton sauvegarder (mode édition)
            if (controller.isEditing.value) ...[
              const SizedBox(height: 16),
              Obx(
                () => controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: controller.saveProfile,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Sauvegarder'),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Card(
      child: Column(
        children: [
          // Déconnexion
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.orange),
            title: const Text('Déconnexion'),
            onTap: controller.logout,
          ),
          const Divider(),

          // Supprimer le compte
          ListTile(
            leading: const Icon(
              Icons.delete_forever_rounded,
              color: Colors.red,
            ),
            title: const Text(
              'Supprimer mon compte',
              style: TextStyle(color: Colors.red),
            ),
            onTap: controller.deleteAccount,
          ),
        ],
      ),
    );
  }
}
