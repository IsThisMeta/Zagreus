import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliStatisticsTimeRangeButton extends StatelessWidget {
  const TautulliStatisticsTimeRangeButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Selector<TautulliState, TautulliStatisticsTimeRange>(
        selector: (_, state) => state.statisticsTimeRange,
        builder: (context, range, _) =>
            ZebrraPopupMenuButton<TautulliStatisticsTimeRange>(
                tooltip: 'Time Range',
                icon: Icons.access_time_rounded,
                onSelected: (value) {
                  context.read<TautulliState>().statisticsTimeRange = value;
                  context.read<TautulliState>().resetStatistics();
                },
                itemBuilder: (context) =>
                    List<PopupMenuEntry<TautulliStatisticsTimeRange>>.generate(
                      TautulliStatisticsTimeRange.values.length,
                      (index) => PopupMenuItem<TautulliStatisticsTimeRange>(
                        value: TautulliStatisticsTimeRange.values[index],
                        child: Text(
                          TautulliStatisticsTimeRange.values[index].name,
                          style: TextStyle(
                            fontSize: ZebrraUI.FONT_SIZE_H3,
                            color: range ==
                                    TautulliStatisticsTimeRange.values[index]
                                ? ZebrraColours.accent
                                : Colors.white,
                          ),
                        ),
                      ),
                    )),
      );
}
