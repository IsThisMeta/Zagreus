import 'package:flutter/material.dart';

import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/tables/bios.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/system/network/network.dart';
import 'package:zebrrasea/system/platform.dart';

class ConfigurationGeneralRoute extends StatefulWidget {
  const ConfigurationGeneralRoute({
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _State();
}

class _State extends State<ConfigurationGeneralRoute>
    with ZebrraScrollControllerMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar(
      title: 'settings.General'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        ..._appearance(),
        ..._localization(),
        ..._modules(),
        if (ZebrraNetwork.isSupported) ..._network(),
        ..._platform(),
      ],
    );
  }

  List<Widget> _appearance() {
    return [
      ZebrraHeader(text: 'settings.Appearance'.tr()),
      _imageBackgroundOpacity(),
      _amoledTheme(),
      _amoledThemeBorders(),
    ];
  }

  List<Widget> _localization() {
    return [
      ZebrraHeader(text: 'settings.Localization'.tr()),
      _use24HourTime(),
    ];
  }

  List<Widget> _modules() {
    return [
      ZebrraHeader(text: 'dashboard.Modules'.tr()),
      _bootModule(),
    ];
  }

  List<Widget> _network() {
    return [
      ZebrraHeader(text: 'settings.Network'.tr()),
      _useTLSValidation(),
    ];
  }

  List<Widget> _platform() {
    if (ZebrraPlatform.isAndroid) {
      return [
        ZebrraHeader(text: 'settings.Platform'.tr()),
        _openDrawerOnBackAction(),
      ];
    }

    return [];
  }

  Widget _openDrawerOnBackAction() {
    const _db = ZebrraSeaDatabase.ANDROID_BACK_OPENS_DRAWER;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'settings.OpenDrawerOnBackAction'.tr(),
        body: [
          TextSpan(text: 'settings.OpenDrawerOnBackActionDescription'.tr()),
        ],
        trailing: ZebrraSwitch(
          value: _db.read(),
          onChanged: _db.update,
        ),
      ),
    );
  }

  Widget _amoledTheme() {
    const _db = ZebrraSeaDatabase.THEME_AMOLED;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'settings.AmoledTheme'.tr(),
        body: [
          TextSpan(text: 'settings.AmoledThemeDescription'.tr()),
        ],
        trailing: ZebrraSwitch(
          value: _db.read(),
          onChanged: (value) {
            _db.update(value);
            ZebrraTheme().initialize();
          },
        ),
      ),
    );
  }

  Widget _amoledThemeBorders() {
    return ZebrraBox.zebrrasea.listenableBuilder(
      selectItems: [
        ZebrraSeaDatabase.THEME_AMOLED_BORDER,
        ZebrraSeaDatabase.THEME_AMOLED,
      ],
      builder: (context, _) => ZebrraBlock(
        title: 'settings.AmoledThemeBorders'.tr(),
        body: [
          TextSpan(text: 'settings.AmoledThemeBordersDescription'.tr()),
        ],
        trailing: ZebrraSwitch(
          value: ZebrraSeaDatabase.THEME_AMOLED_BORDER.read(),
          onChanged: ZebrraSeaDatabase.THEME_AMOLED.read()
              ? ZebrraSeaDatabase.THEME_AMOLED_BORDER.update
              : null,
        ),
      ),
    );
  }

  Widget _imageBackgroundOpacity() {
    const _db = ZebrraSeaDatabase.THEME_IMAGE_BACKGROUND_OPACITY;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'settings.BackgroundImageOpacity'.tr(),
        body: [
          TextSpan(
            text: _db.read() == 0 ? 'zebrrasea.Disabled'.tr() : '${_db.read()}%',
          ),
        ],
        trailing: const ZebrraIconButton.arrow(),
        onTap: () async {
          Tuple2<bool, int> result =
              await SettingsDialogs().changeBackgroundImageOpacity(context);
          if (result.item1) _db.update(result.item2);
        },
      ),
    );
  }

  Widget _useTLSValidation() {
    const _db = ZebrraSeaDatabase.NETWORKING_TLS_VALIDATION;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'settings.TLSCertificateValidation'.tr(),
        body: [
          TextSpan(text: 'settings.TLSCertificateValidationDescription'.tr()),
        ],
        trailing: ZebrraSwitch(
          value: _db.read(),
          onChanged: (data) {
            _db.update(data);
            if (ZebrraNetwork.isSupported) ZebrraNetwork().initialize();
          },
        ),
      ),
    );
  }

  Widget _use24HourTime() {
    const _db = ZebrraSeaDatabase.USE_24_HOUR_TIME;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'settings.Use24HourTime'.tr(),
        body: [TextSpan(text: 'settings.Use24HourTimeDescription'.tr())],
        trailing: ZebrraSwitch(
          value: _db.read(),
          onChanged: _db.update,
        ),
      ),
    );
  }

  Widget _bootModule() {
    const _db = BIOSDatabase.BOOT_MODULE;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'settings.BootModule'.tr(),
        body: [TextSpan(text: _db.read().title)],
        trailing: ZebrraIconButton(icon: _db.read().icon),
        onTap: () async {
          final result = await SettingsDialogs().selectBootModule();
          if (result.item1) {
            BIOSDatabase.BOOT_MODULE.update(result.item2!);
          }
        },
      ),
    );
  }
}
