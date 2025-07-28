import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliActivityDetailsPlayerBlock extends StatelessWidget {
  final TautulliSession session;

  const TautulliActivityDetailsPlayerBlock({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(
            title: 'tautulli.Location'.tr(), body: session.zebrraIPAddress),
        ZebrraTableContent(
            title: 'tautulli.Platform'.tr(), body: session.zebrraPlatform),
        ZebrraTableContent(
            title: 'tautulli.Product'.tr(), body: session.zebrraProduct),
        ZebrraTableContent(
            title: 'tautulli.Player'.tr(), body: session.zebrraPlayer),
        ZebrraTableContent(
            title: 'tautulli.Quality'.tr(), body: session.zebrraQuality),
      ],
    );
  }
}
