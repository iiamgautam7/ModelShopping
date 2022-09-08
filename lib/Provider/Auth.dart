import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/Http.exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authtimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) return _token;
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCK_M9XtiIVAicGrsK7TAad73_iF_9Q96E");
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(
        seconds: int.parse(responseData['expiresIn']),
      ));
      _autologout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
        'authData',
        json.encode({
          'token': _token,
          'userId': _userId,
          'expiry': _expiryDate!.toIso8601String(),
        }),
      );
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutologin() async {
    // print('tryung auto login');
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('authData')) {
        print('not found');
        return false;
      }
      // print('found');
      final extractedAuthData =
          json.decode(prefs.getString('authData')!) as Map<String, dynamic>;
      // print('data: $extractedAuthData');
      final expiryDate = DateTime.parse(extractedAuthData['expiry']!);
      if (expiryDate.isBefore(DateTime.now())) return false;
      _token = extractedAuthData['token'];
      _userId = extractedAuthData['userId'];
      _expiryDate = expiryDate;
      notifyListeners();
      _autologout();
      return true;
    } catch (error) {
      print(error);
    }
    return false;
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authtimer != null) {
      _authtimer!.cancel();
      _authtimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autologout() {
    if (_authtimer != null) {
      _authtimer!.cancel();
    }
    _authtimer = Timer(
        Duration(seconds: _expiryDate!.difference(DateTime.now()).inSeconds),
        logout);
  }
}
