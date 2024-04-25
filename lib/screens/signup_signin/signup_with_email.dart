import 'dart:async';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/screens/signup_signin/signin_with_email.dart';
import 'package:hesa_wallet/screens/signup_signin/terms_conditions.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/app_header.dart';
import 'package:hesa_wallet/widgets/dialog_button.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/configs.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';
import '../../widgets/otp_dialog.dart';

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

  bool _isPasswordCompliant(String password) {
    // Password should contain at least 8 characters
    if (password.length < 8) {
      return false;
    }

    // Password should contain at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return false;
    }

    // Password should contain at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return false;
    }

    // Password should contain at least one numerical character
    if (!RegExp(r'\d').hasMatch(password)) {
      return false;
    }

    // Password should contain at least one special character
    if (!RegExp(r'[\$#@]').hasMatch(password)) {
      return false;
    }

    // If all conditions are met, the password is considered valid
    return true;
  }

  FocusNode firstFieldFocusNode = FocusNode();
  FocusNode secondFieldFocusNode = FocusNode();
  FocusNode thirdFieldFocusNode = FocusNode();
  FocusNode forthFieldFocusNode = FocusNode();
  FocusNode fifthFieldFocusNode = FocusNode();
  FocusNode sixthFieldFocusNode = FocusNode();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
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
    // await Firebase.initializeApp();
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
    _usernameController.dispose();
    _numberController.dispose();
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
  int _timeLeft = 300;
  late StreamController<int> _events;

  String fcmToken = 'Waiting for FCM token...';

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
    _events.add(300);
    // Listen for changes in the text fields and update the button state
    _passwordController.addListener(_updateButtonState);
    _usernameController.addListener(_updateButtonState);
    _numberController.addListener(_updateButtonState);
    otp1Controller.addListener(_updateOtpButtonState);
    otp2Controller.addListener(_updateOtpButtonState);
    otp3Controller.addListener(_updateOtpButtonState);
    otp4Controller.addListener(_updateOtpButtonState);
    otp5Controller.addListener(_updateOtpButtonState);
    otp6Controller.addListener(_updateOtpButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _passwordController.text.isNotEmpty &&
          _usernameController.text.isNotEmpty &&
          _numberController.text.isNotEmpty;
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
        void closeDialogAndNavigate() {
          // Navigator.of(context).pop(); // Close the dialog
          // Navigator.of(context).pop(); // Close the dialog
        }

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
                  // border:
                  //     Border.all(width: 0.1.h, color: AppColors.textColorGrey),
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
                    // color: Colors.yellow,
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
                                //   "Web3 Identity".tr(),
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
                                // Text(
                                //   "Please add a unique username and your mobile number to receive verification codes."
                                //       .tr(),
                                //   style: TextStyle(
                                //       color: AppColors.textColorGrey,
                                //       fontWeight: FontWeight.w400,
                                //       fontSize: 11.7.sp,
                                //       fontFamily: 'Inter'),
                                // ),
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
                                      controller: _usernameController,
                                      onChanged: (value) {

                                        setState(() {
                                        usernameLoading=true;
                                        });
                                        _onUsernameChanged();
                                        setState(() {
                                          usernameLoading=false;
                                        });
                                      },
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                      keyboardType: TextInputType.text,
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
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10, top: 13),
                                          child: Text(
                                            '.mjra',
                                            style: TextStyle(
                                                fontSize: 10.2.sp,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textColorGrey),
                                          ),
                                        ),
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_usernameController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      // "*This username is registered",
                                      "*Username should not be empty",
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
                                    child: usernameLoading ? Text('Checking...',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: AppColors.textColorGreyShade2),

                                    ) : Row(
                                      children: [
                                        auth.userNameAvailable ?
                                        Icon(Icons.check_circle,
                                        size: 10.sp,
                                        color: AppColors.hexaGreen,
                                        ) :
                                        Icon(Icons.cancel,
                                          size: 10.sp,
                                          color: AppColors.errorColor,
                                        ),
                                        SizedBox(width: 2.sp,),
                                        Text(
                                          auth.userNameAvailable
                                              ? "This username is available"
                                              : "This username is taken. Try another.",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.sp,
                                              color: Provider.of<AuthProvider>(
                                                          context,
                                                          listen: false)
                                                      .userNameAvailable
                                                  ? AppColors.hexaGreen
                                                  : AppColors.errorColor),
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
                                    'Mobile number'.tr(),
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
                                      controller: _numberController,
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
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
                                        hintText:
                                            'Enter your mobile number'.tr(),
                                        // contentPadding: EdgeInsets.only(left: 10),
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
                                              left: 10.sp,
                                              top: 12.7.sp,
                                              right: 11.4.sp),
                                          child: Text(
                                            '+966',
                                            style: TextStyle(
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.2.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_numberController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      // "*This mobile number is registered",
                                      "*Mobile number should not be empty",
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
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      onChanged: (password) {
                                        setState(() {
                                          _isPasswordValid =
                                              _isPasswordCompliant(password);
                                        });
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
                                if (_passwordController.text.isEmpty &&
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
                                if (!_isPasswordValid &&
                                    isValidating &&
                                    _passwordController.text.isNotEmpty)
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
                                SizedBox(height: 20.h)
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 12.h,
                            width: double.infinity,
                            color: AppColors.backgroundColor,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 20,
                          right: 20,
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                // Expanded(child: SizedBox()),
                                AppButton(
                                    title: 'Create account'.tr(),
                                    isactive: isButtonActive ? true : false,
                                    handler: () async {
                                      setState(() {
                                        isValidating = true;
                                      });
                                      if (_usernameController.text.isNotEmpty &&
                                          _numberController.text.isNotEmpty &&
                                          _passwordController.text.isNotEmpty) {
                                        setState(() {
                                          _isLoading = true;
                                          if (_isLoading) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          }
                                        });
                                        final result =
                                            await Provider.of<AuthProvider>(
                                                    context,
                                                    listen: false)
                                                .registerUser(
                                          context: context,
                                          firstName: args['firstName'],
                                          lastName: args['lastName'],
                                          idNumber: args['id'],
                                          idType: args['idType'],
                                          userName: _usernameController.text,
                                          mobileNumber: _numberController.text,
                                          password: _passwordController.text,
                                          deviceToken: fcmToken,
                                        );
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        if (result == AuthResult.success) {
                                          await getTokenizedUserPayLoad();
                                          startTimer();
                                          otpDialog(
                                            events: _events,
                                            firstBtnHandler: () async {
                                              if (otp1Controller.text.isNotEmpty &&
                                                  otp2Controller
                                                      .text.isNotEmpty &&
                                                  otp3Controller
                                                      .text.isNotEmpty &&
                                                  otp4Controller
                                                      .text.isNotEmpty &&
                                                  otp5Controller
                                                      .text.isNotEmpty &&
                                                  otp6Controller
                                                      .text.isNotEmpty) {
                                                try {
                                                  setState(() {
                                                    _isLoadingOtpDialoge = true;
                                                  });
                                                  print('loading popup' +
                                                      _isLoadingOtpDialoge.toString());
                                                  // Navigator.pop(context);
                                                  final result = await Provider
                                                          .of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                      .verifyUser(
                                                          context: context,
                                                          mobile:
                                                              _numberController
                                                                  .text,
                                                          code: otp1Controller
                                                                  .text +
                                                              otp2Controller
                                                                  .text +
                                                              otp3Controller
                                                                  .text +
                                                              otp4Controller
                                                                  .text +
                                                              otp5Controller
                                                                  .text +
                                                              otp6Controller
                                                                  .text,
                                                          token:
                                                              tokenizedUserPL);
                                                  setState(() {
                                                    _isLoadingOtpDialoge = false;
                                                  });
                                                  print('loading popup 2' +
                                                      _isLoadingOtpDialoge.toString());
                                                  if (result ==
                                                      AuthResult.success) {
                                                    Navigator.of(context)
                                                        .pushNamedAndRemoveUntil(
                                                            '/TermsAndConditions',
                                                            (Route d) => false);
                                                  }
                                                } catch (error) {
                                                  print("Error: $error");
                                                  setState(() {
                                                    _isLoadingOtpDialoge = false;
                                                  });
                                                  // _showToast('An error occurred'); // Show an error message
                                                } finally {
                                                  setState(() {
                                                    _isLoadingOtpDialoge = false;
                                                  });
                                                }
                                              }
                                            },
                                            secondBtnHandler: () async {
                                              if (_timeLeft == 0) {
                                                print(
                                                    'resend function calling');
                                                try {
                                                  setState(() {
                                                    _isLoadingResend = true;
                                                  });
                                                  final result = await Provider
                                                          .of<AuthProvider>(
                                                              context,
                                                              listen: false)
                                                      .sendLoginOTP(
                                                          mobile:
                                                              _numberController
                                                                  .text,
                                                          context: context);
                                                  setState(() {
                                                    _isLoadingResend = false;
                                                  });
                                                  if (result ==
                                                      AuthResult.success) {
                                                    startTimer();
                                                  }
                                                } catch (error) {
                                                  print("Error: $error");
                                                  // _showToast('An error occurred'); // Show an error message
                                                } finally {
                                                  setState(() {
                                                    _isLoadingResend = false;
                                                  });
                                                }
                                              } else {}
                                            },
                                            firstTitle: 'Verify',
                                            secondTitle: 'Resend code: ',

                                            // "${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}",

                                            context: context,
                                            isDark: themeNotifier.isDark,
                                            isFirstButtonActive:
                                                isOtpButtonActive,
                                            isSecondButtonActive: false,
                                            otp1Controller: otp1Controller,
                                            otp2Controller: otp2Controller,
                                            otp3Controller: otp3Controller,
                                            otp4Controller: otp4Controller,
                                            otp5Controller: otp5Controller,
                                            otp6Controller: otp6Controller,
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
                                            firstBtnBgColor:
                                                AppColors.activeButtonColor,
                                            firstBtnTextColor:
                                                AppColors.textColorBlack,
                                            secondBtnBgColor:
                                                Colors.transparent,
                                            secondBtnTextColor: _timeLeft != 0
                                                ? AppColors.textColorBlack
                                                    .withOpacity(0.8)
                                                : AppColors.textColorWhite,
                                            // themeNotifier.isDark
                                            //     ? AppColors.textColorWhite
                                            //     : AppColors.textColorBlack
                                            //         .withOpacity(0.8),
                                            isLoading: _isLoading,
                                            // isLoading: _isLoadingResend,
                                          );
                                        }
                                      }
                                    },
                                    // isLoading: _isLoading,
                                    isGradient: true,
                                    color: Colors.transparent,
                                    textColor: AppColors.textColorBlack),
                                Container(
                                  height: 4.h,
                                  width: double.infinity,
                                  color: AppColors.backgroundColor,
                                ),
                              ],
                            ),
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

  Widget otpContainer({
    required FocusNode focusNode,
    required FocusNode previousFocusNode,
    required TextEditingController controller,
    required Function handler,
  }) {
    return TextFieldParent(
      width: 9.8.w,
      otpHeight: 8.h,
      color: Colors.white.withOpacity(0.5),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
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
        // onChanged: (value) => handler(),
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
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Colors.transparent,
                // Off-white color
                // width: 2.0,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Colors.transparent,
                // Off-white color
                // width: 2.0,
              )),
        ),
      ),
      // height: 8.h,
      // width: 10.w,
      // decoration: BoxDecoration(
      //   color: Colors.transparent,
      //   borderRadius: BorderRadius.circular(10),
      // )
    );
  }
}
