import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zebrrasea/core.dart';

class ZebrraActionBarCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? backgroundColor;
  final Color color;
  final IconData icon;
  final Function? onTap;
  final Function? onLongPress;
  final bool? checkboxState;
  final void Function(bool?)? checkboxOnChanged;

  const ZebrraActionBarCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.color = ZebrraColours.accent,
    this.icon = ZebrraIcons.ARROW_RIGHT,
    this.checkboxState,
    this.checkboxOnChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraCard(
      context: context,
      child: InkWell(
        child: SizedBox(
          child: Padding(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ZebrraText(
                        text: title,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          fontSize: ZebrraUI.FONT_SIZE_BUTTON,
                          fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
                          color: color,
                        ),
                      ),
                      if (subtitle != null)
                        ZebrraText(
                          text: subtitle!,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            fontSize: ZebrraUI.FONT_SIZE_SUBHEADER,
                            color: ZebrraColours.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                if (checkboxState != null)
                  Container(
                    width: 30.0,
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 20.0,
                      child: Checkbox(
                        value: checkboxState,
                        onChanged: checkboxOnChanged,
                      ),
                    ),
                  ),
                if (checkboxState == null)
                  Container(
                    width: 30.0,
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 20.0,
                      child: Icon(
                        icon,
                        size: 20.0,
                      ),
                    ),
                  ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
          ),
          height: ZebrraButton.DEFAULT_HEIGHT,
        ),
        borderRadius: BorderRadius.circular(ZebrraUI.BORDER_RADIUS),
        onTap: _onTapHandler() as void Function()?,
        onLongPress: _onLongPressHandler() as void Function()?,
      ),
      margin: ZebrraUI.MARGIN_HALF,
      color: backgroundColor != null
          ? backgroundColor!.withOpacity(ZebrraUI.OPACITY_DIMMED)
          : ZebrraTheme.isAMOLEDTheme
              ? Colors.black.withOpacity(ZebrraUI.OPACITY_DIMMED)
              : ZebrraColours.primary.withOpacity(ZebrraUI.OPACITY_DIMMED),
    );
  }

  Function? _onTapHandler() {
    if (onTap != null) {
      return () async {
        HapticFeedback.lightImpact();
        onTap!();
      };
    }
    if (checkboxState != null && checkboxOnChanged != null) {
      return () async => checkboxOnChanged!(!checkboxState!);
    }
    return null;
  }

  Function? _onLongPressHandler() {
    if (onLongPress != null) {
      return () async {
        HapticFeedback.heavyImpact();
        onLongPress!();
      };
    }
    return null;
  }
}
