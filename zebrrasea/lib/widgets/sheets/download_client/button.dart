import 'package:flutter/material.dart';
import 'package:zebrrasea/database/models/profile.dart';
import 'package:zebrrasea/widgets/sheets/download_client/sheet.dart';
import 'package:zebrrasea/widgets/ui.dart';

class DownloadClientButton extends StatelessWidget {
  const DownloadClientButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (_shouldShow) {
      return ZebrraIconButton.appBar(
        icon: ZebrraIcons.DOWNLOAD,
        onPressed: DownloadClientSheet().show,
      );
    }
    return const SizedBox();
  }

  bool get _shouldShow {
    final profile = ZebrraProfile.current;
    return profile.sabnzbdEnabled || profile.nzbgetEnabled;
  }
}
