import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/int/duration.dart';
import 'package:zebrrasea/modules/lidarr.dart';

class LidarrDetailsTrackTile extends StatefulWidget {
  final LidarrTrackData data;
  final bool monitored;

  const LidarrDetailsTrackTile({
    Key? key,
    required this.data,
    required this.monitored,
  }) : super(key: key);

  @override
  State<LidarrDetailsTrackTile> createState() => _State();
}

class _State extends State<LidarrDetailsTrackTile> {
  @override
  Widget build(BuildContext context) => ZebrraBlock(
        title: widget.data.title,
        body: [
          TextSpan(text: widget.data.duration.asTrackDuration(divisor: 1000)),
          widget.data.file(widget.monitored),
        ],
        disabled: !widget.monitored,
        leading: ZebrraIconButton(
          text: widget.data.trackNumber,
          textSize: ZebrraUI.FONT_SIZE_H4,
        ),
      );
}
