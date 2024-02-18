import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/providers/user_provider.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/button.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../providers/theme_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_header.dart';
import '../userpayment_and_bankingpages/wallet_add_bank.dart';
import '../userpayment_and_bankingpages/wallet_add_card.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({Key? key}) : super(key: key);

  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _identificationNumberController =
      TextEditingController();

  FocusNode firstFieldFocusNode = FocusNode();
  FocusNode secondFieldFocusNode = FocusNode();
  FocusNode thirdFieldFocusNode = FocusNode();
  FocusNode forthFieldFocusNode = FocusNode();
  FocusNode fifthFieldFocusNode = FocusNode();
  FocusNode sixthFieldFocusNode = FocusNode();

  String firstName = '';
  String lastName = '';
  String mobileNum = '';
  String idNumber = '';
  String username = '';
  String email = '';
  bool isValidating = false;
  bool isButtonActive = false;
  bool isEditAble = false;
  var _isLoading = false;
  var accessToken = "";

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    // print(accessToken);
  }

  Future<void> init() async {
    await getAccessToken();
    print("this is token" + accessToken);
    var userDetails = await Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
    setState(() {
      _isLoading = false;
    });
    setState(() {
      mobileNum = userDetails
          .mobileNum!; // Assuming 'mobileNum' is a field in userDetails
      _numberController.text = mobileNum.substring(4);
      firstName = userDetails
          .firstName!; // Assuming 'firstName' is a field in userDetails
      _firstnameController.text = firstName;
      lastName = userDetails
          .lastName!; // Assuming 'firstName' is a field in userDetails
      _lastnameController.text = lastName;
      idNumber = userDetails
          .idNumber!; // Assuming 'firstName' is a field in userDetails
      _identificationNumberController.text = idNumber;
      username = userDetails
          .userName!; // Assuming 'firstName' is a field in userDetails
      _usernameController.text =
          username; // Set retrieved firstName in the controller
    });
  }

  @override
  void initState() {
    super.initState();
    init();
    // getAccessToken();

    // Listen for changes in the text fields and update the button state
    _firstnameController.addListener(_updateButtonState);
    _usernameController.addListener(_updateButtonState);
    _numberController.addListener(_updateButtonState);
    _lastnameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _firstnameController.text.isNotEmpty &&
          // _usernameController.text.isNotEmpty &&
          // _lastnameController.text.isNotEmpty;
          // &&
          // _emailController.text.isNotEmpty &&
          _numberController.text.isNotEmpty;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
     Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _usernameController.dispose();
    _numberController.dispose();
    _lastnameController.dispose();
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
                MainHeader(title: 'Account information'.tr()),
                // SizedBox(
                //   height: 2.h,
                // ),
                // _isLoading ? CircularProgressIndicator(
                //   color: AppColors.profileHeaderDark,
                // ) :
                Expanded(
                  child: Container(
                    height: 85.h,
                    // color: Colors.red,
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
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: isEditAble
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                                right: 2.sp,
                                                top: 18.sp,
                                                bottom: 10.sp),
                                            child: GestureDetector(
                                              onTap: () => setState(() {
                                                isEditAble = false;
                                              }),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isEditAble = true;
                                              });
                                            },
                                            child: Image.asset(
                                              "assets/images/edit_information.png",
                                              height: 6.h,
                                              width: 6.w,
                                            ),
                                          )),
                                // SizedBox(
                                //   height: 4.h,
                                // ),
                                // SizedBox(height: 2.h,),
                                Align(
                                  alignment: isEnglish
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: Text(
                                    'First Name'.tr(),
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
                                      readOnly: isEditAble ? false : true,
                                      controller: _firstnameController,
                                      keyboardType: TextInputType.name,
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom+200),
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
                                        // hintText: 'No payment card have been added',
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
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_firstnameController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      "*Enter first name",
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w400,
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
                                    'Last Name'.tr(),
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
                                      readOnly: true,
                                      controller: _lastnameController,
                                      keyboardType: TextInputType.name,
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
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
                                        // hintText: 'No banking have been added',
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
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_lastnameController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      "*Enter last name",
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w400,
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
                                    'Username'.tr(),
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
                                      readOnly: true,
                                      controller: _usernameController,
                                      keyboardType: TextInputType.name,
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
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
                                        // hintText: 'No banking have been added',
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
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_usernameController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      "*Enter username",
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w400,
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
                                    'Mobile Number'.tr(),
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
                                      readOnly: isEditAble ? false : true,
                                      controller: _numberController,
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom +
                                              140),
                                      keyboardType: TextInputType.number,
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
                                        // hintText: 'Enter your Mobile Number',
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

                                        prefixIcon: Padding(
                                          padding: EdgeInsets.only(
                                              left: 12.sp,
                                              top: 12.4.sp,
                                              right: 12.sp),
                                          child: Text(
                                            '+966',
                                            style: TextStyle(
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_numberController.text.isEmpty && isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      "*Enter number",
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                // SizedBox(
                                //   height: 2.h,
                                // ),
                                // Align(
                                //   alignment: isEnglish
                                //       ? Alignment.centerLeft
                                //       : Alignment.centerRight,
                                //   child: Text(
                                //     'Email Address'.tr(),
                                //     style: TextStyle(
                                //         fontSize: 11.7.sp,
                                //         fontFamily: 'Inter',
                                //         fontWeight: FontWeight.w600,
                                //         color: themeNotifier.isDark
                                //             ? AppColors.textColorWhite
                                //             : AppColors.textColorBlack),
                                //   ),
                                // ),
                                // SizedBox(
                                //   height: 1.h,
                                // ),
                                // TextFieldParent(
                                //   child: TextField(
                                //       readOnly: isEditAble ? false : true,
                                //       controller: _emailController,
                                //       scrollPadding: EdgeInsets.only(
                                //           bottom: MediaQuery.of(context)
                                //               .viewInsets
                                //               .bottom),
                                //       keyboardType: TextInputType.emailAddress,
                                //       style: TextStyle(
                                //           fontSize: 10.2.sp,
                                //           color: themeNotifier.isDark
                                //               ? AppColors.textColorWhite
                                //               : AppColors.textColorBlack,
                                //           fontWeight: FontWeight.w400,
                                //           // Off-white color,
                                //           fontFamily: 'Inter'),
                                //       decoration: InputDecoration(
                                //         contentPadding: EdgeInsets.symmetric(
                                //             vertical: 10.0, horizontal: 16.0),
                                //         // hintText: 'No banking have been added',
                                //         hintStyle: TextStyle(
                                //             fontSize: 10.2.sp,
                                //             color: AppColors.textColorGrey,
                                //             fontWeight: FontWeight.w400,
                                //             // Off-white color,
                                //             fontFamily: 'Inter'),
                                //         enabledBorder: OutlineInputBorder(
                                //             borderRadius:
                                //                 BorderRadius.circular(8.0),
                                //             borderSide: BorderSide(
                                //               color: Colors.transparent,
                                //               // Off-white color
                                //               // width: 2.0,
                                //             )),
                                //         focusedBorder: OutlineInputBorder(
                                //             borderRadius:
                                //                 BorderRadius.circular(8.0),
                                //             borderSide: BorderSide(
                                //               color: Colors.transparent,
                                //               // Off-white color
                                //               // width: 2.0,
                                //             )),
                                //         // labelText: 'Enter your password',
                                //       ),
                                //       cursorColor: AppColors.textColorGrey),
                                // ),
                                // if (_emailController.text.isEmpty && isValidating)
                                //   Padding(
                                //     padding: EdgeInsets.only(top: 7.sp),
                                //     child: Text(
                                //       "*Email unverified - resend verification.",
                                //       style: TextStyle(
                                //           fontSize: 10.sp,
                                //           fontWeight: FontWeight.w400,
                                //           color: AppColors.errorColor),
                                //     ),
                                //   ),

                                SizedBox(
                                  height: 2.h,
                                ),
                                // Align(
                                //   alignment: isEnglish
                                //       ? Alignment.centerLeft
                                //       : Alignment.centerRight,
                                //   child: Text(
                                //     'Nationality'.tr(),
                                //     style: TextStyle(
                                //         fontSize: 11.7.sp,
                                //         fontFamily: 'Inter',
                                //         fontWeight: FontWeight.w600,
                                //         color: themeNotifier.isDark
                                //             ? AppColors.textColorWhite
                                //             : AppColors.textColorBlack),
                                //   ),
                                // ),
                                // SizedBox(
                                //   height: 1.h,
                                // ),
                                // TextFieldParent(
                                //   child: TextField(
                                //       readOnly: isEditAble ? false : true,
                                //       // controller: _usernameController,
                                //       keyboardType: TextInputType.name,
                                //       scrollPadding: EdgeInsets.only(
                                //           bottom: MediaQuery.of(context)
                                //               .viewInsets
                                //               .bottom),
                                //       style: TextStyle(
                                //           fontSize: 10.2.sp,
                                //           color: themeNotifier.isDark
                                //               ? AppColors.textColorWhite
                                //               : AppColors.textColorBlack,
                                //           fontWeight: FontWeight.w400,
                                //           // Off-white color,
                                //           fontFamily: 'Inter'),
                                //       decoration: InputDecoration(
                                //         contentPadding: EdgeInsets.symmetric(
                                //             vertical: 10.0, horizontal: 16.0),
                                //         // hintText: 'No banking have been added',
                                //         hintStyle: TextStyle(
                                //             fontSize: 10.2.sp,
                                //             color: AppColors.textColorGrey,
                                //             fontWeight: FontWeight.w400,
                                //             // Off-white color,
                                //             fontFamily: 'Inter'),
                                //         enabledBorder: OutlineInputBorder(
                                //             borderRadius:
                                //                 BorderRadius.circular(8.0),
                                //             borderSide: BorderSide(
                                //               color: Colors.transparent,
                                //               // Off-white color
                                //               // width: 2.0,
                                //             )),
                                //         focusedBorder: OutlineInputBorder(
                                //             borderRadius:
                                //                 BorderRadius.circular(8.0),
                                //             borderSide: BorderSide(
                                //               color: Colors.transparent,
                                //               // Off-white color
                                //               // width: 2.0,
                                //             )),
                                //         // labelText: 'Enter your password',
                                //       ),
                                //       cursorColor: AppColors.textColorGrey),
                                // ),
                                // if (_usernameController.text.isEmpty &&
                                //     isValidating)
                                //   Padding(
                                //     padding: EdgeInsets.only(top: 7.sp),
                                //     child: Text(
                                //       "*Enter username",
                                //       style: TextStyle(
                                //           fontSize: 10.sp,
                                //           fontWeight: FontWeight.w400,
                                //           color: AppColors.errorColor),
                                //     ),
                                //   ),

                                // SizedBox(
                                //   height: 2.h,
                                // ),
                                Align(
                                  alignment: isEnglish
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: Text(
                                    'Identification Number'.tr(),
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
                                      readOnly: true,
                                      controller: _identificationNumberController,
                                      keyboardType: TextInputType.name,
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
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
                                        // hintText: 'No banking have been added',
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
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_identificationNumberController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      "*Enter Identification Number",
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                // Expanded(child: SizedBox()),

                                // SizedBox(
                                //   height: 2.h,
                                // ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 0,
                          child: Column(
                            children: [
                              Container(
                                height: 2.h,
                                width: double.infinity,
                                color: AppColors.backgroundColor,
                              ),
                              Container(
                                color: AppColors.backgroundColor,
                                child: AppButton(
                                    title: 'Save changes'.tr(),
                                    isactive:
                                    isEditAble && isButtonActive ? true : false,
                                    handler: () async {
                                      setState(() {
                                        isValidating = true;
                                      });
                                      print(_firstnameController.text);
                                      print(_numberController.text);
                                      if (_firstnameController.text.isNotEmpty &&
                                          _numberController.text.isNotEmpty &&
                                          isEditAble == true

                                      ) {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        var result = Provider.of<UserProvider>(
                                            context,
                                            listen: false)
                                            .userUpdate(
                                          context: context,
                                          token: accessToken,
                                          editableFirstName:
                                          _firstnameController.text,
                                          editableMobileNum:
                                          '+966' + _numberController.text,
                                        );
                                        await Future.delayed(Duration(milliseconds: 1500),
                                                (){});
                                        setState(() {
                                          _isLoading =
                                          false;
                                        });
                                        if (result == AuthResult.success) {
                                          _refreshData();
                                        }
                                      }

                                      // if (isButtonActive)
                                      //   showDialog(
                                      //     context: context,
                                      //     builder: (BuildContext context) {
                                      //       final screenWidth =
                                      //           MediaQuery.of(context).size.width;
                                      //       final dialogWidth = screenWidth * 0.85;
                                      //       return Dialog(
                                      //         shape: RoundedRectangleBorder(
                                      //           borderRadius:
                                      //               BorderRadius.circular(8.0),
                                      //         ),
                                      //         backgroundColor: Colors.transparent,
                                      //         child: BackdropFilter(
                                      //             filter: ImageFilter.blur(
                                      //                 sigmaX: 7, sigmaY: 7),
                                      //             child: Container(
                                      //               height: 55.h,
                                      //               width: dialogWidth,
                                      //               decoration: BoxDecoration(
                                      //                 // border: Border.all(
                                      //                 //     width: 0.1.h,
                                      //                 //     color: AppColors.textColorGrey),
                                      //                 color: themeNotifier.isDark
                                      //                     ? AppColors.showDialogClr
                                      //                     : AppColors.textColorWhite,
                                      //                 borderRadius:
                                      //                     BorderRadius.circular(15),
                                      //               ),
                                      //               child: Column(
                                      //                 children: [
                                      //                   SizedBox(
                                      //                     height: 3.h,
                                      //                   ),
                                      //                   Align(
                                      //                     alignment:
                                      //                         Alignment.bottomCenter,
                                      //                     child: Image.asset(
                                      //                       "assets/images/svg_icon.png",
                                      //                       height: 5.9.h,
                                      //                       width: 5.6.h,
                                      //                     ),
                                      //                   ),
                                      //                   SizedBox(height: 2.h),
                                      //                   Text(
                                      //                     'OTP verification'.tr(),
                                      //                     style: TextStyle(
                                      //                         fontWeight:
                                      //                             FontWeight.w600,
                                      //                         fontSize: 17.5.sp,
                                      //                         color: themeNotifier
                                      //                                 .isDark
                                      //                             ? AppColors
                                      //                                 .textColorWhite
                                      //                             : AppColors
                                      //                                 .textColorBlack),
                                      //                   ),
                                      //                   SizedBox(
                                      //                     height: 2.h,
                                      //                   ),
                                      //                   Row(
                                      //                     mainAxisAlignment:
                                      //                         MainAxisAlignment
                                      //                             .center,
                                      //                     children: [
                                      //                       otpContainer(
                                      //                         focusNode:
                                      //                             firstFieldFocusNode,
                                      //                         handler: () => FocusScope
                                      //                                 .of(context)
                                      //                             .requestFocus(
                                      //                                 secondFieldFocusNode),
                                      //                       ),
                                      //                       SizedBox(
                                      //                         width: 1.h,
                                      //                       ),
                                      //                       otpContainer(
                                      //                         focusNode:
                                      //                             secondFieldFocusNode,
                                      //                         handler: () => FocusScope
                                      //                                 .of(context)
                                      //                             .requestFocus(
                                      //                                 thirdFieldFocusNode),
                                      //                       ),
                                      //                       SizedBox(
                                      //                         width: 1.h,
                                      //                       ),
                                      //                       otpContainer(
                                      //                         focusNode:
                                      //                             thirdFieldFocusNode,
                                      //                         handler: () => FocusScope
                                      //                                 .of(context)
                                      //                             .requestFocus(
                                      //                                 forthFieldFocusNode),
                                      //                       ),
                                      //                       SizedBox(
                                      //                         width: 1.h,
                                      //                       ),
                                      //                       otpContainer(
                                      //                         focusNode:
                                      //                             forthFieldFocusNode,
                                      //                         handler: () => FocusScope
                                      //                                 .of(context)
                                      //                             .requestFocus(
                                      //                                 fifthFieldFocusNode),
                                      //                       ),
                                      //                       SizedBox(
                                      //                         width: 1.h,
                                      //                       ),
                                      //                       otpContainer(
                                      //                         focusNode:
                                      //                             fifthFieldFocusNode,
                                      //                         handler: () => FocusScope
                                      //                                 .of(context)
                                      //                             .requestFocus(
                                      //                                 sixthFieldFocusNode),
                                      //                       ),
                                      //                       SizedBox(
                                      //                         width: 1.h,
                                      //                       ),
                                      //                       otpContainer(
                                      //                         focusNode:
                                      //                             sixthFieldFocusNode,
                                      //                         handler: () => null,
                                      //                       ),
                                      //                     ],
                                      //                   ),
                                      //                   SizedBox(
                                      //                     height: 1.h,
                                      //                   ),
                                      //                   // Text(
                                      //                   //   '*Incorrect verification code'.tr(),
                                      //                   //   style: TextStyle(
                                      //                   //       color: AppColors.errorColor,
                                      //                   //       fontSize: 10.2.sp,
                                      //                   //       fontWeight: FontWeight.w400),
                                      //                   // ),
                                      //                   SizedBox(
                                      //                     height: 2.h,
                                      //                   ),
                                      //                   Padding(
                                      //                     padding:
                                      //                         EdgeInsets.symmetric(
                                      //                             horizontal: 5.sp),
                                      //                     child: Text(
                                      //                       'Please enter the correct verification code sent your mobile number.'
                                      //                           .tr(),
                                      //                       textAlign:
                                      //                           TextAlign.center,
                                      //                       style: TextStyle(
                                      //                           height: 1.4,
                                      //                           color: AppColors
                                      //                               .textColorGrey,
                                      //                           fontSize: 10.2.sp,
                                      //                           fontWeight:
                                      //                               FontWeight.w400),
                                      //                       maxLines: 2,
                                      //                     ),
                                      //                   ),
                                      //                   Expanded(child: SizedBox()),
                                      //                   Padding(
                                      //                     padding: const EdgeInsets
                                      //                         .symmetric(
                                      //                         horizontal: 22),
                                      //                     child: AppButton(
                                      //                       title: 'Confirm'.tr(),
                                      //                       handler: () {
                                      //                         Navigator.pop(context);
                                      //                       },
                                      //                       isGradient: true,
                                      //                       color: Colors.transparent,
                                      //                       textColor: AppColors
                                      //                           .textColorBlack,
                                      //                     ),
                                      //                   ),
                                      //                   SizedBox(height: 2.h),
                                      //                   Padding(
                                      //                     padding: const EdgeInsets
                                      //                         .symmetric(
                                      //                         horizontal: 22),
                                      //                     child: AppButton(
                                      //                         title:
                                      //                             'Resend code 06:00'
                                      //                                 .tr(),
                                      //                         handler: () {
                                      //                           // Navigator.push(
                                      //                           //   context,
                                      //                           //   MaterialPageRoute(
                                      //                           //     builder: (context) => TermsAndConditions(),
                                      //                           //   ),
                                      //                           // );
                                      //                         },
                                      //                         isGradient: false,
                                      //                         textColor: themeNotifier
                                      //                                 .isDark
                                      //                             ? AppColors
                                      //                                 .textColorWhite
                                      //                             : AppColors
                                      //                                 .textColorBlack
                                      //                                 .withOpacity(
                                      //                                     0.8),
                                      //                         color:
                                      //                             Colors.transparent),
                                      //                   ),
                                      //                   Expanded(child: SizedBox()),
                                      //                 ],
                                      //               ),
                                      //             )),
                                      //       );
                                      //     },
                                      //   );
                                    },
                                    // isLoading: _isLoading,
                                    isGradient: true,
                                    color: AppColors.textColorBlack),
                              ),
                              Container(
                                height: 4.h,
                                width: double.infinity,
                                color: AppColors.backgroundColor,
                              ),

                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if(_isLoading)
            LoaderBluredScreen()
        ],
      );
    });
  }

  Widget otpContainer({
    required FocusNode focusNode,
    required Function handler,
  }) {
    return Container(
      child: TextField(
        focusNode: focusNode,
        onChanged: (value) => handler(),
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
          letterSpacing: 16,
        ),
        decoration: InputDecoration(
          counterText: '', // Hide the default character counter
          contentPadding: EdgeInsets.only(left: 11, top: 16, bottom: 16),
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
