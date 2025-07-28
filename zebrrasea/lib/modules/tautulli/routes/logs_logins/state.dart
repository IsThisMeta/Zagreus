import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliLogsLoginsState extends ChangeNotifier {
  TautulliLogsLoginsState(BuildContext context) {
    fetchLogs(context);
  }

  Future<TautulliUserLogins>? _logs;
  Future<TautulliUserLogins>? get logs => _logs;
  Future<void> fetchLogs(BuildContext context) async {
    if (context.read<TautulliState>().enabled) {
      _logs = context.read<TautulliState>().api!.users.getUserLogins(
            length: TautulliDatabase.CONTENT_LOAD_LENGTH.read(),
          );
    }
    notifyListeners();
  }
}
