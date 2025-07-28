import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraFloatingActionButtonAnimated extends StatelessWidget {
  final Object? heroTag;
  final AnimatedIconData icon;
  final AnimationController? controller;
  final Color color;
  final Color backgroundColor;
  final Function onPressed;

  const ZebrraFloatingActionButtonAnimated({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.controller,
    this.backgroundColor = ZebrraColours.accent,
    this.color = Colors.white,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: AnimatedIcon(
        icon: icon,
        color: color,
        progress: controller!,
      ),
      heroTag: heroTag,
      onPressed: onPressed as void Function()?,
      backgroundColor: backgroundColor,
    );
  }
}
