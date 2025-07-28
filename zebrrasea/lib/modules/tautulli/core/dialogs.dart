import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliDialogs {
  Future<Tuple2<bool, TautulliGlobalSettingsType?>> globalSettings(
      BuildContext context) async {
    bool _flag = false;
    TautulliGlobalSettingsType? _value;

    void _setValues(bool flag, TautulliGlobalSettingsType value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'zebrrasea.Settings'.tr(),
      content: List.generate(
        TautulliGlobalSettingsType.values.length,
        (index) => ZebrraDialog.tile(
          text: TautulliGlobalSettingsType.values[index].name,
          icon: TautulliGlobalSettingsType.values[index].icon,
          iconColor: ZebrraColours().byListIndex(index),
          onTap: () =>
              _setValues(true, TautulliGlobalSettingsType.values[index]),
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _value);
  }

  static Future<List<dynamic>> setDefaultPage(
    BuildContext context, {
    required List<String> titles,
    required List<IconData> icons,
  }) async {
    bool _flag = false;
    int _index = 0;

    void _setValues(bool flag, int index) {
      _flag = flag;
      _index = index;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Page',
      content: List.generate(
        titles.length,
        (index) => ZebrraDialog.tile(
          text: titles[index],
          icon: icons[index],
          iconColor: ZebrraColours().byListIndex(index),
          onTap: () => _setValues(true, index),
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );

    return [_flag, _index];
  }

  Future<Tuple2<bool, String>> terminateSession(BuildContext context) async {
    bool _flag = false;
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController _textController = TextEditingController(
        text: TautulliDatabase.TERMINATION_MESSAGE.read());

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'tautulli.TerminateSession'.tr(),
      buttons: [
        ZebrraDialog.button(
          text: 'tautulli.Terminate'.tr(),
          textColor: ZebrraColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZebrraDialog.textContent(
            text: '${"tautulli.TerminationConfirmMessage".tr()}\n'),
        ZebrraDialog.textContent(text: 'tautulli.TerminationAttachMessage'.tr()),
        Form(
          key: _formKey,
          child: ZebrraDialog.textFormInput(
            controller: _textController,
            title: 'tautulli.TerminationMessage'.tr(),
            onSubmitted: (_) => _setValues(true),
            validator: (_) => null,
          ),
        ),
      ],
      contentPadding: ZebrraDialog.inputTextDialogContentPadding(),
    );

    return Tuple2(_flag, _textController.text);
  }

  static Future<List<dynamic>> setRefreshRate(BuildContext context) async {
    bool _flag = false;
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController _textController = TextEditingController(
        text: TautulliDatabase.REFRESH_RATE.read().toString());

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Refresh Rate',
      buttons: [
        ZebrraDialog.button(
          text: 'Set',
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZebrraDialog.textContent(
            text:
                'Set the rate at which the activity information will refresh at in seconds.'),
        Form(
          key: _formKey,
          child: ZebrraDialog.textFormInput(
            controller: _textController,
            title: 'Refresh Rate',
            onSubmitted: (_) => _setValues(true),
            validator: (value) {
              int? _value = int.tryParse(value!);
              if (_value != null && _value >= 1) return null;
              return 'Minimum of 1 Second';
            },
            keyboardType: TextInputType.number,
          ),
        ),
      ],
      contentPadding: ZebrraDialog.inputTextDialogContentPadding(),
    );

    return [_flag, int.tryParse(_textController.text) ?? 10];
  }

  static Future<List<dynamic>> setStatisticsItemCount(
      BuildContext context) async {
    bool _flag = false;
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController _textController = TextEditingController(
        text: TautulliDatabase.STATISTICS_STATS_COUNT.read().toString());

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Statistics Item Count',
      buttons: [
        ZebrraDialog.button(
          text: 'Set',
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZebrraDialog.textContent(
            text:
                'Set the amount of items fetched for each category in the statistics.'),
        Form(
          key: _formKey,
          child: ZebrraDialog.textFormInput(
            controller: _textController,
            title: 'Item Count',
            onSubmitted: (_) => _setValues(true),
            validator: (value) {
              int? _value = int.tryParse(value!);
              if (_value != null && _value >= 1) return null;
              return 'Minimum of 1 Item';
            },
            keyboardType: TextInputType.number,
          ),
        ),
      ],
      contentPadding: ZebrraDialog.inputTextDialogContentPadding(),
    );

    return [_flag, int.tryParse(_textController.text) ?? 3];
  }

  static Future<Tuple2<bool, String>> setTerminationMessage(
      BuildContext context) async {
    bool _flag = false;
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController _textController = TextEditingController(
        text: TautulliDatabase.TERMINATION_MESSAGE.read());

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Termination Message',
      buttons: [
        ZebrraDialog.button(
          text: 'Set',
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZebrraDialog.textContent(
            text: 'Set a default, prefilled message for terminating sessions.'),
        Form(
          key: _formKey,
          child: ZebrraDialog.textFormInput(
            controller: _textController,
            title: 'Termination Message',
            onSubmitted: (_) => _setValues(true),
            validator: (value) => null,
          ),
        ),
      ],
      contentPadding: ZebrraDialog.inputTextDialogContentPadding(),
    );

    return Tuple2(_flag, _textController.text);
  }
}
