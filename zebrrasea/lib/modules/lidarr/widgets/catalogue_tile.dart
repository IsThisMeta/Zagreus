import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/lidarr.dart';
import 'package:zebrrasea/router/routes/lidarr.dart';

class LidarrCatalogueTile extends StatefulWidget {
  final LidarrCatalogueData data;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function refresh;
  final Function refreshState;

  const LidarrCatalogueTile({
    Key? key,
    required this.data,
    required this.scaffoldKey,
    required this.refresh,
    required this.refreshState,
  }) : super(key: key);

  @override
  State<LidarrCatalogueTile> createState() => _State();
}

class _State extends State<LidarrCatalogueTile> {
  @override
  Widget build(BuildContext context) {
    return Selector<LidarrState, LidarrCatalogueSorting>(
      selector: (_, state) => state.sortCatalogueType,
      builder: (context, sortingType, _) => ZebrraBlock(
        title: widget.data.title,
        disabled: !widget.data.monitored!,
        body: [
          TextSpan(
            children: [
              TextSpan(text: widget.data.albums),
              TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
              TextSpan(text: widget.data.tracks),
            ],
          ),
          TextSpan(text: widget.data.subtitle(sortingType)),
        ],
        trailing: ZebrraIconButton(
          icon: widget.data.monitored!
              ? ZebrraIcons.MONITOR_ON
              : ZebrraIcons.MONITOR_OFF,
          onPressed: _toggleMonitoredStatus,
        ),
        posterPlaceholderIcon: ZebrraIcons.USER,
        posterUrl: widget.data.posterURI(),
        posterHeaders: ZebrraProfile.current.lidarrHeaders,
        backgroundUrl: widget.data.fanartURI(),
        backgroundHeaders: ZebrraProfile.current.lidarrHeaders,
        posterIsSquare: true,
        onTap: () async => _enterArtist(),
        onLongPress: () async => _handlePopup(),
      ),
    );
  }

  Future<void> _toggleMonitoredStatus() async {
    final _api = LidarrAPI.from(ZebrraProfile.current);
    await _api
        .toggleArtistMonitored(widget.data.artistID, !widget.data.monitored!)
        .then((_) {
      if (mounted)
        setState(() => widget.data.monitored = !widget.data.monitored!);
      widget.refreshState();
      showZebrraSuccessSnackBar(
        title: widget.data.monitored! ? 'Monitoring' : 'No Longer Monitoring',
        message: widget.data.title,
      );
    }).catchError((error) {
      showZebrraErrorSnackBar(
        title: widget.data.monitored!
            ? 'Failed to Stop Monitoring'
            : 'Failed to Monitor',
        error: error,
      );
    });
  }

  Future<void> _enterArtist() async {
    LidarrRoutes.ARTIST.go(
      extra: widget.data,
      params: {
        'artist': widget.data.artistID.toString(),
      },
    );
  }

  Future<void> _handlePopup() async {
    List<dynamic> values = await LidarrDialogs.editArtist(context, widget.data);
    if (values[0])
      switch (values[1]) {
        case 'refresh_artist':
          _refreshArtist();
          break;
        case 'edit_artist':
          _enterEditArtist();
          break;
        case 'remove_artist':
          _removeArtist();
          break;
        default:
          ZebrraLogger()
              .warning('Invalid method passed through popup. (${values[1]})');
      }
  }

  Future<void> _enterEditArtist() async {
    LidarrRoutes.ARTIST_EDIT.go(
      extra: widget.data,
      params: {
        'artist': widget.data.artistID.toString(),
      },
    );
  }

  Future<void> _refreshArtist() async {
    final _api = LidarrAPI.from(ZebrraProfile.current);
    await _api
        .refreshArtist(widget.data.artistID)
        .then((_) => showZebrraSuccessSnackBar(
            title: 'Refreshing...', message: widget.data.title))
        .catchError((error) =>
            showZebrraErrorSnackBar(title: 'Failed to Refresh', error: error));
  }

  Future<void> _removeArtist() async {
    final _api = LidarrAPI.from(ZebrraProfile.current);
    List values = await LidarrDialogs.deleteArtist(context);
    if (values[0]) {
      if (values[1]) {
        values = await ZebrraDialogs()
            .deleteCatalogueWithFiles(context, widget.data.title);
        if (values[0]) {
          await _api
              .removeArtist(widget.data.artistID, deleteFiles: true)
              .then((_) {
            showZebrraSuccessSnackBar(
                title: 'Removed (With Data)', message: widget.data.title);
            widget.refresh();
          }).catchError((error) {
            showZebrraErrorSnackBar(
              title: 'Failed to Remove (With Data)',
              error: error,
            );
          });
        }
      } else {
        await _api
            .removeArtist(widget.data.artistID, deleteFiles: false)
            .then((_) {
          showZebrraSuccessSnackBar(title: 'Removed', message: widget.data.title);
          widget.refresh();
        }).catchError((error) {
          showZebrraErrorSnackBar(
            title: 'Failed to Remove',
            error: error,
          );
        });
      }
    }
  }
}
