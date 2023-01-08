import 'dart:convert';

import 'package:dd_app_ui/domain/models/user.dart';
import 'package:intl/date_symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _userKey = "_kUser";
  static const String _connectionKey = "_kConn";

  static Future<User?> getStoredUser() async {
    var sp = await SharedPreferences.getInstance();
    var json = sp.getString(_userKey);
    return (json == "" || json == null)
        ? null
        : User.fromJson(jsonDecode(json));
  }

  static Future setStoredUser(User? user) async {
    var sp = await SharedPreferences.getInstance();
    if (user == null) {
      await sp.remove(_userKey);
    } else {
      await sp.setString(_userKey, jsonEncode(user.toJson()));
    }
  }

  static Future<bool> getConnectionState() async {
    var sp = await SharedPreferences.getInstance();
    var res = sp.getBool(_connectionKey);
    if (res == null || res == false) {
      return false;
    }
    return true;
  }

  static Future setConnectionState(bool? isConnected) async {
    var sp = await SharedPreferences.getInstance();
    if (isConnected == null || isConnected == false) {
      await sp.remove(_connectionKey);
    } else {
      await sp.setBool(_connectionKey, isConnected);
    }
  }
}
