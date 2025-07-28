import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/models/log.dart';
import 'package:zebrrasea/extensions/datetime.dart';

class SettingsSystemLogTile extends StatelessWidget {
  final ZebrraLog log;

  const SettingsSystemLogTile({
    Key? key,
    required this.log,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String dateTime =
        DateTime.fromMillisecondsSinceEpoch(log.timestamp).asDateTime();
    return ZebrraExpandableListTile(
      title: log.message,
      collapsedSubtitles: [
        TextSpan(text: dateTime),
        TextSpan(
          text: log.type.title.toUpperCase(),
          style: TextStyle(
            color: log.type.color,
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          ),
        ),
      ],
      expandedHighlightedNodes: [
        ZebrraHighlightedNode(
          text: log.type.title.toUpperCase(),
          backgroundColor: log.type.color,
        ),
        ZebrraHighlightedNode(
          text: dateTime,
          backgroundColor: ZebrraColours.blueGrey,
        ),
      ],
      expandedTableContent: [
        if (log.className != null && log.className!.isNotEmpty)
          ZebrraTableContent(title: 'settings.Class'.tr(), body: log.className),
        if (log.methodName != null && log.methodName!.isNotEmpty)
          ZebrraTableContent(title: 'settings.Method'.tr(), body: log.methodName),
        if (log.error != null && log.error!.isNotEmpty)
          ZebrraTableContent(title: 'settings.Exception'.tr(), body: log.error),
      ],
    );
  }
}
