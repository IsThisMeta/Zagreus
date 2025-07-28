import 'package:flutter/material.dart';
import 'package:zebrrasea/database/tables/bios.dart';
import 'package:zebrrasea/modules.dart';
import 'package:zebrrasea/router/routes.dart';
import 'package:zebrrasea/router/routes/dashboard.dart';
import 'package:zebrrasea/system/bios.dart';
import 'package:zebrrasea/vendor.dart';

enum BIOSRoutes with ZebrraRoutesMixin {
  HOME('/');

  @override
  final String path;

  const BIOSRoutes(this.path);

  @override
  ZebrraModule? get module => null;

  @override
  bool isModuleEnabled(BuildContext context) => true;

  @override
  GoRoute get routes {
    switch (this) {
      case BIOSRoutes.HOME:
        return redirect(redirect: (context, _) {
          ZebrraOS().boot(context);

          final fallback = DashboardRoutes.HOME.path;
          return BIOSDatabase.BOOT_MODULE.read().homeRoute ?? fallback;
        });
    }
  }
}
