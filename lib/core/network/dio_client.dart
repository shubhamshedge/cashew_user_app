import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

class DioClient {
  late final Dio _dio;
  final SecureStorageService _storageService;

  DioClient(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            final fullUrl = options.uri.toString();
            debugPrint('==================== 🌐 API REQUEST 🌐 ====================');
            debugPrint('--> [${options.method}] $fullUrl');
            if (options.queryParameters.isNotEmpty) {
              debugPrint('Query Parameters: ${options.queryParameters}');
            }
            if (options.data != null) {
              debugPrint('Body Parameters: ${options.data}');
            }
            debugPrint('Headers: ${options.headers}');
            debugPrint('===========================================================');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            final fullUrl = response.requestOptions.uri.toString();
            debugPrint('==================== ✅ API RESPONSE ✅ ====================');
            debugPrint('<-- [${response.statusCode}] [${response.requestOptions.method}] $fullUrl');
            debugPrint('Response Data: ${response.data}');
            debugPrint('============================================================');
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            final fullUrl = error.requestOptions.uri.toString();
            debugPrint('==================== ❌ API ERROR ❌ ====================');
            debugPrint('<-- [${error.response?.statusCode ?? "NO_CODE"}] [${error.requestOptions.method}] $fullUrl');
            debugPrint('Error Message: ${error.message}');
            debugPrint('Error Response Data: ${error.response?.data}');
            debugPrint('==========================================================');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  dynamic _handleResponse(Response response) {
    print("Shubham => Response = ${response}");
    final body = response.data;
    print("Shubham => response.data = ${response.data}");
    if (body is Map<String, dynamic> && body.containsKey('success')) {
      if (body['success'] == true) {
        return body['data'];
      } else {
        throw ApiException(
          message: body['message'] ?? 'API request failed',
          errors: body['errors'],
        );
      }
    }
    return body;
  }

  ApiException _handleDioError(DioException error) {
    if (error.response != null && error.response?.data != null) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        return ApiException(
          message: data['message'] ?? 'Server error occurred',
          statusCode: error.response?.statusCode,
          errors: data['errors'],
        );
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException(message: 'Connection timed out. Please try again.');
    } else if (error.type == DioExceptionType.connectionError) {
      return ApiException(message: 'Unable to connect to server. Check your network or backend URL.');
    }

    return ApiException(
      message: error.message ?? 'An unexpected network error occurred.',
      statusCode: error.response?.statusCode,
    );
  }
}
