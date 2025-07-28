import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zebrrasea/core.dart';

class ZebrraDialogs {
  /// Show an an edit text prompt.
  ///
  /// Can pass in [prefill] String to prefill the [TextFormField]. Can also pass in a list of [TextSpan] tp show text above the field.
  ///
  /// Returns list containing:
  /// - 0: Flag (true if they hit save, false if they cancelled the prompt)
  /// - 1: Value from the [TextEditingController].
  Future<Tuple2<bool, String>> editText(
      BuildContext context, String dialogTitle,
      {String prefill = '', List<TextSpan>? extraText}) async {
    bool _flag = false;
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController()..text = prefill;

    void _setValues(bool flag) {
      if (_formKey.currentState?.validate() ?? false) {
        _flag = flag;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await ZebrraDialog.dialog(
      context: context,
      title: dialogTitle,
      buttons: [
        ZebrraDialog.button(
          text: 'Save',
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        if (extraText?.isNotEmpty ?? false)
          ZebrraDialog.richText(children: extraText),
        Form(
          key: _formKey,
          child: ZebrraDialog.textFormInput(
            controller: _textController,
            title: dialogTitle,
            onSubmitted: (_) => _setValues(true),
            validator: (_) => null,
          ),
        ),
      ],
      contentPadding: (extraText?.length ?? 0) == 0
          ? ZebrraDialog.inputDialogContentPadding()
          : ZebrraDialog.inputTextDialogContentPadding(),
    );
    return Tuple2(_flag, _textController.text);
  }

  /// Show a text preview dialog.
  ///
  /// Can pass in boolean [alignLeft] to left align the text in the dialog (useful for bulleted lists)
  Future<void> textPreview(
      BuildContext context, String? dialogTitle, String text,
      {bool alignLeft = false}) async {
    await ZebrraDialog.dialog(
      context: context,
      title: dialogTitle,
      cancelButtonText: 'Close',
      buttons: [
        ZebrraDialog.button(
            text: 'Copy',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              showZebrraSuccessSnackBar(
                  title: 'Copied Content',
                  message: 'Copied text to the clipboard');
              Navigator.of(context, rootNavigator: true).pop();
            }),
      ],
      content: [
        ZebrraDialog.textContent(text: text),
      ],
      contentPadding: ZebrraDialog.textDialogContentPadding(),
    );
  }

  Future<void> showRejections(
      BuildContext context, List<String> rejections) async {
    if (rejections.isEmpty)
      return textPreview(
        context,
        'Rejection Reasons',
        'No rejections found',
      );

    await ZebrraDialog.dialog(
      context: context,
      title: 'Rejection Reasons',
      cancelButtonText: 'Close',
      content: List.generate(
        rejections.length,
        (index) => ZebrraDialog.tile(
          text: rejections[index],
          icon: Icons.report_outlined,
          iconColor: ZebrraColours.red,
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
  }

  Future<void> showMessages(BuildContext context, List<String> messages) async {
    if (messages.isEmpty) {
      return textPreview(context, 'Messages', 'No messages found');
    }
    await ZebrraDialog.dialog(
      context: context,
      title: 'Messages',
      cancelButtonText: 'Close',
      content: List.generate(
        messages.length,
        (index) => ZebrraDialog.tile(
          text: messages[index],
          icon: Icons.info_outline_rounded,
          iconColor: ZebrraColours.accent,
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
  }

  /// **Will be removed in future**
  ///
  /// Show a delete catalogue with all files warning dialog.
  Future<List<dynamic>> deleteCatalogueWithFiles(
      BuildContext context, String moduleTitle) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Delete All Files',
      buttons: [
        ZebrraDialog.button(
          text: 'Delete',
          textColor: ZebrraColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZebrraDialog.textContent(
            text:
                'Are you sure you want to delete all the files and folders for $moduleTitle?'),
      ],
      contentPadding: ZebrraDialog.textDialogContentPadding(),
    );
    return [_flag];
  }

  Future<ZebrraModule?> selectDownloadClient() async {
    final profile = ZebrraProfile.current;
    final context = ZebrraState.context;
    ZebrraModule? module;

    await ZebrraDialog.dialog(
      context: context,
      title: 'zebrrasea.DownloadClient'.tr(),
      content: [
        if (profile.nzbgetEnabled)
          ZebrraDialog.tile(
            text: ZebrraModule.NZBGET.title,
            icon: ZebrraModule.NZBGET.icon,
            iconColor: ZebrraModule.NZBGET.color,
            onTap: () {
              module = ZebrraModule.NZBGET;
              Navigator.of(context).pop();
            },
          ),
        if (profile.sabnzbdEnabled)
          ZebrraDialog.tile(
            text: ZebrraModule.SABNZBD.title,
            icon: ZebrraModule.SABNZBD.icon,
            iconColor: ZebrraModule.SABNZBD.color,
            onTap: () {
              module = ZebrraModule.SABNZBD;
              Navigator.of(context).pop();
            },
          ),
      ],
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );

    return module;
  }
}
