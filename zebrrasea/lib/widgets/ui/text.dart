import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraText extends Text {
  /// Create a new [Text] widget.
  const ZebrraText({
    required String text,
    Key? key,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    TextStyle? style,
    TextAlign? textAlign,
  }) : super(
          text,
          key: key,
          maxLines: maxLines == 0 ? null : maxLines,
          overflow: overflow,
          softWrap: softWrap,
          style: style,
          textAlign: textAlign,
        );

  /// Create a [ZebrraText] widget with the styling pre-assigned to be a ZebrraSea title.
  factory ZebrraText.title({
    Key? key,
    required String text,
    int maxLines = 1,
    bool softWrap = false,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.fade,
    Color color = Colors.white,
  }) =>
      ZebrraText(
        text: text,
        key: key,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        textAlign: textAlign,
        style: TextStyle(
          color: color,
          fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          fontSize: ZebrraUI.FONT_SIZE_H2,
        ),
      );

  /// Create a [ZebrraText] widget with the styling pre-assigned to be a ZebrraSea subtitle.
  factory ZebrraText.subtitle({
    Key? key,
    required String text,
    int maxLines = 1,
    bool softWrap = false,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.fade,
    Color color = ZebrraColours.grey,
    FontStyle fontStyle = FontStyle.normal,
  }) =>
      ZebrraText(
        key: key,
        text: text,
        softWrap: softWrap,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow,
        style: TextStyle(
          color: color,
          fontSize: ZebrraUI.FONT_SIZE_H3,
          fontStyle: fontStyle,
        ),
      );
}
