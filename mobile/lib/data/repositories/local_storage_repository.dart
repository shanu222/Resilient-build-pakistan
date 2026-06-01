import 'package:hive_flutter/hive_flutter.dart';

/// Hive-backed offline storage for locations, projects, PDF bookmarks, downloads.
class LocalStorageRepository {
  static const _locationsBox = 'saved_locations';
  static const _projectsBox = 'saved_projects';
  static const _bookmarksBox = 'pdf_bookmarks';
  static const _downloadsBox = 'offline_downloads';
  static const _academyProgressBox = 'academy_progress';
  static const _onboardingKey = 'onboarding_complete';

  Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map>(_locationsBox),
      Hive.openBox<Map>(_projectsBox),
      Hive.openBox<String>(_bookmarksBox),
      Hive.openBox<Map>(_downloadsBox),
      Hive.openBox<int>(_academyProgressBox),
      Hive.openBox<dynamic>('settings'),
    ]);
  }

  bool get onboardingComplete =>
      Hive.box<dynamic>('settings').get(_onboardingKey, defaultValue: false)
          as bool;

  Future<void> setOnboardingComplete() async {
    await Hive.box<dynamic>('settings').put(_onboardingKey, true);
  }

  Future<void> saveLocation(Map<String, dynamic> location) async {
    final id = location['id'] as String;
    await Hive.box<Map>(_locationsBox).put(id, location);
  }

  List<Map<dynamic, dynamic>> getSavedLocations() {
    return Hive.box<Map>(_locationsBox).values.toList();
  }

  Future<void> saveProject(Map<String, dynamic> project) async {
    await Hive.box<Map>(_projectsBox).put(project['id'], project);
  }

  List<Map<dynamic, dynamic>> getProjects() {
    return Hive.box<Map>(_projectsBox).values.toList();
  }

  Future<void> togglePdfBookmark(String assetPath) async {
    final box = Hive.box<String>(_bookmarksBox);
    if (box.containsKey(assetPath)) {
      await box.delete(assetPath);
    } else {
      await box.put(assetPath, DateTime.now().toIso8601String());
    }
  }

  bool isPdfBookmarked(String assetPath) =>
      Hive.box<String>(_bookmarksBox).containsKey(assetPath);

  Set<String> get bookmarkedPdfs =>
      Hive.box<String>(_bookmarksBox).keys.cast<String>().toSet();

  Future<void> registerOfflineDownload(String key, String localPath) async {
    await Hive.box<Map>(_downloadsBox).put(key, {
      'path': localPath,
      'at': DateTime.now().toIso8601String(),
    });
  }

  String? getOfflinePath(String key) {
    final v = Hive.box<Map>(_downloadsBox).get(key);
    return v?['path'] as String?;
  }

  int getAcademyProgress(String modeId) =>
      Hive.box<int>(_academyProgressBox).get(modeId, defaultValue: 0) ?? 0;

  Future<void> setAcademyProgress(String modeId, int percent) async {
    await Hive.box<int>(_academyProgressBox).put(modeId, percent);
  }
}
