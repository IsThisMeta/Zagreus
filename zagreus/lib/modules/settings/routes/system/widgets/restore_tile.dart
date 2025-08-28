import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/database/config.dart';
import 'package:zagreus/system/filesystem/file.dart';
import 'package:zagreus/system/filesystem/filesystem.dart';

class SettingsSystemBackupRestoreRestoreTile extends StatelessWidget {
  const SettingsSystemBackupRestoreRestoreTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'settings.RestoreFromDevice'.tr(),
      body: [TextSpan(text: 'settings.RestoreFromDeviceDescription'.tr())],
      trailing: const ZagIconButton(icon: Icons.download_rounded),
      onTap: () async => _restore(context),
    );
  }

  Future<void> _restore(BuildContext context) async {
    try {
      ZagFile? file = await ZagFileSystem().read(context, ['zagreus']);
      if (file != null) await _decryptBackup(context, file);
    } catch (error, stack) {
      ZagLogger().error('Failed to restore device backup', error, stack);
      showZagErrorSnackBar(
        title: 'settings.RestoreFromCloudFailure'.tr(),
        error: error,
      );
    }
  }

  Future<void> _decryptBackup(
    BuildContext context,
    ZagFile file,
  ) async {
    String encrypted = String.fromCharCodes(file.data);
    try {
      await ZagConfig().import(context, encrypted);
      showZagSuccessSnackBar(
        title: 'settings.RestoreFromCloudSuccess'.tr(),
        message: 'settings.RestoreFromCloudSuccessMessage'.tr(),
      );
    } catch (_) {
      showZagErrorSnackBar(
        title: 'settings.RestoreFromCloudFailure'.tr(),
        message: 'zagreus.IncorrectEncryptionKey'.tr(),
        showButton: true,
        buttonText: 'zagreus.Retry'.tr(),
        buttonOnPressed: () async => _decryptBackup(context, file),
      );
    }
  }
}
