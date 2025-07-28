import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliActivityDetailsMetadataBlock extends StatelessWidget {
  final TautulliSession session;

  const TautulliActivityDetailsMetadataBlock({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(
            title: 'tautulli.Title'.tr(), body: session.zebrraFullTitle),
        if (session.year != null)
          ZebrraTableContent(title: 'tautulli.Year'.tr(), body: session.zebrraYear),
        ZebrraTableContent(
            title: 'tautulli.Duration'.tr(), body: session.zebrraDuration),
        ZebrraTableContent(title: 'tautulli.ETA'.tr(), body: session.zebrraETA),
        ZebrraTableContent(
            title: 'tautulli.Library'.tr(), body: session.zebrraLibraryName),
        ZebrraTableContent(
            title: 'tautulli.User'.tr(), body: session.zebrraFriendlyName),
      ],
    );
  }
}
