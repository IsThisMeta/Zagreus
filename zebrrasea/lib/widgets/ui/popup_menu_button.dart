import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zebrrasea/core.dart';

class ZebrraPopupMenuButton<T> extends PopupMenuButton<T> {
  ZebrraPopupMenuButton({
    required PopupMenuItemSelected<T> onSelected,
    required PopupMenuItemBuilder<T> itemBuilder,
    Key? key,
    IconData? icon,
    Widget? child,
    String? tooltip,
  }) : super(
          key: key,
          shape: ZebrraUI.shapeBorder,
          tooltip: tooltip,
          icon: icon == null ? null : Icon(icon),
          child: child,
          onSelected: (result) {
            HapticFeedback.selectionClick();
            onSelected(result);
          },
          itemBuilder: itemBuilder,
        );
}
