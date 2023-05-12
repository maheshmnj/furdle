import 'package:flutter/material.dart';
import 'package:furdle/extensions.dart';
import 'package:furdle/models/models.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../service/settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController extends ChangeNotifier {
  SettingsController() {
    loadSettings();
  }

  // Make SettingsService a private variable so it is not used directly.
  SettingsService? _settingsService;
  late Settings _settings;


  String _version = '';

  String get version => _version;

  set version(String value) {
    _version = value;
    notifyListeners();
  }

  bool isSameDate() {
    final now = DateTime.now();
    if (_settings.stats.total > 0) {
      bool isSame = _settings.stats.puzzles.last.date!.isSameDate(now);
      return isSame;
    }
    return false;
  }

  Stats get stats => _settings.stats;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  ThemeMode? _themeMode;

  Difficulty get difficulty => _settings.difficulty;

  set difficulty(Difficulty value) {
    _settings.difficulty = value;
    notifyListeners();
  }

  bool get isFurdleMode => _settingsService!.isFurdleMode;

  set isFurdleMode(bool value) {
    _settingsService!.isFurdleMode = value;
    notifyListeners();
  }

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode? get themeMode => _themeMode;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  ///
  Future<void> loadSettings() async {
    _settingsService = SettingsService();
    await _settingsService!.init();
    _settings = Settings.initialize();
    _themeMode = await getTheme();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  Future<ThemeMode> getTheme() async {
    return _settingsService!.getTheme();
  }

  Future<Difficulty> getDifficulty() async {
    return _settingsService!.getDifficulty();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    // Dot not perform any work if null or new and old ThemeMode are identical
    if (newThemeMode == null || (newThemeMode == _themeMode)) return;

    // Otherwise, store the new theme mode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService!.setTheme(newThemeMode);
  }

  /// Update stats on Game over
  Future<void> addPuzzleToStats(Puzzle puzzle) async {
    _settings.stats.puzzles.add(puzzle);
    updateStats();
  }

  Future<Stats> getStats() async {
    Stats _stats = await _settingsService!.getStats();
    _settings.stats = _stats;
    return _stats;
  }

  Future<void> updateStats() async {
    await _settingsService!.updateStats(stats);
  }

  Future<void> clear() async {
    _settingsService!.clear();
  }
}
