import 'package:zebrrasea/core.dart';

part 'indexer.g.dart';

@JsonSerializable()
@HiveType(typeId: 1, adapterName: 'ZebrraIndexerAdapter')
class ZebrraIndexer extends HiveObject {
  @JsonKey()
  @HiveField(0, defaultValue: '')
  String displayName;

  @JsonKey()
  @HiveField(1, defaultValue: '')
  String host;

  @JsonKey(name: 'key')
  @HiveField(2, defaultValue: '')
  String apiKey;

  @JsonKey()
  @HiveField(3, defaultValue: <String, String>{})
  Map<String, String> headers;

  ZebrraIndexer._internal({
    required this.displayName,
    required this.host,
    required this.apiKey,
    required this.headers,
  });

  factory ZebrraIndexer({
    String? displayName,
    String? host,
    String? apiKey,
    Map<String, String>? headers,
  }) {
    return ZebrraIndexer._internal(
      displayName: displayName ?? '',
      host: host ?? '',
      apiKey: apiKey ?? '',
      headers: headers ?? {},
    );
  }

  @override
  String toString() => json.encode(this.toJson());

  Map<String, dynamic> toJson() => _$ZebrraIndexerToJson(this);

  factory ZebrraIndexer.fromJson(Map<String, dynamic> json) {
    return _$ZebrraIndexerFromJson(json);
  }

  factory ZebrraIndexer.clone(ZebrraIndexer profile) {
    return ZebrraIndexer.fromJson(profile.toJson());
  }

  factory ZebrraIndexer.get(String key) {
    return ZebrraBox.indexers.read(key)!;
  }
}
