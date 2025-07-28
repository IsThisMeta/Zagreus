import 'package:flutter/material.dart';
import 'package:zebrrasea/modules.dart';
import 'package:zebrrasea/modules/nzbget/routes/nzbget.dart';
import 'package:zebrrasea/modules/nzbget/routes/statistics.dart';
import 'package:zebrrasea/router/routes.dart';
import 'package:zebrrasea/vendor.dart';

enum NZBGetRoutes with ZebrraRoutesMixin {
  HOME('/nzbget'),
  STATISTICS('statistics');

  @override
  final String path;

  const NZBGetRoutes(this.path);

  @override
  ZebrraModule get module => ZebrraModule.NZBGET;

  @override
  bool isModuleEnabled(BuildContext context) => true;

  @override
  GoRoute get routes {
    switch (this) {
      case NZBGetRoutes.HOME:
        return route(widget: const NZBGetRoute());
      case NZBGetRoutes.STATISTICS:
        return route(widget: const StatisticsRoute());
    }
  }

  @override
  List<GoRoute> get subroutes {
    switch (this) {
      case NZBGetRoutes.HOME:
        return [
          NZBGetRoutes.STATISTICS.routes,
        ];
      default:
        return const [];
    }
  }
}
