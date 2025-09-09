import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/config/encryption_config_private.dart';
import 'package:zagreus/database/config.dart';
import 'package:zagreus/supabase/firestore.dart';
import 'package:zagreus/supabase/storage.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/utils/encryption.dart';

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
      final docs = await ZagSupabaseFirestore().getBackupEntries();
      final result = await SettingsDialogs().getBackupFromCloud(context, docs);

      if (result.item1) {
        String? id = result.item2!.id;
        String? encrypted = await ZagSupabaseStorage().downloadBackup(id);
        if (encrypted != null) _decryptBackup(context, encrypted);
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

  Future<void> _decryptBackup(BuildContext context, String encrypted) async {
    try {
      // Auto-generate encryption key from user ID (same as backup)
      final user = ZagSupabase.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Use same encryption pattern from private config
      String encryptionKey = EncryptionConfig.getBackupEncryptionKey(user.id, user.email ?? '');
      
      String decrypted = ZagEncryption().decrypt(encryptionKey, encrypted);
      await ZagConfig().import(context, decrypted);
      showZagSuccessSnackBar(
        title: 'settings.RestoreFromCloudSuccess'.tr(),
        message: 'settings.RestoreFromCloudSuccessMessage'.tr(),
      );
    } catch (error, stack) {
      ZagLogger().error('Failed to decrypt backup', error, stack);
      showZagErrorSnackBar(
        title: 'settings.RestoreFromCloudFailure'.tr(),
        message: 'Failed to restore backup. This backup may have been created with a different account.',
      );
    }
  }
}
