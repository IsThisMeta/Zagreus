import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/duration/timestamp.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliStatisticsPlatformTile extends StatefulWidget {
  final Map<String, dynamic> data;

  const TautulliStatisticsPlatformTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<TautulliStatisticsPlatformTile> {
  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: widget.data['platform'] ?? 'Unknown Platform',
      body: _body(),
      posterPlaceholderIcon: ZebrraIcons.DEVICES,
      posterIsSquare: true,
    );
  }

  List<TextSpan> _body() {
    return [
      TextSpan(
        text: widget.data['total_plays'].toString() +
            (widget.data['total_plays'] == 1 ? ' Play' : ' Plays'),
        style: TextStyle(
          color: context.watch<TautulliState>().statisticsType ==
                  TautulliStatsType.PLAYS
              ? ZebrraColours.accent
              : null,
          fontWeight: context.watch<TautulliState>().statisticsType ==
                  TautulliStatsType.PLAYS
              ? ZebrraUI.FONT_WEIGHT_BOLD
              : null,
        ),
      ),
      widget.data['total_duration'] != null
          ? TextSpan(
              text: Duration(seconds: widget.data['total_duration'])
                  .asWordsTimestamp(),
              style: TextStyle(
                color: context.watch<TautulliState>().statisticsType ==
                        TautulliStatsType.DURATION
                    ? ZebrraColours.accent
                    : null,
                fontWeight: context.watch<TautulliState>().statisticsType ==
                        TautulliStatsType.DURATION
                    ? ZebrraUI.FONT_WEIGHT_BOLD
                    : null,
              ),
            )
          : const TextSpan(text: ZebrraUI.TEXT_EMDASH),
    ];
  }
}
