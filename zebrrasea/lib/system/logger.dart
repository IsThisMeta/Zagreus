import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/database/models/log.dart';
import 'package:zebrrasea/types/exception.dart';
import 'package:zebrrasea/types/log_type.dart';

class ZebrraLogger {
  static String get checkLogsMessage => 'zebrrasea.CheckLogsMessage'.tr();

  void initialize() {
    FlutterError.onError = (details) async {
      if (kDebugMode) FlutterError.dumpErrorToConsole(details);
      Zone.current.handleUncaughtError(
        details.exception,
        details.stack ?? StackTrace.current,
      );
    };
    _compact();
  }

  Future<void> _compact([int count = 50]) async {
    if (ZebrraBox.logs.data.length <= count) return;
    List<ZebrraLog> logs = ZebrraBox.logs.data.toList();
    logs.sort((a, b) => (b.timestamp).compareTo(a.timestamp));
    logs.skip(count).forEach((log) => log.delete());
  }

  Future<String> export() async {
    final logs = ZebrraBox.logs.data.map((log) => log.toJson()).toList();
    final encoder = JsonEncoder.withIndent(' '.repeat(4));
    return encoder.convert(logs);
  }

  Future<void> clear() async => ZebrraBox.logs.clear();

  void debug(String message) {
    ZebrraLog log = ZebrraLog.withMessage(
      type: ZebrraLogType.DEBUG,
      message: message,
    );
    ZebrraBox.logs.create(log);
  }

  void warning(String message, [String? className, String? methodName]) {
    ZebrraLog log = ZebrraLog.withMessage(
      type: ZebrraLogType.WARNING,
      message: message,
      className: className,
      methodName: methodName,
    );
    ZebrraBox.logs.create(log);
  }

  void error(String message, dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print(message);
      print(error);
      print(stackTrace);
    }

    if (error is! NetworkImageLoadException) {
      ZebrraLog log = ZebrraLog.withError(
        type: ZebrraLogType.ERROR,
        message: message,
        error: error,
        stackTrace: stackTrace,
      );
      ZebrraBox.logs.create(log);
    }
  }

  void critical(dynamic error, StackTrace stackTrace) {
    if (kDebugMode) {
      print(error);
      print(stackTrace);
    }

    if (error is! NetworkImageLoadException) {
      ZebrraLog log = ZebrraLog.withError(
        type: ZebrraLogType.CRITICAL,
        message: error?.toString() ?? ZebrraUI.TEXT_EMDASH,
        error: error,
        stackTrace: stackTrace,
      );
      ZebrraBox.logs.create(log);
    }
  }

  void exception(ZebrraException exception, [StackTrace? trace]) {
    switch (exception.type) {
      case ZebrraLogType.WARNING:
        warning(exception.toString(), exception.runtimeType.toString());
        break;
      case ZebrraLogType.ERROR:
        error(exception.toString(), exception, trace);
        break;
      default:
        break;
    }
  }
}
