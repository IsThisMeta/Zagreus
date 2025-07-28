import 'package:flutter/material.dart';

import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/config.dart';
import 'package:zebrrasea/system/filesystem/filesystem.dart';

class SettingsSystemBackupRestoreBackupTile extends StatelessWidget {
  const SettingsSystemBackupRestoreBackupTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'settings.BackupToDevice'.tr(),
      body: [TextSpan(text: 'settings.BackupToDeviceDescription'.tr())],
      trailing: const ZebrraIconButton(icon: Icons.upload_rounded),
      onTap: () async => _backup(context),
    );
  }

  Future<void> _backup(BuildContext context) async {
    try {
      String data = ZebrraConfig().export();
      String name = DateFormat('y-MM-dd kk-mm-ss').format(DateTime.now());
      bool result = await ZebrraFileSystem().save(
        context,
        '$name.zebrrasea',
        data.codeUnits,
      );
      if (result) {
        showZebrraSuccessSnackBar(
          title: 'settings.BackupToCloudSuccess'.tr(),
          message: '$name.zebrrasea',
        );
      }
    } catch (error, stack) {
      ZebrraLogger().error('Failed to create device backup', error, stack);
      showZebrraErrorSnackBar(
        title: 'settings.BackupToCloudFailure'.tr(),
        error: error,
      );
    }
  }
}
