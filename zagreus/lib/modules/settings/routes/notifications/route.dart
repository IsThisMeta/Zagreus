import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/messaging.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/modules/settings/routes/notifications/widgets/module_tile.dart';
import 'package:zagreus/utils/links.dart';

class NotificationsRoute extends StatefulWidget {
  const NotificationsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<NotificationsRoute> createState() => _State();
}

class _State extends State<NotificationsRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'settings.Notifications'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        FutureBuilder(
          future: ZagSupabaseMessaging.instance.areNotificationsAllowed(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData && !snapshot.data!)
              return ZagBanner(
                headerText: 'settings.NotAuthorized'.tr(),
                bodyText: 'settings.NotAuthorizedMessage'.tr(),
                icon: Icons.error_outline_rounded,
                iconColor: ZagColours.red,
              );
            return const SizedBox(height: 0.0, width: double.infinity);
          },
        ),
        SettingsBanners.NOTIFICATIONS_MODULE_SUPPORT.banner(),
        ZagBlock(
          title: 'settings.GettingStarted'.tr(),
          body: [TextSpan(text: 'settings.GettingStartedDescription'.tr())],
          trailing: const ZagIconButton.arrow(),
          onTap: ZagLinkedContent.NOTIFICATIONS_DOC.launch,
        ),
        _enableInAppNotifications(),
        ZagDivider(),
        ..._modules(),
      ],
    );
  }

  Widget _enableInAppNotifications() {
    const db = ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS;
    return ZagBlock(
      title: 'settings.EnableInAppNotifications'.tr(),
      trailing: db.listenableBuilder(
        builder: (context, _) => ZagSwitch(
          value: db.read(),
          onChanged: db.update,
        ),
      ),
    );
  }

  List<Widget> _modules() {
    List<SettingsNotificationsModuleTile> modules = [];
    for (ZagModule module in ZagModule.values) {
      if (module.hasWebhooks) {
        modules.add(SettingsNotificationsModuleTile(module: module));
      }
    }
    return modules;
  }
}
