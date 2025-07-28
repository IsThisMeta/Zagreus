import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrManualImportDetailsState extends ChangeNotifier {
  final String path;

  RadarrManualImportDetailsState(
    BuildContext context, {
    required this.path,
  }) {
    fetchManualImport(context);
  }

  bool canExecuteAction = false;
  ZebrraLoadingState _loadingState = ZebrraLoadingState.INACTIVE;
  ZebrraLoadingState get loadingState => _loadingState;
  set loadingState(ZebrraLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  Future<List<RadarrManualImport>>? _manualImport;
  Future<List<RadarrManualImport>>? get manualImport => _manualImport;
  Future<void> fetchManualImport(BuildContext context) async {
    if (context.read<RadarrState>().enabled)
      _manualImport = context.read<RadarrState>().api!.manualImport.get(
            folder: path,
            filterExistingFiles: true,
          );
    notifyListeners();
  }

  List<int> _selectedFiles = [];
  List<int> get selectedFiles => _selectedFiles;
  set selectedFiles(List<int> selectedFiles) {
    _selectedFiles = selectedFiles;
    notifyListeners();
  }

  void addSelectedFile(int id) {
    if (_selectedFiles.contains(id)) return;
    _selectedFiles.add(id);
    notifyListeners();
  }

  void removeSelectedFile(int id) {
    if (!_selectedFiles.contains(id)) return;
    _selectedFiles.remove(id);
    notifyListeners();
  }

  void toggleSelectedFile(int id) {
    _selectedFiles.contains(id) ? removeSelectedFile(id) : addSelectedFile(id);
  }

  void setSelectedFile(int id, bool state) {
    if (!_selectedFiles.contains(id) && state) addSelectedFile(id);
    if (_selectedFiles.contains(id) && !state) removeSelectedFile(id);
  }
}
