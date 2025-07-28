import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraExpandableListTile extends StatefulWidget {
  final String title;
  final List<TextSpan> collapsedSubtitles;
  final Widget? collapsedTrailing;
  final Widget? collapsedLeading;
  final Color? backgroundColor;
  final Function? onLongPress;
  final List<ZebrraHighlightedNode>? expandedHighlightedNodes;
  final List<ZebrraTableContent> expandedTableContent;
  final List<ZebrraButton>? expandedTableButtons;
  final bool initialExpanded;

  /// Create a [ZebrraExpandableListTile] which is a list tile that expands into a table-style card.
  ///
  /// If [expandedWidget] is supplied, that widget is used as the body within the expanded card.
  /// Any
  const ZebrraExpandableListTile({
    Key? key,
    required this.title,
    required this.collapsedSubtitles,
    required this.expandedTableContent,
    this.collapsedTrailing,
    this.collapsedLeading,
    this.onLongPress,
    this.expandedHighlightedNodes,
    this.expandedTableButtons,
    this.backgroundColor,
    this.initialExpanded = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ZebrraExpandableListTile> {
  ExpandableController? controller;

  @override
  void initState() {
    super.initState();
    controller = ExpandableController(initialExpanded: widget.initialExpanded);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      controller: controller,
      child: Expandable(
        collapsed: collapsed(),
        expanded: expanded(),
      ),
    );
  }

  List<TextSpan> _parseSubtitles() {
    if (widget.collapsedSubtitles.isEmpty) return [];
    List<TextSpan> _result = [];
    for (int i = 0; i < widget.collapsedSubtitles.length; i++) {
      _result.add(widget.collapsedSubtitles[i]);
    }
    return _result;
  }

  Widget collapsed() {
    return ZebrraBlock(
      title: widget.title,
      body: _parseSubtitles(),
      onTap: controller!.toggle,
      onLongPress: widget.onLongPress,
      trailing: widget.collapsedTrailing,
      leading: widget.collapsedLeading,
      // color: widget.backgroundColor,
    );
  }

  Widget expanded() {
    return ZebrraCard(
      context: context,
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.only(
            top: ZebrraUI.DEFAULT_MARGIN_SIZE,
            bottom: widget.expandedTableButtons?.isEmpty ?? true
                ? (ZebrraUI.DEFAULT_MARGIN_SIZE / 4 * 3)
                : ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      child: ZebrraText.title(
                        text: widget.title,
                        softWrap: true,
                        maxLines: 8,
                      ),
                      padding: const EdgeInsets.only(
                        left: ZebrraUI.DEFAULT_MARGIN_SIZE,
                        right: ZebrraUI.DEFAULT_MARGIN_SIZE,
                        bottom: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
                      ),
                    ),
                    if (widget.expandedHighlightedNodes != null)
                      Padding(
                        child: Wrap(
                          direction: Axis.horizontal,
                          spacing: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
                          runSpacing: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
                          children: widget.expandedHighlightedNodes!,
                        ),
                        padding: const EdgeInsets.only(
                          left: ZebrraUI.DEFAULT_MARGIN_SIZE,
                          right: ZebrraUI.DEFAULT_MARGIN_SIZE,
                          bottom: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
                        ),
                      ),
                    ...widget.expandedTableContent
                        .map((child) => Padding(
                              child: child,
                              padding: const EdgeInsets.symmetric(
                                horizontal: ZebrraUI.DEFAULT_MARGIN_SIZE,
                              ),
                            ))
                        .toList(),
                    if (widget.expandedTableButtons != null)
                      Padding(
                        child: Wrap(
                          children: [
                            ...List.generate(
                              widget.expandedTableButtons!.length,
                              (index) {
                                int bCount =
                                    widget.expandedTableButtons!.length;
                                double widthFactor = 0.5;

                                if (index == (bCount - 1) && bCount.isOdd) {
                                  widthFactor = 1;
                                }

                                return FractionallySizedBox(
                                  child: widget.expandedTableButtons![index],
                                  widthFactor: widthFactor,
                                );
                              },
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: ZebrraUI.DEFAULT_MARGIN_SIZE / 2,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        borderRadius: BorderRadius.circular(ZebrraUI.BORDER_RADIUS),
        onTap: controller!.toggle,
        onLongPress: widget.onLongPress as void Function()?,
      ),
      color: widget.backgroundColor,
    );
  }
}
