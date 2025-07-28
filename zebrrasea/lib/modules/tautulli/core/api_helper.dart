import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliAPIHelper {
  /// Backup Tautulli's configuration.
  Future<bool> backupConfiguration({
    required BuildContext context,
    bool showSnackbar = true,
  }) async {
    if (context.read<TautulliState>().enabled) {
      return await context
          .read<TautulliState>()
          .api!
          .system
          .backupConfig()
          .then((_) {
        if (showSnackbar)
          showZebrraSuccessSnackBar(
            title: 'tautulli.BackingUpConfiguration'.tr(),
            message: 'tautulli.BackingUpConfigurationDescription'.tr(),
          );
        return true;
      }).catchError((error, trace) {
        ZebrraLogger().error('Failed to backup configuration', error, trace);
        if (showSnackbar)
          showZebrraErrorSnackBar(
            title: 'tautulli.BackingUpConfigurationFailed'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  /// Backup Tautulli's database.
  Future<bool> backupDatabase({
    required BuildContext context,
    bool showSnackbar = true,
  }) async {
    if (context.read<TautulliState>().enabled) {
      return await context
          .read<TautulliState>()
          .api!
          .system
          .backupDB()
          .then((_) {
        if (showSnackbar)
          showZebrraSuccessSnackBar(
            title: 'tautulli.BackingUpDatabase'.tr(),
            message: 'tautulli.BackingUpDatabaseDescription'.tr(),
          );
        return true;
      }).catchError((error, trace) {
        ZebrraLogger().error('Failed to backup database', error, trace);
        if (showSnackbar)
          showZebrraErrorSnackBar(
            title: 'tautulli.BackingUpDatabaseFailed'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  /// Delete cache.
  Future<bool> deleteCache({
    required BuildContext context,
    bool showSnackbar = true,
  }) async {
    if (context.read<TautulliState>().enabled) {
      return await context
          .read<TautulliState>()
          .api!
          .system
          .deleteCache()
          .then((_) {
        if (showSnackbar)
          showZebrraSuccessSnackBar(
            title: 'tautulli.DeletingCache'.tr(),
            message: 'tautulli.DeletingCacheDescription'.tr(),
          );
        return true;
      }).catchError((error, trace) {
        ZebrraLogger().error('Failed to delete cache', error, trace);
        if (showSnackbar)
          showZebrraErrorSnackBar(
            title: 'tautulli.DeletingCacheFailed'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  /// Delete image cache.
  Future<bool> deleteImageCache({
    required BuildContext context,
    bool showSnackbar = true,
  }) async {
    if (context.read<TautulliState>().enabled) {
      return await context
          .read<TautulliState>()
          .api!
          .system
          .deleteImageCache()
          .then((_) {
        if (showSnackbar)
          showZebrraSuccessSnackBar(
            title: 'tautulli.DeletingImageCache'.tr(),
            message: 'tautulli.DeletingImageCacheDescription'.tr(),
          );
        return true;
      }).catchError((error, trace) {
        ZebrraLogger().error('Failed to delete image cache', error, trace);
        if (showSnackbar)
          showZebrraErrorSnackBar(
            title: 'tautulli.DeletingImageCacheFailed'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  /// Delete temporary sessions.
  Future<bool> deleteTemporarySessions({
    required BuildContext context,
    bool showSnackbar = true,
  }) async {
    if (context.read<TautulliState>().enabled) {
      return await context
          .read<TautulliState>()
          .api!
          .activity
          .deleteTempSessions()
          .then((_) {
        if (showSnackbar)
          showZebrraSuccessSnackBar(
            title: 'tautulli.DeletingTemporarySessions'.tr(),
            message: 'tautulli.DeletingTemporarySessionsDescription'.tr(),
          );
        return true;
      }).catchError((error, trace) {
        ZebrraLogger().error('Failed to delete temporary sessions', error, trace);
        if (showSnackbar)
          showZebrraErrorSnackBar(
            title: 'tautulli.DeletingTemporarySessionsFailed'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }

  /// Terminate an active session.
  Future<bool> terminateSession({
    required BuildContext context,
    required TautulliSession session,
    String? terminationMessage,
    bool showSnackbar = true,
  }) async {
    if (context.read<TautulliState>().enabled) {
      return await context
          .read<TautulliState>()
          .api!
          .activity
          .terminateSession(
            sessionKey: session.sessionKey,
            message: terminationMessage,
          )
          .then((_) {
        showZebrraSuccessSnackBar(
          title: 'tautulli.TerminatedSession'.tr(),
          message: [
            session.friendlyName,
            session.title,
          ].join(ZebrraUI.TEXT_EMDASH.pad()),
        );
        return true;
      }).catchError((error, stack) {
        ZebrraLogger().error('Failed to delete temporary sessions', error, stack);
        if (showSnackbar)
          showZebrraErrorSnackBar(
            title: 'tautulli.TerminateSessionFailed'.tr(),
            error: error,
          );
        return false;
      });
    }
    return false;
  }
}
