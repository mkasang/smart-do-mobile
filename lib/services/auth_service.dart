import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:smart_do/app/routes/app_routes.dart';
import 'package:smart_do/models/user_model.dart';
import 'package:smart_do/services/api_service.dart';
import 'package:smart_do/services/snackbar_service.dart';
import 'package:smart_do/app/constants/api_endpoints.dart';

class AuthService extends GetxService {
  final _storage = const FlutterSecureStorage();
  late final ApiService _apiService;
  late final SnackbarService _snackbarService;

  // États observables
  final token = ''.obs;
  final currentUser = Rx<UserModel?>(null);
  final isLoading = false.obs;
  final isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>();
    _snackbarService = Get.find<SnackbarService>();
    _loadStoredToken();
  }

  // Charger le token stocké au démarrage
  Future<void> _loadStoredToken() async {
    try {
      print('🔐 Chargement du token stocké...');
      final storedToken = await _storage.read(key: 'auth_token');

      if (storedToken != null && storedToken.isNotEmpty) {
        print('✅ Token trouvé: ${storedToken.substring(0, 20)}...');
        token.value = storedToken;

        // Tenter de récupérer le profil avec ce token
        final success = await getProfile();

        if (success) {
          print('✅ Profil chargé avec succès, utilisateur connecté');
          isInitialized.value = true;

          // Rediriger vers dashboard si on est sur login
          if (Get.currentRoute == AppRoutes.login) {
            print('🔄 Redirection vers dashboard...');
            Get.offAllNamed(AppRoutes.dashboard);
          }
        } else {
          print('❌ Échec chargement profil, token invalide');
          await logout(); // Nettoie le token invalide
          isInitialized.value = true;
        }
      } else {
        print('ℹ️ Aucun token trouvé');
        isInitialized.value = true;
      }
    } catch (e) {
      print('❌ Erreur chargement token: $e');
      isInitialized.value = true;
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

        _snackbarService.showSuccess('Inscription réussie');
        return true;
      } else {
        _snackbarService.showError(response.message ?? 'Erreur inscription');
        return false;
      }
    } catch (e) {
      print('❌ Erreur register: $e');
      _snackbarService.showError('Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Connexion
  Future<bool> login({required String email, required String password}) async {
    isLoading.value = true;

    try {
      print('🔐 Tentative de connexion pour: $email');

      final response = await _apiService.post<Map<String, dynamic>>(
        path: ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (response.success && response.data != null) {
        final userData = response.data!['user'] as Map<String, dynamic>;
        final newToken = response.data!['token'] as String;

        print('✅ Connexion réussie, token reçu');

        // Sauvegarder le token
        await _saveToken(newToken);

        // Créer l'utilisateur
        currentUser.value = UserModel.fromJson(userData);

        _snackbarService.showSuccess('Connexion réussie');
        return true;
      } else {
        print('❌ Échec connexion: ${response.message}');
        _snackbarService.showError(response.message ?? 'Erreur connexion');
        return false;
      }
    } catch (e) {
      print('❌ Erreur login: $e');
      _snackbarService.showError('Erreur: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer le profil
  Future<bool> getProfile() async {
    try {
      print('👤 Récupération du profil...');

      final response = await _apiService.get<Map<String, dynamic>>(
        path: ApiEndpoints.profile,
      );

      if (response.success && response.data != null) {
        final userData = response.data!['user'] as Map<String, dynamic>;
        currentUser.value = UserModel.fromJson(userData);

        // Sauvegarder en cache
        await _cacheUser(userData);

        print('✅ Profil récupéré: ${currentUser.value?.name}');
        return true;
      } else {
        print('❌ Échec récupération profil');
        return false;
      }
    } catch (e) {
      print('❌ Erreur profil: $e');
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    isLoading.value = true;

    try {
      print('🔓 Déconnexion...');

      // Nettoyer le stockage
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'cached_user');

      // Réinitialiser les états
      token.value = '';
      currentUser.value = null;

      print('✅ Déconnexion réussie');

      // Rediriger vers login
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      print('❌ Erreur logout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Sauvegarder le token
  Future<void> _saveToken(String newToken) async {
    await _storage.write(key: 'auth_token', value: newToken);
    token.value = newToken;
    print('💾 Token sauvegardé');
  }

  // Sauvegarder l'utilisateur en cache
  Future<void> _cacheUser(Map<String, dynamic> userData) async {
    final userJson = jsonEncode(userData);
    await _storage.write(key: 'cached_user', value: userJson);
  }

  // Vérifier si l'utilisateur est connecté
  bool get isLoggedIn {
    final hasToken = token.value.isNotEmpty;
    final hasUser = currentUser.value != null;
    print('🔐 Vérification connexion: token=$hasToken, user=$hasUser');
    return hasToken && hasUser;
  }

  // Récupérer le token (pour les intercepteurs)
  String get getToken => token.value;
}
