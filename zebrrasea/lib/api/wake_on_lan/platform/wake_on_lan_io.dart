import 'package:wake_on_lan/wake_on_lan.dart';
import 'package:zebrrasea/api/wake_on_lan/wake_on_lan.dart';
import 'package:zebrrasea/database/models/profile.dart';
import 'package:zebrrasea/system/logger.dart';
import 'package:zebrrasea/vendor.dart';
import 'package:zebrrasea/widgets/ui.dart';

bool isPlatformSupported() => true;
ZebrraWakeOnLAN getWakeOnLAN() => IO();

class IO implements ZebrraWakeOnLAN {
  @override
  Future<void> wake() async {
    ZebrraProfile profile = ZebrraProfile.current;
    try {
      final ip = IPAddress(profile.wakeOnLANBroadcastAddress);
      final mac = MACAddress(profile.wakeOnLANMACAddress);
      return WakeOnLAN(ip, mac).wake().then((_) {
        showZebrraSuccessSnackBar(
          title: 'wake_on_lan.MagicPacketSent'.tr(),
          message: 'wake_on_lan.MagicPacketSentMessage'.tr(),
        );
      });
    } catch (error, stack) {
      ZebrraLogger().error(
        'Failed to send wake on LAN magic packet',
        error,
        stack,
      );
      showZebrraErrorSnackBar(
        title: 'wake_on_lan.MagicPacketFailedToSend'.tr(),
        error: error,
      );
    }
  }
}
