import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraDivider extends Divider {
  ZebrraDivider({
    Key? key,
  }) : super(
          key: key,
          thickness: 1.0,
          color: ZebrraColours.accent.dimmed(),
          indent: ZebrraUI.DEFAULT_MARGIN_SIZE * 5,
          endIndent: ZebrraUI.DEFAULT_MARGIN_SIZE * 5,
        );
}
