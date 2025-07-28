import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrAddMovieDetailsTagsTile extends StatelessWidget {
  const RadarrAddMovieDetailsTagsTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'radarr.Tags'.tr(),
      body: [
        TextSpan(
          text: context.watch<RadarrAddMovieDetailsState>().tags.isEmpty
              ? ZebrraUI.TEXT_EMDASH
              : context
                  .watch<RadarrAddMovieDetailsState>()
                  .tags
                  .map((e) => e.label)
                  .join(', '),
        ),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async => await RadarrDialogs().setAddTags(context),
    );
  }
}
