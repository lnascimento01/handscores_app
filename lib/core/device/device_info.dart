import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfo {
  static Future<Map<String, String?>> getDeviceMeta() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      return {
        'device_name': '${a.brand} ${a.model}',
        'platform': 'android',
      };
    } else if (Platform.isIOS) {
      final i = await info.iosInfo;
      return {
        'device_name': i.name,
        'platform': 'ios',
      };
    }
    return {'device_name': null, 'platform': null};
  }
}