import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/lidarr.dart';
import 'package:zebrrasea/router/router.dart';

class ArtistEditRoute extends StatefulWidget {
  final LidarrCatalogueData? data;
  final int? artistId;

  const ArtistEditRoute({
    Key? key,
    required this.data,
    required this.artistId,
  }) : super(key: key);

  @override
  State<ArtistEditRoute> createState() => _State();
}

class _State extends State<ArtistEditRoute> with ZebrraScrollControllerMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<bool>? _future;

  List<LidarrQualityProfile> _qualityProfiles = [];
  List<LidarrMetadataProfile> _metadataProfiles = [];
  LidarrQualityProfile? _qualityProfile;
  LidarrMetadataProfile? _metadataProfile;
  String? _path;
  bool? _monitored;
  bool? _albumFolders;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  Widget build(BuildContext context) => ZebrraScaffold(
        scaffoldKey: _scaffoldKey,
        body: _body,
        appBar: _appBar,
        bottomNavigationBar: _bottomActionBar(),
      );

  Future<void> _refresh() async {
    setState(() {
      _future = _fetch();
    });
  }

  Future<bool> _fetch() async {
    final _api = LidarrAPI.from(ZebrraProfile.current);
    return _fetchProfiles(_api).then((_) => _fetchMetadata(_api)).then((_) {
      _path = widget.data!.path;
      _monitored = widget.data!.monitored;
      _albumFolders = widget.data!.albumFolders;
      return true;
    });
  }

  Future<void> _fetchProfiles(LidarrAPI api) async {
    return await api.getQualityProfiles().then((profiles) {
      _qualityProfiles = profiles.values.toList();
      if (_qualityProfiles.isNotEmpty) {
        for (var profile in _qualityProfiles) {
          if (profile.id == widget.data!.qualityProfile) {
            _qualityProfile = profile;
          }
        }
      }
    });
  }

  Future<void> _fetchMetadata(LidarrAPI api) async {
    return await api.getMetadataProfiles().then((metadatas) {
      _metadataProfiles = metadatas.values.toList();
      if (_metadataProfiles.isNotEmpty) {
        for (var profile in _metadataProfiles) {
          if (profile.id == widget.data!.metadataProfile) {
            _metadataProfile = profile;
          }
        }
      }
    });
  }

  PreferredSizeWidget get _appBar {
    return ZebrraAppBar(
      title: widget.data?.title ?? 'Edit Artist',
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZebrraBottomActionBar(
      actions: [
        ZebrraButton.text(
          text: 'zebrrasea.Update'.tr(),
          icon: Icons.edit_rounded,
          onTap: _save,
        ),
      ],
    );
  }

  Widget get _body => FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              {
                if (snapshot.hasError || snapshot.data == null)
                  return ZebrraMessage.error(onTap: _refresh);
                return _list;
              }
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
            default:
              return const ZebrraLoader();
          }
        },
      );

  Widget get _list => ZebrraListView(
        controller: scrollController,
        children: <Widget>[
          ZebrraBlock(
            title: 'Monitored',
            trailing: ZebrraSwitch(
              value: _monitored!,
              onChanged: (value) => setState(() => _monitored = value),
            ),
          ),
          ZebrraBlock(
            title: 'Quality Profile',
            body: [TextSpan(text: _qualityProfile!.name)],
            trailing: const ZebrraIconButton.arrow(),
            onTap: _changeProfile,
          ),
          ZebrraBlock(
            title: 'Metadata Profile',
            body: [TextSpan(text: _metadataProfile!.name)],
            trailing: const ZebrraIconButton.arrow(),
            onTap: _changeMetadata,
          ),
          ZebrraBlock(
            title: 'Artist Path',
            body: [TextSpan(text: _path)],
            trailing: const ZebrraIconButton.arrow(),
            onTap: _changePath,
          ),
        ],
      );

  Future<void> _changePath() async {
    Tuple2<bool, String> _values =
        await ZebrraDialogs().editText(context, 'Artist Path', prefill: _path!);
    if (_values.item1 && mounted) setState(() => _path = _values.item2);
  }

  Future<void> _changeProfile() async {
    List<dynamic> _values =
        await LidarrDialogs.editQualityProfile(context, _qualityProfiles);
    if (_values[0] && mounted) setState(() => _qualityProfile = _values[1]);
  }

  Future<void> _changeMetadata() async {
    List<dynamic> _values =
        await LidarrDialogs.editMetadataProfile(context, _metadataProfiles);
    if (_values[0] && mounted) setState(() => _metadataProfile = _values[1]);
  }

  Future<void> _save() async {
    final _api = LidarrAPI.from(ZebrraProfile.current);
    await _api
        .editArtist(
      widget.data!.artistID,
      _qualityProfile!,
      _metadataProfile!,
      _path,
      _monitored,
      _albumFolders,
    )
        .then((_) {
      widget.data!.qualityProfile = _qualityProfile!.id;
      widget.data!.quality = _qualityProfile!.name;
      widget.data!.metadataProfile = _metadataProfile!.id;
      widget.data!.metadata = _metadataProfile!.name;
      widget.data!.path = _path;
      widget.data!.monitored = _monitored;
      widget.data!.albumFolders = _albumFolders;
      showZebrraSuccessSnackBar(
        title: 'Artist Updated',
        message: widget.data!.title,
      );
      ZebrraRouter.router.pop();
    }).catchError((error, stack) {
      ZebrraLogger().error('Failed to update artist', error, stack);
      showZebrraErrorSnackBar(
        title: 'Failed to Update',
        error: error,
      );
    });
  }
}
