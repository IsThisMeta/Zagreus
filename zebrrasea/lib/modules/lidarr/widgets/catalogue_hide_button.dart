import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/lidarr.dart';

class LidarrCatalogueHideButton extends StatefulWidget {
  final ScrollController controller;

  const LidarrCatalogueHideButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<LidarrCatalogueHideButton> createState() => _State();
}

class _State extends State<LidarrCatalogueHideButton> {
  @override
  Widget build(BuildContext context) => ZebrraCard(
        context: context,
        child: Consumer<LidarrState>(
          builder: (context, model, widget) => InkWell(
            child: ZebrraIconButton(
              icon: model.hideUnmonitoredArtists
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
            ),
            onTap: () =>
                model.hideUnmonitoredArtists = !model.hideUnmonitoredArtists,
            borderRadius: BorderRadius.circular(ZebrraUI.BORDER_RADIUS),
          ),
        ),
        height: ZebrraTextInputBar.defaultHeight,
        width: ZebrraTextInputBar.defaultHeight,
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        color: Theme.of(context).canvasColor,
      );
}
