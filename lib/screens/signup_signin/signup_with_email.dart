import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/screens/onboarding_notifications/verify_email.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../constants/colors.dart';
import '../../constants/configs.dart';
import '../../providers/theme_provider.dart';
import 'dart:io' as OS;
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';

class SignUpWithEmail extends StatefulWidget {
  const SignUpWithEmail({Key? key}) : super(key: key);

  static const routeName = 'signupWithEmail';

  @override
  State<SignUpWithEmail> createState() => _SignUpWithEmailState();
}

class _SignUpWithEmailState extends State<SignUpWithEmail> {
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

  FocusNode firstFieldFocusNode = FocusNode();
  FocusNode secondFieldFocusNode = FocusNode();
  FocusNode thirdFieldFocusNode = FocusNode();
  FocusNode forthFieldFocusNode = FocusNode();
  FocusNode fifthFieldFocusNode = FocusNode();
  FocusNode sixthFieldFocusNode = FocusNode();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController otp5Controller = TextEditingController();
  final TextEditingController otp6Controller = TextEditingController();
  Timer? _debounce;

  void _onUsernameChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        usernameLoading = true;
      });
      await Provider.of<AuthProvider>(context, listen: false)
          .checkUsername(userName: _usernameController.text, context: context);
      setState(() {
        usernameLoading = false;
      });
    });
  }

  generateFcmToken() async {
    await FirebaseMessaging.instance.getToken().then((newToken) {
      print("fcm===" + newToken!);
      setState(() {
        fcmToken = newToken;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  var _isLoading = false;
  var _isLoadingOtpDialoge = false;
  bool isButtonActive = false;
  Timer? _timer;
  bool _isTimerActive = false;
  bool usernameLoading = false;
  var _isLoadingResend = false;
  bool isValidating = false;
  var tokenizedUserPL;
  int _remainingTimeSeconds = 0;
  bool _isPasswordValid = false;
  bool _obscurePassword = true;
  bool isOtpButtonActive = false;
  int _timeLeft = 60;
  late StreamController<int> _events;

  String fcmToken = 'Waiting for FCM token...';

  FocusNode userNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode mobileNumFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  getTokenizedUserPayLoad() async {
    final prefs = await SharedPreferences.getInstance();
    tokenizedUserPL = await prefs.getString('tokenizedUserPayload');
  }

  void startTimer() {
    _isTimerActive = true;
    Timer.periodic(Duration(seconds: 1), (timer) {
      (_timeLeft > 0) ? _timeLeft-- : _timer?.cancel();
      print(_timeLeft);
      _events.add(_timeLeft);
    });
  }

  @override
  void initState() {
    super.initState();
    generateFcmToken();
    _events = new StreamController<int>();
    _events.add(60);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
    _usernameController.addListener(_updateButtonState);
    _numberController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    otp1Controller.addListener(_updateOtpButtonState);
    otp2Controller.addListener(_updateOtpButtonState);
    otp3Controller.addListener(_updateOtpButtonState);
    otp4Controller.addListener(_updateOtpButtonState);
    otp5Controller.addListener(_updateOtpButtonState);
    otp6Controller.addListener(_updateOtpButtonState);
    Provider.of<AuthProvider>(context, listen: false)
        .registerUserErrorResponse = null;
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _usernameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
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

  AddBankingDetailsPopup(bool isDark) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.85;
        void closeDialogAndNavigate() {}

        Future.delayed(Duration(seconds: 3), closeDialogAndNavigate);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                height: 40.h,
                width: dialogWidth,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.showDialogClr
                      : AppColors.textColorWhite,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 4.h,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        "assets/images/bank_popup.png",
                        height: 6.h,
                        width: 5.8.h,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Add banking details'.tr(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17.sp,
                          color: AppColors.textColorWhite),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'To assure you receive your payments, register your bank account details.'
                            .tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            fontSize: 10.2.sp,
                            color: AppColors.textColorGrey),
                      ),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: AppButton(
                          title: 'Add bank account'.tr(),
                          handler: () {},
                          isGradient: true,
                          color: AppColors.textColorBlack),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    print(args['id']);
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: Column(
              children: [
                MainHeader(title: 'Create a Wallet'.tr()),
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
                                Consumer<AuthProvider>(
                                    builder: (context, auth, child) {
                                  return TextFieldParent(
                                    child: TextField(
                                        focusNode: userNameFocusNode,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        textInputAction: TextInputAction.next,
                                        onEditingComplete: () {
                                          emailFocusNode.requestFocus();
                                        },
                                        controller: _usernameController,
                                        onChanged: (value) {
                                          setState(() {
                                            usernameLoading = true;
                                          });
                                          _onUsernameChanged();
                                          setState(() {
                                            usernameLoading = false;
                                          });
                                        },
                                        scrollPadding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        keyboardType: TextInputType.text,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[a-zA-Z0-9]')),
                                        ],
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
                                          hintText: 'username'.tr(),
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
                                                color: (_usernameController
                                                                .text.isEmpty &&
                                                            isValidating) ||
                                                        (!auth.userNameAvailable &&
                                                            _usernameController
                                                                .text
                                                                .isNotEmpty)
                                                    ? AppColors.errorColor
                                                    : Colors.transparent,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: (_usernameController
                                                                .text.isEmpty &&
                                                            isValidating) ||
                                                        (!auth.userNameAvailable &&
                                                            _usernameController
                                                                .text
                                                                .isNotEmpty)
                                                    ? AppColors.errorColor
                                                    : AppColors
                                                        .focusTextFieldColor,
                                              )),
                                          suffixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10, top: 13),
                                              child: Consumer<AuthProvider>(
                                                  builder:
                                                      (context, auth, child) {
                                                return Text('.mjra'.tr(),
                                                    style: TextStyle(
                                                        fontSize: 10.2.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: auth.userNameAvailable &&
                                                                _usernameController
                                                                    .text
                                                                    .isNotEmpty
                                                            ? AppColors
                                                                .textColorWhite
                                                            : AppColors
                                                                .textColorGrey));
                                              })),
                                        ),
                                        cursorColor: AppColors.textColorGrey),
                                  );
                                }),
                                if (_usernameController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      // "*This username is registered",
                                      "*Username should not be empty".tr(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                if (_usernameController.text.isNotEmpty)
                                  Consumer<AuthProvider>(
                                      builder: (context, auth, child) {
                                    return Padding(
                                      padding: EdgeInsets.only(top: 7.sp),
                                      child: usernameLoading
                                          ? Text(
                                              'Checking...'.tr(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10.sp,
                                                  color: AppColors
                                                      .textColorGreyShade2),
                                            )
                                          : Row(
                                              children: [
                                                auth.userNameAvailable
                                                    ? Icon(
                                                        Icons.check_circle,
                                                        size: 10.sp,
                                                        color:
                                                            AppColors.hexaGreen,
                                                      )
                                                    : Icon(
                                                        Icons.cancel,
                                                        size: 10.sp,
                                                        color: AppColors
                                                            .errorColor,
                                                      ),
                                                SizedBox(
                                                  width: 2.sp,
                                                ),
                                                Text(
                                                  auth.userNameAvailable
                                                      ? "This username is available"
                                                          .tr()
                                                      : "This username is taken. Try another."
                                                          .tr(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 10.sp,
                                                      color: Provider.of<
                                                                      AuthProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .userNameAvailable
                                                          ? AppColors.hexaGreen
                                                          : AppColors
                                                              .errorColor),
                                                ),
                                              ],
                                            ),
                                    );
                                  }),
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
                                      onChanged: (v) {
                                        auth.registerUserErrorResponse = null;
                                      },
                                      focusNode: emailFocusNode,
                                      textInputAction: TextInputAction.next,
                                      onEditingComplete: () {
                                        passwordFocusNode.requestFocus();
                                      },
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
                                            vertical: OS.Platform.isIOS
                                                ? 14.5.sp
                                                : 10.0,
                                            horizontal: OS.Platform.isIOS
                                                ? 10.sp
                                                : 16.0),
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
                                              color: (isValidating &&
                                                          _emailController
                                                              .text.isEmpty) ||
                                                      auth.registerUserErrorResponse
                                                          .toString()
                                                          .contains('Email')
                                                  ||
                                                  auth.registerUserErrorResponse
                                                      .toString()
                                                      .contains('البريد الإلكتروني')||
                                                      ((!_emailController.text
                                                                  .contains(
                                                                      '@') ||
                                                              !_emailController
                                                                  .text
                                                                  .contains(
                                                                      '.com')) &&
                                                          _emailController
                                                              .text.isNotEmpty)
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
                                if (auth.registerUserErrorResponse != null &&
                                    _emailController.text.isNotEmpty &&
                                    isValidating &&
                                    auth.registerUserErrorResponse
                                        .toString()
                                        .contains('Email')  ||
                                    auth.registerUserErrorResponse
                                        .toString()
                                        .contains('البريد الإلكتروني')
                                )
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      // isEnglish
                                      //     ?
                                      "*${auth.registerUserErrorResponse}",
                                      // : "البريد الاكتروني مسجل مسبقا*",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                if (_emailController.text.isNotEmpty &&
                                    isValidating &&
                                    (!_emailController.text.contains('@') ||
                                        !_emailController.text
                                            .contains('.com')))
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      // "*Please enter a valid email address".tr(),
                                      "*Enter valid email address".tr(),
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                if (_emailController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      "*Email address should not be empty".tr(),
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
                                    'Set Password'.tr(),
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
                                      focusNode: passwordFocusNode,
                                      textInputAction: TextInputAction.next,
                                      onEditingComplete: () {
                                        confirmPasswordFocusNode.requestFocus();
                                      },
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom /
                                              1.8),
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      onChanged: (password) {
                                        _validatePassword(password);
                                        auth.registerUserErrorResponse = null;
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
                                              color: (_passwordController
                                                              .text.isEmpty &&
                                                          isValidating) ||
                                                      ((!_hasUppercase ||
                                                              !_hasLowercase ||
                                                              !_hasDigits ||
                                                              !_hasSpecialCharacters ||
                                                              !_hasMinLength) &&
                                                          _passwordController
                                                              .text.isNotEmpty)
                                                  ? AppColors.errorColor
                                                  : Colors.transparent,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color: (_passwordController
                                                              .text.isEmpty &&
                                                          isValidating) ||
                                                      ((!_hasUppercase ||
                                                              !_hasLowercase ||
                                                              !_hasDigits ||
                                                              !_hasSpecialCharacters ||
                                                              !_hasMinLength) &&
                                                          _passwordController
                                                              .text.isNotEmpty)
                                                  ? AppColors.errorColor
                                                  : AppColors
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
                                          onPressed: _togglePasswordVisibility,
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                        ),
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_passwordController.text.isEmpty &&
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
                                SizedBox(height: 2.h),
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
                                            color: _passwordController
                                                    .text.isEmpty
                                                ? AppColors.textColorGrey
                                                : conditionMet
                                                    ? AppColors.passwordGreen
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
                                                color: _passwordController
                                                        .text.isEmpty
                                                    ? AppColors.textColorGrey
                                                    : conditionMet
                                                        ? AppColors
                                                            .passwordGreen
                                                        : AppColors.errorColor,
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
                                      focusNode: confirmPasswordFocusNode,
                                      textInputAction: TextInputAction.done,
                                      onChanged: (v) {
                                        auth.registerUserErrorResponse = null;
                                      },
                                      onEditingComplete: () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                      controller: _confirmPasswordController,
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
                                              color: (_confirmPasswordController
                                                              .text.isEmpty &&
                                                          isValidating) ||
                                                      _confirmPasswordController.text
                                                              .isNotEmpty &&
                                                          _passwordController
                                                              .text
                                                              .isNotEmpty &&
                                                          _confirmPasswordController
                                                                  .text !=
                                                              _passwordController
                                                                  .text
                                                  ? AppColors.errorColor
                                                  : Colors.transparent,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color: _confirmPasswordController
                                                          .text.isNotEmpty &&
                                                      _passwordController
                                                          .text.isNotEmpty &&
                                                      _confirmPasswordController
                                                              .text !=
                                                          _passwordController
                                                              .text
                                                  ? AppColors.errorColor
                                                  : AppColors
                                                      .focusTextFieldColor,
                                            )),
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
                                if (_confirmPasswordController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      "*Confirm Password should not be empty"
                                          .tr(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                if (_confirmPasswordController
                                        .text.isNotEmpty &&
                                    _passwordController.text.isNotEmpty &&
                                    _confirmPasswordController.text !=
                                        _passwordController.text)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      "*Password doesn't match".tr(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                SizedBox(height: 10.h),
                                Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 2.sp),
                                  color: Colors.transparent,
                                  child: Column(
                                    children: [
                                      // Expanded(child: SizedBox()),
                                      AppButton(
                                          title: 'Create account'.tr(),
                                          isactive:
                                              isButtonActive ? true : false,
                                          handler: () async {
                                            setState(() {
                                              isValidating = true;
                                            });
                                            if (isButtonActive) {
                                              final String password =
                                                  _passwordController.text;
                                              final bytes =
                                                  utf8.encode(password);
                                              final sha512Hash =
                                                  sha512.convert(bytes);
                                              final sha512String =
                                                  sha512Hash.toString();
                                              setState(() {
                                                _isLoading = true;
                                                if (_isLoading) {
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                }
                                              });
                                              final result = await Provider.of<
                                                          AuthProvider>(context,
                                                      listen: false)
                                                  .registerUserStep3(
                                                context: context,
                                                email: _emailController.text,
                                                username:
                                                    _usernameController.text,
                                                password: sha512String,
                                                isEnglish: isEnglish,
                                              );
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              if (result ==
                                                  AuthResult.success) {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          VerifyEmail()),
                                                );
                                              }
                                            }
                                          },
                                          isGradient: true,
                                          color: Colors.transparent,
                                          textColor: AppColors.textColorBlack),
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
