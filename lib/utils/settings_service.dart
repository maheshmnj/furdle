import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:furdle/constants/strings.dart';
import 'package:furdle/models/models.dart';
import 'package:furdle/utils/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  ThemeMode _themeMode = ThemeMode.system;

  bool _isFurdleMode = false;

  bool get isFurdleMode => _isFurdleMode;

  set isFurdleMode(bool value) {
    _sharedPreferences.setBool(kFurdleKey, value);
    _isFurdleMode = value;
  }

  static Size _screenSize = Size.zero;

  static Size get screenSize => _screenSize;

  static set screenSize(Size value) {
    _screenSize = value;
  }

  late SharedPreferences _sharedPreferences;

  late Stats _stats;

  late bool _isAlreadyPlayed = false;

  Difficulty _difficulty = Difficulty.medium;

  Difficulty get difficulty => _difficulty;

  set difficulty(Difficulty value) {
    _difficulty = value;
    _sharedPreferences.setString(kDifficultyKey, value.name);
  }

  Stats get stats => _stats;

  bool get isAlreadyPlayed => _isAlreadyPlayed;

  set isAlreadyPlayed(bool value) {
    _isAlreadyPlayed = value;
  }

  set stats(Stats value) {
    _stats = value;
  }

  Future<ThemeMode> themeMode() async {
    return _themeMode;
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.
    _sharedPreferences.setBool(kThemeKey, theme == ThemeMode.dark);
  }

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> loadFurdle() async {
    _isFurdleMode = _sharedPreferences.getBool(kFurdleKey) ?? false;
    _stats = Stats.initialStats();
    _stats = await getStats();
    _difficulty = await getDifficulty();
    _isAlreadyPlayed = isSameDate();
  }

  bool isSameDate() {
    final now = DateTime.now();
    if (_stats.total > 0) {
      bool isSame = _stats.puzzles.last.date.isSameDate(now);
      return isSame;
    }
    return false;
  }

  Future<void> saveCurrentFurdle(Puzzle puzzle) async {
    final map = json.encode(puzzle.toJson());
    _sharedPreferences.setString(kPuzzleState, map);
  }

  Future<Puzzle> getSavedPuzzle() async {
    final String savedPuzzle = _sharedPreferences.getString(kPuzzleState) ?? '';
    if (savedPuzzle.isEmpty) {
      return Puzzle.initialize();
    }
    final decodedMap = jsonDecode(savedPuzzle) as Map<String, dynamic>;
    final puzzle = Puzzle.fromJson(decodedMap);
    return puzzle;
  }

  // we shouldn't clear Last played Puzzle anytime
  Future<void> clearSavedPuzzle() async {
    _sharedPreferences.remove(kPuzzleState);
  }

  Future<Difficulty> getDifficulty() async {
    String difficulty =
        _sharedPreferences.getString(kDifficultyKey) ?? 'medium';
    return _difficulty = difficulty.toLowerCase() == 'easy'
        ? Difficulty.easy
        : difficulty.toLowerCase() == 'medium'
            ? Difficulty.medium
            : Difficulty.hard;
  }

  Future<Stats> getStats() async {
    final savedPuzzle = await getSavedPuzzle();
    try {
      final list = _sharedPreferences.getStringList(kMatchHistoryKey) ?? [];
      _stats.puzzles = list.map((e) {
        final puzzle = Puzzle.fromJson(jsonDecode(e) as Map<String, dynamic>);
        return puzzle;
      }).toList();
      if (savedPuzzle.cells.isNotEmpty && savedPuzzle.moves > 0) {
        _stats.puzzle = savedPuzzle;
      }
      return _stats;
    } catch (_) {
      return Stats.initialStats();
    }
  }

  Future<void> configTheme() async {
    WidgetsFlutterBinding.ensureInitialized();
    _sharedPreferences = await SharedPreferences.getInstance();
    final isDark = _sharedPreferences.getBool(kThemeKey);
    _themeMode = isDark == null
        ? ThemeMode.system
        : isDark
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  /// Update stats on Game over
  Future<void> updatePuzzleStats(Puzzle puzzle) async {
    _stats.puzzles.add(puzzle);
    final puzzleMapList =
        _stats.puzzles.map((e) => json.encode(e.toJson())).toList();
    _sharedPreferences.setStringList(kMatchHistoryKey, puzzleMapList);
    _stats = await getStats();
    saveCurrentFurdle(puzzle);
  }

  Future<void> clear() async {
    _sharedPreferences.clear();
  }
}
