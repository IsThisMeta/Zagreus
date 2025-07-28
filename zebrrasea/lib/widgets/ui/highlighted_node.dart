import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraHighlightedNode extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final String text;

  const ZebrraHighlightedNode({
    Key? key,
    required this.text,
    this.backgroundColor = ZebrraColours.accent,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        child: Text(
          text,
          maxLines: 1,
          style: TextStyle(
            fontSize: ZebrraUI.FONT_SIZE_H4,
            color: textColor,
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ZebrraUI.BORDER_RADIUS),
      ),
    );
  }
}
