import 'package:dio/dio.dart';
import 'package:handscore/core/device/device_id.dart';
import 'package:handscore/core/device/device_info.dart';
import 'package:handscore/core/device/fingerprint.dart';
import 'package:handscore/core/secure/secure_store.dart';
import 'package:handscore/features/auth/data/models.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  // ---------- PUBLIC ----------
  Future<void> register(RegisterRequest req) async {
    await _dio.post('/auth/sign-up', data: req.toJson());
  }

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final tdt = await SecureStore.read(SecureStore.kTrustedDeviceToken);
    final deviceId = await DeviceId.getOrCreate();
    final deviceMeta = await DeviceInfo.getDeviceMeta();

    final resp = await _dio.post(
      '/auth/sign-in',
      data: {
        'email': email,
        'password': password,
        'device_id': deviceId,
        'device_name': deviceMeta['device_name'],
        'platform': deviceMeta['platform'],
        if (tdt != null && tdt.isNotEmpty) 'trusted_device_token': tdt,
      },
      // garante que não mande Authorization herdado por engano
      options: Options(headers: {'Authorization': null}),
    );

    return LoginResponse.fromJson(Map<String, dynamic>.from(resp.data as Map));
  }

  Future<void> signOut() async {
    await _dio.post('/auth/sign-out');
  }

  Future<int?> challenge({required String channel}) async {
    final deviceId = await DeviceId.getOrCreate();
    final resp = await _dio.post(
      '/auth/mfa/challenge',
      data: {'channel': channel, 'device_id': deviceId},
    );

    // evita "unchecked_use_of_nullable_value"
    final raw = resp.data;
    if (raw is! Map) return null;
    final data = Map<String, dynamic>.from(raw as Map);

    final cid = data['challenge_id'];
    if (cid is int) return cid;
    if (cid is String) return int.tryParse(cid);
    return null;
  }

  /// Verifica MFA. Se sucesso, salva tokens “plenos” e conclui trusted device se necessário.
  Future<void> verifyMfa({required String code, int? challengeId}) async {
    final deviceId = await DeviceId.getOrCreate();
    final resp = await _dio.post(
      '/auth/mfa/verify',
      data: {
        'code': code,
        'device_id': deviceId,
        if (challengeId != null) 'challenge_id': challengeId,
      },
    );

    final data = Map<String, dynamic>.from(resp.data as Map);
    final at = data['access_token'] as String?;
    final rt = data['refresh_token'] as String?;

    if (at != null && at.isNotEmpty) {
      await SecureStore.write(SecureStore.kAccessToken, at);
    }
    if (rt != null && rt.isNotEmpty) {
      await SecureStore.write(SecureStore.kRefreshToken, rt);
    }

    // algumas APIs podem pedir “confiança” do device depois do verify
    if (data['trusted_device_setup'] == true) {
      await completeTrustedDevice();
    }
  }

  /// Conclui o trust do dispositivo e guarda o trusted_device_token
  Future<void> completeTrustedDevice() async {
    final fp = await DeviceFingerprint.build(); // algo como "Model:hash..."
    final resp = await _dio.post(
      '/auth/trusted-device',
      data: {'device_name': fp.split(':').first, 'device_fingerprint': fp},
    );

    final data = Map<String, dynamic>.from(resp.data as Map);
    final token = data['trusted_device_token'] as String?;
    if (token != null && token.isNotEmpty) {
      await SecureStore.write(SecureStore.kTrustedDeviceToken, token);
    }
  }

  /// Se você tiver refresh por rota dedicada
  Future<void> refresh() async {
    final resp = await _dio.post('/auth/refresh');
    final data = Map<String, dynamic>.from(resp.data as Map);
    final at = data['access_token'] as String?;
    final rt = data['refresh_token'] as String?;
    if (at != null && at.isNotEmpty) {
      await SecureStore.write(SecureStore.kAccessToken, at);
    }
    if (rt != null && rt.isNotEmpty) {
      await SecureStore.write(SecureStore.kRefreshToken, rt);
    }
  }
}
