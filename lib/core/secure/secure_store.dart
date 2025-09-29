import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  // Opções por plataforma (mantém compatibilidade com o que você já tinha no Android)
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences:
          true, // ✅ SharedPreferences criptografado no Android
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility
          .first_unlock, // chave disponível após 1º desbloqueio
    ),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
    // Se precisar, dá para configurar web/windows/linux aqui depois.
  );

  // === Tokens / Trusted Device ===
  static const kAccessToken = 'access_token';
  static const kRefreshToken = 'refresh_token';
  static const kTrustedDeviceToken = 'trusted_device_token';

  // === Identidade do dispositivo (para login) ===
  static const kDeviceId = 'device_id';
  static const kDeviceName = 'device_name';

  // === API básica ===
  static Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  static Future<String?> read(String key) => _storage.read(key: key);

  static Future<void> delete(String key) => _storage.delete(key: key);

  // === Helpers opcionais (não-impactantes) ===

  /// Grava apenas se estiver ausente (útil para device_id / device_name)
  static Future<String> writeIfAbsent(
    String key,
    String Function() factory,
  ) async {
    final existing = await read(key);
    if (existing != null && existing.isNotEmpty) return existing;
    final value = factory();
    await write(key, value);
    return value;
  }

  /// Atalho para gravar os dois tokens de uma vez
  static Future<void> setTokens({
    String? accessToken,
    String? refreshToken,
  }) async {
    if (accessToken != null && accessToken.isNotEmpty) {
      await write(kAccessToken, accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await write(kRefreshToken, refreshToken);
    }
  }

  /// Remove access/refresh tokens
  static Future<void> clearTokens() async {
    await delete(kAccessToken);
    await delete(kRefreshToken);
  }
}
