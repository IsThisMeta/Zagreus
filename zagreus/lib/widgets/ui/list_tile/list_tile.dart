import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

@Deprecated("Use ZagBlock instead")
class ZagListTile extends Card {
  ZagListTile({
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
    EdgeInsets margin = ZagUI.MARGIN_H_DEFAULT_V_HALF,
  }) : super(
          key: key,
          child: Container(
            height: height,
            child: InkWell(
              child: Row(
                children: [
                  if (leading != null)
                    SizedBox(
                      width: ZagUI.DEFAULT_MARGIN_SIZE * 4 +
                          ZagUI.DEFAULT_MARGIN_SIZE / 2,
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
                            height: ZagBlock.TITLE_HEIGHT,
                          ),
                          if (subtitle != null) subtitle,
                        ],
                      ),
                      padding: EdgeInsets.only(
                        top: ZagUI.DEFAULT_MARGIN_SIZE,
                        bottom: ZagUI.DEFAULT_MARGIN_SIZE,
                        left: leading != null ? 0 : ZagUI.DEFAULT_MARGIN_SIZE,
                        right:
                            trailing != null ? 0 : ZagUI.DEFAULT_MARGIN_SIZE,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        right: ZagUI.DEFAULT_MARGIN_SIZE / 2,
                      ),
                      child: SizedBox(
                        width: ZagUI.DEFAULT_MARGIN_SIZE * 4,
                        child: trailing,
                      ),
                    ),
                ],
              ),
              borderRadius: BorderRadius.circular(ZagUI.BORDER_RADIUS),
              onTap: onTap as void Function()?,
              onLongPress: onLongPress as void Function()?,
              mouseCursor: MouseCursor.defer,
            ),
            decoration: decoration,
          ),
          margin: margin,
          elevation: ZagUI.ELEVATION,
          shape: drawBorder ? ZagUI.shapeBorder : ZagShapeBorder(),
          color: color ?? Theme.of(context).primaryColor,
        );
}
