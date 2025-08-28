import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/database/config.dart';
import 'package:zagreus/system/filesystem/filesystem.dart';

class SettingsSystemBackupRestoreBackupTile extends StatelessWidget {
  const SettingsSystemBackupRestoreBackupTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'settings.BackupToDevice'.tr(),
      body: [TextSpan(text: 'settings.BackupToDeviceDescription'.tr())],
      trailing: const ZagIconButton(icon: Icons.upload_rounded),
      onTap: () async => _backup(context),
    );
  }

  Future<void> _backup(BuildContext context) async {
    try {
      String data = ZagConfig().export();
      String name = DateFormat('y-MM-dd kk-mm-ss').format(DateTime.now());
      bool result = await ZagFileSystem().save(
        context,
        '$name.zagreus',
        data.codeUnits,
      );
      if (result) {
        showZagSuccessSnackBar(
          title: 'settings.BackupToCloudSuccess'.tr(),
          message: '$name.zagreus',
        );
      }
    } catch (error, stack) {
      ZagLogger().error('Failed to create device backup', error, stack);
      showZagErrorSnackBar(
        title: 'settings.BackupToCloudFailure'.tr(),
        error: error,
      );
    }
  }
}
