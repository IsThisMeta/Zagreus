import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zebrrasea/core.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:zebrrasea/extensions/page_controller.dart';
import 'package:zebrrasea/extensions/scroll_controller.dart';

class ZebrraBottomNavigationBar extends StatefulWidget {
  final PageController? pageController;
  final List<IconData> icons;
  final List<String> titles;
  final List<ScrollController>? scrollControllers;
  final List<Widget>? topActions;
  final ValueChanged<int>? onTabChange;
  final List<Widget?>? leadingOnTab;

  ZebrraBottomNavigationBar({
    Key? key,
    required this.pageController,
    required this.icons,
    required this.titles,
    this.topActions,
    this.onTabChange,
    this.leadingOnTab,
    this.scrollControllers,
  }) : super(key: key) {
    assert(
      icons.length == titles.length,
      'An unequal amount of titles and icons were passed to ZebrraNavigationBar.',
    );
    if (leadingOnTab != null) {
      assert(
        icons.length == leadingOnTab!.length,
        'An unequal amount of icons and leadingOnTab were passed to ZebrraNavigationBar.',
      );
    }
    if (scrollControllers != null) {
      assert(
        icons.length == scrollControllers!.length,
        'An unequal amount of icons and scrollControllers were passed to ZebrraNavigationBar.',
      );
    }
  }

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ZebrraBottomNavigationBar> {
  late int _index;

  @override
  void initState() {
    _index = widget.pageController?.initialPage ?? 0;
    widget.pageController?.addListener(_pageControllerListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.pageController?.removeListener(_pageControllerListener);
    super.dispose();
  }

  void _pageControllerListener() {
    if ((widget.pageController!.page?.round() ?? _index) == _index) return;
    setState(() => _index = widget.pageController!.page!.round());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.topActions?.isNotEmpty ?? false) _actionBar,
        _navigationBar,
      ],
    );
  }

  Widget get _actionBar {
    return ZebrraBottomActionBar(
      actions: widget.topActions,
      useSafeArea: false,
      padding: ZebrraUI.MARGIN_HALF,
    );
  }

  Widget get _navigationBar {
    return Container(
      child: SafeArea(
        child: Padding(
          child: GNav(
            gap: ZebrraUI.MARGIN_SIZE_HALF,
            duration: const Duration(milliseconds: ZebrraUI.ANIMATION_SPEED),
            tabBackgroundColor: Theme.of(context).canvasColor.dimmed(),
            activeColor: ZebrraColours.accent,
            tabs: List.generate(
                widget.icons.length,
                (index) => GButton(
                      icon: widget.icons[index],
                      text: widget.titles[index],
                      active: _index == index,
                      iconSize: ZebrraUI.ICON_SIZE,
                      haptic: true,
                      padding: const EdgeInsets.all(10.0).add(EdgeInsets.only(
                        left: _index == index ? ZebrraUI.MARGIN_SIZE_HALF : 0.0,
                      )),
                      iconColor: Colors.white,
                      textStyle: const TextStyle(
                        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
                        fontSize: ZebrraUI.FONT_SIZE_H3,
                        color: Colors.white,
                      ),
                      iconActiveColor: ZebrraColours.accent,
                      leading: widget.leadingOnTab == null
                          ? null
                          : widget.leadingOnTab![index],
                    )).toList(),
            tabActiveBorder: ZebrraUI.shouldUseBorder
                ? Border.all(color: ZebrraColours.white10)
                : null,
            tabBorder: ZebrraUI.shouldUseBorder
                ? Border.all(color: Colors.transparent)
                : null,
            selectedIndex: _index,
            onTabChange: _onDestinationSelected,
          ),
          padding: (widget.topActions?.isNotEmpty ?? false)
              ? ZebrraUI.MARGIN_DEFAULT.copyWith(top: 0.0)
              : ZebrraUI.MARGIN_DEFAULT,
        ),
        top: false,
      ),
      color: Theme.of(context).primaryColor,
    );
  }

  void _onDestinationSelected(int idx) {
    HapticFeedback.mediumImpact();
    if (idx == _index && widget.scrollControllers != null) {
      widget.scrollControllers![idx].animateToStart();
    } else if (widget.pageController != null) {
      widget.pageController!.protectedJumpToPage(idx);
    }
    if (widget.onTabChange != null) widget.onTabChange!(idx);
    setState(() => _index = idx);
  }
}
