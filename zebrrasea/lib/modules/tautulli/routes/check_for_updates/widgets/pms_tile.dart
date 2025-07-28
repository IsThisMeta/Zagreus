import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliCheckForUpdatesPMSTile extends StatelessWidget {
  final TautulliPMSUpdate update;

  const TautulliCheckForUpdatesPMSTile({
    Key? key,
    required this.update,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'Plex Media Server',
      body: _subtitle(),
      trailing: _trailing(),
    );
  }

  Widget _trailing() {
    return Column(
      children: [
        ZebrraIconButton(
          icon: ZebrraIcons.PLEX,
          iconSize: ZebrraUI.ICON_SIZE - 2.0,
          color: ZebrraColours().byListIndex(0),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  List<TextSpan> _subtitle() {
    return [
      if (!(update.updateAvailable ?? false))
        const TextSpan(
          text: 'No Updates Available',
          style: TextStyle(
            color: ZebrraColours.accent,
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          ),
        ),
      if (!(update.updateAvailable ?? false))
        TextSpan(
            text: 'Current Version: ${update.version ?? ZebrraUI.TEXT_EMDASH}'),
      if (update.updateAvailable ?? false)
        const TextSpan(
          text: 'Update Available',
          style: TextStyle(
            color: ZebrraColours.orange,
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          ),
        ),
      if (update.updateAvailable ?? false)
        TextSpan(
            text: 'Latest Version: ${update.version ?? ZebrraUI.TEXT_EMDASH}'),
    ];
  }
}
