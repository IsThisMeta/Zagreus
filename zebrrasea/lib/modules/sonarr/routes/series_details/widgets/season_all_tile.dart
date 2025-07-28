import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/router/routes/sonarr.dart';

class SonarrSeriesDetailsSeasonAllTile extends StatelessWidget {
  final SonarrSeries? series;

  const SonarrSeriesDetailsSeasonAllTile({
    Key? key,
    required this.series,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'sonarr.AllSeasons'.tr(),
      disabled: !series!.monitored!,
      body: [
        _subtitle1(),
        _subtitle2(),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async {
        SonarrRoutes.SERIES_SEASON.go(params: {
          'series': (series?.id ?? -1).toString(),
          'season': '-1',
        });
      },
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      text: series?.statistics?.sizeOnDisk?.asBytes(decimals: 1) ?? '0.0B',
    );
  }

  TextSpan _subtitle2() {
    return TextSpan(
      style: TextStyle(
        color: series!.zebrraPercentageComplete == 100
            ? ZebrraColours.accent
            : ZebrraColours.red,
        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
      ),
      text: [
        '${series!.zebrraPercentageComplete}%',
        ZebrraUI.TEXT_BULLET,
        '${series!.statistics?.episodeFileCount ?? 0}/${series!.statistics?.episodeCount ?? 0}',
        'Episodes Available',
      ].join(' '),
    );
  }
}
