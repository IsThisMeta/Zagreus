import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraShapeBorder extends RoundedRectangleBorder {
  ZebrraShapeBorder({
    bool useBorder = false,
    bool topOnly = false,
  }) : super(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(ZebrraUI.BORDER_RADIUS),
            topRight: const Radius.circular(ZebrraUI.BORDER_RADIUS),
            bottomLeft: topOnly
                ? Radius.zero
                : const Radius.circular(ZebrraUI.BORDER_RADIUS),
            bottomRight: topOnly
                ? Radius.zero
                : const Radius.circular(ZebrraUI.BORDER_RADIUS),
          ),
          side: useBorder
              ? const BorderSide(color: ZebrraColours.white10)
              : BorderSide.none,
        );
}
