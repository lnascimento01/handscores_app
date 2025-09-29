import 'package:handscore/core/secure/secure_store.dart';
import 'package:handscore/features/auth/data/auth_api.dart';
import 'package:handscore/features/auth/data/models.dart';

class AuthRepository {
  final AuthApi api;
  AuthRepository(this.api);

  Future<void> register(RegisterRequest req) => api.register(req);

  Future<UserDto> getCurrentUser() => api.me();

  Future<bool> validateSavedSession() => api.validateSession();

  Future<LoginResponse> login({
    required String email,
    required String password,
    required String deviceId,
    required String deviceName,
    required String platform,
  }) async {
    final res = await api.login(
      email: email,
      password: password,
      deviceId: deviceId,
      deviceName: deviceName,
      platform: platform,
    );

    // Salvar tokens, se vierem
    final at = res.accessToken;
    final rt = res.refreshToken;
    if (at != null && at.isNotEmpty) {
      await SecureStore.write(SecureStore.kAccessToken, at);
    }
    if (rt != null && rt.isNotEmpty) {
      await SecureStore.write(SecureStore.kRefreshToken, rt);
    }

    if (!res.mfaRequired && res.trustedDeviceChallenge) {
      await api.completeTrustedDevice();
    }

    return res;
  }

  Future<Object?> requestMfaChallenge(String channel) =>
      api.challenge(channel: channel);

  Future<void> verifyMfa(String code, {int? challengeId}) =>
      api.verifyMfa(code: code, challengeId: challengeId);

  Future<void> logout() async {
    try {
      await api.signOut();
    } catch (_) {}
    await SecureStore.delete(SecureStore.kAccessToken);
    await SecureStore.delete(SecureStore.kRefreshToken);
  }
}
