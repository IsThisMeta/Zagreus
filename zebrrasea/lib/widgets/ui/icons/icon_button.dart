import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zebrrasea/core.dart';

class ZebrraIconButton extends StatelessWidget {
  final IconData? icon;
  final double iconSize;
  final String? text;
  final double textSize;
  final Color color;
  final Function? onPressed;
  final Function? onLongPress;
  final ZebrraLoadingState? loadingState;
  final AlignmentGeometry alignment;
  final MouseCursor? mouseCursor;

  const ZebrraIconButton.arrow({
    Key? key,
    this.text,
    this.textSize = ZebrraUI.FONT_SIZE_H5,
    this.icon = ZebrraIcons.ARROW_RIGHT,
    this.iconSize = ZebrraUI.ICON_SIZE,
    this.alignment = Alignment.center,
    this.color = Colors.white,
    this.onPressed,
    this.onLongPress,
    this.loadingState,
    this.mouseCursor,
  }) : super(key: key);

  const ZebrraIconButton.appBar({
    Key? key,
    this.text,
    this.textSize = ZebrraUI.FONT_SIZE_H5,
    this.icon,
    this.iconSize = ZebrraUI.ICON_SIZE,
    this.alignment = Alignment.center,
    this.color = Colors.white,
    this.onPressed,
    this.onLongPress,
    this.loadingState,
    this.mouseCursor,
  }) : super(key: key);

  const ZebrraIconButton({
    Key? key,
    this.text,
    this.textSize = ZebrraUI.FONT_SIZE_H5,
    this.icon,
    this.iconSize = ZebrraUI.ICON_SIZE,
    this.alignment = Alignment.center,
    this.color = Colors.white,
    this.onPressed,
    this.onLongPress,
    this.loadingState,
    this.mouseCursor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: IconButton(
        icon: loadingState == ZebrraLoadingState.ACTIVE ? _loader() : _icon(),
        iconSize: iconSize,
        alignment: alignment,
        padding: EdgeInsets.zero,
        onPressed: _onPressed() as void Function()?,
        mouseCursor: mouseCursor ??
            (onPressed != null ? SystemMouseCursors.click : MouseCursor.defer),
      ),
      hoverColor: Colors.transparent,
      mouseCursor: mouseCursor ??
          (onLongPress != null ? SystemMouseCursors.click : MouseCursor.defer),
      onLongPress: _onLongPress() as void Function()?,
    );
  }

  Function? _onPressed() {
    if (onPressed == null) return null;
    if (loadingState == ZebrraLoadingState.ACTIVE) return null;
    return () async {
      HapticFeedback.lightImpact();
      onPressed!();
    };
  }

  Function? _onLongPress() {
    if (onLongPress == null) return null;
    if (loadingState == ZebrraLoadingState.ACTIVE) return null;
    return () async {
      HapticFeedback.heavyImpact();
      onLongPress!();
    };
  }

  Widget _loader() {
    return ZebrraLoader(
      size: ZebrraUI.FONT_SIZE_H4,
      color: color,
      useSafeArea: false,
    );
  }

  Widget _icon() {
    assert((text != null || icon != null), 'both text and icon cannot be null');
    if (loadingState == ZebrraLoadingState.ERROR) {
      return Icon(
        Icons.error_rounded,
        color: color,
      );
    } else if (icon != null) {
      return Icon(
        icon,
        color: color,
      );
    } else {
      return Text(
        text!,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          fontSize: textSize,
        ),
      );
    }
  }
}
