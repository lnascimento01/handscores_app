import 'dart:io';
import 'package:dio/dio.dart';
import 'package:handscore/features/auth/data/models.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<void> register(RegisterRequest req) async {
    await _dio.post<void>(
      '/auth/sign-up',
      data: req.toJson(),
      options: Options(
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      ),
    );
  }

  /// Faz login e mapeia chaves legadas (token -> access_token, mfa_enabled -> mfa_required)
  Future<LoginResponse> login({
    required String email,
    required String password,
    String? deviceId,
    String? deviceName,
    String platform = 'android',
  }) async {
    final payload = <String, dynamic>{
      'email': email,
      'password': password,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceName != null) 'device_name': deviceName,
      'platform': platform,
    };

    final Response<Map<String, dynamic>?> res = await _dio.post(
      '/auth/sign-in',
      data: payload,
      options: Options(
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: null, // login não usa bearer
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      ),
    );

    final map = Map<String, dynamic>.from(res.data ?? const {});
    // Mapeia chaves alternativas
    map.putIfAbsent('access_token', () => map['token']);
    map.putIfAbsent('mfa_required', () => map['mfa_enabled']);
    map.putIfAbsent('mfa_channels', () => map['mfaChannels']);
    map.putIfAbsent('challenge_id', () => map['challengeId']);
    map.putIfAbsent('temp_token', () => map['tempToken']);
    map.putIfAbsent('refresh_token', () => map['refreshToken']);
    map.putIfAbsent('expires_in', () => map['expiresIn']);
    map.putIfAbsent(
      'trusted_device_challenge',
      () => map['trustedDeviceChallenge'],
    );

    return LoginResponse.fromJson(map);
  }

  /// Retorna o usuário atual (token obrigatório)
  Future<UserDto> me() async {
    final Response<Map<String, dynamic>?> res = await _dio.get('/auth/me');
    final data = Map<String, dynamic>.from(res.data ?? const {});
    return UserDto.fromJson(data);
  }

  /// Opcional: valida sessão (se existir essa rota no backend)
  Future<bool> validateSession() async {
    final Response<Map<String, dynamic>?> res = await _dio.post(
      '/auth/validate',
    );
    final data = res.data;
    if (data == null) return true; // se backend não enviar nada, considere ok
    final v = data['valid'];
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    if (v is num) return v != 0;
    return true;
  }

  /// Pode retornar `int` ou `{ challenge_id, expires_in }`
  Future<Object?> challenge({required String channel}) async {
    final Response<dynamic> res = await _dio.post(
      '/auth/mfa/challenge',
      data: {'channel': channel},
      options: Options(
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      ),
    );
    final data = res.data;
    if (data is int) return data;
    if (data is Map) return Map<String, dynamic>.from(data as Map);
    return null;
  }

  Future<void> verifyMfa({required String code, int? challengeId}) async {
    await _dio.post<void>(
      '/auth/mfa/verify',
      data: {
        'code': code,
        if (challengeId != null) 'challenge_id': challengeId,
      },
      options: Options(
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      ),
    );
  }

  Future<void> completeTrustedDevice() async {
    await _dio.post<void>('/auth/trusted-device/complete');
  }

  Future<void> signOut() async {
    await _dio.post<void>('/auth/sign-out');
  }
}
