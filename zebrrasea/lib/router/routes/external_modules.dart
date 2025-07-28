import 'package:flutter/material.dart';
import 'package:zebrrasea/modules.dart';
import 'package:zebrrasea/modules/external_modules/routes/external_modules/route.dart';
import 'package:zebrrasea/router/routes.dart';
import 'package:zebrrasea/vendor.dart';

enum ExternalModulesRoutes with ZebrraRoutesMixin {
  HOME('/external_modules');

  @override
  final String path;

  const ExternalModulesRoutes(this.path);

  @override
  ZebrraModule get module => ZebrraModule.EXTERNAL_MODULES;

  @override
  bool isModuleEnabled(BuildContext context) => true;

  @override
  GoRoute get routes {
    switch (this) {
      case ExternalModulesRoutes.HOME:
        return route(widget: const ExternalModulesRoute());
    }
  }
}
