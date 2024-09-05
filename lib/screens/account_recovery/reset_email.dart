import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/providers/user_provider.dart';
import 'package:hesa_wallet/screens/account_recovery/reset_password.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dart:io' as OS;
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/app_header.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';
import '../signup_signin/signin_with_email.dart';

class ResetEmail extends StatefulWidget {
  const ResetEmail({Key? key}) : super(key: key);

  @override
  State<ResetEmail> createState() => _ResetEmailState();
}

class _ResetEmailState extends State<ResetEmail> {
  final TextEditingController _emailController = TextEditingController();

  bool isValidating = false;
  bool isLoading = false;
  bool isButtonActive = false;
  var _isLoading = false;
  bool isKeyboardVisible = false;
  var accessToken;

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    print(accessToken);
  }

  init() {
    getAccessToken();
  }

  @override
  void initState() {
    super.initState();
    init();
    // Listen for changes in the text fields and update the button state
    _emailController.addListener(_updateButtonState);
    KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _emailController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    // Clean up the controllers when they are no longer needed
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user =Provider.of<UserProvider>(context, listen: false);
    Locale currentLocale = context.locale;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: Column(
              children: [
                MainHeader(title: 'Reset Password'.tr()),
                Expanded(
                  child: Container(
                    height: 85.h,
                    // color: AppColors.errorColor,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 4.h,
                                ),
                                // Text(
                                //   "Reset Password".tr(),
                                //   style: TextStyle(
                                //       color: themeNotifier.isDark
                                //           ? AppColors.textColorWhite
                                //           : AppColors.textColorBlack,
                                //       fontWeight: FontWeight.w600,
                                //       fontSize: 17.5.sp,
                                //       fontFamily: 'Inter'),
                                // ),
                                // SizedBox(
                                //   height: 1.h,
                                // ),
                                Text(
                                  "Please enter your registered email address to receive a reset link."
                                      .tr(),
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
                                  alignment: currentLocale.languageCode == 'en'
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: Text(
                                    'Email Address'.tr(),
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
                                      onChanged: (v){
                                        user.emailErrorResponse=null;
                                      },
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                      keyboardType: TextInputType.emailAddress,
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
                                            vertical: OS.Platform.isIOS ? 14.5.sp : 10.0, horizontal:   OS.Platform.isIOS ? 10.sp :16.0),
                                        hintText:
                                            'Enter your recovery email'.tr(),
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
                                              color: (isValidating && _emailController.text.isEmpty) || user.emailErrorResponse.toString().contains('Email')
                                                  ? AppColors.errorColor
                                                  : Colors.transparent,
                                              // Off-white color
                                              // width: 2.0,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color: AppColors.focusTextFieldColor,
                                            )),
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_emailController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      // "*Email address not recognized".tr(),
                                      "*Email address should not be empty".tr(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                if (user.emailErrorResponse != null && _emailController.text.isNotEmpty && isValidating && user.emailErrorResponse.toString().contains('Email'))
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(

                                      "*${user.emailErrorResponse}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                // Expanded(child: SizedBox()),

                                SizedBox(
                                  height: 6.h,
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom:  OS.Platform.isIOS  && !isKeyboardVisible ? 50 :30,
                          child:
                          AppButton(
                            title: 'Proceed'.tr(),
                            isactive: isButtonActive ? true : false,
                            handler: () async {
                              setState(() {
                                isValidating = true;
                              });
                              if (_emailController.text.isNotEmpty) {
                                setState(() {
                                  isLoading = true;
                                  if (isLoading) {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                  }
                                  user.emailErrorResponse=null;
                                });
                                final result = await Provider.of<UserProvider>(
                                  context,
                                  listen: false,
                                ).forgotPassword(
                                  email: _emailController.text,
                                  context: context,
                                );
                                setState(() {
                                  isLoading = false;
                                });
                                if (result == AuthResult.success) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      final screenWidth =
                                          MediaQuery.of(context).size.width;
                                      final dialogWidth = screenWidth * 0.85;
                                      void closeDialogAndNavigate() {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        Navigator.of(context).pushNamed(
                                            SigninWithEmail.routeName,
                                            arguments: {
                                              'comingFromWallet': false,
                                            });
                                      }

                                      Future.delayed(Duration(seconds: 3),
                                          closeDialogAndNavigate);
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8.0),
                                        ),
                                        backgroundColor: Colors.transparent,
                                        child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 7, sigmaY: 7),
                                            child: Container(
                                              height: 30.h,
                                              width: dialogWidth,
                                              decoration: BoxDecoration(
                                                // border: Border.all(
                                                //     width: 0.1.h,
                                                //     color: AppColors.textColorGrey),
                                                color: themeNotifier.isDark
                                                    ? AppColors.showDialogClr
                                                    : AppColors.textColorWhite,
                                                borderRadius:
                                                BorderRadius.circular(15),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 4.h,
                                                  ),
                                                  Align(
                                                    alignment:
                                                    Alignment.bottomCenter,
                                                    child: Image.asset(
                                                      "assets/images/email.png",
                                                      height: 5.9.h,
                                                      width: 5.6.h,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    'Reset Instruction Sent'
                                                        .tr(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w600,
                                                        fontSize: 17.sp,
                                                        color: themeNotifier
                                                            .isDark
                                                            ? AppColors
                                                            .textColorWhite
                                                            : AppColors
                                                            .textColorBlack),
                                                  ),
                                                  SizedBox(
                                                    height: 2.h,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20),
                                                    child: Text(
                                                      'Please check your email to continue resetting your pasword.'
                                                          .tr(),
                                                      textAlign:
                                                      TextAlign.center,
                                                      style: TextStyle(
                                                          height: 1.4,
                                                          fontWeight:
                                                          FontWeight.w400,
                                                          fontSize: 10.2.sp,
                                                          color: AppColors
                                                              .textColorGrey),
                                                    ),
                                                  ),
                                                  // SizedBox(
                                                  //   height: 4.h,
                                                  // ),
                                                ],
                                              ),
                                            )),
                                      );
                                    },
                                  );
                                }
                              }
                            },
                            isGradient: true,
                            color: Colors.transparent,
                            textColor: AppColors.textColorBlack,
                          ),

                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) LoaderBluredScreen()
        ],
      );
    });
  }
}
