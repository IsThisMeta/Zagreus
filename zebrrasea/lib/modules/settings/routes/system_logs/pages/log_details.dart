import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/models/log.dart';
import 'package:zebrrasea/modules/settings/routes/system_logs/widgets/log_tile.dart';
import 'package:zebrrasea/types/log_type.dart';

class SystemLogsDetailsRoute extends StatefulWidget {
  final ZebrraLogType? type;

  const SystemLogsDetailsRoute({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  State<SystemLogsDetailsRoute> createState() => _State();
}

class _State extends State<SystemLogsDetailsRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar(
      title: 'settings.Logs'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraBox.logs.listenableBuilder(builder: (context, _) {
      List<ZebrraLog> logs = filter();
      if (logs.isEmpty) {
        return ZebrraMessage.goBack(
          context: context,
          text: 'settings.NoLogsFound'.tr(),
        );
      }
      return ZebrraListViewBuilder(
        controller: scrollController,
        itemCount: logs.length,
        itemBuilder: (context, index) => SettingsSystemLogTile(
          log: logs[index],
        ),
      );
    });
  }

  List<ZebrraLog> filter() {
    List<ZebrraLog> logs;
    const box = ZebrraBox.logs;

    switch (widget.type) {
      case ZebrraLogType.WARNING:
        logs =
            box.data.where((log) => log.type == ZebrraLogType.WARNING).toList();
        break;
      case ZebrraLogType.ERROR:
        logs = box.data.where((log) => log.type == ZebrraLogType.ERROR).toList();
        break;
      case ZebrraLogType.CRITICAL:
        logs =
            box.data.where((log) => log.type == ZebrraLogType.CRITICAL).toList();
        break;
      case ZebrraLogType.DEBUG:
        logs = box.data.where((log) => log.type == ZebrraLogType.DEBUG).toList();
        break;
      default:
        logs = box.data.where((log) => log.type.enabled).toList();
        break;
    }
    logs.sort((a, b) => (b.timestamp).compareTo(a.timestamp));
    return logs;
  }
}
