import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/search.dart';

class SearchSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final ScrollController scrollController;
  final Function(String) submitCallback;

  const SearchSearchBar({
    Key? key,
    required this.submitCallback,
    required this.scrollController,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      const Size.fromHeight(ZebrraTextInputBar.defaultAppBarHeight);

  @override
  State<SearchSearchBar> createState() => _State();
}

class _State extends State<SearchSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Consumer<SearchState>(
            builder: (context, state, _) => ZebrraTextInputBar(
              controller: _controller,
              scrollController: widget.scrollController,
              autofocus: true,
              onChanged: (value) =>
                  context.read<SearchState>().searchQuery = value,
              onSubmitted: widget.submitCallback,
              margin: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 14.0),
            ),
          ),
        ),
      ],
    );
  }
}
