import 'package:flutter/material.dart';

import 'package:zebrrasea/modules.dart';
import 'package:zebrrasea/database/models/profile.dart';
import 'package:zebrrasea/database/tables/zebrrasea.dart';
import 'package:zebrrasea/vendor.dart';
import 'package:zebrrasea/widgets/ui.dart';
import 'package:zebrrasea/api/wake_on_lan/wake_on_lan.dart';
import 'package:zebrrasea/modules/dashboard/routes/dashboard/widgets/navigation_bar.dart';

class ModulesPage extends StatefulWidget {
  const ModulesPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ModulesPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _list();
  }

  Widget _list() {
    if (!(ZebrraProfile.current.isAnythingEnabled())) {
      return ZebrraMessage(
        text: 'zebrrasea.NoModulesEnabled'.tr(),
        buttonText: 'zebrrasea.GoToSettings'.tr(),
        onTap: ZebrraModule.SETTINGS.launch,
      );
    }
    return ZebrraListView(
      controller: HomeNavigationBar.scrollControllers[0],
      itemExtent: ZebrraBlock.calculateItemExtent(1),
      children: ZebrraSeaDatabase.DRAWER_AUTOMATIC_MANAGE.read()
          ? _buildAlphabeticalList()
          : _buildManuallyOrderedList(),
    );
  }

  List<Widget> _buildAlphabeticalList() {
    List<Widget> modules = [];
    int index = 0;
    ZebrraModule.active
      ..sort((a, b) => a.title.toLowerCase().compareTo(
            b.title.toLowerCase(),
          ))
      ..forEach((module) {
        if (module.isEnabled) {
          if (module == ZebrraModule.WAKE_ON_LAN) {
            modules.add(_buildWakeOnLAN(context, index));
          } else {
            modules.add(_buildFromZebrraModule(module, index));
          }
          index++;
        }
      });
    modules.add(_buildFromZebrraModule(ZebrraModule.SETTINGS, index));
    return modules;
  }

  List<Widget> _buildManuallyOrderedList() {
    List<Widget> modules = [];
    int index = 0;
    ZebrraDrawer.moduleOrderedList().forEach((module) {
      if (module.isEnabled) {
        if (module == ZebrraModule.WAKE_ON_LAN) {
          modules.add(_buildWakeOnLAN(context, index));
        } else {
          modules.add(_buildFromZebrraModule(module, index));
        }
        index++;
      }
    });
    modules.add(_buildFromZebrraModule(ZebrraModule.SETTINGS, index));
    return modules;
  }

  Widget _buildFromZebrraModule(ZebrraModule module, int listIndex) {
    return ZebrraBlock(
      title: module.title,
      body: [TextSpan(text: module.description)],
      trailing: ZebrraIconButton(icon: module.icon, color: module.color),
      onTap: module.launch,
    );
  }

  Widget _buildWakeOnLAN(BuildContext context, int listIndex) {
    return ZebrraBlock(
      title: ZebrraModule.WAKE_ON_LAN.title,
      body: [TextSpan(text: ZebrraModule.WAKE_ON_LAN.description)],
      trailing: ZebrraIconButton(
        icon: ZebrraModule.WAKE_ON_LAN.icon,
        color: ZebrraModule.WAKE_ON_LAN.color,
      ),
      onTap: () async => ZebrraWakeOnLAN().wake(),
    );
  }
}
