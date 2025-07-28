import 'package:flutter/material.dart';

import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/database.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/modules/settings/routes/system/widgets/backup_tile.dart';
import 'package:zebrrasea/modules/settings/routes/system/widgets/restore_tile.dart';
import 'package:zebrrasea/router/routes/settings.dart';
import 'package:zebrrasea/system/cache/image/image_cache.dart';

class SystemRoute extends StatefulWidget {
  const SystemRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SystemRoute> createState() => _State();
}

class _State extends State<SystemRoute> with ZebrraScrollControllerMixin {
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
      title: 'settings.System'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: <Widget>[
        const SettingsSystemBackupRestoreBackupTile(),
        const SettingsSystemBackupRestoreRestoreTile(),
        ZebrraDivider(),
        _logs(),
        _clearImageCache(),
        _clearConfiguration(),
      ],
    );
  }

  Widget _logs() {
    return ZebrraBlock(
      title: 'settings.Logs'.tr(),
      body: [TextSpan(text: 'settings.LogsDescription'.tr())],
      trailing: const ZebrraIconButton(icon: Icons.developer_mode_rounded),
      onTap: SettingsRoutes.SYSTEM_LOGS.go,
    );
  }

  Widget _clearImageCache() {
    return ZebrraBlock(
      title: 'settings.ClearImageCache'.tr(),
      body: [TextSpan(text: 'settings.ClearImageCacheDescription'.tr())],
      trailing: const ZebrraIconButton(icon: Icons.image_not_supported_rounded),
      onTap: () async {
        bool result = await SettingsDialogs().clearImageCache(context);
        if (result) {
          result = await ZebrraImageCache().clear();
          if (result) {
            showZebrraSuccessSnackBar(
              title: 'settings.ImageCacheCleared'.tr(),
              message: 'settings.ImageCacheClearedDescription'.tr(),
            );
          } else {
            showZebrraErrorSnackBar(
              title: 'settings.FailedToClearImageCache'.tr(),
              message: 'settings.FailedToClearImageCacheDescription'.tr(),
            );
          }
        }
      },
    );
  }

  Widget _clearConfiguration() {
    return ZebrraBlock(
      title: 'settings.ClearConfiguration'.tr(),
      body: [TextSpan(text: 'settings.CleanSlate'.tr())],
      trailing: const ZebrraIconButton(icon: Icons.delete_sweep_rounded),
      onTap: () async {
        bool result = await SettingsDialogs().clearConfiguration(context);
        if (result) {
          ZebrraDatabase().bootstrap();
          ZebrraState.reset(context);
          showZebrraSuccessSnackBar(
            title: 'settings.ConfigurationCleared'.tr(),
            message: 'settings.ConfigurationClearedDescription'.tr(),
          );
        }
      },
    );
  }
}
