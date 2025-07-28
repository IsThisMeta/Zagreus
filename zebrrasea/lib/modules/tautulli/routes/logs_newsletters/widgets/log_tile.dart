import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliLogsNewsletterLogTile extends StatelessWidget {
  final TautulliNewsletterLogRecord newsletter;

  const TautulliLogsNewsletterLogTile({
    Key? key,
    required this.newsletter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: newsletter.agentName,
      body: _body(),
      trailing: _trailing(),
    );
  }

  List<TextSpan> _body() {
    return [
      TextSpan(text: newsletter.notifyAction),
      TextSpan(text: newsletter.subjectText),
      TextSpan(text: newsletter.bodyText),
      TextSpan(
        text: newsletter.timestamp!.asDateTime(),
        style: const TextStyle(
          color: ZebrraColours.accent,
          fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
        ),
      ),
    ];
  }

  Widget _trailing() => Column(
        children: [
          ZebrraIconButton(
            icon: newsletter.success!
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: newsletter.success! ? ZebrraColours.white : ZebrraColours.red,
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
      );
}
