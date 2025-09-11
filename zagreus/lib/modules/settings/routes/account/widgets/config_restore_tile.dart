import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/config.dart';
import 'package:zagreus/supabase/database.dart';
import 'package:zagreus/supabase/storage.dart';
import 'package:zagreus/modules/settings.dart';

class SettingsAccountRestoreConfigurationTile extends StatefulWidget {
  const SettingsAccountRestoreConfigurationTile({
    Key? key,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<SettingsAccountRestoreConfigurationTile> {
  ZagLoadingState _loadingState = ZagLoadingState.INACTIVE;

  void updateState(ZagLoadingState state) {
    if (mounted) setState(() => _loadingState = state);
  }

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'settings.RestoreFromCloud'.tr(),
      body: [TextSpan(text: 'settings.RestoreFromCloudDescription'.tr())],
      trailing: ZagIconButton(
        icon: ZagIcons.CLOUD_DOWNLOAD,
        loadingState: _loadingState,
      ),
      onTap: () async => _restore(context),
    );
  }

  Future<void> _restore(BuildContext context) async {
    if (_loadingState == ZagLoadingState.ACTIVE) return;
    updateState(ZagLoadingState.ACTIVE);
    try {
      final docs = await ZagSupabaseDatabase().getBackupEntries();
      final result = await SettingsDialogs().getBackupFromCloud(context, docs);

      if (result.item1) {
        String? id = result.item2!.id;
        String? configData = await ZagSupabaseStorage().downloadBackup(id);
        if (configData != null) {
          await _restoreBackup(context, configData);
        }
      }
    } catch (error, stack) {
      ZagLogger().error('Failed to restore cloud backup', error, stack);
      showZagErrorSnackBar(
        title: 'settings.RestoreFromCloudFailure'.tr(),
        error: error,
      );
    }
    updateState(ZagLoadingState.INACTIVE);
  }

  Future<void> _restoreBackup(BuildContext context, String configData) async {
    try {
      // No decryption needed - just import the raw config
      await ZagConfig().import(context, configData);
      showZagSuccessSnackBar(
        title: 'settings.RestoreFromCloudSuccess'.tr(),
        message: 'settings.RestoreFromCloudSuccessMessage'.tr(),
      );
    } catch (error, stack) {
      ZagLogger().error('Failed to restore backup', error, stack);
      showZagErrorSnackBar(
        title: 'settings.RestoreFromCloudFailure'.tr(),
        message: 'Failed to restore backup configuration.',
      );
    }
  }
}
