import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/discover.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/vendor.dart';

enum DiscoverRoutes with ZagRoutesMixin {
  HOME('/discover'),
  RECENTLY_DOWNLOADED('recently_downloaded');

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
      case DiscoverRoutes.RECENTLY_DOWNLOADED:
        return route(widget: const DiscoverRecentlyDownloadedRoute());
    }
  }
  
  @override
  List<GoRoute> get subroutes {
    switch (this) {
      case DiscoverRoutes.HOME:
        return [
          DiscoverRoutes.RECENTLY_DOWNLOADED.routes,
        ];
      case DiscoverRoutes.RECENTLY_DOWNLOADED:
        return [];
    }
  }
}