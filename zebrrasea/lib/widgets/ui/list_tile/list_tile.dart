import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

@Deprecated("Use ZebrraBlock instead")
class ZebrraListTile extends Card {
  ZebrraListTile({
    Key? key,
    required BuildContext context,
    required Widget title,
    required double height,
    Widget? subtitle,
    Widget? trailing,
    Widget? leading,
    Color? color,
    Decoration? decoration,
    Function? onTap,
    Function? onLongPress,
    bool drawBorder = true,
    EdgeInsets margin = ZebrraUI.MARGIN_H_DEFAULT_V_HALF,
  }) : super(
          key: key,
          child: Container(
            height: height,
            child: InkWell(
              child: Row(
                children: [
                  if (leading != null)
                    SizedBox(
                      width: ZebrraUI.DEFAULT_MARGIN_SIZE * 4 +
                          ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
                      child: leading,
                    ),
                  Expanded(
                    child: Padding(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: title,
                            height: ZebrraBlock.TITLE_HEIGHT,
                          ),
                          if (subtitle != null) subtitle,
                        ],
                      ),
                      padding: EdgeInsets.only(
                        top: ZebrraUI.DEFAULT_MARGIN_SIZE,
                        bottom: ZebrraUI.DEFAULT_MARGIN_SIZE,
                        left: leading != null ? 0 : ZebrraUI.DEFAULT_MARGIN_SIZE,
                        right:
                            trailing != null ? 0 : ZebrraUI.DEFAULT_MARGIN_SIZE,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        right: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
                      ),
                      child: SizedBox(
                        width: ZebrraUI.DEFAULT_MARGIN_SIZE * 4,
                        child: trailing,
                      ),
                    ),
                ],
              ),
              borderRadius: BorderRadius.circular(ZebrraUI.BORDER_RADIUS),
              onTap: onTap as void Function()?,
              onLongPress: onLongPress as void Function()?,
              mouseCursor: MouseCursor.defer,
            ),
            decoration: decoration,
          ),
          margin: margin,
          elevation: ZebrraUI.ELEVATION,
          shape: drawBorder ? ZebrraUI.shapeBorder : ZebrraShapeBorder(),
          color: color ?? Theme.of(context).primaryColor,
        );
}
