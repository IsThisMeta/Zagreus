import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesEditMonitoredTile extends StatelessWidget {
  const SonarrSeriesEditMonitoredTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'sonarr.Monitored'.tr(),
      trailing: ZebrraSwitch(
        value: context.watch<SonarrSeriesEditState>().monitored,
        onChanged: (value) =>
            context.read<SonarrSeriesEditState>().monitored = value,
      ),
    );
  }
}
