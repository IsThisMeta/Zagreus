import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/supabase/messaging.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class SettingsRoute extends StatefulWidget {
  const SettingsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsRoute> createState() => _State();
}

class _State extends State<SettingsRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      drawer: _drawer(),
      body: _body(),
    );
  }

  Widget _drawer() => ZagDrawer(page: ZagModule.SETTINGS.key);

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      useDrawer: true,
      scrollControllers: [scrollController],
      title: ZagModule.SETTINGS.title,
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagBlock(
          title: 'settings.Account'.tr(),
          body: [TextSpan(text: 'settings.AccountDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.account_circle_rounded),
          onTap: SettingsRoutes.ACCOUNT.go,
        ),
        ZagBlock(
          title: 'settings.Configuration'.tr(),
          body: [TextSpan(text: 'settings.ConfigurationDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.device_hub_rounded),
          onTap: SettingsRoutes.CONFIGURATION.go,
        ),
        if (ZagSupabaseMessaging.isSupported)
          ZagBlock(
            title: 'settings.Notifications'.tr(),
            body: [TextSpan(text: 'settings.NotificationsDescription'.tr())],
            trailing: const ZagIconButton(icon: Icons.notifications_rounded),
            onTap: SettingsRoutes.NOTIFICATIONS.go,
          ),
        ZagBlock(
          title: 'settings.Profiles'.tr(),
          body: [TextSpan(text: 'settings.ProfilesDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.switch_account_rounded),
          onTap: SettingsRoutes.PROFILES.go,
        ),
        ZagDivider(),
        _buildProButton(),
        ZagBlock(
          title: 'settings.Resources'.tr(),
          body: [TextSpan(text: 'settings.ResourcesDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.help_outline_rounded),
          onTap: SettingsRoutes.RESOURCES.go,
        ),
        ZagBlock(
          title: 'settings.System'.tr(),
          body: [TextSpan(text: 'settings.SystemDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.settings_rounded),
          onTap: SettingsRoutes.SYSTEM.go,
        ),
      ],
    );
  }
  
  Widget _buildProButton() {
    final bool isPro = ZagreusPro.isEnabled;
    
    return ZagBlock(
      title: 'Zagreus Pro',
      body: [
        TextSpan(
          text: isPro 
            ? 'Active • ${ZagreusPro.subscriptionType == "monthly" ? "Monthly" : "Yearly"} subscription'
            : 'Unlock premium features • \$0.79/mo or \$3.99/yr'
        )
      ],
      trailing: ZagIconButton(
        icon: isPro ? Icons.star_rounded : Icons.lock_open_rounded,
        color: isPro ? ZagColours.orange : ZagColours.accent,
      ),
      onTap: () => _showProDialog(context),
    );
  }
  
  void _showProDialog(BuildContext context) {
    final bool isPro = ZagreusPro.isEnabled;
    
    ZagDialog.dialog(
      context: context,
      title: 'Zagreus Pro',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              isPro 
                ? 'You have an active ${ZagreusPro.subscriptionType} subscription.\n\n'
                  'Premium features unlocked:\n'
                  '• Discover module with trending content\n'
                  '• Recommended movies & shows\n'
                  '• Missing from collections\n\n'
                  'Thank you for supporting Zagreus!'
                : 'Unlock premium features and support Zagreus development!\n\n'
                  'Premium features:\n'
                  '• Beautiful movie & TV discovery\n'
                  '• Trending & popular content\n'
                  '• Recommended based on your library\n'
                  '• Missing movies from collections\n\n'
                  'Choose your plan:',
              style: const TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
              ),
            ),
          ),
          if (!isPro) ...[
            ZagDialog.tile(
              icon: Icons.calendar_month_rounded,
              iconColor: ZagColours.accent,
              text: 'Monthly • \$0.79/month',
              onTap: () {
                Navigator.of(context).pop();
                _purchasePro(true);
              },
            ),
            ZagDialog.tile(
              icon: Icons.star_rounded,
              iconColor: ZagColours.orange,
              text: 'Yearly • \$3.99/year (Save 58%!)',
              onTap: () {
                Navigator.of(context).pop();
                _purchasePro(false);
              },
            ),
          ],
          // Debug only - cancel subscription button
          if (isPro && const bool.fromEnvironment('dart.vm.product') == false)
            ZagDialog.tile(
              icon: Icons.cancel_rounded,
              iconColor: ZagColours.red,
              text: '[DEBUG] Cancel Subscription',
              onTap: () {
                Navigator.of(context).pop();
                _cancelPro();
              },
            ),
        ],
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }
  
  void _purchasePro(bool isMonthly) {
    // TODO: Implement actual IAP
    ZagreusPro.enablePro(isMonthly: isMonthly);
    setState(() {});
    showZagInfoSnackBar(
      title: 'Welcome to Zagreus Pro!',
      message: 'Premium features are now unlocked',
    );
  }
  
  void _cancelPro() {
    // Debug only - reset Pro status
    ZagreusDatabase.ZAGREUS_PRO_ENABLED.update(false);
    ZagreusDatabase.ZAGREUS_PRO_EXPIRY.update('');
    ZagreusDatabase.ZAGREUS_PRO_SUBSCRIPTION_TYPE.update('');
    setState(() {});
    showZagInfoSnackBar(
      title: '[DEBUG] Subscription Cancelled',
      message: 'Zagreus Pro has been disabled',
    );
  }
}
