import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraTextSpan extends TextSpan {
  const ZebrraTextSpan.extended({
    required String? text,
  }) : super(
          text: text,
          style: const TextStyle(
            height: ZebrraBlock.SUBTITLE_HEIGHT / ZebrraUI.FONT_SIZE_H3,
          ),
        );
}
