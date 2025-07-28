import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/core.dart';

Future<void> showZebrraSuccessSnackBar({
  required String title,
  required String? message,
  bool showButton = false,
  String buttonText = 'view',
  Function? buttonOnPressed,
}) async =>
    showZebrraSnackBar(
      title: title,
      message: message.uiSafe(),
      type: ZebrraSnackbarType.SUCCESS,
      showButton: showButton,
      buttonText: buttonText,
      buttonOnPressed: buttonOnPressed,
    );
