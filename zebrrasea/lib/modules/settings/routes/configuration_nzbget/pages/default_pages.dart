import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/tables/nzbget.dart';
import 'package:zebrrasea/modules/nzbget.dart';

class ConfigurationNZBGetDefaultPagesRoute extends StatefulWidget {
  const ConfigurationNZBGetDefaultPagesRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationNZBGetDefaultPagesRoute> createState() => _State();
}

class _State extends State<ConfigurationNZBGetDefaultPagesRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      title: 'settings.DefaultPages'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        _homePage(),
      ],
    );
  }

  Widget _homePage() {
    const _db = NZBGetDatabase.NAVIGATION_INDEX;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'zebrrasea.Home'.tr(),
        body: [TextSpan(text: NZBGetNavigationBar.titles[_db.read()])],
        trailing: ZebrraIconButton(
          icon: NZBGetNavigationBar.icons[_db.read()],
        ),
        onTap: () async {
          List values = await NZBGetDialogs.defaultPage(context);
          if (values[0]) _db.update(values[1]);
        },
      ),
    );
  }
}
