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
        baseUrl: baseUrl, // já inclui /api/v1
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {HttpHeaders.acceptHeader: 'application/json'},
      ),
    );

    // HttpClient custom (dev certificates) — defina UMA vez
    void setDevBadCerts() {
      (dio.httpClientAdapter as dynamic).onHttpClientCreate = (client) {
        final c = httpClientFactory?.call() ?? HttpClient();
        c.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
              return host == 'localhost' ||
                  host == '127.0.0.1' ||
                  host == '10.0.2.2';
            };
        return c;
      };
    }

    assert(() {
      setDevBadCerts();
      return true;
    }());
    if (kDebugMode) {
      setDevBadCerts();
    }

    // Log (apenas um)
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

    // Auth + TrustedDevice + Refresh
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
          // Tenta refresh quando 401
          if (e.response?.statusCode == 401) {
            final refreshed = await _tryRefreshToken(dio);
            if (refreshed) {
              // Reexecuta a request original COM o novo bearer
              final req = e.requestOptions;
              final at = await SecureStore.read(SecureStore.kAccessToken);
              if (at != null && at.isNotEmpty) {
                req.headers[HttpHeaders.authorizationHeader] = 'Bearer $at';
              }
              try {
                final clone = await dio.fetch<dynamic>(req);
                return handler.resolve(clone);
              } catch (err) {
                return handler.next(e);
              }
            }
          }
          handler.next(e);
        },
      ),
    );

    // TLS pinning/custom HttpClient se fornecido
    if (httpClientFactory != null) {
      (dio.httpClientAdapter as dynamic).onHttpClientCreate = (client) =>
          httpClientFactory();
    }

    return DioClient._(dio);
  }

  static Future<bool> _tryRefreshToken(Dio dio) async {
    final rt = await SecureStore.read(SecureStore.kRefreshToken);
    if (rt == null || rt.isEmpty) return false;

    try {
      // baseUrl já tem /api/v1 => use apenas '/auth/refresh'
      final Response<Map<String, dynamic>?> res = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': rt},
        options: Options(headers: {HttpHeaders.authorizationHeader: null}),
      );

      final data = Map<String, dynamic>.from(res.data ?? const {});
      final at = data['access_token']?.toString();
      final newRt = data['refresh_token']?.toString();

      if (at != null && at.isNotEmpty) {
        await SecureStore.write(SecureStore.kAccessToken, at);
      }
      if (newRt != null && newRt.isNotEmpty) {
        await SecureStore.write(SecureStore.kRefreshToken, newRt);
      }
      return true;
    } catch (_) {
      await SecureStore.delete(SecureStore.kAccessToken);
      await SecureStore.delete(SecureStore.kRefreshToken);
      return false;
    }
  }
}
