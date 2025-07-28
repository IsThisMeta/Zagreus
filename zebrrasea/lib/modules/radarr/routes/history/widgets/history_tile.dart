import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/radarr.dart';
import 'package:zebrrasea/router/routes/radarr.dart';

class RadarrHistoryTile extends StatelessWidget {
  final RadarrHistoryRecord history;
  final bool movieHistory;
  final String title;

  /// If [movieHistory] is false (default), you must supply a title or else a dash will be shown.
  const RadarrHistoryTile({
    Key? key,
    required this.history,
    this.movieHistory = false,
    this.title = ZebrraUI.TEXT_EMDASH,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraExpandableListTile(
      title: movieHistory ? history.sourceTitle! : title,
      collapsedSubtitles: [
        TextSpan(
          text: [
            history.date?.asAge() ?? ZebrraUI.TEXT_EMDASH,
            history.date?.asDateTime() ?? ZebrraUI.TEXT_EMDASH,
          ].join(ZebrraUI.TEXT_BULLET.pad()),
        ),
        TextSpan(
          text: history.eventType?.zebrraReadable(history) ?? ZebrraUI.TEXT_EMDASH,
          style: TextStyle(
            color: history.eventType?.zebrraColour ?? ZebrraColours.blueGrey,
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          ),
        ),
      ],
      expandedHighlightedNodes: [
        ZebrraHighlightedNode(
          text: history.eventType!.readable!,
          backgroundColor: history.eventType!.zebrraColour,
        ),
        ...history.customFormats!
            .map<ZebrraHighlightedNode>((format) => ZebrraHighlightedNode(
                  text: format.name!,
                  backgroundColor: ZebrraColours.blueGrey,
                )),
      ],
      expandedTableContent: history.eventType?.zebrraTableContent(
            history,
            movieHistory: movieHistory,
          ) ??
          [],
      onLongPress: movieHistory
          ? null
          : () => RadarrRoutes.MOVIE.go(params: {
                'movie': history.movieId!.toString(),
              }),
    );
  }
}
