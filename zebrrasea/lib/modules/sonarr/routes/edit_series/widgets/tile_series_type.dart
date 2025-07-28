import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesEditSeriesTypeTile extends StatelessWidget {
  const SonarrSeriesEditSeriesTypeTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'sonarr.SeriesType'.tr(),
      body: [
        TextSpan(
            text: context
                    .watch<SonarrSeriesEditState>()
                    .seriesType
                    ?.value
                    ?.toTitleCase() ??
                ZebrraUI.TEXT_EMDASH),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async => _onTap(context),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    Tuple2<bool, SonarrSeriesType?> result =
        await SonarrDialogs().editSeriesType(context);
    if (result.item1)
      context.read<SonarrSeriesEditState>().seriesType = result.item2!;
  }
}
