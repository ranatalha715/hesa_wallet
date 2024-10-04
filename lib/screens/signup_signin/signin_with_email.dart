import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:hesa_wallet/screens/signup_signin/signin_with_mobile.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'dart:io' as OS;
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../constants/colors.dart';
import '../../constants/configs.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';
import '../account_recovery/reset_email.dart';

class SigninWithEmail extends StatefulWidget {
  static const routeName = '/SigninWithEmail';

  const SigninWithEmail({Key? key}) : super(key: key);

  @override
  State<SigninWithEmail> createState() => _SigninWithEmailState();
}

class _SigninWithEmailState extends State<SigninWithEmail> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _obscurePassword = true;
  var _isLoading = false;
  bool isButtonActive = false;
  bool isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);

    KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  bool isValidating = false;

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          Navigator.of(context).pop();
        }
      },
      child: Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
        return Stack(
          children: [
            WillPopScope(
              onWillPop: () async {
                args!['comingFromWallet'] == true
                    ? Navigator.pop(context)
                    : exit(0);
                return false;
              },
              child: Scaffold(
                backgroundColor: themeNotifier.isDark
                    ? AppColors.backgroundColor
                    : AppColors.textColorWhite,
                body: Column(
                  children: [
                    MainHeader(
                      title: 'Login'.tr(),
                      handler: args!['comingFromWallet'] == true
                          ? () => Navigator.pop(context)
                          : () => exit(0),
                    ),
                    Expanded(
                      child: Container(
                        // color: Colors.red,
                        height: 85.h,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 4.h,
                              ),
                              Text(
                                "Login using Email/Username.".tr(),
                                style: TextStyle(
                                    color: AppColors.textColorGrey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11.7.sp,
                                    fontFamily: 'Inter'),
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Align(
                                alignment: isEnglish
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Text(
                                  'Email/username'.tr(),
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
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (v) {
                                      auth.loginErrorResponse = null;
                                    },
                                    style: TextStyle(
                                        fontSize: 10.2.sp,
                                        color: themeNotifier.isDark
                                            ? AppColors.textColorWhite
                                            : AppColors.textColorBlack,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Inter'),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: OS.Platform.isIOS
                                              ? 14.5.sp
                                              : 10.0,
                                          horizontal:
                                              OS.Platform.isIOS ? 10.sp : 16.0),
                                      hintText:
                                          'Enter your email or username'.tr(),
                                      hintStyle: TextStyle(
                                          fontSize: 10.2.sp,
                                          color: AppColors.textColorGrey,
                                          fontWeight: FontWeight.w400,
                                          // Off-white color,
                                          fontFamily: 'Inter'),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: (isValidating &&
                                                        _emailController
                                                            .text.isEmpty) ||
                                                    auth.loginErrorResponse
                                                        .toString()
                                                        .contains('username')
                                                ? AppColors.errorColor
                                                : Colors.transparent,
                                          )),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color:
                                                AppColors.focusTextFieldColor,
                                          )),
                                    ),
                                    cursorColor: AppColors.textColorGrey),
                              ),
                              if (_emailController.text.isEmpty && isValidating)
                                Padding(
                                  padding: EdgeInsets.only(top: 7.sp),
                                  child: Text(
                                    "*Email Address or username should not be empty",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10.sp,
                                        color: AppColors.errorColor),
                                  ),
                                ),
                              if (auth.loginErrorResponse != null &&
                                  _emailController.text.isNotEmpty &&
                                  isValidating &&
                                  auth.loginErrorResponse
                                      .toString()
                                      .contains('username'))
                                Padding(
                                  padding: EdgeInsets.only(top: 7.sp),
                                  child: Text(
                                    auth.loginErrorResponse ==
                                            "This username is unavailable"
                                        ? "*Email Address or username not recognized"
                                        : "",
                                    // "*${auth.loginErrorResponse}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10.sp,
                                        color: AppColors.errorColor),
                                  ),
                                ),
                              SizedBox(
                                height: 2.h,
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
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            140),
                                    controller: _passwordController,
                                    keyboardType: TextInputType.visiblePassword,
                                    onChanged: (v) {
                                      auth.loginErrorResponse = null;
                                    },
                                    obscureText: _obscurePassword,
                                    style: TextStyle(
                                        fontSize: 10.2.sp,
                                        color: themeNotifier.isDark
                                            ? AppColors.textColorWhite
                                            : AppColors.textColorBlack,
                                        fontWeight: FontWeight.w400,
                                        // Off-white color,
                                        fontFamily: 'Inter'),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: OS.Platform.isIOS
                                              ? 14.5.sp
                                              : 10.0,
                                          horizontal:
                                              OS.Platform.isIOS ? 10.sp : 16.0),
                                      hintText: 'Enter your password'.tr(),
                                      hintStyle: TextStyle(
                                          fontSize: 10.2.sp,
                                          color: AppColors.textColorGrey,
                                          fontWeight: FontWeight.w400,
                                          // Off-white color,
                                          fontFamily: 'Inter'),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
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
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color:
                                                AppColors.focusTextFieldColor,
                                          )),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 17.5.sp,
                                            color: AppColors.textColorGrey),
                                        onPressed: _togglePasswordVisibility,
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                      ),
                                    ),
                                    cursorColor: AppColors.textColorGrey),
                              ),
                              SizedBox(
                                height: 1.5.h,
                              ),
                              if (_passwordController.text.isEmpty &&
                                  isValidating)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 7.sp),
                                  child: Text(
                                    "*Password should not be empty",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10.sp,
                                        color: AppColors.errorColor),
                                  ),
                                ),
                              if (auth.loginErrorResponse != null &&
                                  _passwordController.text.isNotEmpty &&
                                  isValidating &&
                                  auth.loginErrorResponse
                                      .toString()
                                      .contains('password'))
                                Padding(
                                  padding: EdgeInsets.only(bottom: 7.sp),
                                  child: Text(
                                    auth.loginErrorResponse ==
                                            "You have entered an invalid password"
                                        ? "*Password incorrect"
                                        : "",
                                    // "*${auth.loginErrorResponse}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10.sp,
                                        color: AppColors.errorColor),
                                  ),
                                ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResetEmail(),
                                    ),
                                  ),
                                  child: Container(
                                    child: Text(
                                      'Forgot password?'.tr(),
                                      style: TextStyle(
                                        fontSize: 11.7.sp,
                                        fontWeight: FontWeight.w600,
                                        color: themeNotifier.isDark
                                            ? AppColors.textColorWhite
                                            : AppColors.textColorBlack,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // SizedBox(height: 3.h,),
                              Expanded(child: SizedBox()),
                              AppButton(
                                title: 'Log in'.tr(),
                                isactive: isButtonActive,
                                handler: () async {
                                  setState(() {
                                    isValidating = true;
                                  });

                                  if (_emailController.text.isNotEmpty &&
                                      _passwordController.text.isNotEmpty) {
                                    setState(() {
                                      _isLoading = true;
                                      if (_isLoading) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      }
                                      auth.loginErrorResponse = null;
                                    });
                                    final String password =
                                        _passwordController.text;
                                    final bytes = utf8.encode(password);
                                    final sha512Hash = sha512.convert(bytes);
                                    final sha512String = sha512Hash.toString();
                                    final result =
                                        await Provider.of<AuthProvider>(context,
                                                listen: false)
                                            .loginWithUsername(
                                                username: _emailController.text,
                                                password:
                                                sha512String,
                                                // sha512String,
                                                context: context);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    if (result == AuthResult.success) {
                                      await Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              'nfts-page', (Route d) => false,
                                              arguments: {});
                                    }
                                  }
                                },
                                isGradient: true,
                                color: Colors.transparent,
                                textColor: AppColors.textColorBlack,
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SigninWithMobile(),
                                  ),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  height: 4.h,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      "Login with mobile number".tr(),
                                      style: TextStyle(
                                        color: themeNotifier.isDark
                                            ? AppColors.textColorWhite
                                            : AppColors.textColorBlack,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10.sp,
                                        fontFamily: 'Inter',
                                      ),
                                      // textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: OS.Platform.isIOS && !isKeyboardVisible
                                    ? 5.h
                                    : 2.h,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (OS.Platform.isIOS)
              KeyboardVisibilityBuilder(builder: (context, child) {
                return Visibility(
                    visible: isKeyboardVisible,
                    child: Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: () =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          child: Container(
                              color: AppColors.textColorWhite,
                              height: 4.h,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      'Done',
                                      style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 11.5.sp,
                                              fontWeight: FontWeight.bold)
                                          .apply(fontWeightDelta: -1),
                                    ),
                                  ))),
                        )));
              }),
            if (_isLoading)
              Positioned(
                  top: 12.h,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LoaderBluredScreen()),
          ],
        );
      }),
    );
  }
}
