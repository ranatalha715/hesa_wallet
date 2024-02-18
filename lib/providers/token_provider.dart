import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class TokenProvider with ChangeNotifier {
  String _wstoken = '';
  Timer? _tokenRefreshTimer;
  // bool _isWifiOn = true; // Default to true, assuming WiFi is initially on

  TokenProvider() {
    _loadToken();
    _startTokenRefreshTimer();
    // _checkWifiStatus();
  }


  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _wstoken = prefs.getString('wsToken') ?? '';
    if (isTokenExpired(_wstoken)) {
      print('Token is expired.');
      prefs.remove('wsToken');
    } else {
      print('Token is not expired.');
    }

    notifyListeners();
  }

  void _startTokenRefreshTimer() {
    const duration = Duration(seconds: 3);
    _tokenRefreshTimer = Timer.periodic(duration, (timer) {
      _loadToken();
    });
    print('calling after every 3 seconds');
    notifyListeners();
  }

  String get wstoken => _wstoken;
  // Future<void> _checkWifiStatus() async {
  //   var connectivityResult = await Connectivity().checkConnectivity();
  //   _isWifiOn = connectivityResult == ConnectivityResult.wifi;
  //   notifyListeners();
  // }
  // Future<void> updateWifiStatus() async {
  //   var connectivityResult = await Connectivity().checkConnectivity();
  //   _isWifiOn = connectivityResult == ConnectivityResult.wifi;
  //   notifyListeners();
  // }

  // set wstoken(String value) {
  //   _wstoken = value;
  //   // Save the updated _wstoken to shared preferences
  //   _saveToken();
  //   notifyListeners();
  // }
  //
  // Future<void> _saveToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('wsToken', _wstoken);
  // }

  bool get isTokenEmpty => _wstoken.isEmpty || _wstoken == '';
  // bool get isWifiOn => _isWifiOn;
}
