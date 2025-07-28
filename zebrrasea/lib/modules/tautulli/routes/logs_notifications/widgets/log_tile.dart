import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliLogsNotificationLogTile extends StatelessWidget {
  final TautulliNotificationLogRecord notification;

  const TautulliLogsNotificationLogTile({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: notification.agentName,
      body: _body(),
      trailing: _trailing(),
    );
  }

  List<TextSpan> _body() {
    return [
      TextSpan(text: notification.notifyAction),
      TextSpan(text: notification.subjectText),
      TextSpan(text: notification.bodyText),
      TextSpan(
        text: notification.timestamp!.asDateTime(),
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
            icon: notification.success!
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: notification.success! ? ZebrraColours.white : ZebrraColours.red,
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
      );
}
