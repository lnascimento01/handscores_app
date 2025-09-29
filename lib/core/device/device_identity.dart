import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:handscore/core/secure/secure_store.dart';

class DeviceIdentity {
  static const _kDeviceId = SecureStore.kDeviceId;
  static const _kDeviceName = SecureStore.kDeviceName;

  static Future<({String id, String name, String platform})> ensure() async {
    // 1) tenta recuperar do storage
    var id = await SecureStore.read(_kDeviceId);
    var name = await SecureStore.read(_kDeviceName);

    // 2) plataforma
    final platform = _platformString();

    // 3) tenta coletar infos; se plugin não estiver registrado, usa fallback
    String appName = 'HandScore';
    try {
      final pkg = await PackageInfo.fromPlatform();
      if ((pkg.appName).isNotEmpty) appName = pkg.appName;
    } catch (_) {
      // MissingPluginException ou outra falha -> mantém appName default
    }

    String fallbackName = 'Dispositivo ($appName)';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        // device_info_plus tem webInfo, mas se não registrar, cai no catch
        // final web = await deviceInfo.webBrowserInfo;
        fallbackName = 'Web ($appName)';
        id ??= const Uuid().v4();
      } else if (Platform.isAndroid) {
        final a = await deviceInfo.androidInfo;
        id ??= a.id ?? a.fingerprint ?? const Uuid().v4();
        fallbackName = '${a.manufacturer} ${a.model} ($appName)'.trim();
      } else if (Platform.isIOS) {
        final i = await deviceInfo.iosInfo;
        id ??= i.identifierForVendor ?? const Uuid().v4();
        fallbackName = '${i.name} ${i.model} ($appName)'.trim();
      } else if (Platform.isMacOS) {
        final m = await deviceInfo.macOsInfo;
        id ??= m.systemGUID ?? const Uuid().v4();
        fallbackName = 'macOS ${m.model} ($appName)';
      } else if (Platform.isWindows) {
        final w = await deviceInfo.windowsInfo;
        id ??= w.deviceId ?? const Uuid().v4();
        fallbackName = 'Windows ${w.computerName} ($appName)';
      } else if (Platform.isLinux) {
        final l = await deviceInfo.linuxInfo;
        id ??= l.machineId ?? const Uuid().v4();
        fallbackName = 'Linux ${l.prettyName ?? ''} ($appName)'.trim();
      } else {
        id ??= const Uuid().v4();
      }
    } catch (_) {
      // MissingPluginException ou qualquer falha -> gera UUID e nome genérico
      id ??= const Uuid().v4();
      fallbackName = 'Device ($appName)';
    }

    name ??= fallbackName;

    // 4) persiste se novo
    await SecureStore.write(_kDeviceId, id);
    await SecureStore.write(_kDeviceName, name);

    return (id: id, name: name, platform: platform);
  }

  static String _platformString() {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
      if (Platform.isMacOS) return 'macos';
      if (Platform.isWindows) return 'windows';
      if (Platform.isLinux) return 'linux';
    } catch (_) {}
    return 'unknown';
  }
}
