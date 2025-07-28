import 'package:zebrrasea/core.dart';

Future<void> showZebrraErrorSnackBar({
  required String title,
  dynamic error,
  String? message,
  bool showButton = false,
  String buttonText = 'view',
  Function? buttonOnPressed,
}) async =>
    showZebrraSnackBar(
      title: title,
      message: message ?? ZebrraLogger.checkLogsMessage,
      type: ZebrraSnackbarType.ERROR,
      showButton: error != null || showButton,
      buttonText: buttonText,
      buttonOnPressed: () async {
        if (error != null) {
          ZebrraDialogs().textPreview(
            ZebrraState.context,
            'Error',
            error.toString(),
          );
        } else if (buttonOnPressed != null) {
          buttonOnPressed();
        }
      },
    );
