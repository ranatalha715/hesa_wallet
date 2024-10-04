import 'dart:async';
import 'dart:ui';
import 'package:animated_checkmark/animated_checkmark.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../constants/configs.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';
import '../../widgets/otp_dialog.dart';

class DeleteAccountDisclaimer extends StatefulWidget {
  const DeleteAccountDisclaimer({Key? key}) : super(key: key);

  @override
  State<DeleteAccountDisclaimer> createState() =>
      _DeleteAccountDisclaimerState();
}

class _DeleteAccountDisclaimerState extends State<DeleteAccountDisclaimer> {
  final ScrollController scrollController = ScrollController();

  List<String> accountDefinitions = [
    'Account means a unique account created for You to access our Service or parts of our Service.'
        .tr(),
    'Affiliate means an entity that controls, is controlled by or is under common control with a party, where "control" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.'
        .tr(),
    'Affiliate means an entity that controls, is controlled by or is under common control with a party, where "control" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.'
        .tr()
        .tr(),
    'Affiliate means an entity that controls, is controlled by or is under common control with a party, where "control" means ownership of'
        .tr(),
  ];

  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController otp5Controller = TextEditingController();
  final TextEditingController otp6Controller = TextEditingController();

  FocusNode firstFieldFocusNode = FocusNode();
  FocusNode secondFieldFocusNode = FocusNode();
  FocusNode thirdFieldFocusNode = FocusNode();
  FocusNode forthFieldFocusNode = FocusNode();
  FocusNode fifthFieldFocusNode = FocusNode();
  FocusNode sixthFieldFocusNode = FocusNode();

  bool _isSelected = false;
  var isLoading = false;
  var accessToken = '';
  var _isLoadingResend = false;
  var _isLoading = false;
  var _isinit = true;
  bool _isTimerActive = false;
  var _isLoadingOtpDialoge = false;
  int _timeLeft = 60;
  bool isOtpButtonActive = false;
  Timer? _timer;
  StreamController<int> _events = StreamController<int>.broadcast();

  getWsToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
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

  void restartCountdown() {
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
  void initState() {
    // TODO: implement initState

    _events = new StreamController<int>();
    _events.add(60);
    getWsToken();
    otp1Controller.addListener(_updateOtpButtonState);
    otp2Controller.addListener(_updateOtpButtonState);
    otp3Controller.addListener(_updateOtpButtonState);
    otp4Controller.addListener(_updateOtpButtonState);
    otp5Controller.addListener(_updateOtpButtonState);
    otp6Controller.addListener(_updateOtpButtonState);
    super.initState();
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
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if (_isinit) {
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final auth=Provider.of<AuthProvider>(context,listen: false);
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: Column(
              children: [
                MainHeader(title: 'Delete Account'.tr()),
                Stack(
                  children: [
                    Container(
                      height: 85.h,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5.h,
                              ),
                              Text(
                                "Are you sure you want to delete your wallet?"
                                    .tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 1.4,
                                    color: AppColors.textColorWhite,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 19.sp,
                                    fontFamily: 'Inter'),
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Text(
                                "Deleting your wallet means your wallet will remain inactive and become disabled. Transactions pending on other Dapps will not be able to send requests to your wallet anymore. "
                                    .tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 1.4,
                                    color: AppColors.textColorWhite,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    fontFamily: 'Inter'),
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Container(
                          color: themeNotifier.isDark
                              ? AppColors.backgroundColor
                              : AppColors.textColorWhite,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        _isSelected = !_isSelected;
                                      }),
                                      child: AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          height: 2.4.h,
                                          width: 2.4.h,
                                          decoration: BoxDecoration(
                                            color: _isSelected
                                                ? AppColors.hexaGreen
                                                : Colors.transparent,
                                            // Animate the color
                                            border: Border.all(
                                                color: _isSelected
                                                    ? AppColors.hexaGreen
                                                    : AppColors.textColorWhite,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                          child: Checkmark(
                                            checked: _isSelected,
                                            indeterminate: false,
                                            size: 11.sp,
                                            color: Colors.black,
                                            drawCross: false,
                                            drawDash: false,
                                          ),
                                          ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 3.w,
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 3.sp),
                                      child: Column(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                    text:
                                                        'I agree to permanently deleting my account in accordance to Hesa Wallet’s '
                                                            .tr(),
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .textColorWhite,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 10.sp,
                                                        fontFamily: 'Inter')),
                                                TextSpan(
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () {},
                                                    text: 'Terms & Conditions'
                                                        .tr(),
                                                    style: TextStyle(
                                                        height: 1.4,
                                                        color: themeNotifier
                                                                .isDark
                                                            ? AppColors
                                                                .textColorToska
                                                            : AppColors
                                                                .textColorBlack,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 10.sp,
                                                        fontFamily: 'Inter')),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              AppButton(
                                title: 'Delete Account'.tr(),
                                isactive: _isSelected,
                                isGradientWithBorder: true,
                                handler: () async {
                                  if (_isSelected) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    final result = await Provider.of<
                                        AuthProvider>(context,
                                        listen: false)
                                        .deleteAccountStep1(
                                      termsAndConditions: _isSelected.toString(),
                                        context: context, token: accessToken,
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    if (result ==
                                        AuthResult.success) {

                                      startTimer();
                                      otpDialog(
                                        fromTransaction: false,
                                        fromAuth: true,
                                        fromUser: false,
                                        events: _events,
                                        firstBtnHandler: () async {
                                            try {
                                              setState(() {
                                                _isLoadingOtpDialoge =
                                                true;
                                              });
                                              await Future.delayed(const Duration(milliseconds: 500));
                                              print('loading popup' +
                                                  _isLoadingOtpDialoge
                                                      .toString());
                                              final result = await Provider
                                                  .of<AuthProvider>(
                                                  context,
                                                  listen:
                                                  false)
                                                  .deleteAccountStep2(
                                                context:
                                                context,
                                                code: Provider.of<AuthProvider>(context, listen: false).codeFromOtpBoxes,
                                                token: accessToken,);
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

                                              }
                                            } catch (error) {
                                              print("Error: $error");
                                              setState(() {
                                                _isLoadingOtpDialoge =
                                                false;
                                              });
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
                                                  .registerNumResendOtp(

                                                  context:
                                                  context, token: accessToken, medium: "sms");
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
                                        secondTitle: 'Resend code ',

                                        context: context,
                                        isDark: themeNotifier.isDark,
                                        isFirstButtonActive:
                                        isOtpButtonActive,
                                        isSecondButtonActive: !_isTimerActive,
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
                                        isLoading: _isLoading,
                                      );
                                    }
                                  }

                                },

                                isGradient: false,
                                color: AppColors.deleteAccountBtnColor
                                    .withOpacity(0.10),
                                textColor: AppColors.textColorBlack,
                                buttonWithBorderColor: AppColors.errorColor,
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              AppButton(
                                title: 'Cancel'.tr(),
                                // isactive: _isSelected,
                                isGradientWithBorder: true,

                                handler: () => Navigator.pop(context),
                                isGradient: false,
                                color: AppColors.deleteAccWarningClr
                                    .withOpacity(0.10),
                                textColor: AppColors.textColorBlack,
                                buttonWithBorderColor: AppColors.greenBorderClr,
                              ),
                            ],
                          ),
                        ))
                  ],
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
