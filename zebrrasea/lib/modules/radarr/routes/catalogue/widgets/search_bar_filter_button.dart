import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/scroll_controller.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrCatalogueSearchBarFilterButton extends StatefulWidget {
  final ScrollController controller;

  const RadarrCatalogueSearchBarFilterButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<RadarrCatalogueSearchBarFilterButton> createState() => _State();
}

class _State extends State<RadarrCatalogueSearchBarFilterButton> {
  @override
  Widget build(BuildContext context) {
    return ZebrraCard(
      context: context,
      child: Consumer<RadarrState>(
        builder: (context, state, _) => ZebrraPopupMenuButton<RadarrMoviesFilter>(
          tooltip: 'radarr.FilterCatalogue'.tr(),
          icon: ZebrraIcons.FILTER,
          onSelected: (result) {
            state.moviesFilterType = result;
            widget.controller.animateToStart();
          },
          itemBuilder: (context) =>
              List<PopupMenuEntry<RadarrMoviesFilter>>.generate(
            RadarrMoviesFilter.values.length,
            (index) => PopupMenuItem<RadarrMoviesFilter>(
              value: RadarrMoviesFilter.values[index],
              child: Text(
                RadarrMoviesFilter.values[index].readable,
                style: TextStyle(
                  fontSize: ZebrraUI.FONT_SIZE_H3,
                  color:
                      state.moviesFilterType == RadarrMoviesFilter.values[index]
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
      margin: const EdgeInsets.only(left: ZebrraUI.DEFAULT_MARGIN_SIZE),
      color: Theme.of(context).canvasColor,
    );
  }
}
