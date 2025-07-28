import 'package:flutter/material.dart';

import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/config.dart';
import 'package:zebrrasea/system/filesystem/file.dart';
import 'package:zebrrasea/system/filesystem/filesystem.dart';

class SettingsSystemBackupRestoreRestoreTile extends StatelessWidget {
  const SettingsSystemBackupRestoreRestoreTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: 'settings.RestoreFromDevice'.tr(),
      body: [TextSpan(text: 'settings.RestoreFromDeviceDescription'.tr())],
      trailing: const ZebrraIconButton(icon: Icons.download_rounded),
      onTap: () async => _restore(context),
    );
  }

  Future<void> _restore(BuildContext context) async {
    try {
      ZebrraFile? file = await ZebrraFileSystem().read(context, ['zebrrasea']);
      if (file != null) await _decryptBackup(context, file);
    } catch (error, stack) {
      ZebrraLogger().error('Failed to restore device backup', error, stack);
      showZebrraErrorSnackBar(
        title: 'settings.RestoreFromCloudFailure'.tr(),
        error: error,
      );
    }
  }

  Future<void> _decryptBackup(
    BuildContext context,
    ZebrraFile file,
  ) async {
    String encrypted = String.fromCharCodes(file.data);
    try {
      await ZebrraConfig().import(context, encrypted);
      showZebrraSuccessSnackBar(
        title: 'settings.RestoreFromCloudSuccess'.tr(),
        message: 'settings.RestoreFromCloudSuccessMessage'.tr(),
      );
    } catch (_) {
      showZebrraErrorSnackBar(
        title: 'settings.RestoreFromCloudFailure'.tr(),
        message: 'zebrrasea.IncorrectEncryptionKey'.tr(),
        showButton: true,
        buttonText: 'zebrrasea.Retry'.tr(),
        buttonOnPressed: () async => _decryptBackup(context, file),
      );
    }
  }
}
