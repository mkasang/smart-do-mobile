import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:smart_do/models/user_model.dart';
import 'package:smart_do/services/api_service.dart';
import 'package:smart_do/app/constants/api_endpoints.dart';
import 'package:smart_do/services/snackbar_service.dart';

class AuthService extends GetxService {
  final _storage = const FlutterSecureStorage();
  final _apiService = Get.find<ApiService>();

  // États observables
  final token = ''.obs;
  final currentUser = Rx<UserModel?>(null);
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStoredToken();
  }

  // Charger le token stocké au démarrage
  Future<void> _loadStoredToken() async {
    try {
      final storedToken = await _storage.read(key: 'auth_token');
      if (storedToken != null && storedToken.isNotEmpty) {
        token.value = storedToken;
        await getProfile();
      }
    } catch (e) {
      print('Erreur chargement token: $e');
    }
  }

  // Inscription
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        path: ApiEndpoints.register,
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.success && response.data != null) {
        final userData = response.data!['user'] as Map<String, dynamic>;
        final newToken = response.data!['token'] as String;

        // Sauvegarder le token
        await _saveToken(newToken);

        // Créer l'utilisateur
        currentUser.value = UserModel.fromJson(userData);

        return true;
      } else {
        Get.find<SnackbarService>().showError(
          response.message ?? 'Erreur inscription',
        );
        return false;
      }
    } catch (e) {
      Get.find<SnackbarService>().showError('Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Connexion
  Future<bool> login({required String email, required String password}) async {
    isLoading.value = true;

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        path: ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (response.success && response.data != null) {
        final userData = response.data!['user'] as Map<String, dynamic>;
        final newToken = response.data!['token'] as String;

        // Sauvegarder le token
        await _saveToken(newToken);

        // Créer l'utilisateur
        currentUser.value = UserModel.fromJson(userData);

        return true;
      } else {
        Get.find<SnackbarService>().showError(
          response.message ?? 'Erreur connexion',
        );
        return false;
      }
    } catch (e) {
      Get.find<SnackbarService>().showError('Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer le profil
  Future<void> getProfile() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        path: ApiEndpoints.profile,
      );

      if (response.success && response.data != null) {
        final userData = response.data!['user'] as Map<String, dynamic>;
        currentUser.value = UserModel.fromJson(userData);

        // Sauvegarder en cache
        await _cacheUser(userData);
      }
    } catch (e) {
      print('Erreur profil: $e');
    }
  }

  // Déconnexion
  Future<void> logout() async {
    isLoading.value = true;

    try {
      // Appel API optionnel pour logout côté serveur
      // await _apiService.post(path: '/logout');

      // Nettoyer le stockage
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'cached_user');

      // Réinitialiser les états
      token.value = '';
      currentUser.value = null;
    } catch (e) {
      print('Erreur logout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Sauvegarder le token
  Future<void> _saveToken(String newToken) async {
    await _storage.write(key: 'auth_token', value: newToken);
    token.value = newToken;
  }

  // Sauvegarder l'utilisateur en cache
  Future<void> _cacheUser(Map<String, dynamic> userData) async {
    final userJson = jsonEncode(userData);
    await _storage.write(key: 'cached_user', value: userJson);
  }

  // Vérifier si l'utilisateur est connecté
  bool get isLoggedIn => token.value.isNotEmpty;

  // Récupérer le token (pour les intercepteurs)
  String get getToken => token.value;
}
