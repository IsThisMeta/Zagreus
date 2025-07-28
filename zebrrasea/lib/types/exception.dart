import 'package:zebrrasea/types/log_type.dart';

abstract class ZebrraException implements Exception {
  ZebrraLogType get type;
}

mixin WarningExceptionMixin implements ZebrraException {
  @override
  ZebrraLogType get type => ZebrraLogType.WARNING;
}

mixin ErrorExceptionMixin implements ZebrraException {
  @override
  ZebrraLogType get type => ZebrraLogType.ERROR;
}
