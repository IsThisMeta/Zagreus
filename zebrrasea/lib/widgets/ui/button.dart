import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zebrrasea/system/state.dart';
import 'package:zebrrasea/types/loading_state.dart';
import 'package:zebrrasea/widgets/ui.dart';

enum ZebrraButtonType {
  TEXT,
  ICON,
  LOADER,
}

/// A Zebrra-styled button.
class ZebrraButton extends Card {
  static const DEFAULT_HEIGHT = 46.0;

  ZebrraButton._({
    Key? key,
    required Widget child,
    EdgeInsets margin = ZebrraUI.MARGIN_HALF,
    Color? backgroundColor,
    double height = DEFAULT_HEIGHT,
    Alignment alignment = Alignment.center,
    Decoration? decoration,
    Function? onTap,
    Function? onLongPress,
    ZebrraLoadingState? loadingState,
  }) : super(
          key: key,
          child: InkWell(
            child: Container(
              child: child,
              decoration: decoration,
              height: height,
              alignment: alignment,
            ),
            borderRadius: BorderRadius.circular(ZebrraUI.BORDER_RADIUS),
            onTap: () async {
              HapticFeedback.lightImpact();
              if (onTap != null && loadingState != ZebrraLoadingState.ACTIVE)
                onTap();
            },
            onLongPress: () async {
              HapticFeedback.heavyImpact();
              if (onLongPress != null &&
                  loadingState != ZebrraLoadingState.ACTIVE) onLongPress();
            },
          ),
          margin: margin,
          color: backgroundColor != null
              ? backgroundColor.withOpacity(ZebrraUI.OPACITY_DIMMED)
              : Theme.of(ZebrraState.context)
                  .canvasColor
                  .withOpacity(ZebrraUI.OPACITY_DIMMED),
          shape:
              backgroundColor != null ? ZebrraShapeBorder() : ZebrraUI.shapeBorder,
          elevation: ZebrraUI.ELEVATION,
          clipBehavior: Clip.antiAlias,
        );

  /// Create a default button.
  ///
  /// If [ZebrraLoadingState] is passed in, will build the correct button based on the type.
  factory ZebrraButton({
    required ZebrraButtonType type,
    Color color = ZebrraColours.accent,
    Color? backgroundColor,
    String? text,
    IconData? icon,
    double iconSize = ZebrraUI.ICON_SIZE,
    ZebrraLoadingState? loadingState,
    EdgeInsets margin = ZebrraUI.MARGIN_HALF,
    double height = DEFAULT_HEIGHT,
    Alignment alignment = Alignment.center,
    Decoration? decoration,
    Function? onTap,
    Function? onLongPress,
  }) {
    switch (loadingState) {
      case ZebrraLoadingState.ACTIVE:
        return ZebrraButton.loader(
          color: color,
          backgroundColor: backgroundColor,
          margin: margin,
          height: height,
          alignment: alignment,
          decoration: decoration,
          onTap: onTap,
          onLongPress: onLongPress,
          loadingState: loadingState,
        );
      case ZebrraLoadingState.ERROR:
        return ZebrraButton.icon(
          icon: Icons.error_rounded,
          iconSize: iconSize,
          color: color,
          backgroundColor: backgroundColor,
          margin: margin,
          height: height,
          alignment: alignment,
          decoration: decoration,
          onTap: onTap,
          onLongPress: onLongPress,
          loadingState: loadingState,
        );
      default:
        break;
    }
    switch (type) {
      case ZebrraButtonType.TEXT:
        return ZebrraButton.text(
          text: text!,
          icon: icon,
          iconSize: iconSize,
          color: color,
          backgroundColor: backgroundColor,
          margin: margin,
          height: height,
          alignment: alignment,
          decoration: decoration,
          onTap: onTap,
          onLongPress: onLongPress,
          loadingState: loadingState,
        );
      case ZebrraButtonType.ICON:
        assert(icon != null);
        return ZebrraButton.icon(
          icon: icon,
          iconSize: iconSize,
          color: color,
          backgroundColor: backgroundColor,
          margin: margin,
          height: height,
          alignment: alignment,
          decoration: decoration,
          onTap: onTap,
          onLongPress: onLongPress,
          loadingState: loadingState,
        );
      case ZebrraButtonType.LOADER:
        return ZebrraButton.loader(
          color: color,
          backgroundColor: backgroundColor,
          margin: margin,
          height: height,
          alignment: alignment,
          decoration: decoration,
          onTap: onTap,
          onLongPress: onLongPress,
          loadingState: loadingState,
        );
    }
  }

  /// Build a button that contains a centered text string.
  factory ZebrraButton.text({
    required String text,
    required IconData? icon,
    double iconSize = ZebrraUI.ICON_SIZE,
    Color color = ZebrraColours.accent,
    Color? backgroundColor,
    EdgeInsets margin = ZebrraUI.MARGIN_HALF,
    double height = DEFAULT_HEIGHT,
    Alignment alignment = Alignment.center,
    Decoration? decoration,
    ZebrraLoadingState? loadingState,
    Function? onTap,
    Function? onLongPress,
  }) {
    return ZebrraButton._(
      child: Padding(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null)
              Padding(
                child: Icon(
                  icon,
                  color: color,
                  size: iconSize,
                ),
                padding: const EdgeInsets.only(
                    right: ZebrraUI.DEFAULT_MARGIN_SIZE / 2),
              ),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
                  fontSize: ZebrraUI.FONT_SIZE_H3,
                ),
                overflow: TextOverflow.fade,
                softWrap: false,
                maxLines: 1,
              ),
            ),
          ],
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: ZebrraUI.DEFAULT_MARGIN_SIZE),
      ),
      margin: margin,
      height: height,
      backgroundColor: backgroundColor,
      alignment: alignment,
      decoration: decoration,
      onTap: onTap,
      onLongPress: onLongPress,
      loadingState: loadingState,
    );
  }

  /// Build a button that contains a [ZebrraLoader].
  factory ZebrraButton.loader({
    EdgeInsets margin = ZebrraUI.MARGIN_HALF,
    Color color = ZebrraColours.accent,
    Color? backgroundColor,
    double height = DEFAULT_HEIGHT,
    Alignment alignment = Alignment.center,
    Decoration? decoration,
    Function? onTap,
    Function? onLongPress,
    ZebrraLoadingState? loadingState,
  }) {
    return ZebrraButton._(
      child: ZebrraLoader(
        useSafeArea: false,
        color: color,
        size: ZebrraUI.FONT_SIZE_H3,
      ),
      margin: margin,
      height: height,
      backgroundColor: backgroundColor,
      alignment: alignment,
      decoration: decoration,
      onTap: onTap,
      onLongPress: onLongPress,
      loadingState: loadingState,
    );
  }

  /// Build a button that contains a single, centered [Icon].
  factory ZebrraButton.icon({
    required IconData? icon,
    Color color = ZebrraColours.accent,
    Color? backgroundColor,
    EdgeInsets margin = ZebrraUI.MARGIN_HALF,
    double height = DEFAULT_HEIGHT,
    double iconSize = ZebrraUI.ICON_SIZE,
    Alignment alignment = Alignment.center,
    Decoration? decoration,
    Function? onTap,
    Function? onLongPress,
    ZebrraLoadingState? loadingState,
  }) {
    return ZebrraButton._(
      child: Icon(
        icon,
        color: color,
        size: iconSize,
      ),
      margin: margin,
      height: height,
      backgroundColor: backgroundColor,
      alignment: alignment,
      decoration: decoration,
      onTap: onTap,
      onLongPress: onLongPress,
      loadingState: loadingState,
    );
  }
}
