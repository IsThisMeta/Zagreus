import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliLogsTautulliLogTile extends StatelessWidget {
  final TautulliLog log;

  const TautulliLogsTautulliLogTile({
    Key? key,
    required this.log,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraExpandableListTile(
      title: log.message!.trim(),
      collapsedSubtitles: [
        _subtitle1(),
        _subtitle2(),
      ],
      expandedTableContent: _tableContent(),
    );
  }

  TextSpan _subtitle1() => TextSpan(text: log.timestamp ?? ZebrraUI.TEXT_EMDASH);

  TextSpan _subtitle2() {
    return TextSpan(
      text: log.level ?? ZebrraUI.TEXT_EMDASH,
      style: const TextStyle(
        color: ZebrraColours.accent,
        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
      ),
    );
  }

  List<ZebrraTableContent> _tableContent() {
    return [
      ZebrraTableContent(title: 'level', body: log.level),
      ZebrraTableContent(title: 'timestamp', body: log.timestamp),
      ZebrraTableContent(title: 'thread', body: log.thread),
    ];
  }
}
