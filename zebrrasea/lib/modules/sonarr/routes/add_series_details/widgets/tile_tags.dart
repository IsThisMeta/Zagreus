import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesAddDetailsTagsTile extends StatelessWidget {
  const SonarrSeriesAddDetailsTagsTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<SonarrTag> _tags = context.watch<SonarrSeriesAddDetailsState>().tags;
    return ZebrraBlock(
      title: 'sonarr.Tags'.tr(),
      body: [
        TextSpan(
          text: _tags.isEmpty
              ? ZebrraUI.TEXT_EMDASH
              : _tags.map((e) => e.label).join(', '),
        ),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async => await SonarrDialogs().setAddTags(context),
    );
  }
}
