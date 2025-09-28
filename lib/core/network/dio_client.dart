import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:handscore/core/secure/secure_store.dart';

class DioClient {
  final Dio dio;

  DioClient._(this.dio);

  factory DioClient(
    String baseUrl, {
    HttpClient Function()? httpClientFactory,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl, // ✅ já vem com /api/v1 do provider/env
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {HttpHeaders.acceptHeader: 'application/json'},
      ),
    );

    // Em debug, aceite cert self-signed de localhost/10.0.2.2
    assert(() {
      (dio.httpClientAdapter as dynamic).onHttpClientCreate = (client) {
        final c = HttpClient();
        c.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
              return host == '10.0.2.2' ||
                  host == '127.0.0.1' ||
                  host == 'localhost';
            };
        return c;
      };
      return true;
    }());

    // (opcional) LogInterceptor
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    if (kDebugMode) {
      (dio.httpClientAdapter as dynamic).onHttpClientCreate = (client) {
        final c = HttpClient();
        // só confia em localhost/10.0.2.2 em dev
        c.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
              return host == 'localhost' ||
                  host == '10.0.2.2' ||
                  host == '127.0.0.1';
            };
        return c;
      };
    }

    // Auth + TrustedDevice header
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final at = await SecureStore.read(SecureStore.kAccessToken);
          if (at != null && at.isNotEmpty) {
            options.headers[HttpHeaders.authorizationHeader] = 'Bearer $at';
          }
          final tdt = await SecureStore.read(SecureStore.kTrustedDeviceToken);
          if (tdt != null && tdt.isNotEmpty) {
            options.headers['X-Trusted-Device'] = tdt;
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          // Auto refresh (se houver refresh endpoint)
          if (e.response?.statusCode == 401) {
            final refreshed = await _tryRefreshToken(dio);
            if (refreshed) {
              final req = e.requestOptions;
              final clone = await dio.fetch<dynamic>(req);
              return handler.resolve(clone);
            }
          }
          handler.next(e);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );

    // TLS pinning via HttpClient se fornecido
    if (httpClientFactory != null) {
      (dio.httpClientAdapter as dynamic).onHttpClientCreate = (client) =>
          httpClientFactory();
    }

    return DioClient._(dio);
  }

  static Future<bool> _tryRefreshToken(Dio dio) async {
    final rt = await SecureStore.read(SecureStore.kRefreshToken);
    if (rt == null) return false;
    try {
      final res = await dio.post(
        '/api/auth/refresh',
        data: {'refresh_token': rt},
        options: Options(headers: {HttpHeaders.authorizationHeader: null}),
      );
      final data = res.data as Map;
      await SecureStore.write(SecureStore.kAccessToken, data['access_token']);
      if (data['refresh_token'] != null) {
        await SecureStore.write(
          SecureStore.kRefreshToken,
          data['refresh_token'],
        );
      }
      return true;
    } catch (_) {
      await SecureStore.delete(SecureStore.kAccessToken);
      await SecureStore.delete(SecureStore.kRefreshToken);
      return false;
    }
  }
}
