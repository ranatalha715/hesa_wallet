


import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/colors.dart';
import '../../constants/configs.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/main_header.dart';
import '../../widgets/otp_dialog.dart';

class VerifyEmail extends StatefulWidget {


  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {

  Timer? _timer;
  late StreamController<int> _events;
  var _isLoadingOtpDialoge = false;
  var _isLoadingResend = false;
  bool _isTimerActive = false;
  var _isLoading = false;
  bool isOtpButtonActive = false;
  int _timeLeft = 60;
  var accessToken = "";




  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    // print(accessToken);
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
    _isTimerActive = true;
    Timer.periodic(Duration(seconds: 1), (timer) {
      (_timeLeft > 0) ? _timeLeft-- : _timer?.cancel();
      print(_timeLeft);
      _events.add(_timeLeft);
    });
  }


  openVerifyEmailPopup(){
    startTimer();
    otpDialog(
      events: _events,
      isBlurred: false,
      isEmailOtpDialog: true,
      firstBtnHandler: () async {
          try {
            setState(() {
              _isLoadingOtpDialoge =
              true;
            });
            await Future.delayed(const Duration(milliseconds: 1000));
            print('loading popup' +
                _isLoadingOtpDialoge
                    .toString());
            final result = await Provider
                .of<AuthProvider>(
                context,
                listen:
                false)
                .registerUserStep4(
              context:
              context,

              code:  Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes,
            );

            setState(() {
              _isLoadingOtpDialoge =
              false;
            });
            print('loading popup 2' +
                _isLoadingOtpDialoge
                    .toString());
            if (result ==
                AuthResult
                    .success) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(
                  '/TermsAndConditions',
                      (Route d) =>
                  false);
            }
          } catch (error) {
            print("Error: $error");
            setState(() {
              _isLoadingOtpDialoge =
              false;
            });
            // _showToast('An error occurred'); // Show an error message
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
            final result = await Provider
                .of<AuthProvider>(
                context,
                listen:
                false)
                .registerEmailResendOtp(
                medium: "email",
                token: accessToken,
                context:
                context);
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
            // _showToast('An error occurred'); // Show an error message
          } finally {
            setState(() {
              _isLoadingResend =
              false;
            });
          }
        } else {}
      },
      firstTitle: 'Verify',
      secondTitle: 'Resend code: ',

      // "${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}",

      context: context,
      isDark: true,
      isFirstButtonActive:
      isOtpButtonActive,
      isSecondButtonActive: false,
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
      // themeNotifier.isDark
      //     ? AppColors.textColorWhite
      //     : AppColors.textColorBlack
      //         .withOpacity(0.8),
      isLoading: _isLoading,
      // isLoading: _isLoadingResend,
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

    Future.delayed(Duration(milliseconds: 500 ), () {
      openVerifyEmailPopup();
    });
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
    return Scaffold(
      backgroundColor: themeNotifier.isDark
          ? AppColors.backgroundColor
          : AppColors.textColorWhite,
      body: SingleChildScrollView(
      child: Column(
          children: [
      MainHeader(title: 'Verify Email'),
      // SizedBox(
      //   height: 2.h,
      // ),
      ])
    ));

    });
  }}

