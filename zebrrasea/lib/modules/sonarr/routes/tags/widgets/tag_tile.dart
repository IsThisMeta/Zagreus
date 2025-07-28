import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrTagsTagTile extends StatefulWidget {
  final SonarrTag tag;

  const SonarrTagsTagTile({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  State<SonarrTagsTagTile> createState() => _State();
}

class _State extends State<SonarrTagsTagTile> with ZebrraLoadCallbackMixin {
  List<String?>? seriesList;

  @override
  Future<void> loadCallback() async {
    await context.read<SonarrState>().series!.then((series) {
      List<String?> _series = [];
      series.values.forEach((element) {
        if (element.tags!.contains(widget.tag.id)) _series.add(element.title);
      });
      _series.sort();
      if (mounted)
        setState(() {
          seriesList = _series;
        });
    }).catchError((error) {
      if (mounted)
        setState(() {
          seriesList = null;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: widget.tag.label,
      body: [TextSpan(text: subtitle())],
      trailing: (seriesList?.isNotEmpty ?? true)
          ? null
          : ZebrraIconButton(
              icon: ZebrraIcons.DELETE,
              color: ZebrraColours.red,
              onPressed: _handleDelete,
            ),
      onTap: _handleInfo,
    );
  }

  String subtitle() {
    if (seriesList == null) return 'Loading...';
    if (seriesList!.isEmpty) return 'No Series';
    return '${seriesList!.length} Series';
  }

  Future<void> _handleInfo() async {
    return ZebrraDialogs().textPreview(
      context,
      'Series List',
      (seriesList?.isEmpty ?? true) ? 'No Series' : seriesList!.join('\n'),
    );
  }

  Future<void> _handleDelete() async {
    if (seriesList?.isNotEmpty ?? true) {
      showZebrraErrorSnackBar(
        title: 'Cannot Delete Tag',
        message: 'The tag must not be attached to any series',
      );
    } else {
      bool result = await SonarrDialogs().deleteTag(context);
      if (result)
        context
            .read<SonarrState>()
            .api!
            .tag
            .delete(id: widget.tag.id!)
            .then((_) {
          showZebrraSuccessSnackBar(
            title: 'Deleted Tag',
            message: widget.tag.label,
          );
          context.read<SonarrState>().fetchTags();
        }).catchError((error, stack) {
          ZebrraLogger().error(
            'Failed to delete tag: ${widget.tag.id}',
            error,
            stack,
          );
          showZebrraErrorSnackBar(
            title: 'Failed to Delete Tag',
            error: error,
          );
        });
    }
  }
}
