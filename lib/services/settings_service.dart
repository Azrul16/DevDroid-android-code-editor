import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/project_model.dart';

class SettingsService {
  static const _recentProjectsKey = 'recent_projects';
  static const _fontFamilyKey = 'editor_font_family';
  static const _fontSizeKey = 'editor_font_size';
  static const _tabSizeKey = 'editor_tab_size';
  static const _pinLineNumbersKey = 'editor_pin_line_numbers';
  static const _deleteEmptyLineFastKey = 'editor_delete_empty_line_fast';
  static const _deleteMultipleSpacesKey = 'editor_delete_multiple_spaces';
  static const _symbolPairAutocompleteKey = 'editor_symbol_pair_autocomplete';
  static const _lookFeelDynamicColorKey = 'look_feel_dynamic_color';

  Future<List<ProjectModel>> loadRecentProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_recentProjectsKey) ?? const [];

    return rawList.map((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return ProjectModel(
        name: map['name'] as String,
        path: map['path'] as String,
      );
    }).toList();
  }

  Future<void> saveRecentProjects(List<ProjectModel> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = projects.map((project) {
      return jsonEncode({'name': project.name, 'path': project.path});
    }).toList();

    await prefs.setStringList(_recentProjectsKey, encoded);
  }

  Future<String> getFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fontFamilyKey) ?? 'KlyxMono';
  }

  Future<void> setFontFamily(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontFamilyKey, value);
  }

  Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 14.0;
  }

  Future<void> setFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, value);
  }

  Future<int> getTabSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tabSizeKey) ?? 4;
  }

  Future<void> setTabSize(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tabSizeKey, value);
  }

  Future<bool> getPinLineNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinLineNumbersKey) ?? false;
  }

  Future<void> setPinLineNumbers(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinLineNumbersKey, value);
  }

  Future<bool> getDeleteEmptyLineFast() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_deleteEmptyLineFastKey) ?? true;
  }

  Future<void> setDeleteEmptyLineFast(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deleteEmptyLineFastKey, value);
  }

  Future<bool> getDeleteMultipleSpaces() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_deleteMultipleSpacesKey) ?? false;
  }

  Future<void> setDeleteMultipleSpaces(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deleteMultipleSpacesKey, value);
  }

  Future<bool> getSymbolPairAutocomplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_symbolPairAutocompleteKey) ?? true;
  }

  Future<void> setSymbolPairAutocomplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_symbolPairAutocompleteKey, value);
  }

  Future<bool> getDynamicColorEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lookFeelDynamicColorKey) ?? false;
  }

  Future<void> setDynamicColorEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lookFeelDynamicColorKey, value);
  }
}
