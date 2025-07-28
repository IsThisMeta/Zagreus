import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/nzbget.dart';

class NZBGetQueueTile extends StatefulWidget {
  final int index;
  final NZBGetQueueData data;
  final Function refresh;
  final BuildContext queueContext;

  const NZBGetQueueTile({
    required this.data,
    required this.index,
    required this.queueContext,
    required this.refresh,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<NZBGetQueueTile> {
  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: widget.data.name,
      body: [TextSpan(text: widget.data.subtitle)],
      bottom: ZebrraLinearPercentIndicator(
        percent: min(1.0, max(0, widget.data.percentageDone / 100)),
      ),
      trailing: ZebrraReorderableListViewDragger(index: widget.index),
      onTap: _handlePopup,
    );
  }

  Future<void> _handlePopup() async {
    _Helper _helper = _Helper(widget.queueContext, widget.data, widget.refresh);
    List values = await NZBGetDialogs.queueSettings(
        widget.queueContext, widget.data.name, widget.data.paused);
    if (values[0])
      switch (values[1]) {
        case 'status':
          widget.data.paused ? _helper._resumeJob() : _helper._pauseJob();
          break;
        case 'category':
          _helper._category();
          break;
        case 'priority':
          _helper._priority();
          break;
        case 'password':
          _helper._password();
          break;
        case 'rename':
          _helper._rename();
          break;
        case 'delete':
          _helper._delete();
          break;
        default:
          ZebrraLogger().warning('Unknown Case: ${values[1]}');
      }
  }
}

class _Helper {
  final BuildContext context;
  final NZBGetQueueData data;
  final Function refresh;

  _Helper(
    this.context,
    this.data,
    this.refresh,
  );

  Future<void> _pauseJob() async {
    await NZBGetAPI.from(ZebrraProfile.current).pauseSingleJob(data.id).then((_) {
      showZebrraSuccessSnackBar(title: 'Job Paused', message: data.name);
      refresh();
    }).catchError((error) {
      showZebrraErrorSnackBar(
        title: 'Failed to Pause Job',
        error: error,
      );
    });
  }

  Future<void> _resumeJob() async {
    await NZBGetAPI.from(ZebrraProfile.current)
        .resumeSingleJob(data.id)
        .then((_) {
      showZebrraSuccessSnackBar(title: 'Job Resumed', message: data.name);
      refresh();
    }).catchError((error) {
      showZebrraErrorSnackBar(
        title: 'Failed to Resume Job',
        error: error,
      );
    });
  }

  Future<void> _category() async {
    List<NZBGetCategoryData> categories =
        await NZBGetAPI.from(ZebrraProfile.current).getCategories();
    List values = await NZBGetDialogs.changeCategory(context, categories);
    if (values[0])
      await NZBGetAPI.from(ZebrraProfile.current)
          .setJobCategory(data.id, values[1])
          .then((_) {
        showZebrraSuccessSnackBar(
          title: values[1].name == ''
              ? 'Category Set (No Category)'
              : 'Category Set (${values[1].name})',
          message: data.name,
        );
        refresh();
      }).catchError((error) {
        showZebrraErrorSnackBar(
          title: 'Failed to Set Category',
          error: error,
        );
      });
  }

  Future<void> _priority() async {
    List values = await NZBGetDialogs.changePriority(context);
    if (values[0])
      await NZBGetAPI.from(ZebrraProfile.current)
          .setJobPriority(data.id, values[1])
          .then((_) {
        showZebrraSuccessSnackBar(
            title: 'Priority Set (${(values[1] as NZBGetPriority?).name})',
            message: data.name);
        refresh();
      }).catchError((error) {
        showZebrraErrorSnackBar(
          title: 'Failed to Set Priority',
          error: error,
        );
      });
  }

  Future<void> _rename() async {
    List values = await NZBGetDialogs.renameJob(context, data.name);
    if (values[0])
      NZBGetAPI.from(ZebrraProfile.current)
          .renameJob(data.id, values[1])
          .then((_) {
        showZebrraSuccessSnackBar(title: 'Job Renamed', message: values[1]);
        refresh();
      }).catchError((error) {
        showZebrraErrorSnackBar(
          title: 'Failed to Rename Job',
          error: error,
        );
      });
  }

  Future<void> _delete() async {
    List values = await NZBGetDialogs.deleteJob(context);
    if (values[0])
      await NZBGetAPI.from(ZebrraProfile.current).deleteJob(data.id).then((_) {
        showZebrraSuccessSnackBar(title: 'Job Deleted', message: data.name);
        refresh();
      }).catchError((error) {
        showZebrraErrorSnackBar(
          title: 'Failed to Delete Job',
          error: error,
        );
      });
  }

  Future<void> _password() async {
    List values = await NZBGetDialogs.setPassword(context);
    if (values[0])
      await NZBGetAPI.from(ZebrraProfile.current)
          .setJobPassword(data.id, values[1])
          .then((_) {
        showZebrraSuccessSnackBar(title: 'Job Password Set', message: data.name);
        refresh();
      }).catchError((error) {
        showZebrraErrorSnackBar(
          title: 'Failed to Set Job Password',
          error: error,
        );
      });
  }
}
