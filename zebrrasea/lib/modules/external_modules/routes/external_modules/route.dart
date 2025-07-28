import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/external_modules/routes/external_modules/widgets/module_tile.dart';

class ExternalModulesRoute extends StatefulWidget {
  const ExternalModulesRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ExternalModulesRoute> createState() => _State();
}

class _State extends State<ExternalModulesRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZebrraModule.EXTERNAL_MODULES,
      appBar: _appBar(),
      drawer: _drawer(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar(
      useDrawer: true,
      title: ZebrraModule.EXTERNAL_MODULES.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _drawer() => ZebrraDrawer(page: ZebrraModule.EXTERNAL_MODULES.key);

  Widget _body() {
    if (ZebrraBox.externalModules.isEmpty) {
      return ZebrraMessage.moduleNotEnabled(
        context: context,
        module: ZebrraModule.EXTERNAL_MODULES.title,
      );
    }
    return ZebrraListView(
      controller: scrollController,
      itemExtent: ZebrraBlock.calculateItemExtent(1),
      children: _list,
    );
  }

  List<Widget> get _list {
    final list = ZebrraBox.externalModules.data
        .map((module) => ExternalModulesModuleTile(module: module))
        .toList();
    list.sort((a, b) => a.module!.displayName
        .toLowerCase()
        .compareTo(b.module!.displayName.toLowerCase()));

    return list;
  }
}
