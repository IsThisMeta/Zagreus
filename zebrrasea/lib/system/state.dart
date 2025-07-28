import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:zebrrasea/modules/dashboard/core/state.dart';
import 'package:zebrrasea/modules/lidarr/core/state.dart';
import 'package:zebrrasea/modules/radarr/core/state.dart';
import 'package:zebrrasea/modules/search/core/state.dart';
import 'package:zebrrasea/modules/settings/core/state.dart';
import 'package:zebrrasea/modules/sonarr/core/state.dart';
import 'package:zebrrasea/modules/sabnzbd/core/state.dart';
import 'package:zebrrasea/modules/nzbget/core/state.dart';
import 'package:zebrrasea/modules/tautulli/core/state.dart';
import 'package:zebrrasea/modules.dart';
import 'package:zebrrasea/router/router.dart';

class ZebrraState {
  ZebrraState._();

  static BuildContext get context => ZebrraRouter.navigator.currentContext!;

  /// Calls `.reset()` on all states which extend [ZebrraModuleState].
  static void reset([BuildContext? context]) {
    final ctx = context ?? ZebrraState.context;
    ZebrraModule.values.forEach((module) => module.state(ctx)?.reset());
  }

  static MultiProvider providers({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardState()),
        ChangeNotifierProvider(create: (_) => SettingsState()),
        ChangeNotifierProvider(create: (_) => SearchState()),
        ChangeNotifierProvider(create: (_) => LidarrState()),
        ChangeNotifierProvider(create: (_) => RadarrState()),
        ChangeNotifierProvider(create: (_) => SonarrState()),
        ChangeNotifierProvider(create: (_) => NZBGetState()),
        ChangeNotifierProvider(create: (_) => SABnzbdState()),
        ChangeNotifierProvider(create: (_) => TautulliState()),
      ],
      child: child,
    );
  }
}

abstract class ZebrraModuleState extends ChangeNotifier {
  /// Reset the state back to the default
  void reset();
}
