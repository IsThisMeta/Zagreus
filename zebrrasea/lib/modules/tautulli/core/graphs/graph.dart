import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliGraphHelper {
  static const GRAPH_HEIGHT = 225.0;
  static const LEGEND_HEIGHT = 26.0;
  static const DEFAULT_MAX_TITLE_LENGTH = 5;

  BarChartAlignment chartAlignment() => BarChartAlignment.spaceEvenly;

  FlGridData gridData() => const FlGridData(show: false);

  FlBorderData borderData() => FlBorderData(
        show: true,
        border: Border.all(color: ZebrraColours.white10),
      );

  FlTitlesData titlesData(
    TautulliGraphData data, {
    int maxTitleLength = DEFAULT_MAX_TITLE_LENGTH,
    bool titleOverFlowShowEllipsis = true,
  }) {
    String _getTitle(double value) {
      return data.categories![value.truncate()]!.length > maxTitleLength + 1
          ? [
              data.categories![value.truncate()]!
                  .substring(
                      0,
                      min(maxTitleLength,
                          data.categories![value.truncate()]!.length))
                  .toUpperCase(),
              if (titleOverFlowShowEllipsis) ZebrraUI.TEXT_ELLIPSIS,
            ].join()
          : data.categories![value.truncate()]!.toUpperCase();
    }

    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize:
              ZebrraUI.FONT_SIZE_GRAPH_LEGEND + ZebrraUI.DEFAULT_MARGIN_SIZE,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(top: ZebrraUI.DEFAULT_MARGIN_SIZE),
              child: Text(
                _getTitle(value),
                style: const TextStyle(
                  color: ZebrraColours.grey,
                  fontSize: ZebrraUI.FONT_SIZE_GRAPH_LEGEND,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget createLegend(List<TautulliSeriesData> data) {
    return SizedBox(
      child: Row(
        children: List.generate(
          data.length,
          (index) => Padding(
            child: Row(
              children: [
                Padding(
                  child: Container(
                    height: ZebrraUI.FONT_SIZE_GRAPH_LEGEND,
                    width: ZebrraUI.FONT_SIZE_GRAPH_LEGEND,
                    decoration: BoxDecoration(
                      color: ZebrraColours().byGraphLayer(index),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  padding: const EdgeInsets.only(right: 6.0),
                ),
                Text(
                  data[index].name!,
                  style: TextStyle(
                    fontSize: ZebrraUI.FONT_SIZE_GRAPH_LEGEND,
                    color: ZebrraColours().byGraphLayer(index),
                  ),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
          ),
        ),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      height: LEGEND_HEIGHT,
    );
  }

  Widget loadingContainer(BuildContext context) {
    return ZebrraCard(
      context: context,
      child: const SizedBox(
        height: GRAPH_HEIGHT + LEGEND_HEIGHT,
        child: ZebrraLoader(),
      ),
    );
  }

  Widget errorContainer(BuildContext context) {
    return ZebrraCard(
      context: context,
      child: Container(
        height: GRAPH_HEIGHT + LEGEND_HEIGHT,
        alignment: Alignment.center,
        child: const ZebrraIconButton(
          icon: ZebrraIcons.ERROR,
          iconSize: ZebrraUI.ICON_SIZE * 2,
          color: ZebrraColours.red,
        ),
      ),
    );
  }
}
