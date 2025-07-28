import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ConfigurationDrawerRoute extends StatefulWidget {
  const ConfigurationDrawerRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationDrawerRoute> createState() => _State();
}

class _State extends State<ConfigurationDrawerRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ZebrraModule>? _modules;

  @override
  void initState() {
    super.initState();
    _modules = ZebrraDrawer.moduleOrderedList();
  }

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZebrraAppBar(
      scrollControllers: [scrollController],
      title: 'settings.Drawer'.tr(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        SizedBox(height: ZebrraUI.MARGIN_H_DEFAULT_V_HALF.bottom),
        ZebrraBlock(
          title: 'settings.AutomaticallyManageOrder'.tr(),
          body: [
            TextSpan(text: 'settings.AutomaticallyManageOrderDescription'.tr()),
          ],
          trailing: ZebrraSeaDatabase.DRAWER_AUTOMATIC_MANAGE.listenableBuilder(
            builder: (context, _) => ZebrraSwitch(
              value: ZebrraSeaDatabase.DRAWER_AUTOMATIC_MANAGE.read(),
              onChanged: ZebrraSeaDatabase.DRAWER_AUTOMATIC_MANAGE.update,
            ),
          ),
        ),
        ZebrraDivider(),
        Expanded(
          child: ZebrraReorderableListViewBuilder(
            padding: MediaQuery.of(context).padding.copyWith(top: 0).add(
                EdgeInsets.only(bottom: ZebrraUI.MARGIN_H_DEFAULT_V_HALF.bottom)),
            controller: scrollController,
            itemCount: _modules!.length,
            itemBuilder: (context, index) => _reorderableModuleTile(index),
            onReorder: (oIndex, nIndex) {
              if (oIndex > _modules!.length) oIndex = _modules!.length;
              if (oIndex < nIndex) nIndex--;
              ZebrraModule module = _modules![oIndex];
              _modules!.remove(module);
              _modules!.insert(nIndex, module);
              ZebrraSeaDatabase.DRAWER_MANUAL_ORDER.update(_modules!);
            },
          ),
        ),
      ],
    );
  }

  Widget _reorderableModuleTile(int index) {
    return ZebrraSeaDatabase.DRAWER_AUTOMATIC_MANAGE.listenableBuilder(
      key: ObjectKey(_modules![index]),
      builder: (context, _) => ZebrraBlock(
        disabled: ZebrraSeaDatabase.DRAWER_AUTOMATIC_MANAGE.read(),
        title: _modules![index].title,
        body: [TextSpan(text: _modules![index].description)],
        leading: ZebrraIconButton(icon: _modules![index].icon),
        trailing: ZebrraSeaDatabase.DRAWER_AUTOMATIC_MANAGE.read()
            ? null
            : ZebrraReorderableListViewDragger(index: index),
      ),
    );
  }
}
