import 'package:flutter/material.dart';
import 'package:zebrrasea/main.dart';
import 'package:zebrrasea/system/recovery_mode/action_tile.dart';

class BootstrapTile extends RecoveryActionTile {
  const BootstrapTile({
    super.key,
    super.title = 'Bootstrap ZebrraSea',
    super.description = 'Run the bootstrap process and show any errors',
  });

  @override
  Future<void> action(BuildContext context) async {
    await bootstrap();
  }
}
