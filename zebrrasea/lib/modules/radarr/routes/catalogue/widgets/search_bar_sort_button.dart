import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/scroll_controller.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrCatalogueSearchBarSortButton extends StatefulWidget {
  final ScrollController controller;

  const RadarrCatalogueSearchBarSortButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<RadarrCatalogueSearchBarSortButton> createState() => _State();
}

class _State extends State<RadarrCatalogueSearchBarSortButton> {
  @override
  Widget build(BuildContext context) {
    return ZebrraCard(
      context: context,
      child: Consumer<RadarrState>(
        builder: (context, state, _) =>
            ZebrraPopupMenuButton<RadarrMoviesSorting>(
          tooltip: 'radarr.SortCatalogue'.tr(),
          icon: ZebrraIcons.SORT,
          onSelected: (result) {
            if (state.moviesSortType == result) {
              state.moviesSortAscending = !state.moviesSortAscending;
            } else {
              state.moviesSortAscending = true;
              state.moviesSortType = result;
            }
            widget.controller.animateToStart();
          },
          itemBuilder: (context) =>
              List<PopupMenuEntry<RadarrMoviesSorting>>.generate(
            RadarrMoviesSorting.values.length,
            (index) => PopupMenuItem<RadarrMoviesSorting>(
              value: RadarrMoviesSorting.values[index],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    RadarrMoviesSorting.values[index].readable,
                    style: TextStyle(
                      fontSize: ZebrraUI.FONT_SIZE_H3,
                      color: state.moviesSortType ==
                              RadarrMoviesSorting.values[index]
                          ? ZebrraColours.accent
                          : Colors.white,
                    ),
                  ),
                  if (state.moviesSortType == RadarrMoviesSorting.values[index])
                    Icon(
                      state.moviesSortAscending
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
      margin: const EdgeInsets.only(left: ZebrraUI.DEFAULT_MARGIN_SIZE),
      color: Theme.of(context).canvasColor,
      height: ZebrraTextInputBar.defaultHeight,
      width: ZebrraTextInputBar.defaultHeight,
    );
  }
}
