import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  static final AppSettingsController _instance =
      AppSettingsController._internal();
  factory AppSettingsController() => _instance;

  AppSettingsController._internal() {
    _loadSettings();
  }

  String _timeFormat = '24hr'; // '12hr' or '24hr'
  String _weightUnit = 'Kg'; // 'Kg' or 'Lbs'
  String _heightUnit = 'Cm'; // 'Cm' or 'Ft'

  String get timeFormat => _timeFormat;
  String get weightUnit => _weightUnit;
  String get heightUnit => _heightUnit;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _timeFormat = prefs.getString('timeFormat') ?? '24hr';
    _weightUnit = prefs.getString('weightUnit') ?? 'Kg';
    _heightUnit = prefs.getString('heightUnit') ?? 'Cm';
    notifyListeners();
  }

  Future<void> setTimeFormat(String format) async {
    _timeFormat = format;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('timeFormat', format);
    notifyListeners();
  }

  Future<void> setWeightUnit(String unit) async {
    _weightUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weightUnit', unit);
    notifyListeners();
  }

  Future<void> setHeightUnit(String unit) async {
    _heightUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('heightUnit', unit);
    notifyListeners();
  }

  // Formatting utilities
  String formatTime(String timeString) {
    try {
      String timePart = timeString.contains('*')
          ? timeString.split('*').last.trim()
          : timeString;
      DateTime dateTime = (timePart.contains('AM') || timePart.contains('PM'))
          ? DateFormat("hh:mm a").parse(timePart)
          : DateFormat("HH:mm").parse(timePart);

      return _timeFormat == '12hr'
          ? DateFormat("hh:mm a").format(dateTime)
          : DateFormat("HH:mm").format(dateTime);
    } catch (e) {
      return timeString;
    }
  }

  String formatWeight(String weightInKg) {
    try {
      double weight = double.parse(weightInKg);
      return _weightUnit == 'Lbs'
          ? (weight * 2.20462).toStringAsFixed(1)
          : weightInKg;
    } catch (e) {
      return weightInKg;
    }
  }

  String formatHeight(String heightInCm) {
    try {
      double height = double.parse(heightInCm);
      if (_heightUnit == 'Ft') {
        double totalInches = height / 2.54;
        return "${(totalInches / 12).floor()}' ${(totalInches % 12).round()}\"";
      }
      return heightInCm;
    } catch (e) {
      return heightInCm;
    }
  }
}
