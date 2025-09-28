import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceFingerprint {
  static Future<String> build() async {
    final info = DeviceInfoPlugin(); // ✅ agora funciona

    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      return 'android:${a.brand}-${a.model}-${a.id}-${a.device}';
    } else if (Platform.isIOS) {
      final i = await info.iosInfo;
      return 'ios:${i.name}-${i.model}-${i.identifierForVendor}';
    }
    return 'unknown';
  }
}