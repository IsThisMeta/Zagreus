import 'package:flutter/material.dart';
import 'package:zebrrasea/database/tables/dashboard.dart';

import 'package:zebrrasea/widgets/ui.dart';
import 'package:zebrrasea/vendor.dart';
import 'package:zebrrasea/modules/dashboard/routes/dashboard/widgets/navigation_bar.dart';

class DashboardDialogs {
  Future<Tuple2<bool, int>> defaultPage(BuildContext context) async {
    bool _flag = false;
    int _index = 0;

    void _setValues(bool flag, int index) {
      _flag = flag;
      _index = index;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'zebrrasea.Page'.tr(),
      content: List.generate(
        HomeNavigationBar.titles.length,
        (index) => ZebrraDialog.tile(
          text: HomeNavigationBar.titles[index],
          icon: HomeNavigationBar.icons[index],
          iconColor: ZebrraColours().byListIndex(index),
          onTap: () => _setValues(true, index),
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );

    return Tuple2(_flag, _index);
  }

  Future<Tuple2<bool, int>> setPastDays(BuildContext context) async {
    bool _flag = false;
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController _textController = TextEditingController(
      text: DashboardDatabase.CALENDAR_DAYS_PAST.read().toString(),
    );

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'dashboard.PastDays'.tr(),
      buttons: [
        ZebrraDialog.button(
          text: 'zebrrasea.Set'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZebrraDialog.textContent(
          text: 'dashboard.PastDaysDescription'.tr(),
        ),
        Form(
          key: _formKey,
          child: ZebrraDialog.textFormInput(
            controller: _textController,
            title: 'dashboard.PastDays'.tr(),
            onSubmitted: (_) => _setValues(true),
            validator: (value) {
              int? _value = int.tryParse(value!);
              if (_value != null && _value >= 1) return null;
              return 'dashboard.MinimumOfOneDay'.tr();
            },
            keyboardType: TextInputType.number,
          ),
        ),
      ],
      contentPadding: ZebrraDialog.inputTextDialogContentPadding(),
    );

    return Tuple2(_flag, int.tryParse(_textController.text) ?? 14);
  }

  Future<Tuple2<bool, int>> setFutureDays(BuildContext context) async {
    bool _flag = false;
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController _textController = TextEditingController(
      text: DashboardDatabase.CALENDAR_DAYS_FUTURE.read().toString(),
    );

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'dashboard.FutureDays'.tr(),
      buttons: [
        ZebrraDialog.button(
          text: 'zebrrasea.Set'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZebrraDialog.textContent(
          text: 'dashboard.FutureDaysDescription'.tr(),
        ),
        Form(
          key: _formKey,
          child: ZebrraDialog.textFormInput(
            controller: _textController,
            title: 'dashboard.FutureDays'.tr(),
            onSubmitted: (_) => _setValues(true),
            validator: (value) {
              int? _value = int.tryParse(value!);
              if (_value != null && _value >= 1) return null;
              return 'dashboard.MinimumOfOneDay'.tr();
            },
            keyboardType: TextInputType.number,
          ),
        ),
      ],
      contentPadding: ZebrraDialog.inputTextDialogContentPadding(),
    );

    return Tuple2(_flag, int.tryParse(_textController.text) ?? 14);
  }
}
