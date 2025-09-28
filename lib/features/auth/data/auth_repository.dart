import 'package:handscore/core/secure/secure_store.dart';
import 'package:handscore/features/auth/data/auth_api.dart';
import 'package:handscore/features/auth/data/models.dart';

class AuthRepository {
  final AuthApi api;
  AuthRepository(this.api);

  Future<void> register(RegisterRequest req) => api.register(req);

  /// Faz login e retorna o LoginResponse completo (inclui mfaRequired, channels, challengeId...)
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final res = await api.login(email: email, password: password);

    // Se o backend retornar access_token mesmo com MFA pendente (token "fraco"): salvar
    final at = res.accessToken;
    final rt = res.refreshToken;
    if (at != null && at.isNotEmpty) {
      await SecureStore.write(SecureStore.kAccessToken, at);
    }
    if (rt != null && rt.isNotEmpty) {
      await SecureStore.write(SecureStore.kRefreshToken, rt);
    }

    // Se exigir “trusted device” sem MFA, conclui já
    if (!res.mfaRequired && res.trustedDeviceChallenge) {
      await api.completeTrustedDevice();
    }

    return res;
  }

  /// Pede um novo challenge no canal desejado. Retorna o challengeId (ou null).
  Future<int?> requestMfaChallenge(String channel) =>
      api.challenge(channel: channel);

  /// Verifica MFA (com ou sem challengeId) e já salva os tokens "fortes" retornados.
  Future<void> verifyMfa(String code, {int? challengeId}) =>
      api.verifyMfa(code: code, challengeId: challengeId);

  Future<void> logout() async {
    try {
      await api.signOut();
    } catch (_) {
      // mesmo que falhe, limpamos local
    }
    await SecureStore.delete(SecureStore.kAccessToken);
    await SecureStore.delete(SecureStore.kRefreshToken);
  }
}
