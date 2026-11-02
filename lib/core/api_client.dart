import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_exceptions.dart';
import 'config.dart';

Dio buildDio({String? Function()? tokenProvider}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = tokenProvider?.call();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          debugPrint('--> ${options.method} ${options.uri}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final status = response.statusCode ?? 0;
        if (kDebugMode) {
          debugPrint('<-- $status ${response.requestOptions.uri}');
        }
        if (status >= 400) {
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: mapHttpError(status, response.data),
            ),
          );
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          debugPrint('[API Error] ${error.requestOptions.uri}: ${error.type} (${error.message})');
        }

        // Автоматический повтор (Retry) только для GET-запросов при сбоях связи (до 3 попыток)
        final req = error.requestOptions;
        final isGet = req.method.toUpperCase() == 'GET';
        final isNetwork = error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout;

        int retryCount = req.extra['retryCount'] ?? 0;
        if (isGet && isNetwork && retryCount < 3) {
          retryCount++;
          req.extra['retryCount'] = retryCount;
          final delayMs = retryCount * 500;
          if (kDebugMode) {
            debugPrint('[Retry #$retryCount in ${delayMs}ms] ${req.uri}');
          }
          await Future.delayed(Duration(milliseconds: delayMs));
          try {
            final response = await dio.fetch(req);
            return handler.resolve(response);
          } on DioException catch (retryError) {
            return handler.next(retryError);
          }
        }

        return handler.next(error);
      },
    ),
  );

  return dio;
}
