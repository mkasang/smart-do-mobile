import 'package:get/get.dart';
import 'package:smart_do/services/auth_service.dart';
import 'package:smart_do/services/snackbar_service.dart';
import 'package:smart_do/app/routes/app_routes.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final SnackbarService _snackbarService = Get.find<SnackbarService>();

  // États observables
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Connexion
  Future<void> login() async {
    if (!_validateLoginForm()) return;

    isLoading.value = true;

    try {
      final success = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (success) {
        _snackbarService.showSuccess('Connexion réussie');
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Inscription
  Future<void> register() async {
    if (!_validateRegisterForm()) return;

    isLoading.value = true;

    try {
      final success = await _authService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (success) {
        _snackbarService.showSuccess('Inscription réussie');
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _authService.logout();
      _snackbarService.showSuccess('Déconnexion réussie');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _snackbarService.showError('Erreur lors de la déconnexion');
    }
  }

  // Validation formulaire login
  bool _validateLoginForm() {
    if (emailController.text.isEmpty) {
      _snackbarService.showError('L\'email est requis');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text)) {
      _snackbarService.showError('Email invalide');
      return false;
    }
    if (passwordController.text.isEmpty) {
      _snackbarService.showError('Le mot de passe est requis');
      return false;
    }
    if (passwordController.text.length < 6) {
      _snackbarService.showError(
        'Le mot de passe doit contenir au moins 6 caractères',
      );
      return false;
    }
    return true;
  }

  // Validation formulaire inscription
  bool _validateRegisterForm() {
    if (nameController.text.isEmpty) {
      _snackbarService.showError('Le nom est requis');
      return false;
    }
    if (emailController.text.isEmpty) {
      _snackbarService.showError('L\'email est requis');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text)) {
      _snackbarService.showError('Email invalide');
      return false;
    }
    if (passwordController.text.isEmpty) {
      _snackbarService.showError('Le mot de passe est requis');
      return false;
    }
    if (passwordController.text.length < 6) {
      _snackbarService.showError(
        'Le mot de passe doit contenir au moins 6 caractères',
      );
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _snackbarService.showError('Les mots de passe ne correspondent pas');
      return false;
    }
    return true;
  }

  // Basculer visibilité mot de passe
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // Vérifier si utilisateur est connecté
  bool get isLoggedIn => _authService.isLoggedIn;
}
