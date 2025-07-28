import 'package:zebrrasea/api/wake_on_lan/wake_on_lan.dart';

bool isPlatformSupported() => false;
ZebrraWakeOnLAN getWakeOnLAN() =>
    throw UnsupportedError('ZebrraWakeOnLAN unsupported');
