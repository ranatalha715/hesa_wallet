import 'dart:async';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/otp_dialog.dart';
import 'dart:io' as OS;
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';
import '../user_profile_pages/wallet_tokens_nfts.dart';

class SigninWithMobile extends StatefulWidget {
  const SigninWithMobile({Key? key}) : super(key: key);

  @override
  State<SigninWithMobile> createState() => _SigninWithMobileState();
}

class _SigninWithMobileState extends State<SigninWithMobile> {
  FocusNode firstFieldFocusNode = FocusNode();
  FocusNode secondFieldFocusNode = FocusNode();
  FocusNode thirdFieldFocusNode = FocusNode();
  FocusNode forthFieldFocusNode = FocusNode();
  FocusNode fifthFieldFocusNode = FocusNode();
  FocusNode sixthFieldFocusNode = FocusNode();

  final TextEditingController _numberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _validateMobileNumber(String value) {
    if (value.isEmpty) {
      return 'Please enter a mobile number';
    }
    if (!_isValidMobileNumber(value)) {
      return 'Invalid mobile number';
    }
    return null;
  }

  bool _isValidMobileNumber(String value) {
    return value.startsWith('+966') && value.length == 13;
  }

  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController otp5Controller = TextEditingController();
  final TextEditingController otp6Controller = TextEditingController();

  bool isValidating = false;
  bool isButtonActive = false;
  bool isOtpButtonActive = false;
  bool showNumError = false;
  var _isLoading = false;
  Timer? _timer;
  int _timeLeft = 60;
  bool isKeyboardVisible = false;
  bool _isTimerActive = false;
  var _isLoadingResend = false;
  // late StreamController<int> _events;
  late StreamController<int> _events;
  // final events = yourStream.asBroadcastStream();


  var tokenizedUserPL;

  getTokenizedUserPayLoad() async {
    final prefs = await SharedPreferences.getInstance();
    tokenizedUserPL = await prefs.getString('tokenizedUserPayload');
  }

  @override
  void initState() {
    super.initState();
    getTokenizedUserPayLoad();
    // _events = new StreamController<int>();
    _events = StreamController<int>.broadcast();  // Make it a broadcast controller

    _events.add(60);
    _numberController.addListener(_updateButtonState);
    otp1Controller.addListener(_updateOtpButtonState);
    otp2Controller.addListener(_updateOtpButtonState);
    otp3Controller.addListener(_updateOtpButtonState);
    otp4Controller.addListener(_updateOtpButtonState);
    otp5Controller.addListener(_updateOtpButtonState);
    otp6Controller.addListener(_updateOtpButtonState);
    KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _numberController.text.isNotEmpty &&
          _numberController.text.length >= 9;
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

  @override
  void dispose() {
    _numberController.dispose();
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    otp5Controller.dispose();
    otp6Controller.dispose();
    _events.close();

    super.dispose();
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

  removeRoutes() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WalletTokensNfts()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    print('auth.otpErrorResponse');
    print(auth.otpErrorResponse);
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Builder(builder: (BuildContext context) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: themeNotifier.isDark
                  ? AppColors.backgroundColor
                  : AppColors.textColorWhite,
              body: Stack(
                children: [
                  Column(
                    children: [
                      MainHeader(title: 'Login'.tr()),
                      Expanded(
                        child: Container(
                          height: 85.h,
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 4.h,
                                  ),
                                  Text(
                                    "Login using Mobile Number.".tr(),
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
                                    child: TextFormField(
                                        controller: _numberController,
                                        onChanged: (v) {
                                          auth.loginErrorResponse = null;
                                        },

                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(10),
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        scrollPadding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom +
                                                150),
                                        keyboardType: TextInputType.number,
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
                                          hintText:
                                              'Enter your mobile number'.tr(),
                                          hintStyle: TextStyle(
                                              fontSize: 10.2.sp,
                                              color: AppColors.textColorGrey,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Inter'),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: (isValidating &&
                                                            _numberController
                                                                .text
                                                                .isEmpty) ||
                                                        (_numberController.text
                                                                    .length <
                                                                9
                                                            &&
                                                            _numberController
                                                                .text
                                                                .isNotEmpty
                                                            // &&
                                                            // isValidating
                                                        ) ||
                                                        auth.loginErrorResponse
                                                            .toString()
                                                            .contains(
                                                                'mobile number')
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
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, top: 14, right: 12),
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
                                  if (_numberController.text.isEmpty &&
                                      isValidating)
                                    Padding(
                                      padding: EdgeInsets.only(top: 7.sp),
                                      child: Text(
                                        "*Mobile number should not be empty",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10.sp,
                                            color: AppColors.errorColor),
                                      ),
                                    ),
                                  if (
                                      _numberController.text.length < 9 &&
                                      _numberController.text.isNotEmpty
                                          // &&
                                          // showNumError
                                  )
                                    Padding(
                                      padding: EdgeInsets.only(top: 7.sp),
                                      child: Text(
                                        "*Mobile Number should be minimum 9 Characters",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10.sp,
                                            color: AppColors.errorColor),
                                      ),
                                    ),
                                  if (auth.loginErrorResponse != null &&
                                      _numberController.text.isNotEmpty &&
                                      isValidating &&
                                      auth.loginErrorResponse
                                          .toString()
                                          .contains('mobile number'))
                                    Padding(
                                      padding: EdgeInsets.only(top: 7.sp),
                                      child: Text(
                                        "*${auth.loginErrorResponse}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10.sp,
                                            color: AppColors.errorColor),
                                      ),
                                    ),
                                  Expanded(child: SizedBox()),
                                  AppButton(
                                    title: 'Log in'.tr(),
                                    isactive: isButtonActive ? true : false,
                                    handler: () async {
                                      setState(() {
                                        isValidating = true;
                                      });
                                      if (isButtonActive) {
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
                                                .sendLoginOTP(
                                          mobile: _numberController.text,
                                          context: context,
                                        );
                                        setState(() {
                                          _isLoading = false;
                                          isValidating = false;
                                        });
                                        if (result == AuthResult.success) {
                                          startTimer();
                                          otpDialog(
                                            incorrect: auth.otpErrorResponse,
                                            events: _events,
                                            firstBtnHandler: () async {
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500));
                                              final loginWithMobile =
                                                  await Provider.of<
                                                              AuthProvider>(
                                                          context,
                                                          listen: false)
                                                      .logInWithMobile(
                                                mobile: _numberController.text,
                                                context: context,
                                                code: Provider.of<AuthProvider>(
                                                        context,
                                                        listen: false)
                                                    .codeFromOtpBoxes,
                                              );
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              print('loading popup 2' +
                                                  _isLoading.toString());
                                              if (loginWithMobile ==
                                                  AuthResult.success) {
                                                Navigator.pop(context);
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
                                                } finally {
                                                  setState(() {
                                                    _isLoadingResend = false;
                                                  });
                                                }
                                              } else {
                                                print('Timer is still running');
                                              }
                                            },
                                            firstTitle: 'Confirm',
                                            secondTitle: 'Resend code ',
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
                                            isLoading:
                                                _isLoadingResend || _isLoading,
                                          );
                                        }
                                      }
                                    },
                                    isGradient: true,
                                    secondBtnBorderClr: false,
                                    color: Colors.transparent,
                                    textColor: AppColors.textColorBlack,
                                  ),
                                  SizedBox(height: 2.h),
                                  GestureDetector(
                                    onTap: () => Navigator.pushReplacementNamed(
                                        context, '/SigninWithEmail',
                                        arguments: {'comingFromWallet': true}),
                                    child: Container(
                                      width: double.infinity,
                                      height: 4.h,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Text(
                                          "Login with password instead".tr(),
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
                                    height:
                                        OS.Platform.isIOS && !isKeyboardVisible
                                            ? 5.h
                                            : 2.h,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (OS.Platform.isIOS)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child:
                          KeyboardVisibilityBuilder(builder: (context, child) {
                        return Visibility(
                            visible: isKeyboardVisible,
                            child: GestureDetector(
                              onTap: () =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              child: Container(
                                  height: 3.h,
                                  color: AppColors.profileHeaderDark,
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Text(
                                          'Done',
                                          style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11.5.sp,
                                                  fontWeight: FontWeight.bold)
                                              .apply(fontWeightDelta: -1),
                                        ),
                                      ))),
                            ));
                      }),
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
}
