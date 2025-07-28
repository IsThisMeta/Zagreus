import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

part 'list_view_option.g.dart';

const _BLOCK_VIEW = 'BLOCK_VIEW';
const _GRID_VIEW = 'GRID_VIEW';

@HiveType(typeId: 29, adapterName: 'ZebrraListViewOptionAdapter')
enum ZebrraListViewOption {
  @HiveField(0)
  BLOCK_VIEW(_BLOCK_VIEW),
  @HiveField(1)
  GRID_VIEW(_GRID_VIEW);

  final String key;
  const ZebrraListViewOption(this.key);

  static ZebrraListViewOption? fromKey(String? key) {
    switch (key) {
      case _BLOCK_VIEW:
        return ZebrraListViewOption.BLOCK_VIEW;
      case _GRID_VIEW:
        return ZebrraListViewOption.GRID_VIEW;
    }
    return null;
  }
}

extension ZebrraListViewOptionExtension on ZebrraListViewOption {
  String get readable {
    switch (this) {
      case ZebrraListViewOption.BLOCK_VIEW:
        return 'zebrrasea.BlockView'.tr();
      case ZebrraListViewOption.GRID_VIEW:
        return 'zebrrasea.GridView'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case ZebrraListViewOption.BLOCK_VIEW:
        return Icons.view_list_rounded;
      case ZebrraListViewOption.GRID_VIEW:
        return Icons.grid_view_rounded;
    }
  }
}
