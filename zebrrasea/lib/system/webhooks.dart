import 'package:zebrrasea/core.dart';

abstract class ZebrraWebhooks {
  Future<void> handle(Map<dynamic, dynamic> data);

  static String buildUserTokenURL(String token, ZebrraModule module) {
    return 'https://notify.zebrrasea.app/v1/${module.key}/user/$token';
  }

  static String buildDeviceTokenURL(String token, ZebrraModule module) {
    return 'https://notify.zebrrasea.app/v1/${module.key}/device/$token';
  }
}
