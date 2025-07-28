import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliCheckForUpdatesTautulliTile extends StatelessWidget {
  final TautulliUpdateCheck update;

  const TautulliCheckForUpdatesTautulliTile({
    Key? key,
    required this.update,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'Tautulli',
      body: _subtitle(),
      trailing: _trailing(),
    );
  }

  Widget _trailing() {
    return Column(
      children: [
        ZebrraIconButton(
          icon: ZebrraIcons.TAUTULLI,
          color: ZebrraColours().byListIndex(1),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  List<TextSpan> _subtitle() {
    return [
      if (!(update.update ?? false))
        const TextSpan(
          text: 'No Updates Available',
          style: TextStyle(
            color: ZebrraColours.accent,
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          ),
        ),
      if (update.update ?? false)
        const TextSpan(
          text: 'Update Available',
          style: TextStyle(
            color: ZebrraColours.orange,
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          ),
        ),
      if (update.update ?? false)
        TextSpan(
          children: [
            const TextSpan(text: 'Current Version: '),
            TextSpan(
              text: update.currentRelease ??
                  update.currentVersion?.substring(
                    0,
                    min(7, update.currentVersion!.length),
                  ) ??
                  'zebrrasea.Unknown'.tr(),
            ),
          ],
        ),
      if (update.update ?? false)
        TextSpan(
          children: [
            const TextSpan(text: 'Latest Version: '),
            TextSpan(
              text: update.latestRelease ??
                  update.latestVersion?.substring(
                    0,
                    min(7, update.latestVersion!.length),
                  ) ??
                  'zebrrasea.Unknown'.tr(),
            ),
          ],
        ),
      TextSpan(
          text: 'Install Type: ${update.installType ?? ZebrraUI.TEXT_EMDASH}'),
    ];
  }
}
