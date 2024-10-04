import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../constants/colors.dart';
import '../../constants/configs.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/dialog_button.dart';
import '../../widgets/main_header.dart';
import '../../widgets/otp_dialog.dart';

class VerifyEmail extends StatefulWidget {
  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  Timer? _timer;

  // late StreamController<int> _events;
  StreamController<int> _events = StreamController<int>.broadcast();
  var _isLoadingOtpDialoge = false;
  var _isLoadingResend = false;
  bool _isTimerActive = false;
  bool fromAuth = true;
  var otpPin;
  var _isLoading = false;
  bool isOtpButtonActive = false;
  int _timeLeft = 60;
  var accessToken = "";

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  FocusNode firstFieldFocusNode = FocusNode();
  FocusNode secondFieldFocusNode = FocusNode();
  FocusNode thirdFieldFocusNode = FocusNode();
  FocusNode forthFieldFocusNode = FocusNode();
  FocusNode fifthFieldFocusNode = FocusNode();
  FocusNode sixthFieldFocusNode = FocusNode();

  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController otp5Controller = TextEditingController();
  final TextEditingController otp6Controller = TextEditingController();

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

  openVerifyEmailPopup() {
    startTimer();
    otpDialog(
      fromTransaction: false,
      fromAuth: true,
      fromUser: false,
      events: _events,
      isBlurred: false,
      isEmailOtpDialog: true,
      firstBtnHandler: () async {
        try {
          setState(() {
            _isLoadingOtpDialoge = true;
          });
          await Future.delayed(const Duration(milliseconds: 500));
          print('loading popup' + _isLoadingOtpDialoge.toString());
          final result = await Provider.of<AuthProvider>(context, listen: false)
              .registerUserStep4(
            context: context,
            code: Provider.of<AuthProvider>(context, listen: false)
                .codeFromOtpBoxes,
          );

          setState(() {
            _isLoadingOtpDialoge = false;
          });
          print('loading popup 2' + _isLoadingOtpDialoge.toString());
          if (result == AuthResult.success) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/TermsAndConditions', (Route d) => false);
          }
        } catch (error) {
          print("Error: $error");
          setState(() {
            _isLoadingOtpDialoge = false;
          });
        } finally {
          setState(() {
            _isLoadingOtpDialoge = false;
          });
        }
      },
      secondBtnHandler: () async {
        if (_timeLeft == 0) {
          print('resend function calling');
          try {
            setState(() {
              _isLoadingResend = true;
            });
            final result =
                await Provider.of<AuthProvider>(context, listen: false)
                    .registerEmailResendOtp(
                        medium: "email", token: accessToken, context: context);
            setState(() {
              _isLoadingResend = false;
            });
            if (result == AuthResult.success) {
              startTimer();
            }
          } catch (error) {
            print("Error: $error");
          } finally {
            setState(() {
              _isLoadingResend = false;
            });
          }
        } else {}
      },
      firstTitle: 'Verify',
      secondTitle: 'Resend code: ',
      context: context,
      isDark: true,
      isFirstButtonActive: isOtpButtonActive,
      isSecondButtonActive: false,
      otp1Controller: otp1Controller,
      otp2Controller: otp2Controller,
      otp3Controller: otp3Controller,
      otp4Controller: otp4Controller,
      otp5Controller: otp5Controller,
      otp6Controller: otp6Controller,
      firstFieldFocusNode: firstFieldFocusNode,
      secondFieldFocusNode: secondFieldFocusNode,
      thirdFieldFocusNode: thirdFieldFocusNode,
      forthFieldFocusNode: forthFieldFocusNode,
      fifthFieldFocusNode: fifthFieldFocusNode,
      sixthFieldFocusNode: sixthFieldFocusNode,
      firstBtnBgColor: AppColors.activeButtonColor,
      firstBtnTextColor: AppColors.textColorBlack,
      secondBtnBgColor: Colors.transparent,
      secondBtnTextColor: _timeLeft != 0
          ? AppColors.textColorBlack.withOpacity(0.8)
          : AppColors.textColorWhite,
      isLoading: _isLoading,
    );
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

  firstbuttonFunction() async {
    try {
      setState(() {
        _isLoadingOtpDialoge = true;
      });
      await Future.delayed(const Duration(milliseconds: 1000));
      print('loading popup' + _isLoadingOtpDialoge.toString());
      final result = await Provider.of<AuthProvider>(context, listen: false)
          .registerUserStep4(
        context: context,
        code:
            Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes,
      );

      setState(() {
        _isLoadingOtpDialoge = false;
      });
      print('loading popup 2' + _isLoadingOtpDialoge.toString());
      if (result == AuthResult.success) {
        await Future.delayed(const Duration(milliseconds: 1000));
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/TermsAndConditions', (Route d) => false);
      }
    } catch (error) {
      print("Error: $error");
      setState(() {
        _isLoadingOtpDialoge = false;
      });
    } finally {
      setState(() {
        _isLoadingOtpDialoge = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getAccessToken();
    _events = new StreamController<int>();
    _events.add(60);

    otp1Controller.addListener(_updateOtpButtonState);
    otp2Controller.addListener(_updateOtpButtonState);
    otp3Controller.addListener(_updateOtpButtonState);
    otp4Controller.addListener(_updateOtpButtonState);
    otp5Controller.addListener(_updateOtpButtonState);
    otp6Controller.addListener(_updateOtpButtonState);

    // Future.delayed(Duration(milliseconds: 500 ), () {
    //   openVerifyEmailPopup();
    // });
    super.initState();
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
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Consumer<AuthProvider>(builder: (context, auth, child) {
        return Consumer<UserProvider>(builder: (context, user, child) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return StreamBuilder<int>(
                stream: _events.stream,
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  return Scaffold(
                      backgroundColor: themeNotifier.isDark
                          ? AppColors.backgroundColor
                          : AppColors.textColorWhite,
                      body: Column(children: [
                        MainHeader(title: 'Verify Email'),
                        Expanded(
                            child: Container(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 3.h),
                                Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 17.sp),
                                  height: 70.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.showDialogClr,
                                    borderRadius: BorderRadius.circular(10.sp),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.textColorBlack.withOpacity(0.45), // Dark shadow color
                                        offset: Offset(0, 0), // No offset, shadow will appear equally on all sides
                                        blurRadius: 10, // Adjust blur for softer shadow
                                        spreadRadius: 0.4, // Spread the shadow slightly
                                      ),
                                    ],
                                  ),

                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 4.h,
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 18.0),
                                          child: Image.asset(
                                            "assets/images/email.png",
                                            height: 6.2.h,
                                            width: 6.2.h,
                                            color: AppColors.hexaGreen,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      Text(
                                        'Email Verification Sent'.tr(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17.sp,
                                            color: AppColors.textColorWhite),
                                      ),

                                      SizedBox(
                                        height: 2.h,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Text(
                                          'To complete the registration please \nenter the code sent to your email.'
                                              .tr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              height: 1.4,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.2.sp,
                                              color: AppColors.textColorGrey),
                                        ),
                                      ),

                                      SizedBox(height: 2.h),

                                      Text(
                                        'Enter verification Code',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.sp,
                                            color: themeNotifier.isDark
                                                ? AppColors.textColorWhite
                                                : AppColors.textColorBlack),
                                      ),

                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.sp),
                                        child: Pinput(
                                            scrollPadding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .viewInsets
                                                        .bottom -
                                                    100),
                                            controller: otp6Controller,
                                            length: 6,
                                            defaultPinTheme: PinTheme(
                                              width: 9.8.w,
                                              height: 8.h,
                                              textStyle: TextStyle(
                                                  color:
                                                      AppColors.textColorWhite,
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Blogger Sans'
                                                  // letterSpacing: 16,
                                                  ),
                                              decoration: BoxDecoration(
                                                border: fromAuth
                                                    ? Border.all(
                                                        color: auth.otpErrorResponse && !auth.otpSuccessResponse
                                                            ? AppColors
                                                                .errorColor
                                                            : auth.otpSuccessResponse && !auth.otpErrorResponse ?  AppColors.hexaGreen
                                                    : Colors.transparent,
                                                        width: 1.sp)
                                                    : Border.all(
                                                        color: user
                                                                .otpErrorResponse
                                                            ? AppColors
                                                                .errorColor
                                                            : user
                                                                    .otpSuccessResponse
                                                                ? AppColors
                                                                    .hexaGreen
                                                                : Colors
                                                                    .transparent,
                                                        width: 1.sp),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: AppColors
                                                    .transparentBtnBorderColorDark
                                                    .withOpacity(0.15),
                                              ),
                                            ),
                                            pinputAutovalidateMode:
                                                PinputAutovalidateMode.onSubmit,
                                            showCursor: true,
                                            onChanged: (v) =>
                                                Provider.of<AuthProvider>(
                                                        context,
                                                        listen: false)
                                                    .otpSuccessResponse,
                                            onCompleted: (pin) async {
                                              setState(() {
                                                otpPin = pin;
                                              });
                                              print("OTP code");

                                              print(pin.toString());
                                              Provider.of<AuthProvider>(context,
                                                      listen: false)
                                                  .codeFromOtpBoxes = pin;
                                              Provider.of<AuthProvider>(context,
                                                      listen: false)
                                                  .otpSuccessResponse;

                                              otp6Controller.text.length == 6
                                                  ? firstbuttonFunction()
                                                  : () {};
                                            }),
                                      ),
                                      if (auth.otpErrorResponse)
                                        Padding(
                                          padding: EdgeInsets.only(top: 2.h),
                                          child: Text(
                                            '*Incorrect verification code'.tr(),
                                            style: TextStyle(
                                                color: AppColors.errorColor,
                                                fontSize: 10.2.sp,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),

                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      // Expanded(
                                      //     child: SizedBox())
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.sp),
                                          child: DialogButton(
                                            title: 'Confirm',
                                            isactive:
                                                otp6Controller.text.length == 6,
                                            handler: () async {
                                              if (otp6Controller.text.length ==
                                                  6) {
                                                firstbuttonFunction();
                                              }
                                            },
                                            isLoading: false,
                                            color: AppColors.activeButtonColor,
                                            textColor: AppColors.textColorBlack,
                                          )),
                                      SizedBox(height: 2.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 22.sp),
                                        child: AppButton(
                                            title:
                                                // snapshot.data != null && snapshot.data! > 0 ?
                                                'Resend code: ' +
                                                    // "${snapshot.data.toString()}"
                                                    "${(snapshot.data! ~/ 60).toString().padLeft(2, '0')}:${(snapshot.data! % 60).toString().padLeft(2, '0')}"
                                            // :secondTitle
                                            ,

                                            // secondTitle,
                                            isactive: true,
                                            handler: () async {
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
                                                      .registerEmailResendOtp(
                                                          medium: "email",
                                                          token: accessToken,
                                                          context: context);
                                                  setState(() {
                                                    _isLoadingResend = false;
                                                  });
                                                  if (result ==
                                                      AuthResult.success) {
                                                    restartCountdown();
                                                    _events =
                                                        new StreamController<
                                                            int>();
                                                    _events.add(60);
                                                    startTimer();
                                                  }
                                                } catch (error) {
                                                  print("Error: $error");
                                                } finally {
                                                  setState(() {
                                                    _isLoadingResend = false;
                                                  });
                                                }
                                              } else {}
                                            },
                                            isGradient: false,
                                            isGradientWithBorder: false,
                                            textColor: _timeLeft != 0
                                                ? AppColors.textColorBlack
                                                    .withOpacity(0.8)
                                                : AppColors.textColorWhite,
                                            color: Colors.transparent),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                      ]));
                });
          });
        });
      });
    });
  }
}
