import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/links.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrHealthCheckTile extends StatelessWidget {
  final RadarrHealthCheck healthCheck;

  const RadarrHealthCheckTile({
    Key? key,
    required this.healthCheck,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraExpandableListTile(
      title: healthCheck.message!,
      collapsedSubtitles: [
        subtitle1(),
        subtitle2(),
      ],
      expandedTableContent: expandedTable(),
      expandedHighlightedNodes: highlightedNodes(),
      onLongPress: healthCheck.wikiUrl!.openLink,
    );
  }

  TextSpan subtitle1() {
    return TextSpan(text: healthCheck.source);
  }

  TextSpan subtitle2() {
    return TextSpan(
      text: healthCheck.type!.readable,
      style: TextStyle(
        color: healthCheck.type.zebrraColour,
        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
        fontSize: ZebrraUI.FONT_SIZE_H3,
      ),
    );
  }

  List<ZebrraHighlightedNode> highlightedNodes() {
    return [
      ZebrraHighlightedNode(
        text: healthCheck.type!.readable!,
        backgroundColor: healthCheck.type.zebrraColour,
      ),
    ];
  }

  List<ZebrraTableContent> expandedTable() {
    return [
      ZebrraTableContent(title: 'Source', body: healthCheck.source),
    ];
  }
}
