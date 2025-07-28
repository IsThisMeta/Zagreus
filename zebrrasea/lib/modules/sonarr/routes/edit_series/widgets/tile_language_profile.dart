import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesEditLanguageProfileTile extends StatelessWidget {
  final List<SonarrLanguageProfile?> profiles;

  const SonarrSeriesEditLanguageProfileTile({
    Key? key,
    required this.profiles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'sonarr.LanguageProfile'.tr(),
      body: [
        TextSpan(
          text: context.watch<SonarrSeriesEditState>().languageProfile?.name ??
              ZebrraUI.TEXT_EMDASH,
        ),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async => _onTap(context),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    Tuple2<bool, SonarrLanguageProfile?> result =
        await SonarrDialogs().editLanguageProfiles(context, profiles);
    if (result.item1)
      context.read<SonarrSeriesEditState>().languageProfile = result.item2!;
  }
}
