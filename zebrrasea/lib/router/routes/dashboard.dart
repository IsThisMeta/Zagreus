import 'package:flutter/material.dart';
import 'package:zebrrasea/modules.dart';
import 'package:zebrrasea/modules/dashboard/routes/dashboard/route.dart';
import 'package:zebrrasea/router/routes.dart';
import 'package:zebrrasea/vendor.dart';

enum DashboardRoutes with ZebrraRoutesMixin {
  HOME('/dashboard');

  @override
  final String path;

  const DashboardRoutes(this.path);

  @override
  ZebrraModule get module => ZebrraModule.DASHBOARD;

  @override
  bool isModuleEnabled(BuildContext context) => true;

  @override
  GoRoute get routes {
    switch (this) {
      case DashboardRoutes.HOME:
        return route(widget: const DashboardRoute());
    }
  }
}
