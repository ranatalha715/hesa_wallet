import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'dart:io' as OS;
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/screens/user_profile_pages/wallet_tokens_nfts.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';
import '../../widgets/otp_dialog.dart';

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

  FocusNode oldPasswordFocusNode = FocusNode();
  FocusNode newPasswordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

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
  final TextEditingController _oldPasswordController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final TextEditingController _numberController = TextEditingController();

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
  bool _isTimerActive = false;
  bool isOtpButtonActive = false;
  var _isLoadingResend = false;
  Timer? _timer;
  int _timeLeft = 60;
  StreamController<int> _events = StreamController<int>.broadcast();
  bool isButtonActive = false;
  var _isLoadingOtpDialoge = false;
  bool isValidating = false;
  var _isLoading = false;
  var accessToken = "";

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  void _updateOtpButtonState() {
    setState(() {
      isOtpButtonActive = otp1Controller.text.isNotEmpty &&
          otp2Controller.text.isNotEmpty &&
          otp3Controller.text.isNotEmpty &&
          otp4Controller.text.isNotEmpty &&
          otp5Controller.text.isNotEmpty &&
          otp6Controller.text.isNotEmpty;
    });
  }

  @override
  initState() {
    getAccessToken();
    Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
    Provider.of<AuthProvider>(context, listen: false).changePasswordError =
        null;
    super.initState();
    _events = new StreamController<int>();
    _events.add(60);
    _newPasswordController.addListener(_updateButtonState);
    _oldPasswordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
    otp1Controller.addListener(_updateOtpButtonState);
    otp2Controller.addListener(_updateOtpButtonState);
    otp3Controller.addListener(_updateOtpButtonState);
    otp4Controller.addListener(_updateOtpButtonState);
    otp5Controller.addListener(_updateOtpButtonState);
    otp6Controller.addListener(_updateOtpButtonState);
  }

  void updateDialogBoxButtonState() {
    setState(() {
      isOtpButtonActive = true;
    });
  }

  void startTimer() {
    // Cancel the previous timer if it's active
    _timer?.cancel();
    _timeLeft = 60;
    _isTimerActive = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
      }
      print(_timeLeft);
      _events.add(_timeLeft);
    });
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _newPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _oldPasswordController.text.isNotEmpty;
    });
  }

  void restartCountdown() {
    // Reset the countdown to 60 seconds
    _events.add(60);
    Timer.periodic(Duration(seconds: 1), (timer) async {
      var events;
      if (events.hasListener) {
        final currentTime = await events.stream.first;
        if (currentTime > 0) {
          events.add(currentTime - 1);
        } else {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Consumer<UserProvider>(builder: (context, user, child) {
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
                                  Text(
                                    "Please start by entering your current password."
                                        .tr(),
                                    style: TextStyle(
                                        color: AppColors.textColorWhite,
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
                                        // scrollPadding: EdgeInsets.only(
                                        //     bottom: MediaQuery.of(context)
                                        //         .viewInsets
                                        //         .bottom),
                                        controller: _oldPasswordController,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        focusNode: oldPasswordFocusNode,
                                        textInputAction: TextInputAction.next,
                                        onEditingComplete: () {
                                          newPasswordFocusNode.requestFocus();
                                        },
                                        onChanged: (v) {
                                          auth.changePasswordError = null;
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
                                              horizontal: OS.Platform.isIOS
                                                  ? 10.sp
                                                  : 16.0),
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
                                                            _oldPasswordController
                                                                .text
                                                                .isEmpty) ||
                                                        auth.changePasswordError
                                                            .toString()
                                                            .contains(
                                                                'Old Password') ||
                                                    auth.changePasswordError
                                                        .toString()
                                                        .contains('كلمة المرور')
                                                    ? AppColors.errorColor
                                                    : Colors.transparent,
                                                // Off-white color
                                                // width: 2.0,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: AppColors
                                                    .focusTextFieldColor,
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
                                            onPressed:
                                                _togglePasswordVisibility,
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
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
                                  if (auth.changePasswordError != null &&
                                      _oldPasswordController.text.isNotEmpty &&
                                      isValidating &&
                                      auth.changePasswordError
                                          .toString()
                                          .contains('Old Password') ||
                                      auth.changePasswordError
                                          .toString()
                                          .contains('كلمة المرور')
                                  )
                                    Padding(
                                      padding: EdgeInsets.only(top: 7.sp),
                                      child: Text(
                                         "*${auth.changePasswordError}",
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
                                        // scrollPadding: EdgeInsets.only(
                                        //     bottom: MediaQuery.of(context)
                                        //         .viewInsets
                                        //         .bottom),
                                        controller: _newPasswordController,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        obscureText: _obscurePasswordNew,
                                        focusNode: newPasswordFocusNode,
                                        textInputAction: TextInputAction.next,
                                        onEditingComplete: () {
                                          confirmPasswordFocusNode
                                              .requestFocus();
                                        },
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
                                              vertical: OS.Platform.isIOS
                                                  ? 14.5.sp
                                                  : 10.0,
                                              horizontal: OS.Platform.isIOS
                                                  ? 10.sp
                                                  : 16.0),
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
                                                        _newPasswordController
                                                            .text.isEmpty)
                                                    ? AppColors.errorColor
                                                    : Colors.transparent,
                                                // Off-white color
                                                // width: 2.0,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: AppColors
                                                    .focusTextFieldColor,
                                              )),
                                          // labelText: 'Enter your password',
                                          suffixIcon: Material(
                                            color: Colors.transparent,
                                            elevation: 0.0,
                                            child: IconButton(
                                              icon: Icon(
                                                  _obscurePasswordNew
                                                      ? Icons
                                                          .visibility_outlined
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  size: 17.5.sp,
                                                  color:
                                                      AppColors.textColorGrey),
                                              onPressed:
                                                  _togglePasswordVisibilityNew,
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              hoverColor: Colors.transparent,
                                            ),
                                          ),
                                        ),
                                        cursorColor: AppColors.textColorGrey),
                                  ),
                                  if (_newPasswordController.text.isEmpty &&
                                      isValidating)
                                    if (_confirmPasswordController
                                            .text.isEmpty &&
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
                                    controller: _scrollController,
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: accountDefinitions.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      bool conditionMet;
                                      switch (index) {
                                        case 0:
                                          conditionMet =
                                              _hasUppercase && _hasLowercase;
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 4.0, right: 8.0),
                                            child: Icon(
                                              Icons.fiber_manual_record,
                                              size: 7.sp,
                                              color: _newPasswordController
                                                      .text.isEmpty
                                                  ? AppColors.textColorGrey
                                                  : conditionMet
                                                      ? AppColors.hexaGreen
                                                      : AppColors.errorColor,
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 3),
                                              child: Text(
                                                accountDefinitions[index],
                                                style: TextStyle(
                                                  color: _newPasswordController
                                                          .text.isEmpty
                                                      ? AppColors.textColorGrey
                                                      : conditionMet
                                                          ? AppColors.hexaGreen
                                                          : AppColors
                                                              .errorColor,
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
                                        focusNode: confirmPasswordFocusNode,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (v) {
                                          auth.changePasswordError = null;
                                        },
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
                                              vertical: OS.Platform.isIOS
                                                  ? 14.5.sp
                                                  : 10.0,
                                              horizontal: OS.Platform.isIOS
                                                  ? 10.sp
                                                  : 16.0),
                                          hintText:
                                              'Confirm your password'.tr(),
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
                                                            _confirmPasswordController
                                                                .text
                                                                .isEmpty) ||
                                                        auth.changePasswordError
                                                            .toString()
                                                            .contains('match')
                                                    ? AppColors.errorColor
                                                    : Colors.transparent,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: AppColors
                                                    .focusTextFieldColor,
                                              )),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                                _obscurePasswordConfirm
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                                size: 17.5.sp,
                                                color: AppColors.textColorGrey),
                                            onPressed:
                                                _togglePasswordVisibilityConfirm,
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
                                        "*Confirm Password should not be empty"
                                            .tr(),
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.errorColor),
                                      ),
                                    ),
                                  if (auth.changePasswordError != null &&
                                      _confirmPasswordController
                                          .text.isNotEmpty &&
                                      isValidating &&
                                      auth.changePasswordError
                                          .toString()
                                          .contains('match'))
                                    Padding(
                                      padding: EdgeInsets.only(top: 7.sp),
                                      child: Text(
                                        isEnglish
                                            ? "*${auth.changePasswordError}"
                                            : "*كلمة المرور غير متطابقة",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10.sp,
                                            color: AppColors.errorColor),
                                      ),
                                    ),
                                  SizedBox(
                                    height: OS.Platform.isIOS ? 12.h : 14.h,
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        color: themeNotifier.isDark
                                            ? AppColors.backgroundColor
                                            : AppColors.textColorWhite,
                                        child: AppButton(
                                          title: 'Change password'.tr(),
                                          isactive:
                                              isButtonActive ? true : false,
                                          handler: () async {
                                            setState(() {
                                              isValidating = true;
                                            });
                                            if (_oldPasswordController.text.isNotEmpty &&
                                                _newPasswordController
                                                    .text.isNotEmpty &&
                                                _confirmPasswordController
                                                    .text.isNotEmpty) {
                                              setState(() {
                                                _isLoading = true;
                                                if (_isLoading) {
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                }
                                                auth.changePasswordError = null;
                                              });
                                              final String password =
                                                  _oldPasswordController.text;
                                              final bytes =
                                                  utf8.encode(password);
                                              final sha512Hash =
                                                  sha512.convert(bytes);
                                              final sha512String =
                                                  sha512Hash.toString();
                                              var result = await Provider.of<
                                                          AuthProvider>(
                                                      context,
                                                      listen: false)
                                                  .changePasswordStep1(
                                                      oldPassword: sha512String,
                                                      newPassword:
                                                          _newPasswordController
                                                              .text,
                                                      confirmPassword:
                                                          _confirmPasswordController
                                                              .text,
                                                      context: context,
                                                      isEnglish:isEnglish,
                                                      token: accessToken);
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              if (result ==
                                                  AuthResult.success) {
                                                startTimer();
                                                otpDialog(
                                                  fromAuth: false,
                                                  fromUser: true,
                                                  fromTransaction: false,
                                                  events: _events,
                                                  incorrect:
                                                      auth.otpErrorResponse,
                                                  firstBtnHandler: () async {
                                                    try {
                                                      setState(() {
                                                        _isLoadingOtpDialoge =
                                                            true;
                                                      });
                                                      await Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  500));
                                                      print('loading popup' +
                                                          _isLoadingOtpDialoge
                                                              .toString());
                                                      final result2 = await Provider
                                                              .of<AuthProvider>(
                                                                  context,
                                                                  listen: false)
                                                          .changePasswordStep2(
                                                              context: context,
                                                              code: Provider.of<
                                                                          AuthProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .codeFromOtpBoxes,
                                                              token:
                                                                  accessToken);
                                                      setState(() {
                                                        _isLoadingOtpDialoge =
                                                            false;
                                                      });
                                                      print('loading popup 2' +
                                                          _isLoadingOtpDialoge
                                                              .toString());
                                                      if (result2 ==
                                                          AuthResult.success) {
                                                        setState(() {
                                                          _isLoadingOtpDialoge =
                                                              true;
                                                        });

                                                        await Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    1000));
                                                        Navigator.pop(context);
                                                        changePasswordSuccessDialoge();
                                                      }
                                                    } catch (error) {
                                                      print("Error: $error");
                                                    } finally {
                                                      setState(() {
                                                        _isLoadingOtpDialoge =
                                                            false;
                                                      });
                                                    }
                                                  },
                                                  secondBtnHandler: () async {
                                                    if (_timeLeft == 0) {
                                                      print(
                                                          'resend function calling');
                                                      try {
                                                        setState(() {
                                                          _isLoadingResend =
                                                              true;
                                                        });
                                                        final result =
                                                            await Provider.of<
                                                                        AuthProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .sendOTP(
                                                          context: context,
                                                          token: accessToken,
                                                        );
                                                        setState(() {
                                                          _isLoadingResend =
                                                              false;
                                                        });
                                                        if (result ==
                                                            AuthResult
                                                                .success) {
                                                          startTimer();
                                                        }
                                                      } catch (error) {
                                                        print("Error: $error");
                                                      } finally {
                                                        setState(() {
                                                          _isLoadingResend =
                                                              false;
                                                        });
                                                      }
                                                    } else {}
                                                  },
                                                  firstTitle: 'Confirm'.tr(),
                                                  secondTitle: 'Resend code '.tr(),
                                                  context: context,
                                                  isDark: themeNotifier.isDark,
                                                  isFirstButtonActive:
                                                      isOtpButtonActive,
                                                  isSecondButtonActive:
                                                      !_isTimerActive,
                                                  otp1Controller:
                                                      otp1Controller,
                                                  otp2Controller:
                                                      otp2Controller,
                                                  otp3Controller:
                                                      otp3Controller,
                                                  otp4Controller:
                                                      otp4Controller,
                                                  otp5Controller:
                                                      otp5Controller,
                                                  otp6Controller:
                                                      otp6Controller,
                                                  firstFieldFocusNode:
                                                      firstFieldFocusNode,
                                                  secondFieldFocusNode:
                                                      secondFieldFocusNode,
                                                  thirdFieldFocusNode:
                                                      thirdFieldFocusNode,
                                                  forthFieldFocusNode:
                                                      forthFieldFocusNode,
                                                  fifthFieldFocusNode:
                                                      fifthFieldFocusNode,
                                                  sixthFieldFocusNode:
                                                      sixthFieldFocusNode,
                                                  firstBtnBgColor: AppColors
                                                      .activeButtonColor,
                                                  firstBtnTextColor:
                                                      AppColors.textColorBlack,
                                                  secondBtnBgColor:
                                                      Colors.transparent,
                                                  secondBtnTextColor:
                                                      _timeLeft != 0
                                                          ? AppColors
                                                              .textColorBlack
                                                              .withOpacity(0.8)
                                                          : AppColors
                                                              .textColorWhite,
                                                  isLoading:
                                                      _isLoadingOtpDialoge,
                                                );
                                              }
                                            }
                                          },
                                          isGradient: true,
                                          color: Colors.transparent,
                                          textColor: AppColors.textColorBlack,
                                        ),
                                      ),
                                      Container(
                                        height: 4.h,
                                        width: double.infinity,
                                        color: AppColors.backgroundColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
    });
  }

  void changePasswordSuccessDialoge() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.85;
        void closeDialogAndNavigate() {
          Navigator.of(context).pop(); // Close the dialog// Close the dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WalletTokensNfts(),
            ),
          );
        }

        Future.delayed(Duration(milliseconds: 1500), closeDialogAndNavigate);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                height: 25.h,
                width: dialogWidth,
                decoration: BoxDecoration(
                  color: AppColors.showDialogClr,
                  borderRadius: BorderRadius.circular(15),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 4.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Password Updated'.tr(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17.sp,
                              color: AppColors.textColorWhite),
                        ),
                        SizedBox(
                          width: 1.h,
                        ),
                        Image.asset(
                          "assets/images/check_circle.png",
                          height: 4.h,
                          width: 4.h,
                          color: AppColors.textColorWhite,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Your password is now updated. Please remember to secure your password.'
                            .tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: AppColors.textColorGrey),
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
