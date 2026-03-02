import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:smart_do/app/constants/api_endpoints.dart';
import 'package:smart_do/services/auth_service.dart';
import 'package:smart_do/services/snackbar_service.dart';
import 'package:smart_do/app/routes/app_routes.dart';

class ApiService extends GetxService {
  late Dio _dio;
  final snackbarService = Get.find<SnackbarService>();

  @override
  void onInit() {
    super.onInit();
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Ajout des intercepteurs
    _dio.interceptors.add(_authInterceptor);
    _dio.interceptors.add(_loggingInterceptor);
    _dio.interceptors.add(_errorInterceptor);
  }

  // Intercepteur pour ajouter le token JWT
  Interceptor get _authInterceptor => InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = Get.find<AuthService>().token.value;
      if (token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  );

  // Intercepteur pour le logging en debug
  Interceptor get _loggingInterceptor => InterceptorsWrapper(
    onRequest: (options, handler) {
      if (kDebugMode) {
        print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
        print('📤 DATA: ${options.data}');
        print('🔑 HEADERS: ${options.headers}');
      }
      return handler.next(options);
    },
    onResponse: (response, handler) {
      if (kDebugMode) {
        print('✅ RESPONSE[${response.statusCode}] => DATA: ${response.data}');
      }
      return handler.next(response);
    },
    onError: (error, handler) {
      if (kDebugMode) {
        print(
          '❌ ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}',
        );
        print('📄 DATA: ${error.response?.data}');
      }
      return handler.next(error);
    },
  );

  // Intercepteur pour la gestion centralisée des erreurs
  Interceptor get _errorInterceptor => InterceptorsWrapper(
    onError: (error, handler) async {
      // Gestion du token expiré (401)
      if (error.response?.statusCode == 401) {
        await Get.find<AuthService>().logout();
        Get.offAllNamed(AppRoutes.login);
        snackbarService.showError('Session expirée, veuillez vous reconnecter');
        return handler.reject(error);
      }

      // Gestion des erreurs serveur (500)
      if (error.response?.statusCode == 500) {
        snackbarService.showError(
          'Erreur serveur. Veuillez réessayer plus tard.',
        );
      }

      // Gestion des erreurs de connexion
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        snackbarService.showError(
          'Problème de connexion. Vérifiez votre réseau.',
        );
      }

      return handler.next(error);
    },
  );

  // Méthodes génériques avec retour structuré
  Future<ApiResponse<T>> get<T>({
    required String path,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<T>> post<T>({
    required String path,
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<T>> put<T>({
    required String path,
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<T>> patch<T>({
    required String path,
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(path, data: data);
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>({
    required String path,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Gestion de la réponse
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;

      // Format standard de l'API
      if (data is Map &&
          data.containsKey('status') &&
          data['status'] == 'success') {
        final responseData = data['data'];

        if (fromJson != null && responseData != null) {
          return ApiResponse.success(
            data: fromJson(responseData),
            message: data['message'],
          );
        }

        return ApiResponse.success(
          data: responseData as T?,
          message: data['message'],
        );
      }

      // Format non standard mais succès
      return ApiResponse.success(data: data as T?);
    }

    return ApiResponse.error(message: 'Erreur inattendue');
  }

  // Gestion des erreurs
  ApiResponse<T> _handleError<T>(DioException error) {
    String message = 'Une erreur est survenue';

    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('message')) {
        message = data['message'];
      } else if (data is Map && data.containsKey('error')) {
        message = data['error'];
      }

      // Gestion des erreurs de validation (400)
      if (error.response?.statusCode == 400 && data is Map) {
        if (data.containsKey('errors')) {
          final errors = data['errors'] as Map;
          message = errors.values.first.toString();
        }
      }

      // Gestion des conflits (409)
      if (error.response?.statusCode == 409) {
        message = data['message'] ?? 'Email déjà utilisé';
      }
    }

    return ApiResponse.error(message: message);
  }
}

// Classe de réponse générique
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({required this.success, this.data, this.message});

  factory ApiResponse.success({T? data, String? message}) {
    return ApiResponse(success: true, data: data, message: message);
  }

  factory ApiResponse.error({String? message}) {
    return ApiResponse(success: false, message: message);
  }
}
