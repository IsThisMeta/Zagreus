import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';
import 'package:zebrrasea/router/router.dart';

class RadarrEditMovieActionBar extends StatelessWidget {
  const RadarrEditMovieActionBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBottomActionBar(
      actions: [
        ZebrraButton(
          type: ZebrraButtonType.TEXT,
          text: 'zebrrasea.Update'.tr(),
          icon: Icons.edit_rounded,
          loadingState: context.watch<RadarrMoviesEditState>().state,
          onTap: () async => _updateOnTap(context),
        )
      ],
    );
  }

  Future<void> _updateOnTap(BuildContext context) async {
    final state = context.read<RadarrMoviesEditState>();
    state.state = ZebrraLoadingState.ACTIVE;

    if (state.canExecuteAction && state.movie != null) {
      bool moveFiles = false;
      if (state.path != state.movie?.path) {
        moveFiles = await RadarrDialogs().moveFiles();
      }

      final movie = state.movie!.updateEdits(state);
      bool result = await RadarrAPIHelper().updateMovie(
        context: context,
        movie: movie,
        moveFiles: moveFiles,
      );
      if (result) ZebrraRouter().popSafely();
    }
  }
}
