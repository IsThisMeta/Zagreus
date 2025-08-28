import 'package:flutter/material.dart';

import 'package:zagreus/modules.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/api/wake_on_lan/wake_on_lan.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/navigation_bar.dart';

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
    if (!(ZagProfile.current.isAnythingEnabled())) {
      return ZagMessage(
        text: 'zagreus.NoModulesEnabled'.tr(),
        buttonText: 'zagreus.GoToSettings'.tr(),
        onTap: ZagModule.SETTINGS.launch,
      );
    }
    return ZagListView(
      controller: HomeNavigationBar.scrollControllers[0],
      itemExtent: ZagBlock.calculateItemExtent(1),
      children: ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.read()
          ? _buildAlphabeticalList()
          : _buildManuallyOrderedList(),
    );
  }

  List<Widget> _buildAlphabeticalList() {
    List<Widget> modules = [];
    int index = 0;
    ZagModule.active
      ..sort((a, b) => a.title.toLowerCase().compareTo(
            b.title.toLowerCase(),
          ))
      ..forEach((module) {
        if (module.isEnabled) {
          if (module == ZagModule.WAKE_ON_LAN) {
            modules.add(_buildWakeOnLAN(context, index));
          } else {
            modules.add(_buildFromZagModule(module, index));
          }
          index++;
        }
      });
    modules.add(_buildFromZagModule(ZagModule.SETTINGS, index));
    return modules;
  }

  List<Widget> _buildManuallyOrderedList() {
    List<Widget> modules = [];
    int index = 0;
    ZagDrawer.moduleOrderedList().forEach((module) {
      if (module.isEnabled) {
        if (module == ZagModule.WAKE_ON_LAN) {
          modules.add(_buildWakeOnLAN(context, index));
        } else {
          modules.add(_buildFromZagModule(module, index));
        }
        index++;
      }
    });
    modules.add(_buildFromZagModule(ZagModule.SETTINGS, index));
    return modules;
  }

  Widget _buildFromZagModule(ZagModule module, int listIndex) {
    return ZagBlock(
      title: module.title,
      body: [TextSpan(text: module.description)],
      trailing: ZagIconButton(icon: module.icon, color: module.color),
      onTap: module.launch,
    );
  }

  Widget _buildWakeOnLAN(BuildContext context, int listIndex) {
    return ZagBlock(
      title: ZagModule.WAKE_ON_LAN.title,
      body: [TextSpan(text: ZagModule.WAKE_ON_LAN.description)],
      trailing: ZagIconButton(
        icon: ZagModule.WAKE_ON_LAN.icon,
        color: ZagModule.WAKE_ON_LAN.color,
      ),
      onTap: () async => ZagWakeOnLAN().wake(),
    );
  }
}
