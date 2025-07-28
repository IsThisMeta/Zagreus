import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrManualImportDetailsConfigureMoviesSearchBar extends StatefulWidget
    implements PreferredSizeWidget {
  const RadarrManualImportDetailsConfigureMoviesSearchBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      const Size.fromHeight(ZebrraTextInputBar.defaultAppBarHeight);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrManualImportDetailsConfigureMoviesSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) =>
      Consumer<RadarrManualImportDetailsTileState>(
        builder: (context, state, _) => SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: ZebrraTextInputBar(
                  controller: _controller,
                  autofocus: false,
                  onChanged: (value) => context
                      .read<RadarrManualImportDetailsTileState>()
                      .configureMoviesSearchQuery = value,
                  margin: ZebrraTextInputBar.appBarMargin,
                ),
              ),
            ],
          ),
          height: ZebrraTextInputBar.defaultAppBarHeight,
        ),
      );
}
