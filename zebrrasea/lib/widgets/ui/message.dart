import 'package:flutter/material.dart';
import 'package:zebrrasea/modules.dart';
import 'package:zebrrasea/router/router.dart';
import 'package:zebrrasea/router/routes/dashboard.dart';
import 'package:zebrrasea/vendor.dart';
import 'package:zebrrasea/widgets/ui.dart';

class ZebrraMessage extends StatelessWidget {
  final String text;
  final Color textColor;
  final String? buttonText;
  final Function? onTap;
  final bool useSafeArea;

  const ZebrraMessage({
    Key? key,
    required this.text,
    this.textColor = Colors.white,
    this.buttonText,
    this.onTap,
    this.useSafeArea = true,
  }) : super(key: key);

  /// Return a message that is meant to be shown within a [ListView].
  factory ZebrraMessage.inList({
    Key? key,
    required String text,
    bool useSafeArea = false,
  }) {
    return ZebrraMessage(
      key: key,
      text: text,
      useSafeArea: useSafeArea,
    );
  }

  /// Returns a centered message with a simple message, with a button to pop out of the route.
  factory ZebrraMessage.goBack({
    Key? key,
    required String text,
    required BuildContext context,
    bool useSafeArea = true,
  }) {
    return ZebrraMessage(
      key: key,
      text: text,
      buttonText: 'zebrrasea.GoBack'.tr(),
      onTap: () {
        if (ZebrraRouter.router.canPop()) {
          ZebrraRouter.router.pop();
        } else {
          ZebrraRouter.router.pushReplacement(DashboardRoutes.HOME.path);
        }
      },
      useSafeArea: useSafeArea,
    );
  }

  /// Return a pre-structured "An Error Has Occurred" message, with a "Try Again" button shown.
  factory ZebrraMessage.error({
    Key? key,
    required Function onTap,
    bool useSafeArea = true,
  }) {
    return ZebrraMessage(
      key: key,
      text: 'zebrrasea.AnErrorHasOccurred'.tr(),
      buttonText: 'zebrrasea.TryAgain'.tr(),
      onTap: onTap,
      useSafeArea: useSafeArea,
    );
  }

  /// Return a pre-structured "<module> Is Not Enabled" message, with a "Return to Dashboard" button shown.
  factory ZebrraMessage.moduleNotEnabled({
    Key? key,
    required BuildContext context,
    required String module,
    bool useSafeArea = true,
  }) {
    return ZebrraMessage(
      key: key,
      text: 'zebrrasea.ModuleIsNotEnabled'.tr(args: [module]),
      buttonText: 'zebrrasea.ReturnToDashboard'.tr(),
      onTap: ZebrraModule.DASHBOARD.launch,
      useSafeArea: useSafeArea,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: useSafeArea,
      left: useSafeArea,
      right: useSafeArea,
      bottom: useSafeArea,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            margin: ZebrraUI.MARGIN_H_DEFAULT_V_HALF,
            elevation: ZebrraUI.ELEVATION,
            shape: ZebrraUI.shapeBorder,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
                        fontSize: ZebrraUI.FONT_SIZE_MESSAGES,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 24.0, horizontal: 12.0),
                  ),
                ),
              ],
            ),
          ),
          if (buttonText != null)
            ZebrraButtonContainer(
              children: [
                ZebrraButton.text(
                  text: buttonText!,
                  icon: null,
                  onTap: onTap,
                  color: Colors.white,
                  backgroundColor: ZebrraColours.accent,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
