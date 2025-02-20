import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../constants/colors.dart';
import '../../constants/configs.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import 'dart:io' as OS;
import '../../widgets/button.dart';
import '../../widgets/text_field_parent.dart';
import '../account_recovery/reset_email.dart';
import 'package:crypto/crypto.dart';

class UnlockWithPassword extends StatefulWidget {
  @override
  State<UnlockWithPassword> createState() => _UnlockWithPasswordState();
}

class _UnlockWithPasswordState extends State<UnlockWithPassword> {
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  var accessToken;
  bool isValidating = false;
  bool isButtonActive = false;
  var _isLoading = false;

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _passwordController.text.isNotEmpty;
    });
  }

  setLockScreenStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('setLockScreen', value);
    var lul = prefs.getBool('setLockScreen');
    print("lul");
    print(lul);
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  init() async {
    await getAccessToken();
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
  }

  @override
  initState() {
    // TODO: implement initState
    init();
    _passwordController.addListener(_updateButtonState);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context, listen: false);
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return
        Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          child:
          Column(
            children: [
              Container(
                  height: 55.h,
                  width: 100.w,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 18.sp, top: 6.h),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Image.asset(
                              isEnglish
                                  ? "assets/images/back_dark_oldUI.png"
                                  : "assets/images/back_arrow_left.png",
                              height: isEnglish ? 3.1.h : 4.6.h,
                              width: isEnglish ? 3.1.h : 4.6.h,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
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
                    ],
                  )),
              Container(
                height: 45.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.sp,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5.h,
                      ),
                      Align(
                        alignment: isEnglish
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          'Password'.tr(),
                          style: TextStyle(
                              fontSize: 11.7.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: themeNotifier.isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      TextFieldParent(
                        child: TextField(
                            keyboardType: TextInputType.text,
                            onChanged: (v) {
                              auth.loginErrorResponse = null;
                            },
                            scrollPadding: EdgeInsets.only(
                                bottom:
                                MediaQuery
                                    .of(context)
                                    .viewInsets
                                    .bottom /
                                    1.4),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(
                                fontSize: 10.2.sp,
                                color: themeNotifier.isDark
                                    ? AppColors.textColorWhite
                                    : AppColors.textColorBlack,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Inter'),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: OS.Platform.isIOS ? 14.5.sp : 10.0,
                                  horizontal: OS.Platform.isIOS ? 10.sp : 16.0),
                              hintText: 'Enter your password'.tr(),
                              hintStyle: TextStyle(
                                  fontSize: 10.2.sp,
                                  color: AppColors.textColorGrey,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Inter'),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: (isValidating &&
                                        _passwordController
                                            .text.isEmpty) ||
                                        auth.loginErrorResponse
                                            .toString()
                                            .contains('password')
                                        ? AppColors.errorColor
                                        : Colors.transparent,
                                  )),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: (isValidating &&
                                        _passwordController
                                            .text.isEmpty) ||
                                        auth.loginErrorResponse
                                            .toString()
                                            .contains('password')
                                        ? AppColors.errorColor
                                        : AppColors.focusTextFieldColor,
                                  )),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textColorGrey,
                                  size: 17.5.sp,
                                ),
                                onPressed: _togglePasswordVisibility,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                              ),
                            ),
                            cursorColor: AppColors.textColorGrey),
                      ),
                      if (_passwordController.text.isEmpty && isValidating)
                        Padding(
                          padding: EdgeInsets.only(top: 7.sp),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "*Password should not be empty".tr(),
                              /* textAlign :TextAlign.left,*/
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.errorColor),
                            ),
                          ),
                        ),
                      if (auth.loginErrorResponse != null &&
                          _passwordController.text.isNotEmpty &&
                          isValidating &&
                          auth.loginErrorResponse
                              .toString()
                              .contains('password'))
                        Padding(
                          padding: EdgeInsets.only(top: 7.sp),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              auth.loginErrorResponse ==
                                  "You have entered an invalid password"
                                  ? "*Password incorrect".tr()
                                  : "",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10.sp,
                                  color: AppColors.errorColor),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResetEmail(),
                                ),
                              ),
                          child: Text(
                            'Forgot password?'.tr(),
                            style: TextStyle(
                              fontSize: 11.7.sp,
                              fontWeight: FontWeight.bold,
                              color: themeNotifier.isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack,
                              // decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 6.h,
                      ),
                      AppButton(
                          title: 'Unlock'.tr(),
                          isactive: isButtonActive ? true : false,
                          handler: () async {
                            setState(() {
                              isValidating = true;
                            });

                            if (_passwordController.text.isNotEmpty) {
                              setState(() {
                                _isLoading = true;
                                if (_isLoading) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }
                                auth.loginErrorResponse = null;
                              });
                              final String password = _passwordController.text;
                              final bytes = utf8.encode(password);
                              final sha512Hash = sha512.convert(bytes);
                              final sha512String = sha512Hash.toString();
                              final result = await Provider.of<AuthProvider>(
                                  context,
                                  listen: false)
                                  .loginWithUsername(
                                  username: user.userName!,
                                  password: sha512String,
                                  context: context,
                                  isEnglish: isEnglish,
                                  forUnlock: true);
                              setState(() {
                                _isLoading = false;
                              });
                              if (result == AuthResult.success) {
                                setLockScreenStatus(false);
                              }
                            }
                          },
                          isGradient: true,
                          isGradientWithBorder: true,
                          color: Colors.transparent),
                      SizedBox(
                        height: 9.h,
                      ),
                    ],
                  ),
                ),
              ),
              // Positioned(
              //   top: 0,
              //   left: 4.w,
              //   bottom: 0,
              //   child:    GestureDetector(
              //     onTap:  () {
              //       Navigator.pop(context);
              //     },
              //     child: Image.asset(
              //       isEnglish
              //           ? "assets/images/back_dark_oldUI.png"
              //           : "assets/images/back_arrow_left.png",
              //       height: isEnglish ? 3.1.h : 4.6.h,
              //       width: isEnglish ? 3.1.h : 4.6.h,
              //       color: Colors.white,
              //     ),
              //   ),),
            ],
          ),
        ),
      );
    });
  }
}
