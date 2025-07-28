import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrCatalogueSearchBar extends StatefulWidget
    implements PreferredSizeWidget {
  final ScrollController scrollController;

  const RadarrCatalogueSearchBar({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      const Size.fromHeight(ZebrraTextInputBar.defaultAppBarHeight);

  @override
  State<RadarrCatalogueSearchBar> createState() => _State();
}

class _State extends State<RadarrCatalogueSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<RadarrState>().moviesSearchQuery;
    _focusNode.addListener(_handleFocus);
  }

  void _handleFocus() {
    if (_focusNode.hasPrimaryFocus != _hasFocus)
      setState(() => _hasFocus = _focusNode.hasPrimaryFocus);
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _sc = widget.scrollController;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Consumer<RadarrState>(
            builder: (context, state, _) => ZebrraTextInputBar(
              controller: _controller,
              scrollController: _sc,
              focusNode: _focusNode,
              autofocus: false,
              onChanged: (value) =>
                  context.read<RadarrState>().moviesSearchQuery = value,
              margin: EdgeInsets.zero,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(
            milliseconds: ZebrraUI.ANIMATION_SPEED_SCROLLING,
          ),
          curve: Curves.easeInOutQuart,
          width: _hasFocus
              ? 0.0
              : (ZebrraTextInputBar.defaultHeight * 3 +
                  ZebrraUI.DEFAULT_MARGIN_SIZE * 3),
          child: Row(
            children: [
              Flexible(
                child: RadarrCatalogueSearchBarFilterButton(controller: _sc),
              ),
              Flexible(
                child: RadarrCatalogueSearchBarSortButton(controller: _sc),
              ),
              Flexible(
                child: RadarrCatalogueSearchBarViewButton(controller: _sc),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
