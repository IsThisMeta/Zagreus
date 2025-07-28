import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/lidarr.dart';

class LidarrReleasesHideButton extends StatefulWidget {
  final ScrollController controller;

  const LidarrReleasesHideButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<LidarrReleasesHideButton> createState() => _State();
}

class _State extends State<LidarrReleasesHideButton> {
  @override
  Widget build(BuildContext context) => ZebrraCard(
        context: context,
        child: Consumer<LidarrState>(
          builder: (context, model, widget) => ZebrraIconButton(
            icon: model.hideRejectedReleases
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            onPressed: () =>
                model.hideRejectedReleases = !model.hideRejectedReleases,
          ),
        ),
        height: ZebrraTextInputBar.defaultHeight,
        width: ZebrraTextInputBar.defaultHeight,
        margin: ZebrraTextInputBar.appBarMargin
            .subtract(const EdgeInsets.only(left: 12.0)) as EdgeInsets,
        color: Theme.of(context).canvasColor,
      );
}
