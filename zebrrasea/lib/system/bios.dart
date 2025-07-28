import 'package:flutter/material.dart';

import 'package:zebrrasea/system/quick_actions/quick_actions.dart';

class ZebrraOS {
  Future<void> boot(BuildContext context) async {
    if (ZebrraQuickActions.isSupported) ZebrraQuickActions().initialize();
  }
}
