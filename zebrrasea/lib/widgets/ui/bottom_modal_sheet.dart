import 'package:flutter/material.dart';
import 'package:zebrrasea/system/state.dart';
import 'package:zebrrasea/widgets/ui.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ZebrraBottomModalSheet<T> {
  @protected
  Future<T?> showModal({
    Widget Function(BuildContext context)? builder,
  }) async {
    return showBarModalBottomSheet<T>(
      context: ZebrraState.context,
      expand: false,
      backgroundColor:
          ZebrraTheme.isAMOLEDTheme ? Colors.black : ZebrraColours.primary,
      shape: ZebrraShapeBorder(
        topOnly: true,
        useBorder: ZebrraUI.shouldUseBorder,
      ),
      builder: builder ?? this.builder as Widget Function(BuildContext),
      closeProgressThreshold: 0.90,
      elevation: ZebrraUI.ELEVATION,
      overlayStyle: ZebrraTheme().overlayStyle,
    );
  }

  Widget? builder(BuildContext context) => null;

  Future<dynamic> show({
    Widget Function(BuildContext context)? builder,
  }) async =>
      showModal(builder: builder);
}
