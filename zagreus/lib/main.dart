import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:device_preview/device_preview.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/database.dart';
import 'package:zagreus/router/router.dart';
import 'package:zagreus/system/cache/image/image_cache.dart';
import 'package:zagreus/system/cache/memory/memory_store.dart';
import 'package:zagreus/system/network/network.dart';
import 'package:zagreus/system/recovery_mode/main.dart';
import 'package:zagreus/system/window_manager/window_manager.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/modules/services/webhook_sync_service.dart';

/// Zagreus Entry Point: Bootstrap & Run Application
///
/// Runs app in guarded zone to attempt to capture fatal (crashing) errors
Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      try {
        await bootstrap();
        runApp(const ZagBIOS());
      } catch (error) {
        runApp(const ZagRecoveryMode());
      }
    },
    (error, stack) => ZagLogger().critical(error, stack),
  );
}

/// Bootstrap the core
///
Future<void> bootstrap() async {
  await ZagDatabase().initialize();
  ZagLogger().initialize();
  ZagTheme().initialize();
  if (ZagWindowManager.isSupported) await ZagWindowManager().initialize();
  if (ZagNetwork.isSupported) ZagNetwork().initialize();
  if (ZagImageCache.isSupported) ZagImageCache().initialize();
  // Initialize Supabase for auth and storage
  if (ZagSupabase.isSupported) await ZagSupabase().initialize();
  ZagRouter().initialize();
  await ZagMemoryStore().initialize();
  // Initialize webhook sync service
  WebhookSyncService.initialize();
}

class ZagBIOS extends StatefulWidget {
  const ZagBIOS({
    super.key,
  });

  @override
  State<ZagBIOS> createState() => _ZagBIOSState();
}

class _ZagBIOSState extends State<ZagBIOS> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check webhooks when app becomes active, like Ruddarr
      WebhookSyncService.maybeUpdateWebhooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ZagTheme();
    final router = ZagRouter.router;

    return ZagState.providers(
      child: DevicePreview(
        enabled: kDebugMode && ZagPlatform.isDesktop,
        builder: (context) => EasyLocalization(
          supportedLocales: [Locale('en')],
          path: 'assets/localization',
          fallbackLocale: Locale('en'),
          startLocale: Locale('en'),
          useFallbackTranslations: true,
          child: ZagBox.zagreus.listenableBuilder(
            selectItems: [
              ZagreusDatabase.THEME_AMOLED,
              ZagreusDatabase.THEME_AMOLED_BORDER,
              ZagreusDatabase.THEME_MODE,
              ZagreusDatabase.THEME_FOLLOW_SYSTEM,
            ],
            builder: (context, _) {
              final brightness = MediaQuery.of(context).platformBrightness;
              return MaterialApp.router(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                builder: DevicePreview.appBuilder,
                darkTheme: theme.activeTheme(systemBrightness: Brightness.dark),
                theme: theme.activeTheme(systemBrightness: Brightness.light),
                themeMode: ZagreusDatabase.THEME_FOLLOW_SYSTEM.read() 
                    ? ThemeMode.system 
                    : (ZagreusDatabase.THEME_MODE.read() == 'light' ? ThemeMode.light : ThemeMode.dark),
                title: 'Zagreus',
                routeInformationProvider: router.routeInformationProvider,
                routeInformationParser: router.routeInformationParser,
                routerDelegate: router.routerDelegate,
              );
            },
          ),
        ),
      ),
    );
  }
}
