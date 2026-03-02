import 'package:get/get.dart';
import 'package:smart_do/models/user_model.dart';
import 'package:smart_do/services/auth_service.dart';
import 'package:smart_do/services/snackbar_service.dart';
import 'package:smart_do/app/routes/app_routes.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final SnackbarService _snackbarService = Get.find<SnackbarService>();

  // États observables
  final user = Rx<UserModel?>(null);
  final isLoading = false.obs;
  final isEditing = false.obs;

  // Form controllers pour l'édition
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  // Charger les données utilisateur
  void loadUserData() {
    user.value = _authService.currentUser.value;
    _initFormControllers();
  }

  // Initialiser les contrôleurs de formulaire
  void _initFormControllers() {
    if (user.value != null) {
      nameController.text = user.value!.name;
      emailController.text = user.value!.email;
    }
  }

  // Activer le mode édition
  void enableEdit() {
    isEditing.value = true;
  }

  // Annuler l'édition
  void cancelEdit() {
    isEditing.value = false;
    _initFormControllers();
  }

  // Sauvegarder les modifications
  Future<void> saveProfile() async {
    if (!_validateForm()) return;

    isLoading.value = true;

    try {
      // TODO: Implémenter l'appel API pour mettre à jour le profil
      // Pour l'instant, on met juste à jour localement

      final updatedUser = user.value!.copyWith(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
      );

      user.value = updatedUser;
      isEditing.value = false;

      _snackbarService.showSuccess('Profil mis à jour avec succès');
    } catch (e) {
      _snackbarService.showError('Erreur lors de la mise à jour');
    } finally {
      isLoading.value = false;
    }
  }

  // Validation du formulaire
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _snackbarService.showError('Le nom est requis');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _snackbarService.showError('L\'email est requis');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      _snackbarService.showError('Email invalide');
      return false;
    }
    return true;
  }

  // Déconnexion
  Future<void> logout() async {
    final confirmed = await _showLogoutConfirmation();
    if (!confirmed) return;

    await _authService.logout();
    _snackbarService.showSuccess('Déconnexion réussie');
    Get.offAllNamed(AppRoutes.login);
  }

  // Supprimer le compte (avec confirmation)
  Future<void> deleteAccount() async {
    final confirmed = await _showDeleteAccountConfirmation();
    if (!confirmed) return;

    isLoading.value = true;

    try {
      // TODO: Implémenter l'appel API pour supprimer le compte

      await _authService.logout();
      _snackbarService.showSuccess('Compte supprimé avec succès');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _snackbarService.showError('Erreur lors de la suppression du compte');
    } finally {
      isLoading.value = false;
    }
  }

  // Boîtes de dialogue de confirmation
  Future<bool> _showLogoutConfirmation() async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: Text('Confirmation'),
            content: Text('Voulez-vous vraiment vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('Déconnexion'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showDeleteAccountConfirmation() async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: Text('Confirmation'),
            content: Text(
              'Voulez-vous vraiment supprimer votre compte ? '
              'Cette action est irréversible.',
            ),
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

  // Propriétés calculées
  String get userSince {
    if (user.value?.createdAt == null) return 'Nouvel utilisateur';
    final created = user.value!.createdAt!;
    final now = DateTime.now();
    final difference = now.difference(created);

    if (difference.inDays > 365) {
      return 'Membre depuis ${(difference.inDays / 365).floor()} an(s)';
    } else if (difference.inDays > 30) {
      return 'Membre depuis ${(difference.inDays / 30).floor()} mois';
    } else {
      return 'Membre depuis ${difference.inDays} jours';
    }
  }

  String get accountType {
    return user.value?.plan == 'premium' ? 'Premium' : 'Gratuit';
  }

  bool get isPremium {
    return user.value?.plan == 'premium';
  }
}
