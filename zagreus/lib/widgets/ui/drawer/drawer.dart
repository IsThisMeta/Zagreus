import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/wake_on_lan/wake_on_lan.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class ZagDrawer extends StatelessWidget {
  final String page;

  const ZagDrawer({
    Key? key,
    required this.page,
  }) : super(key: key);

  static List<ZagModule> moduleAlphabeticalList() {
    return ZagModule.active
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  static List<ZagModule> moduleOrderedList() {
    try {
      const db = ZagreusDatabase.DRAWER_MANUAL_ORDER;
      final modules = List.from(db.read());
      final missing = ZagModule.active;

      missing.retainWhere((m) => !modules.contains(m));
      modules.addAll(missing);
      modules.retainWhere((m) => (m as ZagModule).featureFlag);

      return modules.cast<ZagModule>();
    } catch (error, stack) {
      ZagLogger().error('Failed to create ordered module list', error, stack);
      return moduleAlphabeticalList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) => ZagBox.indexers.listenableBuilder(
        builder: (context, _) => Drawer(
          elevation: ZagUI.ELEVATION,
          backgroundColor: Theme.of(context).primaryColor,
          child: ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.listenableBuilder(
            builder: (context, _) => Column(
              children: [
                ZagDrawerHeader(page: page),
                Expanded(
                  child: ZagListView(
                    controller: PrimaryScrollController.of(context),
                    children: _moduleList(
                      context,
                      ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.read()
                          ? moduleAlphabeticalList()
                          : moduleOrderedList(),
                    ),
                    physics: const ClampingScrollPhysics(),
                    padding: MediaQuery.of(context).padding.copyWith(top: 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _sharedHeader(BuildContext context) {
    return [
      _buildEntry(
        context: context,
        module: ZagModule.DASHBOARD,
      ),
    ];
  }

  List<Widget> _moduleList(BuildContext context, List<ZagModule> modules) {
    return <Widget>[
      ..._sharedHeader(context),
      ...modules.map((module) {
        // Hide Discover module if not Pro and TestFlight bypass not enabled
        if (module == ZagModule.DISCOVER &&
            !ZagreusPro.isEnabled &&
            !ZagreusDatabase.TESTFLIGHT_BYPASS_PRO.read()) {
          return const SizedBox(height: 0.0);
        }
        
        if (module.isEnabled) {
          return _buildEntry(
            context: context,
            module: module,
            onTap: module == ZagModule.WAKE_ON_LAN ? _wakeOnLAN : null,
          );
        }
        return const SizedBox(height: 0.0);
      }),
    ];
  }

  Widget _buildEntry({
    required BuildContext context,
    required ZagModule module,
    void Function()? onTap,
  }) {
    bool currentPage = page == module.key.toLowerCase();
    return SizedBox(
      height: ZagTextInputBar.defaultAppBarHeight,
      child: InkWell(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              child: Icon(
                module.icon,
                color: currentPage 
                    ? (Theme.of(context).brightness == Brightness.light ? ZagColours.accentLight : module.color)
                    : (Theme.of(context).brightness == Brightness.light ? Colors.black87 : ZagColours.white),
              ),
              padding: ZagUI.MARGIN_DEFAULT_HORIZONTAL * 1.5,
            ),
            Text(
              module.title,
              style: TextStyle(
                color: currentPage 
                    ? (Theme.of(context).brightness == Brightness.light ? ZagColours.accentLight : module.color)
                    : (Theme.of(context).brightness == Brightness.light ? Colors.black87 : ZagColours.white),
                fontWeight: ZagUI.FONT_WEIGHT_BOLD,
              ),
            ),
          ],
        ),
        onTap: onTap ??
            () async {
              Navigator.of(context).pop();
              if (!currentPage) module.launch();
            },
      ),
    );
  }

  Future<void> _wakeOnLAN() async => ZagWakeOnLAN().wake();
}
