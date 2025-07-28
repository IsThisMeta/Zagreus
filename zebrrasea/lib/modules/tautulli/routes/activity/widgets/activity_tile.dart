import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/tautulli.dart';
import 'package:zebrrasea/router/routes/tautulli.dart';

class TautulliActivityTile extends StatelessWidget {
  final TautulliSession session;
  final bool disableOnTap;

  const TautulliActivityTile({
    Key? key,
    required this.session,
    this.disableOnTap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: session.zebrraTitle,
      posterUrl: session.zebrraArtworkPath(context),
      posterHeaders: context.read<TautulliState>().headers,
      posterPlaceholderIcon: ZebrraIcons.VIDEO_CAM,
      backgroundUrl: context.watch<TautulliState>().getImageURLFromPath(
            session.art,
            width: MediaQuery.of(context).size.width.truncate(),
          ),
      body: [
        _subtitle1(),
        _subtitle2(),
        _subtitle3(),
      ],
      bottom: _bottomWidget(),
      bottomHeight: ZebrraLinearPercentIndicator.height,
      trailing: ZebrraIconButton(icon: session.zebrraSessionStateIcon),
      onTap: disableOnTap ? null : () async => _enterDetails(context),
    );
  }

  TextSpan _subtitle1() {
    if (session.mediaType == TautulliMediaType.EPISODE) {
      return TextSpan(
        children: [
          TextSpan(text: session.parentTitle),
          TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
          TextSpan(
              text: 'tautulli.Episode'.tr(args: [
            session.mediaIndex?.toString() ?? ZebrraUI.TEXT_EMDASH
          ])),
          const TextSpan(text: ': '),
          TextSpan(
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
            text: session.title ?? ZebrraUI.TEXT_EMDASH,
          ),
        ],
      );
    }
    if (session.mediaType == TautulliMediaType.MOVIE) {
      return TextSpan(text: session.year.toString());
    }
    if (session.mediaType == TautulliMediaType.TRACK) {
      return TextSpan(
        children: [
          TextSpan(text: session.parentTitle),
          TextSpan(text: ZebrraUI.TEXT_EMDASH.pad()),
          TextSpan(
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
            text: session.title,
          ),
        ],
      );
    }
    if (session.mediaType == TautulliMediaType.LIVE) {
      return TextSpan(text: session.title);
    }
    return const TextSpan(text: ZebrraUI.TEXT_EMDASH);
  }

  TextSpan _subtitle2() {
    return TextSpan(text: session.zebrraFriendlyName);
  }

  TextSpan _subtitle3() {
    return TextSpan(
      text: session.formattedStream(),
      style: const TextStyle(
        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
        color: ZebrraColours.accent,
      ),
    );
  }

  Widget _bottomWidget() {
    return SizedBox(
      height: ZebrraLinearPercentIndicator.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ZebrraLinearPercentIndicator(
            percent: session.zebrraTranscodeProgress,
            progressColor: ZebrraColours.accent.withOpacity(
              ZebrraUI.OPACITY_SPLASH,
            ),
            backgroundColor: Colors.transparent,
          ),
          ZebrraLinearPercentIndicator(
            percent: session.zebrraProgressPercent,
            progressColor: ZebrraColours.accent,
            backgroundColor: ZebrraColours.grey.withOpacity(
              ZebrraUI.OPACITY_SPLASH,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enterDetails(BuildContext context) async {
    TautulliRoutes.ACTIVITY_DETAILS.go(params: {
      'session': session.sessionKey.toString(),
    });
  }
}
