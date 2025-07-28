// ignore: always_use_package_imports
import '../filesystem.dart';

bool isPlatformSupported() => false;
ZebrraFileSystem getFileSystem() =>
    throw UnsupportedError('ZebrraFileSystem unsupported');
