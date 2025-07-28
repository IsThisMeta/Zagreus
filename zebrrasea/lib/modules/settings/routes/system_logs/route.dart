import 'package:flutter/material.dart';

import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/router/routes/settings.dart';
import 'package:zebrrasea/system/filesystem/filesystem.dart';
import 'package:zebrrasea/types/log_type.dart';

class SystemLogsRoute extends StatefulWidget {
  const SystemLogsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SystemLogsRoute> createState() => _State();
}

class _State extends State<SystemLogsRoute> with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar(
      title: 'settings.Logs'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZebrraBottomActionBar(
      actions: [
        _exportLogs(),
        _clearLogs(),
      ],
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        ZebrraBlock(
          title: 'settings.AllLogs'.tr(),
          body: [TextSpan(text: 'settings.AllLogsDescription'.tr())],
          trailing: const ZebrraIconButton(icon: Icons.developer_mode_rounded),
          onTap: () async => _viewLogs(null),
        ),
        ...List.generate(
          ZebrraLogType.values.length,
          (index) {
            if (ZebrraLogType.values[index].enabled)
              return ZebrraBlock(
                title: ZebrraLogType.values[index].title,
                body: [TextSpan(text: ZebrraLogType.values[index].description)],
                trailing: ZebrraIconButton(icon: ZebrraLogType.values[index].icon),
                onTap: () async => _viewLogs(ZebrraLogType.values[index]),
              );
            return Container(height: 0.0);
          },
        ),
      ],
    );
  }

  Future<void> _viewLogs(ZebrraLogType? type) async {
    SettingsRoutes.SYSTEM_LOGS_DETAILS.go(params: {
      'type': type?.key ?? 'all',
    });
  }

  Widget _clearLogs() {
    return ZebrraButton.text(
      text: 'settings.Clear'.tr(),
      icon: ZebrraIcons.DELETE,
      color: ZebrraColours.red,
      onTap: () async {
        bool result = await SettingsDialogs().clearLogs(context);
        if (result) {
          ZebrraLogger().clear();
          showZebrraSuccessSnackBar(
            title: 'settings.LogsCleared'.tr(),
            message: 'settings.LogsClearedDescription'.tr(),
          );
        }
      },
    );
  }

  Widget _exportLogs() {
    return Builder(
      builder: (context) => ZebrraButton.text(
        text: 'settings.Export'.tr(),
        icon: ZebrraIcons.DOWNLOAD,
        onTap: () async {
          String data = await ZebrraLogger().export();
          bool result = await ZebrraFileSystem()
              .save(context, 'logs.json', utf8.encode(data));
          if (result)
            showZebrraSuccessSnackBar(
                title: 'settings.ExportedLogs'.tr(),
                message: 'settings.ExportedLogsMessage'.tr());
        },
      ),
    );
  }
}
