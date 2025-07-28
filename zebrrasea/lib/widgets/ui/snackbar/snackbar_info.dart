import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/core.dart';

Future<void> showZebrraInfoSnackBar({
  required String title,
  required String? message,
  bool showButton = false,
  String buttonText = 'view',
  Function? buttonOnPressed,
}) async =>
    showZebrraSnackBar(
      title: title,
      message: message.uiSafe(),
      type: ZebrraSnackbarType.INFO,
      showButton: showButton,
      buttonText: buttonText,
      buttonOnPressed: buttonOnPressed,
    );
