import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliActivityDetailsStreamBlock extends StatelessWidget {
  final TautulliSession session;

  const TautulliActivityDetailsStreamBlock({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(
          title: 'tautulli.Bandwidth'.tr(),
          body: session.zebrraBandwidth,
        ),
        ZebrraTableContent(
          title: 'tautulli.Stream'.tr(),
          body: session.formattedStream(),
        ),
        ZebrraTableContent(
          title: 'tautulli.Container'.tr(),
          body: session.formattedContainer(),
        ),
        if (session.hasVideo())
          ZebrraTableContent(
            title: 'tautulli.Video'.tr(),
            body: session.formattedVideo(),
          ),
        if (session.hasAudio())
          ZebrraTableContent(
            title: 'tautulli.Audio'.tr(),
            body: session.formattedAudio(),
          ),
        if (session.hasSubtitles())
          ZebrraTableContent(
            title: 'tautulli.Subtitle'.tr(),
            body: session.formattedSubtitles(),
          ),
      ],
    );
  }
}
