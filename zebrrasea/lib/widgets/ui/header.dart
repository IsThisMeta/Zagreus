import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraHeader extends StatelessWidget {
  final String? text;
  final String? subtitle;

  const ZebrraHeader({
    Key? key,
    required this.text,
    this.subtitle,
  }) : super(key: key);

  Widget _headerText() {
    return Text(
      text!,
      style: const TextStyle(
        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
        fontSize: ZebrraUI.FONT_SIZE_H2,
        color: Colors.white,
      ),
    );
  }

  Widget _barSeperator() {
    return Padding(
      child: Container(
        height: 2.0,
        width: ZebrraUI.DEFAULT_MARGIN_SIZE * 3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ZebrraUI.BORDER_RADIUS),
          color: ZebrraColours.accent,
        ),
      ),
      padding: const EdgeInsets.only(
        top: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
        left: 0,
        bottom: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
      ),
    );
  }

  Widget _subtitle() {
    return Padding(
      child: Text(
        subtitle!,
        style: const TextStyle(
          fontSize: ZebrraUI.FONT_SIZE_H4,
          color: ZebrraColours.grey,
          fontWeight: FontWeight.w300,
        ),
      ),
      padding: const EdgeInsets.only(bottom: ZebrraUI.DEFAULT_MARGIN_SIZE / 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerText(),
          _barSeperator(),
          if (subtitle != null) _subtitle(),
        ],
      ),
      padding: const EdgeInsets.only(
        left: ZebrraUI.DEFAULT_MARGIN_SIZE,
        right: ZebrraUI.DEFAULT_MARGIN_SIZE,
        top: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
      ),
    );
  }
}
