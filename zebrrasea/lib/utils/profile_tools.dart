import 'package:zebrrasea/database/models/profile.dart';
import 'package:zebrrasea/database/box.dart';
import 'package:zebrrasea/database/tables/zebrrasea.dart';
import 'package:zebrrasea/system/state.dart';
import 'package:zebrrasea/router/router.dart';
import 'package:zebrrasea/system/logger.dart';
import 'package:zebrrasea/types/exception.dart';
import 'package:zebrrasea/vendor.dart';
import 'package:zebrrasea/widgets/ui.dart';

class ZebrraProfileTools {
  bool changeTo(
    String profile, {
    bool showSnackbar = true,
    bool popToRootRoute = false,
  }) {
    try {
      if (ZebrraSeaDatabase.ENABLED_PROFILE.read() == profile) return true;
      _changeTo(profile);

      if (showSnackbar) {
        showZebrraSuccessSnackBar(
          title: 'settings.ChangedProfile'.tr(),
          message: profile,
        );
      }

      if (popToRootRoute) {
        ZebrraRouter().popToRootRoute();
      }

      return true;
    } on ProfileNotFoundException catch (error, trace) {
      ZebrraLogger().exception(error, trace);
    }
    return false;
  }

  Future<bool> create(
    String profile, {
    bool showSnackbar = true,
  }) async {
    try {
      await _create(profile);
      _changeTo(profile);

      if (showSnackbar) {
        showZebrraSuccessSnackBar(
          title: 'settings.AddedProfile'.tr(),
          message: profile,
        );
      }
    } on ProfileAlreadyExistsException catch (error, trace) {
      ZebrraLogger().exception(error, trace);
    } catch (error, trace) {
      ZebrraLogger().error('Failed to create profile', error, trace);
    }

    return false;
  }

  Future<bool> remove(
    String profile, {
    bool showSnackbar = true,
  }) async {
    try {
      await _remove(profile);

      if (showSnackbar) {
        showZebrraSuccessSnackBar(
          title: 'settings.DeletedProfile'.tr(),
          message: profile,
        );
      }
    } on ProfileNotFoundException catch (error, trace) {
      ZebrraLogger().exception(error, trace);
    } on ActiveProfileRemovalException catch (error, trace) {
      ZebrraLogger().exception(error, trace);
    } catch (error, trace) {
      ZebrraLogger().error('Failed to delete profile', error, trace);
    }

    return false;
  }

  Future<bool> rename(
    String oldProfile,
    String newProfile, {
    bool showSnackbar = true,
  }) async {
    try {
      await _rename(oldProfile, newProfile);

      if (showSnackbar) {
        showZebrraSuccessSnackBar(
          title: 'settings.RenamedProfile'.tr(),
          message: 'settings.ProfileToProfile'.tr(
            args: [oldProfile, newProfile],
          ),
        );
      }

      return true;
    } on ProfileNotFoundException catch (error, trace) {
      ZebrraLogger().exception(error, trace);
    } on ProfileAlreadyExistsException catch (error, trace) {
      ZebrraLogger().exception(error, trace);
    } catch (error, trace) {
      ZebrraLogger().error('Failed to rename profile', error, trace);
    }

    return false;
  }

  void _changeTo(String profile) {
    if (!ZebrraBox.profiles.contains(profile)) {
      throw ProfileNotFoundException(profile);
    }

    ZebrraSeaDatabase.ENABLED_PROFILE.update(profile);
    ZebrraState.reset();
  }

  Future<void> _create(String profile) async {
    if (ZebrraBox.profiles.contains(profile)) {
      throw ProfileAlreadyExistsException(profile);
    }

    await ZebrraBox.profiles.update(profile, ZebrraProfile());
  }

  Future<void> _remove(String profile) async {
    if (ZebrraSeaDatabase.ENABLED_PROFILE.read() == profile) {
      throw ActiveProfileRemovalException(profile);
    }

    if (!ZebrraBox.profiles.contains(profile)) {
      throw ProfileNotFoundException(profile);
    }

    await ZebrraBox.profiles.delete(profile);
  }

  Future<void> _rename(String oldProfile, String newProfile) async {
    if (!ZebrraBox.profiles.contains(oldProfile)) {
      throw ProfileNotFoundException(oldProfile);
    }

    if (ZebrraBox.profiles.contains(newProfile)) {
      throw ProfileAlreadyExistsException(newProfile);
    }

    final oldDb = ZebrraBox.profiles.read(oldProfile)!;
    final newDb = ZebrraProfile.clone(oldDb);

    await ZebrraBox.profiles.update(newProfile, newDb);
    _changeTo(newProfile);

    oldDb.delete();
  }
}

class ProfileNotFoundException with ErrorExceptionMixin {
  final String profile;
  const ProfileNotFoundException(this.profile);

  @override
  String toString() {
    return 'ProfileNotFoundException: "$profile" was not found';
  }
}

class ProfileAlreadyExistsException with ErrorExceptionMixin {
  final String profile;
  const ProfileAlreadyExistsException(this.profile);

  @override
  String toString() {
    return 'ProfileAlreadyExistsException: "$profile" already exists';
  }
}

class ActiveProfileRemovalException with ErrorExceptionMixin {
  final String profile;
  const ActiveProfileRemovalException(this.profile);

  @override
  String toString() {
    return 'ActiveProfileRemovalException: "$profile" can\'t be removed as it is in use';
  }
}
