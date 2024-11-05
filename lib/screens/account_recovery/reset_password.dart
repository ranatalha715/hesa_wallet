import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../constants/colors.dart';
import '../../constants/configs.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  List<String> accountDefinitions = [
    'Upper and lowercase letters'.tr(),
    'Numerical characters'.tr(),
    'Special characters (\$-#-@)'.tr(),
    'At least 8 characters in total'.tr(),
  ];

  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigits = false;
  bool _hasSpecialCharacters = false;
  bool _hasMinLength = false;

  void _validatePassword(String password) {
    setState(() {
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
      _hasSpecialCharacters = password.contains(RegExp(r'[\$#@]'));
      _hasMinLength = password.length >= 8;
    });
  }

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ScrollController scrollController = ScrollController();
  ScrollController _scrollController = ScrollController();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  bool isLoading = false;
  bool isValidating = false;
  bool isButtonActive = false;
  var _isLoading = false;
  bool _isPasswordValid = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscurePasswordConfirm = !_obscurePasswordConfirm;
    });
  }



  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _newPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                                Align(
                                  alignment: currentLocale.languageCode == 'en'
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: Text(
                                    'New Password'.tr(),
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
                                              .bottom+100),
                                      controller: _newPasswordController,
                                      obscureText: _obscurePassword,
                                      onChanged: (password) {
                                        _validatePassword(password);
                                      },
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
                                              color: Colors.transparent,
                                              // Off-white color
                                              // width: 2.0,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color: AppColors.focusTextFieldColor,
                                            )),
                                        // labelText: 'Enter your password',
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
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
                                if (_newPasswordController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      "*Password should not be empty",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                if(!_isPasswordValid && isValidating && _newPasswordController.text.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      "*Password must meet requirements",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                SizedBox(height: 4.h),
                                Text(
                                  "Password must contain".tr(),
                                  style: TextStyle(
                                      color: AppColors.textColorWhite,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10.2.sp,
                                      fontFamily: 'Inter'),
                                ),
                                SizedBox(
                                  height: 0.3.h,
                                ),
                                ListView.builder(
                                  controller: scrollController,
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: accountDefinitions.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    bool conditionMet;
                                    switch (index) {
                                      case 0:
                                        conditionMet = _hasUppercase && _hasLowercase;
                                        break;
                                      case 1:
                                        conditionMet = _hasDigits;
                                        break;
                                      case 2:
                                        conditionMet = _hasSpecialCharacters;
                                        break;
                                      case 3:
                                        conditionMet = _hasMinLength;
                                        break;
                                      default:
                                        conditionMet = false;
                                    }

                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 4.0, right: 8.0),
                                          child: Icon(
                                            Icons.fiber_manual_record,
                                            size: 7.sp,
                                            color: _newPasswordController.text.isEmpty ? AppColors.textColorGrey:conditionMet ? AppColors.hexaGreen : AppColors.errorColor,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 3),
                                            child: Text(
                                              accountDefinitions[index],
                                              style: TextStyle(
                                                color: _newPasswordController.text.isEmpty ? AppColors.textColorGrey:conditionMet ? AppColors.hexaGreen : AppColors.errorColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10.2.sp,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Align(
                                  alignment: currentLocale.languageCode == 'en'
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: Text(
                                    'Confirm password'.tr(),
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
                                              .bottom),
                                      controller: _confirmPasswordController,
                                      keyboardType:
                                      TextInputType.visiblePassword,
                                      obscureText: _obscurePasswordConfirm,
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
                                        hintText: 'Confirm your password'.tr(),
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
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color: AppColors.focusTextFieldColor,
                                            )),
                                        // labelText: 'Enter your password',
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                              _obscurePasswordConfirm
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              size: 17.5.sp,
                                              color: AppColors.textColorGrey),
                                          onPressed: _toggleConfirmPasswordVisibility,
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                        ),
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_confirmPasswordController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      "*Password should not be empty".tr(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                if (_confirmPasswordController.text !=
                                        _newPasswordController.text &&
                                    _confirmPasswordController.text.isEmpty &&
                                    _newPasswordController.text.isEmpty &&
                                    isValidating)
                                Padding(
                                  padding: EdgeInsets.only(top: 7.sp),
                                  child: Text(
                                    "*Password does not match".tr(),
                                    style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.errorColor),
                                  ),
                                ),
                                SizedBox(
                                  height: 25.h,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 30,
                          child: AppButton(
                            title: 'Change password'.tr(),
                            isactive: isButtonActive ? true : false,
                            handler: () async {
                              setState(() {
                                isValidating = true;
                              });
                              if (_newPasswordController.text.isNotEmpty &&
                                  _confirmPasswordController.text.isNotEmpty) {
                                setState(() {
                                  isLoading = true;
                                });
                                final result = await Provider.of<AuthProvider>(
                                        context,
                                        listen: false)
                                    .changePasswordStep1(
                                        oldPassword:
                                            _newPasswordController.text,
                                        newPassword:
                                            _confirmPasswordController.text,
                                        confirmPassword: _confirmPasswordController.text,
                                        context: context,
                                        // isEnglish: isEnglish,
                                        token: '');
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
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
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
                                                color: themeNotifier.isDark
                                                    ? AppColors.showDialogClr
                                                    : AppColors.textColorWhite,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.textColorBlack.withOpacity(0.95),
                                                    offset: Offset(0, 0),
                                                    blurRadius: 10,
                                                    spreadRadius: 0.4,
                                                  ),
                                                ],
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
                                                      "assets/images/check_circle.png",
                                                      height: 6.h,
                                                      width: 5.8.h,
                                                      color: AppColors.hexaGreen,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: Text(
                                                      'Reset Password Completed'
                                                          .tr(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
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
                                                  ),
                                                  SizedBox(
                                                    height: 2.h,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20),
                                                    child: Text(
                                                      'Your password is now update. Please remember to secure your password.'
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
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Positioned(
                top: 12.h,
                bottom: 0,
                left: 0,
                right: 0,
                child: LoaderBluredScreen())
        ],
      );
    });
  }
}
