import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/providers/bank_provider.dart';
import 'package:hesa_wallet/providers/transaction_provider.dart';
import 'package:hesa_wallet/screens/userpayment_and_bankingpages/wallet_banking_and_payment_empty.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/configs.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';
import '../../widgets/otp_dialog.dart';
import '../signup_signin/terms_conditions.dart';

class WalletAddBank extends StatefulWidget {
  const WalletAddBank({Key? key}) : super(key: key);

  @override
  State<WalletAddBank> createState() => _WalletAddBankState();
}

class _WalletAddBankState extends State<WalletAddBank> {
  final TextEditingController _ibannumberController = TextEditingController();
  final TextEditingController _accountholdernamerController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  bool _isSelected = false;
  bool _isChecked = false;
  var accessToken = "";
  var _selectedBank = '';
  var _selectedBankBic = '';
  var isValidating = false;
  var selectedValue;
  bool isDropdownOpen = false;
  var _isLoading = false;
  var _isInit = true;
  bool isButtonActive = false;
  bool isOtpButtonActive = false;
  bool _isTextFieldFocused = false;
  Timer? _timer;
  int _timeLeft = 300;
  bool _isTimerActive = false;
  var _isLoadingResend = false;
  late StreamController<int> _events;
  final ScrollController scrollController = ScrollController();
  FocusNode _ibanfocusNode = FocusNode();
  FocusNode _beneficaryNamefocusNode = FocusNode();

  void startTimer() {
    _isTimerActive = true;
    Timer.periodic(Duration(seconds: 1), (timer) {
      (_timeLeft > 0) ? _timeLeft-- : _timer?.cancel();
      print(_timeLeft);
      _events.add(_timeLeft);
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

  void _onFocusChange() {
    setState(() {
      _isTextFieldFocused = _ibanfocusNode.hasFocus || _beneficaryNamefocusNode.hasFocus;
      if(_isTextFieldFocused){
        setState(() {
          _isSelected=false;
        });
      }
    });
 }

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    // accessToken = prefs.getString('accessToken')!;
    // print(accessToken);
    // print(accessToken);
  }

  @override
  void initState() {
    // TODO: implement initState
    getAccessToken();
    _events = new StreamController<int>();
    _events.add(300);
    _ibannumberController.addListener(_updateButtonState);
    _accountholdernamerController.addListener(_updateButtonState);
    _ibanfocusNode.addListener(_onFocusChange);
    _beneficaryNamefocusNode.addListener(_onFocusChange);
    otp1Controller.addListener(_updateOtpButtonState);
    otp2Controller.addListener(_updateOtpButtonState);
    otp3Controller.addListener(_updateOtpButtonState);
    otp4Controller.addListener(_updateOtpButtonState);
    otp5Controller.addListener(_updateOtpButtonState);
    otp6Controller.addListener(_updateOtpButtonState);

    super.initState();
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _ibannumberController.text.isNotEmpty &&
          _accountholdernamerController.text.isNotEmpty &&
          // _isChecked &&
          _selectedBank != "";
    });
  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      await getAccessToken();
      await Provider.of<BankProvider>(context, listen: false)
          .getAllBanks(accessToken);
      setState(() {
        _isLoading = false;
      });
    }
    _isInit = false;
    // fetchBanks();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    var banks = Provider.of<BankProvider>(context, listen: false).banks;
    // print("testing" + _selectedBank);
    print("testing bic" + _selectedBankBic);
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return GestureDetector(
          onTap: () {
            setState(() {
              _isSelected = false;
            });
          },
        child: Stack(
          children: [
            Scaffold(
                backgroundColor: themeNotifier.isDark
                    ? AppColors.backgroundColor
                    : AppColors.textColorWhite,
                body: Column(children: [
                  MainHeader(title: 'Add Bank Account'.tr()),
                  // SizedBox(
                  //   height: 4.h,
                  // ),
                  Expanded(
                    child: Container(
                      // color: Colors.red,
                      width: double.infinity,
                      height: 85.h,
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 17.sp),
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
                                      'Bank'.tr(),
                                      style: TextStyle(
                                          fontSize: 10.2.sp,
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
                                  Container(
                                    decoration: BoxDecoration(
                                      // border: Border.all(
                                      //   color: _isSelected
                                      //       ? AppColors.textColorGrey
                                      //       : Colors.transparent,
                                      //   width: 1.0,
                                      // ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () => setState(() {
                                            _isSelected = !_isSelected;
                                          }),
                                          child:
                                          Container(
                                            height: 6.5.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.textFieldParentDark,
                                              // border: Border.all(
                                              //   color: _isSelected
                                              //       ? Colors.transparent
                                              //       : AppColors.textColorGrey,
                                              //   width: 1.0,
                                              // ),
                                              // borderRadius:
                                              //     BorderRadius.circular(8.0),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8.0),
                                                // Radius for top-left corner
                                                topRight: Radius.circular(8.0),
                                                bottomLeft: Radius.circular(
                                                    _isSelected ? 0.0 : 8.0),
                                                bottomRight: Radius.circular(_isSelected
                                                    ? 0.0
                                                    : 8.0), // Radius for top-right corner
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // SizedBox(
                                                  //   width: 0.5.h,
                                                  // ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 8.0),
                                                    child: Text(
                                                      _selectedBank == ""
                                                          ? 'Select Bank'.tr()
                                                          : _selectedBank,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 10.2.sp,
                                                          color: themeNotifier.isDark
                                                              ? _selectedBank == ""
                                                                  ? AppColors
                                                                      .textColorGrey
                                                                  : AppColors
                                                                      .textColorWhite
                                                              : AppColors
                                                                  .textColorBlack),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        right: 10),
                                                    child: Icon(
                                                      _isSelected
                                                          ? Icons.keyboard_arrow_up
                                                          : Icons.keyboard_arrow_down,
                                                      size: 22.sp,
                                                      color: themeNotifier.isDark
                                                          ? AppColors.textColorGrey
                                                          : AppColors.textColorBlack,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (_isSelected)
                                          ListView.builder(
                                              controller: scrollController,
                                              itemCount: banks.length,
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              itemBuilder: (context, index) {
                                                bool isFirst = index == 0;

                                                bool isLast =
                                                    index == banks.length - 1;

                                                return
                                                  addBankslist(
                                                  bankName: banks[index].bankName,
                                                  english: isEnglish ? true : false,
                                                  isDark: themeNotifier.isDark
                                                      ? true
                                                      : false,
                                                  isLast: isLast, bankBic: banks[index].bic,
                                                  // isFirst: isFirst,
                                                );
                                              }),
                                      ],
                                    ),
                                  ),
                                  if(_selectedBank == '' && isValidating)
                                    Padding(
                                      padding: EdgeInsets.only(top: 7.sp),
                                      child: Text(
                                        "*Please select atleast one bank",
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
                                      'IBAN  Number'.tr(),
                                      style: TextStyle(
                                          fontSize: 10.2.sp,
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
                                        controller: _ibannumberController,
                                        focusNode: _ibanfocusNode,
                                        keyboardType: TextInputType.number,
                                        scrollPadding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom+200),
                                        onChanged: (v)=>
                                            setState(() {
                                              _isSelected = false;
                                              print("is is " + _isSelected.toString());
                                            }),
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
                                          hintText: 'Enter account IBAN number'.tr(),
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
                                  if (_ibannumberController.text.isEmpty && isValidating)
                                    Padding(
                                      padding: EdgeInsets.only(top: 7.sp),
                                      child: Text(
                                        // "*Please enter a valid email address".tr(),
                                        "*IBAN number should not be empty",
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
                                      _accountholdernamerController.text.length >= 3
                                          ? 'Account holder name'
                                          : 'Account Beneficiary Name'.tr(),
                                      style: TextStyle(
                                          fontSize: 10.2.sp,
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
                                        controller: _accountholdernamerController,
                                        focusNode: _beneficaryNamefocusNode,
                                        scrollPadding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom +
                                                150),
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
                                          hintText: 'Full name'.tr(),
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
                                  if (_accountholdernamerController.text.isEmpty && isValidating)
                                    Padding(
                                      padding: EdgeInsets.only(top: 7.sp),
                                      child: Text(
                                        // "*Please enter a valid email address".tr(),
                                        "*Name should not be empty",
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.errorColor),
                                      ),
                                    ),
                                  SizedBox(
                                    height: 25.h,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              color: themeNotifier.isDark
                                  ? AppColors.backgroundColor
                                  : AppColors.textColorWhite,
                              child: Padding(
                                padding:  EdgeInsets.only(bottom: 30.sp, left: 20.sp, right: 20.sp),
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 1.5.h,
                                      color: AppColors.backgroundColor,
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:  EdgeInsets.only(left: 4.sp),
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              _isChecked = !_isChecked;
                                            }),
                                            child:
                                            Container(
                                              height: 2.4.h,
                                              width: 2.4.h,
                                              decoration: BoxDecoration(
                                                // gradient: LinearGradient(
                                                //   colors: [
                                                //     _isChecked
                                                //         ? Color(0xff92B928)
                                                //         : Colors.transparent,
                                                //     _isChecked
                                                //         ? Color(0xffC9C317)
                                                //         : Colors.transparent
                                                //   ],
                                                // ),
                                                  border: Border.all(
                                                      color: AppColors.textColorWhite,
                                                      width: 1),
                                                  borderRadius:
                                                  BorderRadius.circular(2)),
                                              child: _isChecked
                                                  ? Align(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.check_rounded,
                                                  size: 8.2.sp,
                                                  color:
                                                  AppColors.textColorWhite,
                                                ),
                                              )
                                                  : SizedBox(),
                                            ),
                                          ),
                                        ),
                                        // SizedBox(
                                        //   width: 2.w,
                                        // ),
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
                                                          'I Agree to the Hesa Wallet '
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
                                                            ..onTap = () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                        TermsAndConditions()),
                                                              );
                                                            },
                                                          text:
                                                          'Terms & Conditions'.tr(),
                                                          style: TextStyle(
                                                              color: themeNotifier
                                                                  .isDark
                                                                  ? AppColors
                                                                  .textColorToska
                                                                  : AppColors
                                                                  .textColorBlack,
                                                              decoration: TextDecoration
                                                                  .underline,
                                                              fontWeight:
                                                              FontWeight.w600,
                                                              fontSize: 10.sp,
                                                              fontFamily: 'Inter')),
                                                      // TextSpan(
                                                      //     text: ' of payment receiving.'
                                                      //         .tr(),
                                                      //     style: TextStyle(
                                                      //         color: AppColors
                                                      //             .textColorGrey,
                                                      //         fontWeight:
                                                      //         FontWeight.w400,
                                                      //         fontSize: 12.sp,
                                                      //         fontFamily: 'Inter'))
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
                                      height: 2.h,
                                    ),

                                    // SizedBox(height: 3.h,),
                                    AppButton(
                                      title: 'Add Bank Account'.tr(),
                                      isactive: isButtonActive && _isChecked  ? true : false,
                                      handler: () async {
                                        setState(() {
                                          isValidating = true;
                                        });
                                        if (_ibannumberController.text.isNotEmpty &&
                                            _accountholdernamerController
                                                .text.isNotEmpty &&
                                            _selectedBank != "") {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          final result =
                                              await Provider.of<AuthProvider>(
                                                      context,
                                                      listen: false)
                                                  .sendOTP(
                                                      token: accessToken, context: context);

                                          setState(() {
                                            _isLoading = false;
                                          });
                                          if (result == AuthResult.success) {
                                            startTimer();
                                            otpDialog(
                                              events: _events,
                                              firstBtnHandler:() async {
                                              if (otp1Controller.text.isNotEmpty &&
                                                  otp2Controller.text.isNotEmpty &&
                                                  otp3Controller.text.isNotEmpty &&
                                                  otp4Controller.text.isNotEmpty &&
                                                  otp5Controller.text.isNotEmpty &&
                                                  otp6Controller.text.isNotEmpty) {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                print("before adding bank");

                                                final resultsecond =
                                                await Provider.of<BankProvider>(context,
                                                    listen: false)
                                                    .addBankAccount(
                                                  context: context,
                                                  token: accessToken,
                                                  // bankName: _selectedBank,
                                                  ibanNumber: _ibannumberController.text,
                                                  code: otp1Controller.text +
                                                      otp2Controller.text +
                                                      otp3Controller.text +
                                                      otp4Controller.text +
                                                      otp5Controller.text +
                                                      otp6Controller.text,
                                                  // beneficiaryName:
                                                  // _accountholdernamerController.text,
                                                 bankBic: _selectedBankBic,
                                                );
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                                print("after adding bank");
                                                if (resultsecond == AuthResult.success) {
                                                  Navigator.pop(context);
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      final screenWidth =
                                                          MediaQuery.of(context).size.width;
                                                      final dialogWidth = screenWidth * 0.85;
                                                      void closeDialogAndNavigate() {
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                        // Navigator.of(context).pop(); // Close the
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  WalletBankingAndPaymentEmpty()),
                                                        );
                                                      }

                                                      Future.delayed(Duration(seconds: 3),
                                                          closeDialogAndNavigate);
                                                      return StatefulBuilder(builder:
                                                          (BuildContext context,
                                                          StateSetter setState) {
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
                                                                height: 23.h,
                                                                width: dialogWidth,
                                                                decoration: BoxDecoration(
                                                                  // border: Border.all(
                                                                  //     width:
                                                                  //         0.1.h,
                                                                  //     color: AppColors.textColorGrey),
                                                                  color: themeNotifier.isDark
                                                                      ? AppColors.showDialogClr
                                                                      : AppColors.textColorWhite,
                                                                  borderRadius:
                                                                  BorderRadius.circular(15),
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
                                                                        "assets/images/bank_popup.png",
                                                                        height: 6.h,
                                                                        width: 5.8.h,
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 2.h),
                                                                    Text(
                                                                      'Your Bank account has been added'.tr(),
                                                                      textAlign: TextAlign.center,
                                                                      maxLines: 2,
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                          FontWeight.w600,
                                                                          fontSize: 15.sp,
                                                                          color: themeNotifier.isDark
                                                                              ? AppColors
                                                                              .textColorWhite
                                                                              : AppColors
                                                                              .textColorBlack),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 4.h,
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                        );
                                                      });
                                                    },
                                                  );
                                                }
                                              }
                                            },
                                              secondBtnHandler: () async {
                                                if (_timeLeft == 0) {
                                                  print('resend function calling');
                                                  try {
                                                    setState(() {
                                                      _isLoadingResend = true;
                                                    });
                                                    final result = await Provider.of<
                                                        AuthProvider>(context,
                                                        listen: false)
                                                        .sendOTP(
                                                        context: context, token: accessToken);
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
                                              isFirstButtonActive: isOtpButtonActive,
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
                                              secondBtnBgColor: Colors.transparent,
                                              secondBtnTextColor: _timeLeft != 0
                                                  ? AppColors.textColorBlack
                                                  .withOpacity(0.8)
                                                  : AppColors.textColorWhite,
                                              // themeNotifier.isDark
                                              //     ? AppColors.textColorWhite
                                              //     : AppColors.textColorBlack
                                              //         .withOpacity(0.8),
                                              isLoading: _isLoading,
                                            );
                                          }
                                        }
                                      },
                                      isLoading: _isLoading,
                                      isGradient: true,
                                      color: Colors.transparent,
                                      // textColor: AppColors.textColorGreyShade2,
                                    ),
                                    // SizedBox(
                                    //   height: 3.h,
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ])),
            if(_isLoading)
              LoaderBluredScreen()
          ],
        ),
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
      color: Colors.white.withOpacity(0.15),
      child:
      TextField(
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

  Widget addBankslist({
    required String bankName,
    required String bankBic,
    bool isFirst = false,
    bool isLast = false,
    bool english = false,
    bool isDark = true,
  }) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedBank = bankName;
        _selectedBankBic = bankBic;
        _isSelected = false;
      }),
      child: Container(
        child: Column(
          // mainAxisAlignment: english ? MainAxisAlignment.start : MainAxisAlignment.end,

          children: [
            // if (isFirst)
            //   Divider(
            //     color: AppColors.textColorGrey,
            //   ),
            Container(
              height: 5.5.h,
              decoration: BoxDecoration(
                color: AppColors.textFieldParentDark,
                // border: Border.all(
                //   color: _isSelected
                //       ? Colors.transparent
                //       : AppColors.textColorGrey,
                //   width: 1.0,
                // ),
                // borderRadius: BorderRadius.circular(8.0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(_isSelected && !isLast? 0.0 :8.0 ),
                  // Radius for top-left corner
                  bottomRight: Radius.circular(_isSelected && !isLast? 0.0 :8.0),
                  topLeft: Radius.circular(
                      _isSelected ? 0.0 : 8.0),
                  topRight: Radius.circular(_isSelected
                      ? 0.0
                      : 8.0), // Radius for top-right corner
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                child: Row(
                  mainAxisAlignment:
                      english ? MainAxisAlignment.start : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // color: Colors.red,
                      width: 70.w,
                      child: Text(
                        bankName,
                        // "SNB (Saudi National Bank)".tr(),
                        style: TextStyle(
                            fontSize: 10.2.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textColorWhite
                                : AppColors.textColorBlack,
                        overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // if (!isLast)
            //   Divider(
            //     color: AppColors.textColorGrey,
            //   ),
            // if (isLast)
            //   SizedBox(
            //     height: 1.h,
            //   ),
          ],
        ),
      ),
    );
  }

}
