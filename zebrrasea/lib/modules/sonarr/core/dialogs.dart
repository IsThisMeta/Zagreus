import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrDialogs {
  Future<Tuple2<bool, SonarrGlobalSettingsType?>> globalSettings(
    BuildContext context,
  ) async {
    bool _flag = false;
    SonarrGlobalSettingsType? _value;

    void _setValues(bool flag, SonarrGlobalSettingsType value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'zebrrasea.Settings'.tr(),
      content: List.generate(
        SonarrGlobalSettingsType.values.length,
        (index) => ZebrraDialog.tile(
          text: SonarrGlobalSettingsType.values[index].name,
          icon: SonarrGlobalSettingsType.values[index].icon,
          iconColor: ZebrraColours().byListIndex(index),
          onTap: () => _setValues(true, SonarrGlobalSettingsType.values[index]),
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _value);
  }

  Future<Tuple2<bool, SonarrSeriesSettingsType?>> seriesSettings(
    BuildContext context,
    SonarrSeries series,
  ) async {
    bool _flag = false;
    SonarrSeriesSettingsType? _value;

    void _setValues(bool flag, SonarrSeriesSettingsType value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: series.title,
      content: List.generate(
        SonarrSeriesSettingsType.values.length,
        (index) => ZebrraDialog.tile(
          text: SonarrSeriesSettingsType.values[index].name(series),
          icon: SonarrSeriesSettingsType.values[index].icon(series),
          iconColor: ZebrraColours().byListIndex(index),
          onTap: () => _setValues(true, SonarrSeriesSettingsType.values[index]),
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _value);
  }

  Future<Tuple2<bool, SonarrEpisodeSettingsType?>> episodeSettings({
    required BuildContext context,
    required SonarrEpisode episode,
  }) async {
    bool _flag = false;
    SonarrEpisodeSettingsType? _value;

    void _setValues(bool flag, SonarrEpisodeSettingsType value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: episode.title,
      content: List.generate(
        episode.hasFile!
            ? SonarrEpisodeSettingsType.values.length
            : SonarrEpisodeSettingsType.values.length - 1,
        (index) => ZebrraDialog.tile(
          text: SonarrEpisodeSettingsType.values[index].name(episode),
          icon: SonarrEpisodeSettingsType.values[index].icon(episode),
          iconColor: ZebrraColours().byListIndex(index),
          onTap: () =>
              _setValues(true, SonarrEpisodeSettingsType.values[index]),
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _value);
  }

  Future<Tuple2<bool, SonarrSeasonSettingsType?>> seasonSettings(
    BuildContext context,
    int? seasonNumber,
  ) async {
    bool _flag = false;
    SonarrSeasonSettingsType? _value;

    void _setValues(bool flag, SonarrSeasonSettingsType value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: seasonNumber == 0
          ? 'sonarr.Specials'.tr()
          : 'sonarr.SeasonNumber'.tr(args: [seasonNumber.toString()]),
      content: List.generate(
        SonarrSeasonSettingsType.values.length,
        (index) => ZebrraDialog.tile(
          text: SonarrSeasonSettingsType.values[index].name,
          icon: SonarrSeasonSettingsType.values[index].icon,
          iconColor: ZebrraColours().byListIndex(index),
          onTap: () => _setValues(true, SonarrSeasonSettingsType.values[index]),
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _value);
  }

  Future<Tuple2<bool, SonarrEpisodeMultiSettingsType?>> episodeMultiSettings(
    BuildContext context,
    int episodes,
  ) async {
    bool _flag = false;
    SonarrEpisodeMultiSettingsType? _value;

    void _setValues(bool flag, SonarrEpisodeMultiSettingsType value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: episodes > 1
          ? 'sonarr.EpisodesCount'.tr(args: [episodes.toString()])
          : 'sonarr.OneEpisode'.tr(),
      content: List.generate(
        SonarrEpisodeMultiSettingsType.values.length,
        (idx) => ZebrraDialog.tile(
          text: SonarrEpisodeMultiSettingsType.values[idx].name,
          icon: SonarrEpisodeMultiSettingsType.values[idx].icon,
          iconColor: ZebrraColours().byListIndex(idx),
          onTap: () {
            _setValues(true, SonarrEpisodeMultiSettingsType.values[idx]);
          },
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

  Future<void> setAddTags(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dContext) => ChangeNotifierProvider.value(
        value: context.read<SonarrSeriesAddDetailsState>(),
        builder: (context, _) =>
            Selector<SonarrState, Future<List<SonarrTag>>?>(
          selector: (_, state) => state.tags,
          builder: (context, future, _) => FutureBuilder(
            future: future,
            builder: (context, AsyncSnapshot<List<SonarrTag>> snapshot) {
              return AlertDialog(
                actions: <Widget>[
                  const SonarrTagsAppBarActionAddTag(asDialogButton: true),
                  ZebrraDialog.button(
                    text: 'Close',
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ],
                title: ZebrraDialog.title(text: 'Tags'),
                content: Builder(
                  builder: (context) {
                    if ((snapshot.data?.length ?? 0) == 0)
                      return ZebrraDialog.content(
                        children: [
                          ZebrraDialog.textContent(text: 'No Tags Found'),
                        ],
                      );
                    return ZebrraDialog.content(
                      children: List.generate(
                        snapshot.data!.length,
                        (index) => ZebrraDialog.checkbox(
                          title: snapshot.data![index].label!,
                          value: context
                              .watch<SonarrSeriesAddDetailsState>()
                              .tags
                              .where(
                                  (tag) => tag.id == snapshot.data![index].id)
                              .isNotEmpty,
                          onChanged: (selected) {
                            List<SonarrTag> _tags = context
                                .read<SonarrSeriesAddDetailsState>()
                                .tags;
                            selected!
                                ? _tags.add(snapshot.data![index])
                                : _tags.removeWhere((tag) =>
                                    tag.id == snapshot.data![index].id);
                            context.read<SonarrSeriesAddDetailsState>().tags =
                                _tags;
                          },
                        ),
                      ),
                    );
                  },
                ),
                contentPadding: (snapshot.data?.length ?? 0) == 0
                    ? ZebrraDialog.textDialogContentPadding()
                    : ZebrraDialog.listDialogContentPadding(),
                shape: ZebrraUI.shapeBorder,
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> setEditTags(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dContext) => ChangeNotifierProvider.value(
        value: context.read<SonarrSeriesEditState>(),
        builder: (context, _) =>
            Selector<SonarrState, Future<List<SonarrTag>>?>(
          selector: (_, state) => state.tags,
          builder: (context, future, _) => FutureBuilder(
            future: future,
            builder: (context, AsyncSnapshot<List<SonarrTag>> snapshot) {
              return AlertDialog(
                actions: <Widget>[
                  const SonarrTagsAppBarActionAddTag(asDialogButton: true),
                  ZebrraDialog.button(
                    text: 'Close',
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ],
                title: ZebrraDialog.title(text: 'Tags'),
                content: Builder(
                  builder: (context) {
                    if ((snapshot.data?.length ?? 0) == 0)
                      return ZebrraDialog.content(
                        children: [
                          ZebrraDialog.textContent(text: 'No Tags Found'),
                        ],
                      );
                    return ZebrraDialog.content(
                      children: List.generate(
                        snapshot.data!.length,
                        (index) => ZebrraDialog.checkbox(
                          title: snapshot.data![index].label!,
                          value: context
                              .watch<SonarrSeriesEditState>()
                              .tags
                              ?.where((t) => t.id == snapshot.data![index].id)
                              .isNotEmpty,
                          onChanged: (selected) {
                            List<SonarrTag> _tags =
                                context.read<SonarrSeriesEditState>().tags!;
                            selected!
                                ? _tags.add(snapshot.data![index])
                                : _tags.removeWhere((tag) =>
                                    tag.id == snapshot.data![index].id);
                            context.read<SonarrSeriesEditState>().tags = _tags;
                          },
                        ),
                      ),
                    );
                  },
                ),
                contentPadding: (snapshot.data?.length ?? 0) == 0
                    ? ZebrraDialog.textDialogContentPadding()
                    : ZebrraDialog.listDialogContentPadding(),
                shape: ZebrraUI.shapeBorder,
              );
            },
          ),
        ),
      ),
    );
  }

  Future<Tuple2<bool, String>> addNewTag(BuildContext context) async {
    bool _flag = false;
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController();

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Add Tag',
      buttons: [
        ZebrraDialog.button(
          text: 'Add',
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        Form(
          key: _formKey,
          child: ZebrraDialog.textFormInput(
            controller: _textController,
            title: 'Tag Label',
            onSubmitted: (_) => _setValues(true),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Label cannot be empty';
              return null;
            },
          ),
        ),
      ],
      contentPadding: ZebrraDialog.inputDialogContentPadding(),
    );
    return Tuple2(_flag, _textController.text);
  }

  Future<bool> searchAllMissingEpisodes(
    BuildContext context,
  ) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'sonarr.MissingEpisodes'.tr(),
      buttons: [
        ZebrraDialog.button(
          text: 'sonarr.Search'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZebrraDialog.textContent(
          text: 'sonarr.MissingEpisodesHint1'.tr(),
        ),
      ],
      contentPadding: ZebrraDialog.textDialogContentPadding(),
    );
    return _flag;
  }

  Future<bool> deleteTag(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Delete Tag',
      buttons: [
        ZebrraDialog.button(
          text: 'Delete',
          textColor: ZebrraColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZebrraDialog.textContent(
            text: 'Are you sure you want to delete this tag?'),
      ],
      contentPadding: ZebrraDialog.textDialogContentPadding(),
    );
    return _flag;
  }

  Future<Tuple2<bool, SonarrLanguageProfile?>> editLanguageProfiles(
      BuildContext context, List<SonarrLanguageProfile?> profiles) async {
    bool _flag = false;
    SonarrLanguageProfile? profile;

    void _setValues(bool flag, SonarrLanguageProfile? value) {
      _flag = flag;
      profile = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Language Profile',
      content: List.generate(
        profiles.length,
        (index) => ZebrraDialog.tile(
          text: profiles[index]!.name!,
          icon: Icons.portrait_rounded,
          iconColor: ZebrraColours().byListIndex(index),
          onTap: () => _setValues(true, profiles[index]),
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, profile);
  }

  Future<Tuple2<bool, SonarrQualityProfile?>> editQualityProfile(
      BuildContext context, List<SonarrQualityProfile?> profiles) async {
    bool _flag = false;
    SonarrQualityProfile? profile;

    void _setValues(bool flag, SonarrQualityProfile? value) {
      _flag = flag;
      profile = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Quality Profile',
      content: List.generate(
        profiles.length,
        (index) => ZebrraDialog.tile(
          text: profiles[index]!.name!,
          icon: Icons.portrait_rounded,
          iconColor: ZebrraColours().byListIndex(index),
          onTap: () => _setValues(true, profiles[index]),
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, profile);
  }

  Future<Tuple2<bool, SonarrRootFolder?>> editRootFolder(
      BuildContext context, List<SonarrRootFolder> folders) async {
    bool _flag = false;
    SonarrRootFolder? _folder;

    void _setValues(bool flag, SonarrRootFolder value) {
      _flag = flag;
      _folder = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Root Folder',
      content: List.generate(
        folders.length,
        (index) => ZebrraDialog.tile(
          text: folders[index].path!,
          subtitle: ZebrraDialog.richText(
            children: [
              ZebrraDialog.bolded(
                text: folders[index].freeSpace.asBytes(),
                fontSize: ZebrraDialog.BUTTON_SIZE,
              ),
            ],
          ) as RichText?,
          icon: Icons.folder_rounded,
          iconColor: ZebrraColours().byListIndex(index),
          onTap: () => _setValues(true, folders[index]),
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _folder);
  }

  Future<Tuple2<bool, SonarrSeriesMonitorType?>> editMonitorType(
      BuildContext context) async {
    bool _flag = false;
    SonarrSeriesMonitorType? _type;

    void _setValues(bool flag, SonarrSeriesMonitorType type) {
      _flag = flag;
      _type = type;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Monitoring Options',
      content: List.generate(
        SonarrSeriesMonitorType.values.length,
        (index) => ZebrraDialog.tile(
          text: SonarrSeriesMonitorType.values[index].zebrraName,
          icon: Icons.view_list_rounded,
          iconColor: ZebrraColours().byListIndex(index),
          onTap: () => _setValues(true, SonarrSeriesMonitorType.values[index]),
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _type);
  }

  Future<Tuple2<bool, SonarrSeriesType?>> editSeriesType(
      BuildContext context) async {
    bool _flag = false;
    SonarrSeriesType? _type;

    void _setValues(bool flag, SonarrSeriesType type) {
      _flag = flag;
      _type = type;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Series Type',
      content: List.generate(
        SonarrSeriesType.values.length,
        (index) => ZebrraDialog.tile(
          text: SonarrSeriesType.values[index].value!.toTitleCase(),
          icon: Icons.folder_open_rounded,
          iconColor: ZebrraColours().byListIndex(index),
          onTap: () => _setValues(true, SonarrSeriesType.values[index]),
        ),
      ),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _type);
  }

  Future<bool> removeSeries(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'sonarr.RemoveSeries'.tr(),
      buttons: [
        ZebrraDialog.button(
          text: 'zebrrasea.Remove'.tr(),
          textColor: ZebrraColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        SonarrDatabase.REMOVE_SERIES_EXCLUSION_LIST.listenableBuilder(
          builder: (context, _) => ZebrraDialog.checkbox(
            title: 'sonarr.AddToExclusionList'.tr(),
            value: SonarrDatabase.REMOVE_SERIES_EXCLUSION_LIST.read(),
            onChanged: (value) =>
                SonarrDatabase.REMOVE_SERIES_EXCLUSION_LIST.update(value!),
          ),
        ),
        SonarrDatabase.REMOVE_SERIES_DELETE_FILES.listenableBuilder(
          builder: (context, _) => ZebrraDialog.checkbox(
            title: 'sonarr.DeleteFiles'.tr(),
            value: SonarrDatabase.REMOVE_SERIES_DELETE_FILES.read(),
            onChanged: (value) =>
                SonarrDatabase.REMOVE_SERIES_DELETE_FILES.update(value!),
          ),
        ),
      ],
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
    return _flag;
  }

  Future<void> addSeriesOptions(BuildContext context) async {
    await ZebrraDialog.dialog(
      context: context,
      title: 'zebrrasea.Options'.tr(),
      buttons: [
        ZebrraDialog.button(
          text: 'zebrrasea.Close'.tr(),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ],
      showCancelButton: false,
      content: [
        SonarrDatabase.ADD_SERIES_SEARCH_FOR_MISSING.listenableBuilder(
          builder: (context, _) => ZebrraDialog.checkbox(
            title: 'sonarr.StartSearchForMissingEpisodes'.tr(),
            value: SonarrDatabase.ADD_SERIES_SEARCH_FOR_MISSING.read(),
            onChanged: (value) =>
                SonarrDatabase.ADD_SERIES_SEARCH_FOR_MISSING.update(value!),
          ),
        ),
        SonarrDatabase.ADD_SERIES_SEARCH_FOR_CUTOFF_UNMET.listenableBuilder(
          builder: (context, _) => ZebrraDialog.checkbox(
            title: 'sonarr.StartSearchForCutoffUnmetEpisodes'.tr(),
            value: SonarrDatabase.ADD_SERIES_SEARCH_FOR_CUTOFF_UNMET.read(),
            onChanged: (value) => SonarrDatabase
                .ADD_SERIES_SEARCH_FOR_CUTOFF_UNMET
                .update(value!),
          ),
        ),
      ],
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
  }

  Future<bool> deleteEpisode(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'sonarr.DeleteEpisodeFile'.tr(),
      buttons: [
        ZebrraDialog.button(
          text: 'zebrrasea.Delete'.tr(),
          textColor: ZebrraColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZebrraDialog.textContent(text: 'sonarr.DeleteEpisodeFileHint1'.tr()),
      ],
      contentPadding: ZebrraDialog.textDialogContentPadding(),
    );
    return _flag;
  }

  Future<bool> confirmSeasonSearch(
    BuildContext context,
    int seasonNumber,
  ) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Season Search',
      buttons: [
        ZebrraDialog.button(
          text: 'Search',
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZebrraDialog.textContent(
          text: seasonNumber == 0
              ? 'Search for all episodes in specials?'
              : 'Search for all episodes in season $seasonNumber?',
        ),
      ],
      contentPadding: ZebrraDialog.textDialogContentPadding(),
    );
    return _flag;
  }

  Future<bool> removeFromQueue(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'sonarr.RemoveFromQueue'.tr(),
      buttons: [
        ZebrraDialog.button(
          text: 'zebrrasea.Remove'.tr(),
          textColor: ZebrraColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        SonarrDatabase.QUEUE_REMOVE_DOWNLOAD_CLIENT.listenableBuilder(
          builder: (context, _) => ZebrraDialog.checkbox(
            title: 'sonarr.RemoveFromDownloadClient'.tr(),
            value: SonarrDatabase.QUEUE_REMOVE_DOWNLOAD_CLIENT.read(),
            onChanged: (value) =>
                SonarrDatabase.QUEUE_REMOVE_DOWNLOAD_CLIENT.update(value!),
          ),
        ),
        SonarrDatabase.QUEUE_ADD_BLOCKLIST.listenableBuilder(
          builder: (context, _) => ZebrraDialog.checkbox(
            title: 'sonarr.AddReleaseToBlocklist'.tr(),
            value: SonarrDatabase.QUEUE_ADD_BLOCKLIST.read(),
            onChanged: (value) =>
                SonarrDatabase.QUEUE_ADD_BLOCKLIST.update(value!),
          ),
        ),
      ],
      contentPadding: ZebrraDialog.listDialogContentPadding(),
    );
    return _flag;
  }

  Future<void> showQueueStatusMessages(
    BuildContext context,
    List<SonarrQueueStatusMessage> messages,
  ) async {
    if (messages.isEmpty) {
      return ZebrraDialogs().textPreview(
        context,
        'sonarr.Messages'.tr(),
        'sonarr.NoMessagesFound'.tr(),
      );
    }
    await ZebrraDialog.dialog(
      context: context,
      title: 'sonarr.Messages'.tr(),
      cancelButtonText: 'zebrrasea.Close'.tr(),
      contentPadding: ZebrraDialog.listDialogContentPadding(),
      content: List.generate(
        messages.length,
        (index) => Padding(
          padding: ZebrraDialog.tileContentPadding(),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(right: 32.0),
                    child: Icon(
                      ZebrraIcons.WARNING,
                      color: ZebrraColours.orange,
                      size: 24.0,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      messages[index].title!,
                      style: const TextStyle(
                        fontSize: ZebrraDialog.BODY_SIZE,
                        color: ZebrraColours.orange,
                        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: ZebrraUI.DEFAULT_MARGIN_SIZE / 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (messages[index].messages!.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 32.0 + ZebrraUI.ICON_SIZE,
                              ),
                              child: ZebrraDialog.richText(
                                children: [
                                  TextSpan(
                                    text: messages[index]
                                        .messages!
                                        .map((s) => '${ZebrraUI.TEXT_BULLET} $s')
                                        .join('\n'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Tuple2<bool, int>> setQueuePageSize(BuildContext context) async {
    bool _flag = false;
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController _textController = TextEditingController(
      text: SonarrDatabase.QUEUE_PAGE_SIZE.read().toString(),
    );

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await ZebrraDialog.dialog(
      context: context,
      title: 'Queue Size',
      buttons: [
        ZebrraDialog.button(
          text: 'Set',
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZebrraDialog.textContent(
            text: 'Set the amount of items fetched for the queue.'),
        Form(
          key: _formKey,
          child: ZebrraDialog.textFormInput(
            controller: _textController,
            title: 'Queue Page Size',
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

    return Tuple2(_flag, int.tryParse(_textController.text) ?? 50);
  }
}
