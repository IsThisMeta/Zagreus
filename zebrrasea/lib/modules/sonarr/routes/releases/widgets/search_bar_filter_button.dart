import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/scroll_controller.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrReleasesAppBarFilterButton extends StatefulWidget {
  final ScrollController controller;

  const SonarrReleasesAppBarFilterButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<SonarrReleasesAppBarFilterButton> createState() => _State();
}

class _State extends State<SonarrReleasesAppBarFilterButton> {
  @override
  Widget build(BuildContext context) {
    return ZebrraCard(
      context: context,
      child: Consumer<SonarrReleasesState>(
        builder: (context, state, _) =>
            ZebrraPopupMenuButton<SonarrReleasesFilter>(
          tooltip: 'sonarr.FilterReleases'.tr(),
          icon: Icons.filter_list_rounded,
          onSelected: (result) {
            state.filterType = result;
            widget.controller.animateToStart();
          },
          itemBuilder: (context) =>
              List<PopupMenuEntry<SonarrReleasesFilter>>.generate(
            SonarrReleasesFilter.values.length,
            (index) => PopupMenuItem<SonarrReleasesFilter>(
              value: SonarrReleasesFilter.values[index],
              child: Text(
                SonarrReleasesFilter.values[index].readable,
                style: TextStyle(
                  fontSize: ZebrraUI.FONT_SIZE_H3,
                  color: state.filterType == SonarrReleasesFilter.values[index]
                      ? ZebrraColours.accent
                      : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      height: ZebrraTextInputBar.defaultHeight,
      width: ZebrraTextInputBar.defaultHeight,
      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 14.0),
      color: Theme.of(context).canvasColor,
    );
  }
}
