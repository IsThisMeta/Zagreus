import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/scroll_controller.dart';
import 'package:zebrrasea/modules/radarr.dart';
import 'package:zebrrasea/types/list_view_option.dart';

class RadarrCatalogueSearchBarViewButton extends StatefulWidget {
  final ScrollController controller;

  const RadarrCatalogueSearchBarViewButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<RadarrCatalogueSearchBarViewButton> createState() => _State();
}

class _State extends State<RadarrCatalogueSearchBarViewButton> {
  @override
  Widget build(BuildContext context) {
    return ZebrraCard(
      context: context,
      child: Consumer<RadarrState>(
        builder: (context, state, _) => ZebrraPopupMenuButton<ZebrraListViewOption>(
          tooltip: 'zebrrasea.View'.tr(),
          icon: ZebrraIcons.VIEW,
          onSelected: (result) {
            state.moviesViewType = result;
            widget.controller.animateToStart();
          },
          itemBuilder: (context) =>
              List<PopupMenuEntry<ZebrraListViewOption>>.generate(
            ZebrraListViewOption.values.length,
            (index) => PopupMenuItem<ZebrraListViewOption>(
              value: ZebrraListViewOption.values[index],
              child: Text(
                ZebrraListViewOption.values[index].readable,
                style: TextStyle(
                  fontSize: ZebrraUI.FONT_SIZE_H3,
                  color:
                      state.moviesViewType == ZebrraListViewOption.values[index]
                          ? ZebrraColours.accent
                          : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      margin: const EdgeInsets.only(left: ZebrraUI.DEFAULT_MARGIN_SIZE),
      color: Theme.of(context).canvasColor,
      height: ZebrraTextInputBar.defaultHeight,
      width: ZebrraTextInputBar.defaultHeight,
    );
  }
}
