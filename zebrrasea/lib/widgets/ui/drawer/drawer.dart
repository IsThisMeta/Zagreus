import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/api/wake_on_lan/wake_on_lan.dart';

class ZebrraDrawer extends StatelessWidget {
  final String page;

  const ZebrraDrawer({
    Key? key,
    required this.page,
  }) : super(key: key);

  static List<ZebrraModule> moduleAlphabeticalList() {
    return ZebrraModule.active
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  static List<ZebrraModule> moduleOrderedList() {
    try {
      const db = ZebrraSeaDatabase.DRAWER_MANUAL_ORDER;
      final modules = List.from(db.read());
      final missing = ZebrraModule.active;

      missing.retainWhere((m) => !modules.contains(m));
      modules.addAll(missing);
      modules.retainWhere((m) => (m as ZebrraModule).featureFlag);

      return modules.cast<ZebrraModule>();
    } catch (error, stack) {
      ZebrraLogger().error('Failed to create ordered module list', error, stack);
      return moduleAlphabeticalList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZebrraSeaDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) => ZebrraBox.indexers.listenableBuilder(
        builder: (context, _) => Drawer(
          elevation: ZebrraUI.ELEVATION,
          backgroundColor: Theme.of(context).primaryColor,
          child: ZebrraSeaDatabase.DRAWER_AUTOMATIC_MANAGE.listenableBuilder(
            builder: (context, _) => Column(
              children: [
                ZebrraDrawerHeader(page: page),
                Expanded(
                  child: ZebrraListView(
                    controller: PrimaryScrollController.of(context),
                    children: _moduleList(
                      context,
                      ZebrraSeaDatabase.DRAWER_AUTOMATIC_MANAGE.read()
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
        module: ZebrraModule.DASHBOARD,
      ),
    ];
  }

  List<Widget> _moduleList(BuildContext context, List<ZebrraModule> modules) {
    return <Widget>[
      ..._sharedHeader(context),
      ...modules.map((module) {
        if (module.isEnabled) {
          return _buildEntry(
            context: context,
            module: module,
            onTap: module == ZebrraModule.WAKE_ON_LAN ? _wakeOnLAN : null,
          );
        }
        return const SizedBox(height: 0.0);
      }),
    ];
  }

  Widget _buildEntry({
    required BuildContext context,
    required ZebrraModule module,
    void Function()? onTap,
  }) {
    bool currentPage = page == module.key.toLowerCase();
    return SizedBox(
      height: ZebrraTextInputBar.defaultAppBarHeight,
      child: InkWell(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              child: Icon(
                module.icon,
                color: currentPage ? module.color : ZebrraColours.white,
              ),
              padding: ZebrraUI.MARGIN_DEFAULT_HORIZONTAL * 1.5,
            ),
            Text(
              module.title,
              style: TextStyle(
                color: currentPage ? module.color : ZebrraColours.white,
                fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
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

  Future<void> _wakeOnLAN() async => ZebrraWakeOnLAN().wake();
}
