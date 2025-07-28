import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraCard extends Card {
  ZebrraCard({
    Key? key,
    required BuildContext context,
    required Widget child,
    EdgeInsets margin = ZebrraUI.MARGIN_H_DEFAULT_V_HALF,
    Color? color,
    Decoration? decoration,
    double? height,
    double? width,
  }) : super(
          key: key,
          child: Container(
            child: child,
            decoration: decoration,
            height: height,
            width: width,
          ),
          margin: margin,
          color: color ?? Theme.of(context).primaryColor,
          shape: ZebrraUI.shapeBorder,
          elevation: 0.0,
          clipBehavior: Clip.antiAlias,
        );
}
