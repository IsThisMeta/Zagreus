import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:shimmer/shimmer.dart';

class ZebrraShimmer extends StatelessWidget {
  final Widget child;

  const ZebrraShimmer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: child,
      baseColor: Theme.of(context).primaryColor,
      highlightColor: ZebrraColours.accent,
    );
  }
}
