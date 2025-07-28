import 'package:flutter/material.dart';
import 'package:zebrrasea/database/models/profile.dart';
import 'package:zebrrasea/modules.dart';
import 'package:zebrrasea/modules/nzbget.dart';
import 'package:zebrrasea/modules/sabnzbd/routes.dart';
import 'package:zebrrasea/utils/dialogs.dart';
import 'package:zebrrasea/vendor.dart';
import 'package:zebrrasea/widgets/pages/invalid_route.dart';
import 'package:zebrrasea/widgets/ui.dart';

class DownloadClientSheet extends ZebrraBottomModalSheet {
  Future<ZebrraModule?> getDownloadClient() async {
    final profile = ZebrraProfile.current;
    final nzbget = profile.nzbgetEnabled;
    final sabnzbd = profile.sabnzbdEnabled;

    if (nzbget && sabnzbd) {
      return ZebrraDialogs().selectDownloadClient();
    }
    if (nzbget) {
      return ZebrraModule.NZBGET;
    }
    if (sabnzbd) {
      return ZebrraModule.SABNZBD;
    }

    return null;
  }

  @override
  Future<dynamic> show({
    Widget Function(BuildContext context)? builder,
  }) async {
    final module = await getDownloadClient();
    if (module != null) {
      return showModal(builder: (context) {
        if (module == ZebrraModule.SABNZBD) {
          return const SABnzbdRoute(showDrawer: false);
        }
        if (module == ZebrraModule.NZBGET) {
          return const NZBGetRoute(showDrawer: false);
        }
        return InvalidRoutePage();
      });
    }
  }
}
