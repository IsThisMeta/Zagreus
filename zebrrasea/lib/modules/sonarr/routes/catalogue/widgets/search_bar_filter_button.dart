import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/scroll_controller.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesSearchBarFilterButton extends StatefulWidget {
  final ScrollController controller;

  const SonarrSeriesSearchBarFilterButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<SonarrSeriesSearchBarFilterButton> createState() => _State();
}

class _State extends State<SonarrSeriesSearchBarFilterButton> {
  @override
  Widget build(BuildContext context) => ZebrraCard(
        context: context,
        child: Consumer<SonarrState>(
          builder: (context, state, _) =>
              ZebrraPopupMenuButton<SonarrSeriesFilter>(
            tooltip: 'sonarr.FilterCatalogue'.tr(),
            icon: Icons.filter_list_rounded,
            onSelected: (result) {
              state.seriesFilterType = result;
              widget.controller.animateToStart();
            },
            itemBuilder: (context) =>
                List<PopupMenuEntry<SonarrSeriesFilter>>.generate(
              SonarrSeriesFilter.values.length,
              (index) => PopupMenuItem<SonarrSeriesFilter>(
                value: SonarrSeriesFilter.values[index],
                child: Text(
                  SonarrSeriesFilter.values[index].readable,
                  style: TextStyle(
                    fontSize: ZebrraUI.FONT_SIZE_H3,
                    color: state.seriesFilterType ==
                            SonarrSeriesFilter.values[index]
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
