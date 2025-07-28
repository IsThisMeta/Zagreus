import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrAddMovieDetailsMonitoredTile extends StatelessWidget {
  const RadarrAddMovieDetailsMonitoredTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'radarr.Monitor'.tr(),
      trailing: Selector<RadarrAddMovieDetailsState, bool>(
        selector: (_, state) => state.monitored,
        builder: (context, monitored, _) => ZebrraSwitch(
          value: monitored,
          onChanged: (value) =>
              context.read<RadarrAddMovieDetailsState>().monitored = value,
        ),
      ),
    );
  }
}
