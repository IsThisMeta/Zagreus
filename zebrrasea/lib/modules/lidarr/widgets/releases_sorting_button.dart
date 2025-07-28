import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/scroll_controller.dart';
import 'package:zebrrasea/modules/lidarr.dart';

class LidarrReleasesSortButton extends StatefulWidget {
  final ScrollController controller;

  const LidarrReleasesSortButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<LidarrReleasesSortButton> createState() => _State();
}

class _State extends State<LidarrReleasesSortButton> {
  @override
  Widget build(BuildContext context) => ZebrraCard(
        context: context,
        height: ZebrraTextInputBar.defaultHeight,
        width: ZebrraTextInputBar.defaultHeight,
        child: Consumer<LidarrState>(
          builder: (context, model, _) =>
              ZebrraPopupMenuButton<LidarrReleasesSorting>(
            tooltip: 'Sort Releases',
            icon: Icons.sort_rounded,
            onSelected: (result) {
              if (model.sortReleasesType == result) {
                model.sortReleasesAscending = !model.sortReleasesAscending;
              } else {
                model.sortReleasesAscending = true;
                model.sortReleasesType = result;
              }
              widget.controller.animateToStart();
            },
            itemBuilder: (context) =>
                List<PopupMenuEntry<LidarrReleasesSorting>>.generate(
              LidarrReleasesSorting.values.length,
              (index) => PopupMenuItem<LidarrReleasesSorting>(
                value: LidarrReleasesSorting.values[index],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LidarrReleasesSorting.values[index].readable,
                      style: const TextStyle(
                        fontSize: ZebrraUI.FONT_SIZE_H3,
                      ),
                    ),
                    if (model.sortReleasesType ==
                        LidarrReleasesSorting.values[index])
                      Icon(
                        model.sortReleasesAscending
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: ZebrraUI.FONT_SIZE_H2,
                        color: ZebrraColours.accent,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        margin: ZebrraTextInputBar.appBarMargin
            .subtract(const EdgeInsets.only(left: 12.0)) as EdgeInsets,
        color: Theme.of(context).canvasColor,
      );
}
