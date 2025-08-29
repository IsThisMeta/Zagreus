import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/settings/routes/account/widgets/change_email_tile.dart';
import 'package:zagreus/modules/settings/routes/account/widgets/change_password_tile.dart';
import 'package:zagreus/modules/settings/routes/account/widgets/delete_account_tile.dart';

class AccountSettingsRoute extends StatefulWidget {
  const AccountSettingsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<AccountSettingsRoute> createState() => _State();
}

class _State extends State<AccountSettingsRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'settings.AccountSettings'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: const [
        ChangeEmailTile(),
        ChangePasswordTile(),
        DeleteAccountTile(),
      ],
    );
  }
}
