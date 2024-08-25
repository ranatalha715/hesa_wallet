import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/screens/unlock/unlock_with_password.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/button.dart';
import '../../widgets/text_field_parent.dart';
import '../account_recovery/reset_email.dart';
import '../signup_signin/wallet.dart';
import '../signup_signin/welcome_screen.dart';

class Unlock extends StatefulWidget {
  @override
  State<Unlock> createState() => _UnlockState();
}

class _UnlockState extends State<Unlock> {
  bool _obscurePassword = true;
  late Timer _timer;
  var _isLoading = false;
  var _savedPassCode;
  bool isValidating = false;
  bool isButtonActive = false;
  bool setLockScreen = false;
  String passcode = '';
  bool isMatched = false;
  List<String> numbers = List.generate(6, (index) => '');
  List<String> numbersToSave = List.generate(6, (index) => '');
  bool isFirstFieldFilled = false;
  bool _pinError = false;
  bool isUnlocked = false;

  final TextEditingController _passwordController = TextEditingController();

  void _updateButtonState() {
    setState(() {
      isButtonActive = _passwordController.text.isNotEmpty;
    });
  }

   getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPasscode = prefs.getString('passcode');
    final savedSetLockScreen = prefs.getBool('setLockScreen') ?? false;
    setState(() {
      passcode=savedPasscode!;
      setLockScreen=savedSetLockScreen;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _passwordController.addListener(_updateButtonState);
    getSettings();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      height: 55.h,
                      width: 100.w,
                      // color: Colors.brown,
                      child: Column(
                        children: [
                          Spacer(
                            flex: 5,
                          ),
                          Text(
                            'Account Locked'.tr(),
                            style: TextStyle(
                                color: themeNotifier.isDark
                                    ? AppColors.textColorWhite
                                    : AppColors.textColorBlack,
                                fontWeight: FontWeight.w700,
                                fontSize: 25.sp,
                                fontFamily: 'Blogger Sans'),
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Image.asset(
                            "assets/images/lock_big.png",
                            height: 17.h,
                            width: 17.h,
                            color: themeNotifier.isDark
                                ? AppColors.textColorWhite
                                : AppColors.textColorBlack,
                          ),
                          // Spacer(
                          //   flex: 1,
                          // ),
                        ],
                      )),

                    Container(
                      height: 45.h,
                      // color: Colors.brown,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 4.h,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.sp),
                            child: AppButton(
                                title: 'Unlock'.tr(),
                                isGradientWithBorder: true,
                                isactive: isButtonActive ? true : false,
                                handler: () async {
                                  passcode=="" ?
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => UnlockWithPassword(),
                                  ))

                                      : Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => WelcomeScreen(handler: (){})),
                                  );
                                  // setState(() {
                                  //   isValidating = true;
                                  // });
                                  // if(_passwordController.text.isNotEmpty) {
                                  //   setState(() {
                                  //     _isLoading = true;
                                  //   });
                                  //   await Future.delayed(
                                  //       Duration(milliseconds: 1500),
                                  //           () {});
                                  //   if (_passwordController.text ==
                                  //       _savedPassCode) {
                                  //     // widget.handler();
                                  //   }
                                  //
                                  //   setState(() {
                                  //     _isLoading = false;
                                  //   });
                                  // }
                                },
                                isGradient: false,
                                color: Colors.transparent),
                          ),
                        ],
                      ),
                    ),

                ],
              ),
            ),
          ),
          if (_isLoading) LoaderBluredScreen()
        ],
      );
    });
  }
}
