import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesAddDetailsQualityProfileTile extends StatelessWidget {
  const SonarrSeriesAddDetailsQualityProfileTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'sonarr.QualityProfile'.tr(),
      body: [
        TextSpan(
          text: context
                  .watch<SonarrSeriesAddDetailsState>()
                  .qualityProfile
                  .name ??
              ZebrraUI.TEXT_EMDASH,
        ),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async => _onTap(context),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    List<SonarrQualityProfile> _profiles =
        await context.read<SonarrState>().qualityProfiles!;
    Tuple2<bool, SonarrQualityProfile?> result =
        await SonarrDialogs().editQualityProfile(context, _profiles);
    if (result.item1) {
      context.read<SonarrSeriesAddDetailsState>().qualityProfile =
          result.item2!;
      SonarrDatabase.ADD_SERIES_DEFAULT_QUALITY_PROFILE
          .update(result.item2!.id);
    }
  }
}
