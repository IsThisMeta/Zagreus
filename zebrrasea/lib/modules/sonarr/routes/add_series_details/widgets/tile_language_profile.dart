import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesAddDetailsLanguageProfileTile extends StatelessWidget {
  const SonarrSeriesAddDetailsLanguageProfileTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'sonarr.LanguageProfile'.tr(),
      body: [
        TextSpan(
          text: context
                  .watch<SonarrSeriesAddDetailsState>()
                  .languageProfile
                  .name ??
              ZebrraUI.TEXT_EMDASH,
        ),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async => _onTap(context),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    List<SonarrLanguageProfile> _profiles =
        await context.read<SonarrState>().languageProfiles!;
    Tuple2<bool, SonarrLanguageProfile?> result =
        await SonarrDialogs().editLanguageProfiles(context, _profiles);
    if (result.item1) {
      context.read<SonarrSeriesAddDetailsState>().languageProfile =
          result.item2!;
      SonarrDatabase.ADD_SERIES_DEFAULT_LANGUAGE_PROFILE
          .update(result.item2!.id);
    }
  }
}
