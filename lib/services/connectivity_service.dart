import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:smart_do/services/snackbar_service.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();

  // État observable de la connexion
  final isConnected = true.obs;
  final connectionType = Rx<ConnectivityResult>(ConnectivityResult.none);

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _listenToConnectivityChanges();
  }

  // Initialiser la connexion
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Erreur vérification connectivité: $e');
      isConnected.value = false;
    }
  }

  // Écouter les changements de connexion
  void _listenToConnectivityChanges() {
    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  // Mettre à jour le statut
  void _updateConnectionStatus(ConnectivityResult result) {
    connectionType.value = result;

    final newStatus = result != ConnectivityResult.none;
    final wasConnected = isConnected.value;

    isConnected.value = newStatus;

    // Afficher un message si le statut change
    if (wasConnected != newStatus) {
      if (newStatus) {
        Get.find<SnackbarService>().showSuccess('Connexion rétablie');
      } else {
        Get.find<SnackbarService>().showWarning(
          'Mode hors ligne - Données en cache',
        );
      }
    }
  }

  // Vérifier si connecté
  bool get hasInternet => isConnected.value;

  // Vérifier le type de connexion
  bool get isOnWifi => connectionType.value == ConnectivityResult.wifi;
  bool get isOnMobile => connectionType.value == ConnectivityResult.mobile;

  // Méthode manuelle pour vérifier la connexion
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Stream pour observer les changements
  Stream<ConnectivityResult> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}
