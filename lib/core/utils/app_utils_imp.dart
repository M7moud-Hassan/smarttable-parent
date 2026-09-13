import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/parent/data/models/parent_model.dart';
import '../../features/parent/domain/entities/login_entity.dart';
import '../conts/app_constants.dart';
import 'app_utils.dart';

class AppUtilsImp extends AppUtils {
  AppUtilsImp({required this.preferences});

  final SharedPreferences preferences;

  @override
  Future<void> setUser(ParentUser user) async {
    AppUtils.appUser = user;
    await preferences.setString(AppConstants.keyUser, jsonEncode(user.toJson()));
  }

  @override
  ParentUser? getUser() {
    final raw = preferences.getString(AppConstants.keyUser);
    if (raw == null) return null;
    // مخزَّن تالف أو نموذج تغيّر شكله لا يصحّ أن يمنع التطبيق من الفتح.
    try {
      return ParentUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      AppUtils.log('تعذّرت قراءة بيانات المستخدم المحفوظة: $e');
      return null;
    }
  }

  @override
  Locale getLocale() {
    final code = preferences.getString(AppConstants.keyLocale);
    if (code == 'en') return const Locale('en', 'US');
    return const Locale('ar', 'SA');
  }

  @override
  void setLocale(String languageCode, String countryCode) {
    preferences.setString(AppConstants.keyLocale, languageCode);
    AppUtils.contextApp.setLocale(Locale(languageCode, countryCode));
  }

  @override
  Future<void> login(LoginEntity entity) async {
    await preferences.setString(AppConstants.keyLogin, jsonEncode(entity.toJson()));
  }

  @override
  LoginEntity? getLogin() {
    final raw = preferences.getString(AppConstants.keyLogin);
    if (raw == null) return null;
    try {
      return LoginEntity.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      AppUtils.log('تعذّرت قراءة بيانات الدخول المحفوظة: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await preferences.remove(AppConstants.keyLogin);
    await preferences.remove(AppConstants.keyUser);
    await preferences.remove(AppConstants.keySelectedStudent);
    // الرمز يُمحى مع الجلسة، وإلا بقي طلبٌ يحمله بعد الخروج.
    await clearTokens();
    AppUtils.appUser = null;
    AppUtils.selectedStudent = null;
    AppUtils.students = [];
  }

  @override
  Future<void> setSelectedStudentId(String id) =>
      preferences.setString(AppConstants.keySelectedStudent, id);

  @override
  String? getSelectedStudentId() =>
      preferences.getString(AppConstants.keySelectedStudent);

  @override
  Future<void> setOnboardingSeen() =>
      preferences.setBool(AppConstants.keyOnboardingSeen, true);

  @override
  bool getOnboardingSeen() =>
      preferences.getBool(AppConstants.keyOnboardingSeen) ?? false;

  @override
  Future<void> setTokens({required String access, required String refresh}) async {
    await preferences.setString(AppConstants.keyAccessToken, access);
    await preferences.setString(AppConstants.keyRefreshToken, refresh);
  }

  @override
  String? getAccessToken() => preferences.getString(AppConstants.keyAccessToken);

  @override
  String? getRefreshToken() => preferences.getString(AppConstants.keyRefreshToken);

  @override
  Future<void> clearTokens() async {
    await preferences.remove(AppConstants.keyAccessToken);
    await preferences.remove(AppConstants.keyRefreshToken);
  }

  @override
  Future<void> setNotificationSettings(Map<String, bool> settings) =>
      preferences.setString(AppConstants.keyNotificationSettings, jsonEncode(settings));

  @override
  Map<String, bool>? getNotificationSettings() {
    final raw = preferences.getString(AppConstants.keyNotificationSettings);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value == true));
    } catch (e) {
      AppUtils.log('تعذّرت قراءة إعدادات التنبيهات المحفوظة: $e');
      return null;
    }
  }
}
