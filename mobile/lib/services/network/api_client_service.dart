import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as devtools;

import '../../core/config/environment_config.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../di/service_locator.dart';

class SecureStorageService {
  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';
  static const _userType = 'USER_TYPE';
  static const _sellerTermsAcceptedKey = 'SELLER_TERMS_ACCEPTED';

  final FlutterSecureStorage _storage;
  SecureStorageService({required FlutterSecureStorage storage})
    : _storage = storage;

  Future<void> saveJwtTokens({
    required String accessToken,
    required String refreshToken,
    String? userType,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userType, value: userType);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<String?> getType() async {
    return await _storage.read(key: _userType);
  }

  Future<void> markSellerTermsAccepted(String userId) async {
    await _storage.write(
      key: '${_sellerTermsAcceptedKey}_$userId',
      value: 'true',
    );
  }

  Future<bool> hasAcceptedSellerTerms(String userId) async {
    final result = await _storage.read(
      key: '${_sellerTermsAcceptedKey}_$userId',
    );
    return result == 'true';
  }

  Future<void> saveUserType(String userType) async {
    await _storage.write(key: _userType, value: userType);
  }

  Future<void> saveJwtToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userType);
  }

  Future<void> clearUserType() async {
    await _storage.delete(key: _userType);
  }
}

class ApiClient {
  static final ValueNotifier<bool> networkPauseNotifier = ValueNotifier<bool>(
    false,
  );

  final Dio dio;
  String? _jwtToken;
  String? _jwtRefreshToken;

  SecureStorageService get _secureStorage => getIt<SecureStorageService>();

  Future<void> Function()? onTokenExpired;

  ApiClient({required String baseUrl})
    : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Resume background sync on any successful request
    networkPauseNotifier.value = false;

    devtools.log(
      'Response | ${response.requestOptions.method} ${response.requestOptions.path}',
    );
    devtools.log('Status: ${response.statusCode}');
    devtools.log('Data: ${response.data}');

    handler.next(response);
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check for internet connection first
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = !connectivityResult.contains(ConnectivityResult.none);

    if (!hasConnection) {
      ApiClient.networkPauseNotifier.value = true;
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No Internet Connection',
        ),
      );
    }

    options.baseUrl = options.baseUrl.replaceAll(RegExp(r'(?<!:)//'), '/');
    options.path = options.path.replaceAll(RegExp(r'(?<!:)//'), '/');

    if (options.baseUrl.endsWith('/') && options.path.startsWith('/')) {
      options.path = options.path.substring(1);
    }

    if (options.queryParameters.isNotEmpty) {
      options.queryParameters = options.queryParameters.map((key, value) {
        if (value is String) {
          return MapEntry(key, value.trim());
        } else if (value is List) {
          return MapEntry(
            key,
            value.map((e) => e is String ? e.trim() : e).toList(),
          );
        }
        return MapEntry(key, value);
      });
    }

    if (options.extra['isPrivate'] == true) {
      if (_jwtToken == null || _jwtRefreshToken == null) {
        await getJwtTokens();
      }
      if (_jwtToken != null) {
        devtools.log('Authorization: Bearer $_jwtToken');
        options.headers['Authorization'] = 'Bearer $_jwtToken';
      }
    }
    handler.next(options);
  }

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final response = error.response;
    final statusCode = response?.statusCode;

    if (statusCode == 401 && error.requestOptions.extra['isPrivate'] == true) {
      if (!_isRefreshing) {
        _isRefreshing = true;
        _refreshCompleter = Completer<void>();

        try {
          await _refreshToken();
          _isRefreshing = false;
          _refreshCompleter?.complete();
        } catch (e) {
          _isRefreshing = false;
          _refreshCompleter?.completeError(e);

          if (e is! NetworkException) {
            await clearJwtToken();
            if (onTokenExpired != null) {
              await onTokenExpired!();
            }
          }
          return handler.reject(error);
        }
      } else {
        try {
          await _refreshCompleter?.future;
        } catch (e) {
          return handler.reject(error);
        }
      }

      try {
        if (_jwtToken != null) {
          error.requestOptions.headers['Authorization'] = 'Bearer $_jwtToken';
        }

        final retry = await dio.request(
          error.requestOptions.path,
          data: error.requestOptions.data,
          queryParameters: error.requestOptions.queryParameters,
          options: Options(
            method: error.requestOptions.method,
            headers: error.requestOptions.headers,
            extra: error.requestOptions.extra,
          ),
        );
        return handler.resolve(retry);
      } catch (e) {
        return handler.reject(e is DioException ? e : error);
      }
    }

    return handler.next(error);
  }

  Future<void> getJwtTokens() async {
    _jwtToken = await _secureStorage.getAccessToken();
    _jwtRefreshToken = await _secureStorage.getRefreshToken();
  }

  Future<void> setJwtToken(String token, String refreshToken) async {
    await _secureStorage.saveJwtTokens(
      accessToken: token,
      refreshToken: refreshToken,
    );
    _jwtToken = token;
    _jwtRefreshToken = refreshToken;
  }

  Future<void> clearJwtToken() async {
    await _secureStorage.clearTokens();
    _jwtToken = null;
    _jwtRefreshToken = null;
  }

  Future<Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool isPrivate = true,
  }) async {
    try {
      return await dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          contentType: 'application/json',
          extra: {'isPrivate': isPrivate},
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool isPrivate = true,
  }) async {
    try {
      return await dio.post(
        endpoint,
        data: body,
        options: Options(
          headers: headers,
          contentType: 'application/json',
          extra: {'isPrivate': isPrivate},
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> postMultipart(
    String endpoint,
    FormData body, {
    Map<String, String>? headers,
    bool isPrivate = true,
  }) async {
    try {
      return await dio.post(
        endpoint,
        data: body,
        options: Options(
          headers: headers,
          contentType: 'multipart/form-data',
          extra: {'isPrivate': isPrivate},
          sendTimeout: const Duration(minutes: 3),
          receiveTimeout: const Duration(minutes: 3),
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool isPrivate = true,
  }) async {
    try {
      return await dio.put(
        endpoint,
        data: body,
        options: Options(
          headers: headers,
          contentType: 'application/json',
          extra: {'isPrivate': isPrivate},
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> patch(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool isPrivate = true,
  }) async {
    try {
      return await dio.patch(
        endpoint,
        data: jsonEncode(body),
        options: Options(
          headers: headers,
          contentType: 'application/json',
          extra: {'isPrivate': isPrivate},
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool isPrivate = true,
  }) async {
    try {
      return await dio.delete(
        endpoint,
        options: Options(
          headers: headers,
          contentType: 'application/json',
          extra: {'isPrivate': isPrivate},
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> _refreshToken() async {
    if (_jwtRefreshToken == null) {
      throw ApiFailure('No refresh token available', 401);
    }

    try {
      final response = await dio.post(
        "${AppConsts.apiBaseUrl}/api/auth/token/refresh",
        data: {'refreshToken': _jwtRefreshToken},
        options: Options(extra: {'isPrivate': false}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['accessToken'];

        await _secureStorage.saveJwtToken(newAccessToken);
        _jwtToken = newAccessToken;
      } else if (response.statusCode == 404) {
        throw ApiFailure('No User Found', 401);
      } else {
        throw ApiFailure('Failed to refresh token', response.statusCode);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError ||
          (e.type == DioExceptionType.unknown &&
              e.message?.contains('SocketException') == true)) {
        throw const NetworkException();
      }
      throw ApiFailure(
        'Failed to refresh token: ${e.message}',
        e.response?.statusCode,
      );
    }
  }

  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      networkPauseNotifier.value = true;
      return const NetworkException();
    }

    // Dio handles SocketException under DioExceptionType.unknown in some versions
    if (error.type == DioExceptionType.unknown &&
        error.message?.contains('SocketException') == true) {
      networkPauseNotifier.value = true;
      return const NetworkException();
    }

    final response = error.response;
    final statusCode = response?.statusCode;

    String? message;
    if (response?.data is Map<String, dynamic>) {
      message = response?.data['error'] ?? response?.data['message'];
    } else if (response?.data is String) {
      message = response?.data;
    }
    message ??= error.message ?? 'An error occurred';

    switch (statusCode) {
      case 400:
        if (response?.data is Map && response?.data['errors'] is List) {
          final errors = (response?.data['errors'] as List).cast<String>().join(
            '\n',
          );
          return ValidationException(errors, response?.data['errors']);
        }
        return ValidationException(
          message,
          response?.data is Map ? response?.data['errors'] : null,
        );
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ApiException(403, message ?? 'Account is inactive or has been deleted.');
      case 404:
        return NotFoundException(message);
      case 409:
        return ConflictException(message);
      case 500:
        return ServerException(message);
      default:
        if (EnvironmentConfig.isDevelopment) {
          return ApiException(statusCode, message);
        }
        return const ServerException('Server error. Please try again later.');
    }
  }

  void dispose() {
    dio.close();
  }
}
