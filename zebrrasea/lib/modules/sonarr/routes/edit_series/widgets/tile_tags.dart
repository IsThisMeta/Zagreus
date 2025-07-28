import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesEditTagsTile extends StatelessWidget {
  const SonarrSeriesEditTagsTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'sonarr.Tags'.tr(),
      body: [
        TextSpan(
          text: (context.watch<SonarrSeriesEditState>().tags?.isEmpty ?? true)
              ? 'zebrrasea.NotSet'.tr()
              : context
                  .watch<SonarrSeriesEditState>()
                  .tags
                  ?.map((e) => e.label)
                  .join(', '),
        )
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async => await SonarrDialogs().setEditTags(context),
    );
  }
}
