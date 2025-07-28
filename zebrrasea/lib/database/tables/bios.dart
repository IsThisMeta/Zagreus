import 'package:zebrrasea/database/table.dart';
import 'package:zebrrasea/modules.dart';

enum BIOSDatabase<T> with ZebrraTableMixin<T> {
  BOOT_MODULE<ZebrraModule>(ZebrraModule.DASHBOARD),
  FIRST_BOOT<bool>(true);

  @override
  ZebrraTable get table => ZebrraTable.bios;

  @override
  final T fallback;

  const BIOSDatabase(this.fallback);

  @override
  dynamic export() {
    BIOSDatabase db = this;
    switch (db) {
      case BIOSDatabase.BOOT_MODULE:
        return BIOSDatabase.BOOT_MODULE.read().key;
      default:
        return super.export();
    }
  }

  @override
  void import(dynamic value) {
    BIOSDatabase db = this;
    dynamic result;

    switch (db) {
      case BIOSDatabase.BOOT_MODULE:
        result = ZebrraModule.fromKey(value.toString());
        break;
      default:
        result = value;
        break;
    }

    return super.import(result);
  }
}
