import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';

class ZebrraNavigationBarBadge extends badges.Badge {
  ZebrraNavigationBarBadge({
    Key? key,
    required String text,
    required IconData icon,
    required bool showBadge,
    required bool isActive,
  }) : super(
          key: key,
          badgeStyle: badges.BadgeStyle(
            badgeColor: ZebrraColours.accent.dimmed(),
            elevation: ZebrraUI.ELEVATION,
            shape: badges.BadgeShape.circle,
          ),
          badgeAnimation: const badges.BadgeAnimation.scale(
            animationDuration:
                Duration(milliseconds: ZebrraUI.ANIMATION_SPEED_SCROLLING),
          ),
          position: badges.BadgePosition.topEnd(
            top: -ZebrraUI.DEFAULT_MARGIN_SIZE,
            end: -ZebrraUI.DEFAULT_MARGIN_SIZE,
          ),
          badgeContent: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
          child: Icon(
            icon,
            color: isActive ? ZebrraColours.accent : Colors.white,
          ),
          showBadge: showBadge,
        );
}
