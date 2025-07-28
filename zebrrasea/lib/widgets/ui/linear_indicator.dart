import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ZebrraLinearPercentIndicator extends StatelessWidget {
  static const _LINE_HEIGHT = 4.0;
  static const double height = _LINE_HEIGHT + ZebrraUI.DEFAULT_MARGIN_SIZE / 2;

  final double? percent;
  final Color progressColor;
  final Color? backgroundColor;

  const ZebrraLinearPercentIndicator({
    Key? key,
    this.percent,
    this.progressColor = ZebrraColours.accent,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.bottomCenter,
      child: LinearPercentIndicator(
        percent: percent!,
        padding: EdgeInsets.zero,
        lineHeight: 4.0,
        progressColor: progressColor,
        barRadius: const Radius.circular(ZebrraUI.BORDER_RADIUS),
        backgroundColor:
            backgroundColor ?? progressColor.withOpacity(ZebrraUI.OPACITY_SPLASH),
      ),
    );
  }
}
