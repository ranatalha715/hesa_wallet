import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/screens/settings/account_information.dart';
import 'package:hesa_wallet/screens/user_profile_pages/wallet_tokens_nfts.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../providers/theme_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  FocusNode firstFieldFocusNode = FocusNode();
  FocusNode secondFieldFocusNode = FocusNode();
  FocusNode thirdFieldFocusNode = FocusNode();
  FocusNode forthFieldFocusNode = FocusNode();
  FocusNode fifthFieldFocusNode = FocusNode();
  FocusNode sixthFieldFocusNode = FocusNode();
  List<String> accountDefinitions = [
    'Upper and lowercase letters'.tr(),
    'Numerical characters'.tr(),
    'Special characters (\$-#-@)'.tr(),
    'At least 8 characters in total'.tr(),
  ];
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController otp5Controller = TextEditingController();
  final TextEditingController otp6Controller = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePasswordNew = true;
  bool _obscurePasswordConfirm = true;
  bool isButtonActive = false;
  bool isValidating = false;
  var _isLoading = false;
  var accessToken = "";

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  @override
  initState() {
    super.initState();

    // Listen for changes in the text fields and update the button state
    _newPasswordController.addListener(_updateButtonState);
    _oldPasswordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
    getAccessToken();
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _newPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _oldPasswordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _oldPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;

    });
  }

  void _togglePasswordVisibilityNew() {
    setState(() {
      _obscurePasswordNew = !_obscurePasswordNew;

    });
  }

  void _togglePasswordVisibilityConfirm() {
    setState(() {
      _obscurePasswordConfirm = !_obscurePasswordConfirm;

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
            body: Column(
              children: [
                MainHeader(title: 'Update Password'.tr()),
                Expanded(
                  child: Container(
                    // color: Colors.red,
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
                                // Text(
                                //   "Enter password".tr(),
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
                                  "Please start by entering your current password."
                                      .tr(),
                                  style: TextStyle(
                                      color: AppColors.textColorGrey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11.7.sp,
                                      fontFamily: 'Inter'),
                                ),
                                SizedBox(
                                  height: 3.h,
                                ),
                                Align(
                                  alignment: isEnglish
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: Text(
                                    'Old password'.tr(),
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
                                      controller: _oldPasswordController,
                                      keyboardType:
                                          TextInputType.visiblePassword,
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
                                              color: Colors.transparent,
                                              // Off-white color
                                              // width: 2.0,
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
                                        ),
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_oldPasswordController.text.isEmpty &&
                                    isValidating)

                                    Padding(
                                      padding: EdgeInsets.only(top: 7.sp),
                                      child: Text(
                                        "*Old Password should not be empty"
                                            .tr(),
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.errorColor),
                                      ),
                                    ),
                                  // Padding(
                                  //   padding: EdgeInsets.only(top: 7.sp),
                                  //   child: Text(
                                  //     "*Password is incorrect".tr(),
                                  //     style: TextStyle(
                                  //         fontSize: 10.sp,
                                  //         fontWeight: FontWeight.w400,
                                  //         color: AppColors.errorColor),
                                  //   ),
                                  // ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Align(
                                  alignment: isEnglish
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
                                              .bottom+200),
                                      controller: _newPasswordController,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: _obscurePasswordNew,
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
                                              color: Colors.transparent,
                                              // Off-white color
                                              // width: 2.0,
                                            )),
                                        // labelText: 'Enter your password',
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                              _obscurePasswordNew
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              size: 17.5.sp,
                                              color: AppColors.textColorGrey),
                                          onPressed: _togglePasswordVisibilityNew,
                                        ),
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_newPasswordController.text.isEmpty &&
                                    isValidating)
                                  if (_confirmPasswordController.text.isEmpty &&
                                      isValidating)
                                    Padding(
                                      padding: EdgeInsets.only(top: 7.sp),
                                      child: Text(
                                        "*New Password should not be empty"
                                            .tr(),
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.errorColor),
                                      ),
                                    ),
                                  // Padding(
                                  //   padding: EdgeInsets.only(top: 7.sp),
                                  //   child: Text(
                                  //     "*Password must meet requirements".tr(),
                                  //     style: TextStyle(
                                  //         fontSize: 10.sp,
                                  //         fontWeight: FontWeight.w400,
                                  //         color: AppColors.errorColor),
                                  //   ),
                                  // ),
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
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  controller: _scrollController,
                                  itemCount: accountDefinitions.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 4.0, right: 8.0),
                                          child: Icon(
                                            Icons.fiber_manual_record,
                                            size: 7.sp,
                                            color: AppColors.textColorWhite,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 3),
                                            child: Text(
                                              accountDefinitions[index],
                                              style: TextStyle(
                                                  color:
                                                      AppColors.textColorWhite,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10.2.sp,
                                                  fontFamily: 'Inter'),
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
                                  alignment: isEnglish
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
                                        // labelText: 'Enter your password',
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                              _obscurePasswordConfirm
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              size: 17.5.sp,
                                              color: AppColors.textColorGrey),
                                          onPressed: _togglePasswordVisibilityConfirm
                                        ),
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_confirmPasswordController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      "*Confirm Password should not be empty"
                                          .tr(),
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                // if (_confirmPasswordController.text !=
                                //         _newPasswordController.text &&
                                //     _confirmPasswordController.text.isEmpty &&
                                //     _newPasswordController.text.isEmpty &&
                                //     isValidating)
                                  // Padding(
                                  //   padding: EdgeInsets.only(top: 7.sp),
                                  //   child: Text(
                                  //     "*Password does not match".tr(),
                                  //     style: TextStyle(
                                  //         fontSize: 10.sp,
                                  //         fontWeight: FontWeight.w400,
                                  //         color: AppColors.errorColor),
                                  //   ),
                                  // ),
                                // Expanded(child: SizedBox()),

                                SizedBox(
                                  height: 20.h,
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Column(
                            children: [
                              Container(
                                color: themeNotifier.isDark
                                    ? AppColors.backgroundColor
                                    : AppColors.textColorWhite,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, bottom: 0, right: 20, top: 10),
                                  child: AppButton(
                                    title: 'Change password'.tr(),
                                    isactive: isButtonActive ? true : false,
                                    handler: () async {
                                      setState(() {
                                        isValidating=true;
                                      });
                                      if (_oldPasswordController.text.isNotEmpty &&
                                          _newPasswordController.text.isNotEmpty &&
                                          _confirmPasswordController
                                              .text.isNotEmpty) {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        // await Future.delayed(Duration(milliseconds: 1500),
                                        //         (){});
                                        var result=  await Provider.of<AuthProvider>(context,
                                            listen: false)
                                            .changePassword(
                                            oldPassword:
                                            _oldPasswordController.text,
                                            newPassword:
                                            _newPasswordController.text,
                                            context: context,
                                            token: accessToken);
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        if(result ==AuthResult.success)
                                        {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (BuildContext context) {
                                              final screenWidth =
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width;
                                              final dialogWidth =
                                                  screenWidth * 0.85;
                                              void
                                              closeDialogAndNavigate() {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog// Close the dialog
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        WalletTokensNfts(),
                                                  ),
                                                );
                                              }

                                              Future.delayed(
                                                  Duration(milliseconds: 1500),
                                                  closeDialogAndNavigate);
                                              return Dialog(
                                                shape:
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      8.0),
                                                ),
                                                backgroundColor:
                                                Colors.transparent,
                                                child: BackdropFilter(
                                                    filter: ImageFilter
                                                        .blur(
                                                        sigmaX: 7,
                                                        sigmaY: 7),
                                                    child: Container(
                                                      height: 25.h,
                                                      width:
                                                      dialogWidth,
                                                      decoration:
                                                      BoxDecoration(
                                                        // border: Border.all(
                                                        //     width:
                                                        //         0.1.h,
                                                        //     color: AppColors
                                                        //         .textColorGrey),
                                                        color: themeNotifier.isDark
                                                            ? AppColors
                                                            .showDialogClr
                                                            : AppColors
                                                            .textColorWhite,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            15),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        children: [
                                                          SizedBox(
                                                            height: 4.h,
                                                          ),

                                                          // SizedBox(height: 2.h),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                            children: [
                                                              Text(
                                                                'Password Updated'.tr(),
                                                                textAlign:
                                                                TextAlign.center,
                                                                maxLines:
                                                                2,
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .w600,
                                                                    fontSize: 17
                                                                        .sp,
                                                                    color: themeNotifier.isDark
                                                                        ? AppColors.textColorWhite
                                                                        : AppColors.textColorBlack),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                1.h,
                                                              ),
                                                              Image
                                                                  .asset(
                                                                "assets/images/check_circle.png",
                                                                height:
                                                                4.h,
                                                                width:
                                                                4.h,
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 2.h,
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                20),
                                                            child: Text(
                                                              'Your password is now updated. Please remember to secure your password.'.tr(),
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                              style: TextStyle(
                                                                  height:
                                                                  1.4,
                                                                  fontWeight: FontWeight
                                                                      .w400,
                                                                  fontSize:
                                                                  16,
                                                                  color:
                                                                  AppColors.textColorGrey),
                                                            ),
                                                          ),
                                                          // SizedBox(
                                                          //   height: 4.h,
                                                          // ),
                                                        ],
                                                      ),
                                                    )

                                                ),
                                              );
                                            },
                                          );
                                        }
                                      }

                                      // if(isButtonActive)

                                      //   //change password otp dialoge
                                      // showDialog(
                                      //   context: context,
                                      //   builder: (BuildContext context) {
                                      //     final screenWidth =
                                      //         MediaQuery.of(context).size.width;
                                      //     final dialogWidth = screenWidth * 0.85;
                                      //     return Dialog(
                                      //       shape: RoundedRectangleBorder(
                                      //         borderRadius: BorderRadius.circular(8.0),
                                      //       ),
                                      //       backgroundColor: Colors.transparent,
                                      //       child: BackdropFilter(
                                      //           filter: ImageFilter.blur(
                                      //               sigmaX: 7, sigmaY: 7),
                                      //           child: Container(
                                      //             height: 55.h,
                                      //             width: dialogWidth,
                                      //             decoration: BoxDecoration(
                                      //               color: themeNotifier.isDark
                                      //                   ? AppColors.showDialogClr
                                      //                   : AppColors.textColorWhite,
                                      //               borderRadius:
                                      //                   BorderRadius.circular(15),
                                      //             ),
                                      //             child: Column(
                                      //               children: [
                                      //                 SizedBox(
                                      //                   height: 3.h,
                                      //                 ),
                                      //                 Align(
                                      //                   alignment: Alignment.bottomCenter,
                                      //                   child: Image.asset(
                                      //                     "assets/images/svg_icon.png",
                                      //                     height: 5.9.h,
                                      //                     width: 5.6.h,
                                      //                   ),
                                      //                 ),
                                      //                 SizedBox(height: 2.h),
                                      //                 Text(
                                      //                   'OTP verification'.tr(),
                                      //                   style: TextStyle(
                                      //                       fontWeight: FontWeight.w600,
                                      //                       fontSize: 17.5.sp,
                                      //                       color: themeNotifier.isDark
                                      //                           ? AppColors.textColorWhite
                                      //                           : AppColors
                                      //                               .textColorBlack),
                                      //                 ),
                                      //                 SizedBox(
                                      //                   height: 2.h,
                                      //                 ),
                                      //                 Row(
                                      //                   mainAxisAlignment:
                                      //                       MainAxisAlignment.center,
                                      //                   children: [
                                      //                     otpContainer(
                                      //                       focusNode:
                                      //                           firstFieldFocusNode,
                                      //                       controller:
                                      //                       otp1Controller,
                                      //                       previousFocusNode: firstFieldFocusNode,
                                      //                       handler: () => FocusScope.of(
                                      //                               context)
                                      //                           .requestFocus(
                                      //                               secondFieldFocusNode),
                                      //                     ),
                                      //                     SizedBox(
                                      //                       width: 1.h,
                                      //                     ),
                                      //                     otpContainer(
                                      //                       focusNode:
                                      //                           secondFieldFocusNode,
                                      //                       controller:
                                      //                       otp2Controller,
                                      //                       previousFocusNode: firstFieldFocusNode,
                                      //                       handler: () => FocusScope.of(
                                      //                               context)
                                      //                           .requestFocus(
                                      //                               thirdFieldFocusNode),
                                      //                     ),
                                      //                     SizedBox(
                                      //                       width: 1.h,
                                      //                     ),
                                      //                     otpContainer(
                                      //                       focusNode:
                                      //                           thirdFieldFocusNode,
                                      //                       controller:
                                      //                       otp3Controller,
                                      //                       previousFocusNode: secondFieldFocusNode,
                                      //                       handler: () => FocusScope.of(
                                      //                               context)
                                      //                           .requestFocus(
                                      //                               forthFieldFocusNode),
                                      //                     ),
                                      //                     SizedBox(
                                      //                       width: 1.h,
                                      //                     ),
                                      //                     otpContainer(
                                      //                       focusNode:
                                      //                           forthFieldFocusNode,
                                      //                       controller:
                                      //                       otp4Controller,
                                      //                       previousFocusNode: thirdFieldFocusNode,
                                      //                       handler: () => FocusScope.of(
                                      //                               context)
                                      //                           .requestFocus(
                                      //                               fifthFieldFocusNode),
                                      //                     ),
                                      //                     SizedBox(
                                      //                       width: 1.h,
                                      //                     ),
                                      //                     otpContainer(
                                      //                       focusNode:
                                      //                           fifthFieldFocusNode,
                                      //                       controller:
                                      //                       otp5Controller,
                                      //                       previousFocusNode: forthFieldFocusNode,
                                      //                       handler: () => FocusScope.of(
                                      //                               context)
                                      //                           .requestFocus(
                                      //                               sixthFieldFocusNode),
                                      //                     ),
                                      //                     SizedBox(
                                      //                       width: 1.h,
                                      //                     ),
                                      //                     otpContainer(
                                      //                       focusNode:
                                      //                           sixthFieldFocusNode,
                                      //                       controller:
                                      //                       otp6Controller,
                                      //                       previousFocusNode: fifthFieldFocusNode,
                                      //                       handler: () => null,
                                      //                     ),
                                      //                   ],
                                      //                 ),
                                      //                 SizedBox(
                                      //                   height: 1.h,
                                      //                 ),
                                      //                 Text(
                                      //                   '*Incorrect verification code'
                                      //                       .tr(),
                                      //                   style: TextStyle(
                                      //                       color: AppColors.errorColor,
                                      //                       fontSize: 10.2.sp,
                                      //                       fontWeight: FontWeight.w400),
                                      //                 ),
                                      //                 SizedBox(
                                      //                   height: 2.h,
                                      //                 ),
                                      //                 Padding(
                                      //                   padding:EdgeInsets.symmetric(horizontal: 10.sp),
                                      //                   child: Text(
                                      //                     'Please enter the correct verification code sent your mobile number.'
                                      //                         .tr(),
                                      //                     textAlign: TextAlign.center,
                                      //                     style: TextStyle(
                                      //                         height: 1.4,
                                      //                         color:
                                      //                             AppColors.textColorGrey,
                                      //                         fontSize: 10.2.sp,
                                      //                         fontWeight: FontWeight.w400),
                                      //                   ),
                                      //                 ),
                                      //                 Expanded(child: SizedBox()),
                                      //                 Padding(
                                      //                   padding:
                                      //                       const EdgeInsets.symmetric(
                                      //                           horizontal: 22),
                                      //                   child: AppButton(
                                      //                     title: 'Verify'.tr(),
                                      //                     handler: () {
                                      //                       Navigator.pop(context);
                                      //                       showDialog(
                                      //                         context: context,
                                      //                         builder:
                                      //                             (BuildContext context) {
                                      //                           final screenWidth =
                                      //                               MediaQuery.of(context)
                                      //                                   .size
                                      //                                   .width;
                                      //                           final dialogWidth =
                                      //                               screenWidth * 0.85;
                                      //                           void
                                      //                               closeDialogAndNavigate() {
                                      //                             Navigator.of(context)
                                      //                                 .pop(); // Close the dialog// Close the dialog
                                      //                             Navigator.push(
                                      //                               context,
                                      //                               MaterialPageRoute(
                                      //                                 builder: (context) =>
                                      //                                     AccountInformation(),
                                      //                               ),
                                      //                             );
                                      //                           }
                                      //
                                      //                           Future.delayed(
                                      //                               Duration(seconds: 3),
                                      //                               closeDialogAndNavigate);
                                      //                           return Dialog(
                                      //                             shape:
                                      //                                 RoundedRectangleBorder(
                                      //                               borderRadius:
                                      //                                   BorderRadius
                                      //                                       .circular(
                                      //                                           8.0),
                                      //                             ),
                                      //                             backgroundColor:
                                      //                                 Colors.transparent,
                                      //                             child: BackdropFilter(
                                      //                                 filter: ImageFilter
                                      //                                     .blur(
                                      //                                         sigmaX: 7,
                                      //                                         sigmaY: 7),
                                      //                                 child: Container(
                                      //                                   height: 25.h,
                                      //                                   width:
                                      //                                       dialogWidth,
                                      //                                   decoration:
                                      //                                       BoxDecoration(
                                      //                                     // border: Border.all(
                                      //                                     //     width:
                                      //                                     //         0.1.h,
                                      //                                     //     color: AppColors
                                      //                                     //         .textColorGrey),
                                      //                                     color: themeNotifier.isDark
                                      //                                         ? AppColors
                                      //                                             .showDialogClr
                                      //                                         : AppColors
                                      //                                             .textColorWhite,
                                      //                                     borderRadius:
                                      //                                         BorderRadius
                                      //                                             .circular(
                                      //                                                 15),
                                      //                                   ),
                                      //                                   child: Column(
                                      //                                     mainAxisAlignment:
                                      //                                         MainAxisAlignment
                                      //                                             .center,
                                      //                                     children: [
                                      //                                       SizedBox(
                                      //                                         height: 4.h,
                                      //                                       ),
                                      //
                                      //                                       // SizedBox(height: 2.h),
                                      //                                       Row(
                                      //                                         mainAxisAlignment:
                                      //                                             MainAxisAlignment
                                      //                                                 .center,
                                      //                                         crossAxisAlignment:
                                      //                                             CrossAxisAlignment
                                      //                                                 .center,
                                      //                                         children: [
                                      //                                           Text(
                                      //                                             'Password Updated'.tr(),
                                      //                                             textAlign:
                                      //                                                 TextAlign.center,
                                      //                                             maxLines:
                                      //                                                 2,
                                      //                                             style: TextStyle(
                                      //                                                 fontWeight: FontWeight
                                      //                                                     .w600,
                                      //                                                 fontSize: 17
                                      //                                                     .sp,
                                      //                                                 color: themeNotifier.isDark
                                      //                                                     ? AppColors.textColorWhite
                                      //                                                     : AppColors.textColorBlack),
                                      //                                           ),
                                      //                                           SizedBox(
                                      //                                             width:
                                      //                                                 1.h,
                                      //                                           ),
                                      //                                           Image
                                      //                                               .asset(
                                      //                                             "assets/images/check_circle.png",
                                      //                                             height:
                                      //                                                 4.h,
                                      //                                             width:
                                      //                                                 4.h,
                                      //                                           ),
                                      //                                         ],
                                      //                                       ),
                                      //                                       SizedBox(
                                      //                                         height: 2.h,
                                      //                                       ),
                                      //                                       Padding(
                                      //                                         padding: const EdgeInsets
                                      //                                                 .symmetric(
                                      //                                             horizontal:
                                      //                                                 20),
                                      //                                         child: Text(
                                      //                                           'Your password is now updated. Please remember to secure your password.'.tr(),
                                      //                                           textAlign:
                                      //                                               TextAlign
                                      //                                                   .center,
                                      //                                           style: TextStyle(
                                      //                                               height:
                                      //                                                   1.4,
                                      //                                               fontWeight: FontWeight
                                      //                                                   .w400,
                                      //                                               fontSize:
                                      //                                                   16,
                                      //                                               color:
                                      //                                                   AppColors.textColorGrey),
                                      //                                         ),
                                      //                                       ),
                                      //                                       SizedBox(
                                      //                                         height: 4.h,
                                      //                                       ),
                                      //                                     ],
                                      //                                   ),
                                      //                                 )),
                                      //                           );
                                      //                         },
                                      //                       );
                                      //                     },
                                      //                     isGradient: true,
                                      //                     color: Colors.transparent,
                                      //                     textColor:
                                      //                         AppColors.textColorBlack,
                                      //                   ),
                                      //                 ),
                                      //                 SizedBox(height: 2.h),
                                      //                 Padding(
                                      //                   padding:
                                      //                       const EdgeInsets.symmetric(
                                      //                           horizontal: 22),
                                      //                   child: AppButton(
                                      //                       title:
                                      //                           'Resend code 06:00'.tr(),
                                      //                       handler: () {
                                      //                         // Navigator.push(
                                      //                         //   context,
                                      //                         //   MaterialPageRoute(
                                      //                         //     builder: (context) => TermsAndConditions(),
                                      //                         //   ),
                                      //                         // );
                                      //                       },
                                      //                       isGradient: false,
                                      //                       textColor: themeNotifier
                                      //                               .isDark
                                      //                           ? AppColors.textColorWhite
                                      //                           : AppColors.textColorBlack
                                      //                               .withOpacity(0.8),
                                      //                       color: Colors.transparent),
                                      //                 ),
                                      //                 Expanded(child: SizedBox()),
                                      //               ],
                                      //             ),
                                      //           )),
                                      //     );
                                      //   },
                                      // );

                                      // reset passord dialoge
                                      // showDialog(
                                      //   context: context,
                                      //   builder: (BuildContext context) {
                                      //     final screenWidth =
                                      //         MediaQuery.of(context).size.width;
                                      //     final dialogWidth = screenWidth * 0.85;
                                      //     void closeDialogAndNavigate() {
                                      //       Navigator.of(context).pop(); // Close the dialog
                                      //       Navigator.of(context).pop(); // Close the dialog
                                      //     }
                                      //
                                      //     Future.delayed(Duration(seconds: 3), closeDialogAndNavigate);
                                      //     return
                                      //       Dialog(
                                      //         shape: RoundedRectangleBorder(
                                      //           borderRadius: BorderRadius.circular(8.0),
                                      //         ),
                                      //         backgroundColor: Colors.transparent,
                                      //         child: BackdropFilter(
                                      //             filter: ImageFilter.blur(
                                      //                 sigmaX: 7, sigmaY: 7),
                                      //             child: Container(
                                      //               height: 30.h,
                                      //               width: dialogWidth,
                                      //               decoration: BoxDecoration(
                                      //
                                      //                 color: AppColors.showDialogClr,
                                      //                 borderRadius:
                                      //                 BorderRadius.circular(15),
                                      //               ),
                                      //               child: Column(
                                      //                 mainAxisAlignment: MainAxisAlignment.start,
                                      //                 children: [
                                      //                   SizedBox(
                                      //                     height: 4.h,
                                      //                   ),
                                      //                   Align(
                                      //                     alignment:
                                      //                     Alignment.bottomCenter,
                                      //                     child: Image.asset(
                                      //                       "assets/images/check_circle.png",
                                      //                       height: 6.h,
                                      //                       width: 5.8.h,
                                      //                     ),
                                      //                   ),
                                      //                   SizedBox(height: 2.h),
                                      //                   Text(
                                      //                     'Reset Password\nCompleted',
                                      //                     textAlign: TextAlign.center,
                                      //                     maxLines: 2,
                                      //                     style: TextStyle(
                                      //                         fontWeight: FontWeight.w600,
                                      //                         fontSize: 17.sp,
                                      //                         color: AppColors
                                      //                             .textColorWhite),
                                      //                   ),
                                      //                   SizedBox(
                                      //                     height: 2.h,
                                      //                   ),
                                      //                   Padding(
                                      //                     padding: const EdgeInsets.symmetric(horizontal: 20),
                                      //                     child: Text(
                                      //                       'Your password is now update. Please remember to secure your password. ',
                                      //                       textAlign: TextAlign.center,
                                      //                       style: TextStyle(
                                      //                           height: 1.4,
                                      //                           fontWeight: FontWeight.w400,
                                      //                           fontSize: 10.2.sp,
                                      //                           color: AppColors.textColorGrey),
                                      //                     ),
                                      //
                                      //                   ),
                                      //                   SizedBox(
                                      //                     height: 4.h,
                                      //                   ),
                                      //                 ],
                                      //               ),
                                      //             )),
                                      //       );
                                      //   },
                                      // );
                                    },
                                    isGradient: true,
                                    color: Colors.transparent,
                                    textColor: AppColors.textColorBlack,
                                  ),
                                ),
                              ),
                              Container(
                                height: 4.h,
                                width: double.infinity,
                                color: AppColors.backgroundColor,
                              ),
                            ],
                          ),
                        ),
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

  Widget otpContainer({
    required FocusNode focusNode,
    required FocusNode previousFocusNode,
    required TextEditingController controller,
    required Function handler,
  }) {
    return Container(
      child: TextField(
        focusNode: focusNode,
        // onChanged: (value) => handler(),
        onChanged: (value) {
          if (value.isEmpty) {
            focusNode.requestFocus();
            if (controller.text.isNotEmpty) {
              controller.clear();
              handler();
            } else {
              // Move focus to the previous SMSVerificationTextField
              // and clear its value recursively
              // FocusScope.of(context).previousFocus();
              previousFocusNode.requestFocus();
            }
          } else {
            handler();
          }
        },
        keyboardType: TextInputType.number,
        cursorColor: AppColors.textColorGrey,
        // obscureText: true,
        maxLength: 1,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
        ],
        // Hide the entered OTP digits
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.bottom,
        style: TextStyle(
          color: AppColors.textColorGrey,
          fontSize: 17.5.sp,
          // fontWeight: FontWeight.bold,
          // letterSpacing: 16,
        ),
        decoration: InputDecoration(
          counterText: '', // Hide the default character counter
          contentPadding: EdgeInsets.only(top: 16, bottom: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.textColorGrey,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.textColorGrey,
              width: 1,
            ),
          ),
        ),
      ),
      height: 8.h,
      width: 10.w,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
