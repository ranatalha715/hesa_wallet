import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/providers/user_provider.dart';
import 'package:hesa_wallet/screens/user_profile_pages/wallet_tokens_nfts.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/app_header.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';
import '../account_recovery/reset_password.dart';

class OnboardingAddEmail extends StatefulWidget {
  const OnboardingAddEmail({Key? key}) : super(key: key);

  @override
  State<OnboardingAddEmail> createState() => _OnboardingAddEmailState();
}

class _OnboardingAddEmailState extends State<OnboardingAddEmail> {
  final TextEditingController _emailController = TextEditingController();

  bool isValidating = false;
  bool isButtonActive = false;
  var _isLoading = false;
  var accessToken = "";

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    // print(accessToken);
    print(accessToken);
  }

  @override
 initState() {
    super.initState();
    init();
    // Listen for changes in the text fields and update the button state
     _emailController.addListener(_updateButtonState);
  }

  init() async {
    await getAccessToken();
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
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
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: Column(
              children: [
                MainHeader(title: 'Add email'.tr()),
                Expanded(
                  child: Container(
                    height: 85.h,
                    width: double.infinity,
                    // color: Colors.red,
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 4.h,
                              ),
                              // Text(
                              //   "Please add a valid email".tr(),
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
                                "An email address will ensure you are able to recover your account and receive updates."
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
                                alignment: isEnglish
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
                                          vertical: 10.0, horizontal: 16.0),
                                      hintText:
                                          'Enter a valid email address'.tr(),
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
                                            color: Colors.transparent,
                                            // Off-white color
                                            // width: 2.0,
                                          )),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                            // Off-white color
                                            // width: 2.0,
                                          )),
                                    ),
                                    cursorColor: AppColors.textColorGrey),
                              ),
                              if (_emailController.text.isEmpty && isValidating)
                                Padding(
                                  padding: EdgeInsets.only(top: 7.sp),
                                  child: Text(
                                    // "*Please enter a valid email address".tr(),
                                    "*Email address should not be empty",
                                    style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.errorColor),
                                  ),
                                ),
                              Expanded(child: SizedBox()),

                              // SizedBox(
                              //   height: 6.h,
                              // )
                            ],
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 30,
                          child:
                          AppButton(
                            title: 'Confirm'.tr(),
                            isactive: isButtonActive ? true : false,
                            handler: () async {
                              setState(() {
                                isValidating = true;
                              });

                              if (_emailController.text.isNotEmpty) {
                                setState(() {
                                  _isLoading = true;
                                  if (_isLoading) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  }
                                });

                                try {
                                  // Assuming verifyEmail is an asynchronous function
                                  var result = await Provider.of<UserProvider>(context, listen: false)
                                      .verifyEmail(
                                    email: _emailController.text,
                                    context: context,
                                    token: accessToken,
                                  );

                                  setState(() {
                                    _isLoading = false;
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
                                          Navigator.of(context).popUntil((route) => route.isFirst);

                                        }
                                        Future.delayed(Duration(seconds: 2),
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
                                                      'Email verification sent'
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
                                                        'Please complete the verification to complete registration process.'
                                                            .tr(),
                                                        textAlign: TextAlign.center,
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
                                } catch (error) {
                                  // Error occurred during verification
                                  print("Error during email verification: $error");
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  // Handle error, show a snackbar, or display an error message
                                }
                              }
                            },
                            isGradient: true,
                            color: Colors.transparent,
                            textColor: AppColors.textColorBlack,
                          ),

                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) LoaderBluredScreen()
        ],
      );
    });
  }
}
