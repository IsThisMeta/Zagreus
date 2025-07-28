import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesEditSeriesPathTile extends StatelessWidget {
  const SonarrSeriesEditSeriesPathTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'sonarr.SeriesPath'.tr(),
      body: [
        TextSpan(
          text: context.watch<SonarrSeriesEditState>().seriesPath,
        ),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async => _onTap(context),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    Tuple2<bool, String> _values = await ZebrraDialogs().editText(
      context,
      'sonarr.SeriesPath'.tr(),
      prefill: context.read<SonarrSeriesEditState>().seriesPath,
    );
    if (_values.item1)
      context.read<SonarrSeriesEditState>().seriesPath = _values.item2;
  }
}
