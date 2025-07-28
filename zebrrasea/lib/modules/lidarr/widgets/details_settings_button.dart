import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/lidarr.dart';
import 'package:zebrrasea/router/routes/lidarr.dart';

class LidarrDetailsSettingsButton extends StatefulWidget {
  final LidarrCatalogueData? data;
  final Function(bool) remove;

  const LidarrDetailsSettingsButton({
    Key? key,
    required this.data,
    required this.remove,
  }) : super(key: key);

  @override
  State<LidarrDetailsSettingsButton> createState() => _State();
}

class _State extends State<LidarrDetailsSettingsButton> {
  @override
  Widget build(BuildContext context) => Consumer<LidarrState>(
        builder: (context, model, widget) => ZebrraIconButton(
          icon: Icons.more_vert_rounded,
          onPressed: () async => _handlePopup(context),
        ),
      );

  Future<void> _handlePopup(BuildContext context) async {
    List<dynamic> values =
        await LidarrDialogs.editArtist(context, widget.data!);
    if (values[0])
      switch (values[1]) {
        case 'refresh_artist':
          _refreshArtist(context);
          break;
        case 'edit_artist':
          _enterEditArtist(context);
          break;
        case 'remove_artist':
          _removeArtist(context);
          break;
        default:
          ZebrraLogger()
              .warning('Invalid method passed through popup. (${values[1]})');
      }
  }

  Future<void> _enterEditArtist(BuildContext context) async {
    LidarrRoutes.ARTIST_EDIT.go(
      extra: widget.data,
      params: {
        'artist': widget.data!.artistID.toString(),
      },
    );
  }

  Future<void> _refreshArtist(BuildContext context) async {
    final _api = LidarrAPI.from(ZebrraProfile.current);
    await _api
        .refreshArtist(widget.data!.artistID)
        .then((_) => showZebrraSuccessSnackBar(
            title: 'Refreshing...', message: widget.data!.title))
        .catchError((error) =>
            showZebrraErrorSnackBar(title: 'Failed to Refresh', error: error));
  }

  Future<void> _removeArtist(BuildContext context) async {
    final _api = LidarrAPI.from(ZebrraProfile.current);
    List values = await LidarrDialogs.deleteArtist(context);
    if (values[0]) {
      if (values[1]) {
        values = await ZebrraDialogs()
            .deleteCatalogueWithFiles(context, widget.data!.title);
        if (values[0]) {
          await _api
              .removeArtist(widget.data!.artistID, deleteFiles: true)
              .then((_) => widget.remove(true))
              .catchError((error) => showZebrraErrorSnackBar(
                  title: 'Failed to Remove (With Data)', error: error));
        }
      } else {
        await _api
            .removeArtist(widget.data!.artistID)
            .then((_) => widget.remove(false))
            .catchError((error) =>
                showZebrraErrorSnackBar(title: 'Failed to Remove', error: error));
      }
    }
  }
}
