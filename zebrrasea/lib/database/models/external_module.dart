import 'package:zebrrasea/core.dart';

part 'external_module.g.dart';

@JsonSerializable()
@HiveType(typeId: 26, adapterName: 'ZebrraExternalModuleAdapter')
class ZebrraExternalModule extends HiveObject {
  @JsonKey()
  @HiveField(0, defaultValue: '')
  String displayName;

  @JsonKey()
  @HiveField(1, defaultValue: '')
  String host;

  ZebrraExternalModule({
    this.displayName = '',
    this.host = '',
  });

  @override
  String toString() => json.encode(this.toJson());

  Map<String, dynamic> toJson() => _$ZebrraExternalModuleToJson(this);

  factory ZebrraExternalModule.fromJson(Map<String, dynamic> json) {
    return _$ZebrraExternalModuleFromJson(json);
  }

  factory ZebrraExternalModule.clone(ZebrraExternalModule profile) {
    return ZebrraExternalModule.fromJson(profile.toJson());
  }

  factory ZebrraExternalModule.get(String key) {
    return ZebrraBox.externalModules.read(key)!;
  }
}
