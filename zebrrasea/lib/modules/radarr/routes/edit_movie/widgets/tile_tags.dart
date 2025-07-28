import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrMoviesEditTagsTile extends StatelessWidget {
  const RadarrMoviesEditTagsTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<RadarrTag> _tags = context.watch<RadarrMoviesEditState>().tags;
    return ZebrraBlock(
      title: 'radarr.Tags'.tr(),
      body: [
        TextSpan(
          text: _tags.isEmpty
              ? ZebrraUI.TEXT_EMDASH
              : _tags.map((e) => e.label).join(', '),
        ),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async => await RadarrDialogs().setEditTags(context),
    );
  }
}
