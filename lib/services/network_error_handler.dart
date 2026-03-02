import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:smart_do/services/snackbar_service.dart';

class NetworkErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Délai de connexion dépassé';
        case DioExceptionType.receiveTimeout:
          return 'Délai de réception dépassé';
        case DioExceptionType.sendTimeout:
          return 'Délai d\'envoi dépassé';
        case DioExceptionType.cancel:
          return 'Requête annulée';
        case DioExceptionType.connectionError:
          return 'Erreur de connexion';
        case DioExceptionType.badResponse:
          return _handleBadResponse(error.response);
        default:
          return 'Erreur réseau inattendue';
      }
    }
    return error.toString();
  }

  static String _handleBadResponse(Response? response) {
    if (response == null) return 'Erreur serveur';

    switch (response.statusCode) {
      case 400:
        return 'Requête invalide';
      case 401:
        return 'Non authentifié';
      case 403:
        return 'Accès non autorisé';
      case 404:
        return 'Ressource non trouvée';
      case 409:
        return 'Conflit - Données déjà existantes';
      case 422:
        return 'Données invalides';
      case 500:
        return 'Erreur serveur interne';
      case 503:
        return 'Service temporairement indisponible';
      default:
        return 'Erreur ${response.statusCode}';
    }
  }

  static void showError(dynamic error) {
    Get.find<SnackbarService>().showError(getErrorMessage(error));
  }
}
