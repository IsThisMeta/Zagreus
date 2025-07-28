import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliStatisticsTypeButton extends StatelessWidget {
  const TautulliStatisticsTypeButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Selector<TautulliState, TautulliStatsType>(
        selector: (_, state) => state.statisticsType,
        builder: (context, type, _) => ZebrraPopupMenuButton<TautulliStatsType>(
            tooltip: 'Statistics Type',
            icon: Icons.merge_type_rounded,
            onSelected: (value) {
              context.read<TautulliState>().statisticsType = value;
              context.read<TautulliState>().resetStatistics();
            },
            itemBuilder: (context) =>
                List<PopupMenuEntry<TautulliStatsType>>.generate(
                  TautulliStatsType.values.length,
                  (index) => PopupMenuItem<TautulliStatsType>(
                    value: TautulliStatsType.values[index],
                    child: Text(
                      TautulliStatsType.values[index].value!.toTitleCase(),
                      style: TextStyle(
                        fontSize: ZebrraUI.FONT_SIZE_H3,
                        color: type == TautulliStatsType.values[index]
                            ? ZebrraColours.accent
                            : Colors.white,
                      ),
                    ),
                  ),
                )),
      );
}
