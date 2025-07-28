import 'package:flutter/material.dart';

import 'package:zebrrasea/system/logger.dart';
import 'package:zebrrasea/widgets/pages/error_route.dart';
import 'package:zebrrasea/router/routes.dart';
import 'package:zebrrasea/vendor.dart';

class ZebrraRouter {
  static late GoRouter router;
  static GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();

  void initialize() {
    router = GoRouter(
      navigatorKey: navigator,
      errorBuilder: (_, state) => ErrorRoutePage(exception: state.error),
      initialLocation: ZebrraRoutes.initialLocation,
      routes: ZebrraRoutes.values.map((r) => r.root.routes).toList(),
    );
  }

  void popSafely() {
    if (router.canPop()) router.pop();
  }

  void popToRootRoute() {
    if (navigator.currentState == null) {
      ZebrraLogger().warning('Not observing any navigation navigators, skipping');
      return;
    }
    navigator.currentState!.popUntil((route) => route.isFirst);
  }
}
