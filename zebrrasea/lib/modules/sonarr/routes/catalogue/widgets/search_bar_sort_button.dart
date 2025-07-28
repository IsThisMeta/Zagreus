import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/scroll_controller.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesSearchBarSortButton extends StatefulWidget {
  final ScrollController controller;

  const SonarrSeriesSearchBarSortButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<SonarrSeriesSearchBarSortButton> createState() => _State();
}

class _State extends State<SonarrSeriesSearchBarSortButton> {
  @override
  Widget build(BuildContext context) => ZebrraCard(
        context: context,
        child: Consumer<SonarrState>(
          builder: (context, state, _) =>
              ZebrraPopupMenuButton<SonarrSeriesSorting>(
            tooltip: 'sonarr.SortCatalogue'.tr(),
            icon: Icons.sort_rounded,
            onSelected: (result) {
              if (state.seriesSortType == result) {
                state.seriesSortAscending = !state.seriesSortAscending;
              } else {
                state.seriesSortAscending = true;
                state.seriesSortType = result;
              }
              widget.controller.animateToStart();
            },
            itemBuilder: (context) =>
                List<PopupMenuEntry<SonarrSeriesSorting>>.generate(
              SonarrSeriesSorting.values.length,
              (index) => PopupMenuItem<SonarrSeriesSorting>(
                value: SonarrSeriesSorting.values[index],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      SonarrSeriesSorting.values[index].readable,
                      style: TextStyle(
                        fontSize: ZebrraUI.FONT_SIZE_H3,
                        color: state.seriesSortType ==
                                SonarrSeriesSorting.values[index]
                            ? ZebrraColours.accent
                            : Colors.white,
                      ),
                    ),
                    if (state.seriesSortType ==
                        SonarrSeriesSorting.values[index])
                      Icon(
                        state.seriesSortAscending
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
        margin: const EdgeInsets.only(left: ZebrraUI.DEFAULT_MARGIN_SIZE),
        color: Theme.of(context).canvasColor,
      );
}
