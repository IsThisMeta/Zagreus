import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrDiskSpaceTile extends StatelessWidget {
  final RadarrDiskSpace diskSpace;

  const RadarrDiskSpaceTile({
    Key? key,
    required this.diskSpace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: diskSpace.zebrraPath,
      body: [TextSpan(text: diskSpace.zebrraSpace)],
      bottom: ZebrraLinearPercentIndicator(
        percent: diskSpace.zebrraPercentage / 100,
        progressColor: diskSpace.zebrraColor,
      ),
      bottomHeight: ZebrraLinearPercentIndicator.height,
      trailing: ZebrraIconButton(
        text: diskSpace.zebrraPercentageString,
        textSize: ZebrraUI.FONT_SIZE_H4,
        color: diskSpace.zebrraColor,
      ),
    );
  }
}
