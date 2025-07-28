import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zebrrasea/core.dart';

enum ZebrraSnackbarType {
  SUCCESS,
  ERROR,
  INFO,
}

extension ZebrraSnackbarTypeExtension on ZebrraSnackbarType {
  Color get color {
    switch (this) {
      case ZebrraSnackbarType.SUCCESS:
        return ZebrraColours.accent;
      case ZebrraSnackbarType.ERROR:
        return ZebrraColours.red;
      case ZebrraSnackbarType.INFO:
        return ZebrraColours.blue;
      default:
        return ZebrraColours.purple;
    }
  }

  IconData get icon {
    switch (this) {
      case ZebrraSnackbarType.SUCCESS:
        return Icons.check_circle_outline_rounded;
      case ZebrraSnackbarType.ERROR:
        return Icons.error_outline_rounded;
      case ZebrraSnackbarType.INFO:
        return Icons.info_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}

Future<void> showZebrraSnackBar({
  required String title,
  required ZebrraSnackbarType type,
  required String message,
  Duration? duration,
  FlashPosition position = FlashPosition.bottom,
  bool showButton = false,
  String buttonText = 'view',
  Function? buttonOnPressed,
}) async {
  showFlash(
    context: ZebrraState.context,
    duration: duration ?? Duration(seconds: showButton ? 4 : 2),
    transitionDuration: const Duration(milliseconds: ZebrraUI.ANIMATION_SPEED),
    reverseTransitionDuration:
        const Duration(milliseconds: ZebrraUI.ANIMATION_SPEED),
    builder: (context, controller) => FlashBar(
      controller: controller,
      backgroundColor: Theme.of(context).primaryColor,
      behavior: FlashBehavior.floating,
      margin: ZebrraUI.MARGIN_DEFAULT,
      position: position,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color:
              ZebrraUI.shouldUseBorder ? ZebrraColours.white10 : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(ZebrraUI.BORDER_RADIUS),
      ),
      title: ZebrraText.title(
        text: title,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
      content: ZebrraText.subtitle(
        text: message,
        maxLines: 8,
        overflow: TextOverflow.ellipsis,
      ),
      shouldIconPulse: false,
      icon: Padding(
        child: ZebrraIconButton(
          icon: type.icon,
          color: type.color,
        ),
        padding: const EdgeInsets.only(
          left: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
        ),
      ),
      primaryAction: showButton
          ? TextButton(
              child: Text(
                buttonText.toUpperCase(),
                style: const TextStyle(
                  fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
                  color: ZebrraColours.accent,
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.dismiss();
                buttonOnPressed!();
              },
            )
          : null,
    ),
  );
}
