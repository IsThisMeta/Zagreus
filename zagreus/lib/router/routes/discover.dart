import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/discover.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/vendor.dart';

enum DiscoverRoutes with ZagRoutesMixin {
  HOME('/discover');

  @override
  final String path;

  const DiscoverRoutes(this.path);

  @override
  ZagModule get module => ZagModule.DISCOVER;

  @override
  bool isModuleEnabled(BuildContext context) => true;

  @override
  GoRoute get routes {
    switch (this) {
      case DiscoverRoutes.HOME:
        return route(widget: const DiscoverHomeRoute());
    }
  }
}