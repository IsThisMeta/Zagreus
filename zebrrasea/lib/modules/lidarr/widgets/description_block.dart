import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class LidarrDescriptionBlock extends StatefulWidget {
  final String? description;
  final String title;
  final String uri;
  final bool squareImage;
  final Map? headers;
  final Function? onLongPress;

  const LidarrDescriptionBlock({
    Key? key,
    required this.description,
    required this.title,
    required this.uri,
    required this.headers,
    this.squareImage = false,
    this.onLongPress,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<LidarrDescriptionBlock> {
  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: widget.title,
      body: [
        ZebrraTextSpan.extended(
          text: widget.description?.isNotEmpty ?? false
              ? widget.description
              : 'No Summary Available',
        ),
      ],
      onTap: () async => ZebrraDialogs().textPreview(
        context,
        widget.title,
        widget.description?.trim() ?? 'No Summary Available',
      ),
      onLongPress: widget.onLongPress,
      customBodyMaxLines: 3,
      posterPlaceholderIcon: ZebrraIcons.USER,
      posterHeaders: widget.headers,
      posterIsSquare: widget.squareImage,
      posterUrl: widget.uri,
    );
  }
}
