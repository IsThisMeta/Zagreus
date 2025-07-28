import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/scroll_controller.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrReleasesAppBarSortButton extends StatefulWidget {
  final ScrollController controller;

  const RadarrReleasesAppBarSortButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<RadarrReleasesAppBarSortButton> createState() => _State();
}

class _State extends State<RadarrReleasesAppBarSortButton> {
  @override
  Widget build(BuildContext context) {
    return ZebrraCard(
      context: context,
      child: Consumer<RadarrReleasesState>(
        builder: (context, state, _) =>
            ZebrraPopupMenuButton<RadarrReleasesSorting>(
          tooltip: 'Sort Releases',
          icon: Icons.sort_rounded,
          onSelected: (result) {
            if (state.sortType == result) {
              state.sortAscending = !state.sortAscending;
            } else {
              state.sortAscending = true;
              state.sortType = result;
            }
            widget.controller.animateToStart();
          },
          itemBuilder: (context) =>
              List<PopupMenuEntry<RadarrReleasesSorting>>.generate(
            RadarrReleasesSorting.values.length,
            (index) => PopupMenuItem<RadarrReleasesSorting>(
              value: RadarrReleasesSorting.values[index],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    RadarrReleasesSorting.values[index].readable,
                    style: TextStyle(
                      fontSize: ZebrraUI.FONT_SIZE_H3,
                      color:
                          state.sortType == RadarrReleasesSorting.values[index]
                              ? ZebrraColours.accent
                              : Colors.white,
                    ),
                  ),
                  if (state.sortType == RadarrReleasesSorting.values[index])
                    Icon(
                      state.sortAscending
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
      height: ZebrraTextInputBar.defaultHeight,
      width: ZebrraTextInputBar.defaultHeight,
      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 13.5),
      color: Theme.of(context).canvasColor,
    );
  }
}
