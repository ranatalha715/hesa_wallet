import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/models/payment_card_model.dart';
import 'package:hesa_wallet/providers/bank_provider.dart';
import 'package:hesa_wallet/screens/userpayment_and_bankingpages/wallet_add_bank.dart';
import 'package:hesa_wallet/screens/userpayment_and_bankingpages/wallet_add_card.dart';
import 'package:hesa_wallet/screens/userpayment_and_bankingpages/wallet_update_bank.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../providers/auth_provider.dart';
import '../../providers/card_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';
import '../../widgets/otp_dialog.dart';

class WalletBankingAndPaymentEmpty extends StatefulWidget {
  const WalletBankingAndPaymentEmpty({Key? key}) : super(key: key);

  @override
  State<WalletBankingAndPaymentEmpty> createState() =>
      _WalletBankingAndPaymentEmptyState();
}

class _WalletBankingAndPaymentEmptyState
    extends State<WalletBankingAndPaymentEmpty> {
  var _selectedPaymentCard = false;
  bool _isSelected = false;
  bool _isSelectedBank = false;
  var isDeleteBankLoading = false;
  var _selectedBankDetails = false;
  bool isOtpButtonActive = false;
  var accessToken = "";
  Timer? _timer;
  var _isLoading = false;
  int _timeLeft = 60;
  late StreamController<int> _events;
  bool _isTimerActive = false;
  var isLoading = false;
  var isInit = true;
  var isDialogLoading = false;

  FocusNode firstFieldFocusNode = FocusNode();
  FocusNode secondFieldFocusNode = FocusNode();
  FocusNode thirdFieldFocusNode = FocusNode();
  FocusNode forthFieldFocusNode = FocusNode();
  FocusNode fifthFieldFocusNode = FocusNode();
  FocusNode sixthFieldFocusNode = FocusNode();

  final ScrollController scrollController = ScrollController();
  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController otp5Controller = TextEditingController();
  final TextEditingController otp6Controller = TextEditingController();
  navigateToAddCard() async {
    print('card brand');
    print(Provider.of<TransactionProvider>(context, listen: false)
        .selectedCardBrand);
    var result = await Provider.of<TransactionProvider>(context, listen: false)
        .tokenizeCardRequest(
            token: accessToken,
            brand: Provider.of<TransactionProvider>(context, listen: false)
                .selectedCardBrand,
            context: context);
    if (result == AuthResult.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WalletAddCard(
            tokenizedCheckoutId:
                Provider.of<TransactionProvider>(context, listen: false)
                    .tokenizedCheckoutId,
          ),
        ),
      );
    }
  }

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
  void initState() {
   _events = new StreamController<int>();
   _events.add(60);
    // TODO: implement initState
   otp1Controller.addListener(_updateOtpButtonState);
   otp2Controller.addListener(_updateOtpButtonState);
   otp3Controller.addListener(_updateOtpButtonState);
   otp4Controller.addListener(_updateOtpButtonState);
   otp5Controller.addListener(_updateOtpButtonState);
   otp6Controller.addListener(_updateOtpButtonState);
   final paymentCards =
       Provider.of<UserProvider>(context, listen: false).paymentCards;
   var trPro = Provider.of<TransactionProvider>(context, listen: false);
   if (trPro.selectedCardNum == null || trPro.selectedCardNum == "") {
     if (paymentCards.isNotEmpty) {
       trPro.selectedCardNum = paymentCards[0].bin;
       trPro.selectedCardLast4Digits = paymentCards[0].last4Digits;
       trPro.selectedCardBrand = paymentCards[0].cardBrand;
     }
   }
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if (isInit) {
      setState(() {
        isLoading = true;
      });
      await getAccessToken();

      await Provider.of<UserProvider>(context, listen: false)
          .getUserDetails(token: accessToken, context: context);
      final paymentCards =
          Provider.of<UserProvider>(context, listen: false).paymentCards;
      var trPro = Provider.of<TransactionProvider>(context, listen: false);
      if (trPro.selectedCardNum == null || trPro.selectedCardNum == "") {
        if (paymentCards.isNotEmpty) {
          trPro.selectedCardNum = paymentCards[0].bin;
          trPro.selectedCardLast4Digits = paymentCards[0].last4Digits;
          trPro.selectedCardBrand = paymentCards[0].cardBrand;
        }
      }
      setState(() {
        isLoading = false;
      });
      super.didChangeDependencies();
    }
    isInit = false;
  }

  Future<void> refreshPage() async {
    setState(() {
      isLoading = true;
    });
    // await getAccessToken();
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
    setState(() {
      isLoading = false;
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

  Future<void> updateBankAccountAndRefreshDetails(bool isPrimary, int index, String accessToken,
      String ibanNumber, String accountholdername, String bic, BuildContext ctx) async {
    setState(() {
      isLoading = true;
    });

    var result =   await Provider.of<BankProvider>(
        context,
        listen: false)
        .updateBankAccountAsPrimaryStep1(
      // bic: bic,
      context: context,
      token: accessToken,
      isPrimary: isPrimary, accountNumber: ibanNumber,
      // accountTitle: accountholdername,
    );
    // await Provider.of<BankProvider>(context, listen: false)
    //     .updateBankAccount(
    //   isPrimary: true,
    //   index: index,
    //   accountNumber: ibanNumber,
    //   bic: bic,
    //   token: accessToken,
    //   context: ctx,
    // );

    if (result == AuthResult.success) {
      startTimer();
      otpDialog(
        fromUser: false,
        fromAuth: false,
        fromTransaction:false,
        events: _events,
        isDark: true,
        firstBtnHandler: () async {
          setState(() {
            _isLoading = true;
          });
          await Future.delayed(
              const Duration(
                  milliseconds: 500));
          final resultsecond = await Provider
              .of<BankProvider>(
              context,
              listen: false)
              .updateBankAccountStep2(
              context: context,
              token: accessToken,
              code: Provider.of<
                  AuthProvider>(
                  context,
                  listen: false)
                  .codeFromOtpBoxes);
          setState(() {
            _isLoading = false;
          });
          print("after adding bank");
          if (resultsecond ==
              AuthResult.success) {
            await Future.delayed(
                const Duration(
                    milliseconds: 500));
           Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WalletBankingAndPaymentEmpty(),
            ),
          );
          }
        },
        secondBtnHandler: () async {
          if (_timeLeft == 0) {
            print(
                'resend function calling');
            try {
              setState(() {
                // _isLoadingResend = true;
              });
              final result = await Provider
                  .of<AuthProvider>(
                  context,
                  listen: false)
                  .sendOTP(
                  context: context,
                  token:
                  accessToken);
              setState(() {
                // _isLoadingResend =
                // false;
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
                // _isLoadingResend =
                // false;
              });
            }
          } else {}
        },
        firstTitle: 'Verify',
        secondTitle: 'Resend code ',

        // "${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}",

        context: context,
        // isDark: themeNotifier.isDark,
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
        secondBtnTextColor: _timeLeft !=
            0
            ? AppColors.textColorBlack
            .withOpacity(0.8)
            : AppColors.textColorWhite,
        // themeNotifier.isDark
        //     ? AppColors.textColorWhite
        //     : AppColors.textColorBlack
        //         .withOpacity(0.8),
        isLoading: _isLoading,
      );







      // Navigator.pop(context);
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => WalletBankingAndPaymentEmpty(),
      //   ),
      // );
      // print('updated success!');
    }

    setState(() {
      isLoading = false;
    });
  }

  changeSelectedCard(List<PaymentCard> paymentCards, int index) async {
    final trPro = Provider.of<TransactionProvider>(context, listen: false);
    setState(() {
      trPro.selectedCardNum = paymentCards[index].bin;
      trPro.selectedCardLast4Digits = paymentCards[index].last4Digits;
      trPro.selectedCardBrand = paymentCards[index].cardBrand;
      _isSelected = false;
      trPro.selectedCardTokenId = paymentCards[index].id;
    });
  }

  Future<void> refreshUserDetails(
      String accessToken, BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
  }

  void confirmBrandDialogue(Function onCloseHandler,
      {required bool showPopup}) {
    if (showPopup) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final dialogWidth = screenWidth * 0.85;
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Colors.transparent,
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                    height: 23.h,
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          'Please select your card type'.tr(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: AppColors.textColorWhite),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Provider.of<TransactionProvider>(context,
                                        listen: false)
                                    .selectedCardBrand = 'VISA';
                                // Navigator.pop(context);
                                navigateToAddCard();
                              },
                              child: Image.asset(
                                "assets/images/VisaPopup.png",
                                height: 40.sp,
                                width: 40.sp,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Provider.of<TransactionProvider>(context,
                                        listen: false)
                                    .selectedCardBrand = 'MASTER';
                                navigateToAddCard();
                              },
                              child: Image.asset(
                                "assets/images/MastercardPopup.png",
                                height: 40.sp,
                                width: 40.sp,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Provider.of<TransactionProvider>(context,
                                        listen: false)
                                    .selectedCardBrand = 'MADA';
                                navigateToAddCard();
                              },
                              child: Image.asset(
                                "assets/images/MadaPayPopup.png",
                                height: 45.sp,
                                width: 44.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                      ],
                    ),
                  )),
            );
          });
        },
      ).then((value) => onCloseHandler());
    } else {
      onCloseHandler();
    }
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final banks = Provider.of<UserProvider>(context, listen: false).banks;
    final bankpro = Provider.of<BankProvider>(context, listen: false);

    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      final paymentCards =
          Provider.of<UserProvider>(context, listen: false).paymentCards;
      var trPro = Provider.of<TransactionProvider>(context, listen: false);
      if (trPro.selectedCardNum == null || trPro.selectedCardNum == "") {
        if (paymentCards.isNotEmpty) {
          trPro.selectedCardNum = paymentCards[0].bin;
          trPro.selectedCardLast4Digits = paymentCards[0].last4Digits;
          trPro.selectedCardBrand = paymentCards[0].cardBrand;
        }
      }
      for (var bank in banks) {
        if (bank.isPrimary == "true") {
          bankpro.selectedBankName = isEnglish ? bank.bankName!:bank.bankNameAr!;
          break;
        }
      }
      for (var bank in banks) {
        if (bank.isPrimary == "true") {
          bankpro.selectedBank = bank.ibanNumber;
          break;
        }
      }
      // print('bankpro.selectedBankName' + bankpro.selectedBankName);
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  MainHeader(title: 'Banking & payments'.tr()),
                  Container(
                    height: 89.h,
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
                              height: 4.h,
                            ),
                            // SizedBox(height: 2.h,),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Payment cards'.tr(),
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        color: themeNotifier.isDark
                                            ? AppColors.textColorWhite
                                            : AppColors.textColorBlack),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () async {
                                      confirmBrandDialogue(
                                        () async {

                                        },
                                        showPopup: true,
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 11.sp,
                                          height: 11.sp,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.transparent,
                                            border: Border.all(
                                                color: AppColors
                                                    .textColorGreyShade2),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            size: 8.sp,
                                            color: themeNotifier.isDark
                                                ? AppColors.textColorGreyShade2
                                                : AppColors.textColorGreyShade2,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 1.5.w,
                                        ),
                                        Text(
                                          'Add new'.tr(),
                                          style: TextStyle(
                                              fontSize: 11.sp,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              color: AppColors
                                                  .textColorGreyShade2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.textFieldParentDark,
                                      borderRadius:
                                          BorderRadius.circular(8.sp)),
                                  child: GestureDetector(
                                    onTap: () => paymentCards.isNotEmpty
                                        ? setState(() {
                                            _isSelected = !_isSelected;
                                          })
                                        : {},
                                    child: Container(
                                      height: 6.5.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.sp)),
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
                                            if( paymentCards.isNotEmpty)
                                            SizedBox(
                                              width: 8.sp,
                                            ),
                                           if( paymentCards.isNotEmpty)
                                            trPro.selectedCardBrand == 'VISA'
                                                ? Image.asset(
                                              "assets/images/Visa.png",
                                              height: 17.sp,
                                            )
                                                : Container(
                                              height: 2.7.h,
                                              decoration: BoxDecoration(
                                                color: AppColors
                                                    .textColorGreyShade2
                                                    .withOpacity(0.27),
                                                borderRadius:
                                                BorderRadius.circular(
                                                    3),
                                              ),
                                              child: Padding(
                                                padding:
                                                EdgeInsets.symmetric(
                                                    horizontal:
                                                    3.3.sp,
                                                    vertical: 0.4.sp),
                                                child: Image.asset(
                                                  trPro.selectedCardBrand ==
                                                      'MASTER'
                                                      ? "assets/images/master2.png"
                                                      : "assets/images/mada_pay.png",
                                                  height: 18.sp,
                                                  width: 18.sp,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: paymentCards.isNotEmpty
                                                  ? Text(
                                                      trPro.selectedCardNum
                                                              .toString()
                                                              .substring(0, 4) +
                                                          " **** **** " +
                                                          trPro
                                                              .selectedCardLast4Digits,
                                                      // 'Payment Cards'.tr(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 11.sp,
                                                          color: themeNotifier
                                                                  .isDark
                                                              ? AppColors
                                                                  .textColorWhite
                                                              : AppColors
                                                                  .textColorBlack),
                                                    )
                                                  : Container(
                                                width: 75.w,
                                                    // color: Colors.yellow,
                                                    child: Text(
                                                        'No payment card have been added'
                                                            .tr(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 11.7.sp,
                                                            color: themeNotifier
                                                                    .isDark
                                                                ? AppColors
                                                                    .textColorGreyShade2
                                                                : AppColors
                                                                    .textColorBlack),
                                                      ),
                                                  ),
                                            ),
                                            Spacer(),
                                            if (paymentCards.isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 6.sp),
                                                child: Icon(
                                                  _isSelected
                                                      ? Icons
                                                      .keyboard_arrow_up
                                                      : Icons
                                                      .keyboard_arrow_down,
                                                  size: 22.sp,
                                                  color:
                                                  AppColors.textColorGrey,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_isSelected)
                                  Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.textFieldParentDark,
                                        boxShadow: [
                                          BoxShadow(
                                            color: _isSelected
                                                ? Colors.black.withOpacity(0.10)
                                                : Colors.transparent,
                                            // Shadow color
                                            offset: Offset(0, 4),
                                            // Pushes the shadow down, removes the top shadow
                                            blurRadius: 3,
                                            // Adjust the blur radius to change shadow size
                                            spreadRadius:
                                                0.5, // Optional: Adjust spread radius if needed
                                          ),
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(8.sp)),
                                    margin: EdgeInsets.only(top: 4.sp),
                                    child: ListView.builder(
                                        controller: scrollController,
                                        itemCount: paymentCards.length,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          bool isFirst = index == 0;

                                          bool isLast =
                                              index == paymentCards.length - 1;

                                          return GestureDetector(
                                            onTap: () {
                                              print(trPro.selectedCardTokenId);
                                              setState(() {
                                                trPro.selectedCardNum =
                                                    paymentCards[index].bin;
                                                trPro.selectedCardLast4Digits =
                                                    paymentCards[index]
                                                        .last4Digits;
                                                trPro.selectedCardBrand =
                                                    paymentCards[index]
                                                        .cardBrand;

                                                _isSelected = false;
                                                trPro.selectedCardTokenId =
                                                    trPro.selectedCardTokenId =
                                                        paymentCards[index].id;
                                              });
                                            },
                                            child: paymentCardWidget(
                                              isFirst: isFirst,
                                              isDark: themeNotifier.isDark
                                                  ? true
                                                  : false,
                                              english: isEnglish ? true : false,
                                              index: index,
                                              isLast: isLast,
                                              cardNum: paymentCards[index].bin,
                                              regNum: paymentCards[index].id,
                                              last4Digits: paymentCards[index]
                                                  .last4Digits,
                                              cardBrand:
                                                  paymentCards[index].cardBrand,
                                            ),
                                          );
                                        }),
                                  )
                              ],
                            ),
                            SizedBox(
                              height: _isSelected ? 10.h : 5.h,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Banking details'.tr(),
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        color: themeNotifier.isDark
                                            ? AppColors.textColorWhite
                                            : AppColors.textColorBlack),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WalletAddBank(),
                                      ),
                                    ),
                                    child: Container(
                                      width: 11.sp,
                                      height: 11.sp,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.transparent,
                                        border: Border.all(
                                            color:
                                                AppColors.textColorGreyShade2),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        size: 8.sp,
                                        color: themeNotifier.isDark
                                            ? AppColors.textColorGreyShade2
                                            : AppColors.textColorGreyShade2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 1.5.w),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WalletAddBank(),
                                      ),
                                    ),
                                    child: Text(
                                      'Add new'.tr(),
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textColorGreyShade2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _isSelectedBank = !_isSelectedBank;
                                  }),
                                  child: Container(
                                    height: 6.5.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.textFieldParentDark,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 1.h,
                                        ),
                                        if(banks.isNotEmpty)
                                        Container(
                                          margin: EdgeInsets.only(left: 4.sp),
                                          // color: Colors.red,
                                          width: 45.w,
                                          child: Text(
                                            bankpro.selectedBankName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight:
                                                    FontWeight.w500,
                                                fontSize: 10.sp,
                                                color: themeNotifier
                                                        .isDark
                                                    ? AppColors
                                                        .textColorWhite
                                                    : AppColors
                                                        .textColorBlack),
                                          ),
                                        ),
                                        if(banks.isNotEmpty)
                                        Spacer(),
                                        Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6.0),
                                            child: banks.isNotEmpty
                                                ?   Text(
                                                    isEnglish ? " **** " +
                                                        bankpro.selectedBank
                                                            .substring(
                                                          bankpro.selectedBank
                                                                  .length -
                                                              4,
                                                        ) :
                                                        bankpro.selectedBank
                                                            .substring(
                                                          bankpro.selectedBank
                                                              .length -
                                                              4,
                                                        ) + " **** " ,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 11.sp,
                                                        color: themeNotifier.isDark
                                                            ? AppColors
                                                                .textColorWhite
                                                            : AppColors
                                                                .textColorBlack),
                                                  )
                                                : Container(
                                              // color: Colors.red,
                                              width: 75.w,
                                                  child: Text(
                                                      'No banking have been added'
                                                          .tr(),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 11.7.sp,
                                                          color: themeNotifier.isDark
                                                              ? AppColors
                                                                  .textColorGreyShade2
                                                              : AppColors
                                                                  .textColorBlack),
                                                    ),
                                                )),
                                        // Spacer(),
                                        if (banks.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: 7.sp),
                                            child:  Icon(
                                              _isSelectedBank
                                                  ? Icons
                                                  .keyboard_arrow_up
                                                  : Icons
                                                  .keyboard_arrow_down,
                                              size: 22.sp,
                                              color:
                                              AppColors.textColorGrey,
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                                _isSelectedBank
                                    ?
                                    Container(
                                      margin: EdgeInsets.only(top:4.sp),
                                      decoration: BoxDecoration(
                                        color: AppColors.textFieldParentDark,
                                        boxShadow: [
                                          BoxShadow(
                                            color: _isSelectedBank
                                                ? Colors.black.withOpacity(0.10)
                                                : Colors.transparent,
                                            offset: Offset(0, 4),
                                            blurRadius: 3,
                                            spreadRadius:
                                            0.5,
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: ListView.builder(
                                          controller: scrollController,
                                          itemCount: banks.length,
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context, index) {
                                            bool isFirst = index == 0;
                                            bool isLast =
                                                index == banks.length - 1;
                                            String lastFourDigits = banks[index]
                                                .ibanNumber
                                                .substring(
                                                  banks[index]
                                                          .ibanNumber
                                                          .length -
                                                      4,
                                                );
                                            bankpro.selectedBank = banks[index]
                                                        .isPrimary ==
                                                    "true"
                                                ? " **** " +
                                                    banks[index]
                                                        .ibanNumber
                                                        .substring(banks[index]
                                                                .ibanNumber
                                                                .length -
                                                            4)
                                                : "";
                                            print("Selected Bank Name");
                                            print(bankpro.selectedBankName);
                                            return bankingDetailsWidget(
                                              accountNumber:
                                                 isEnglish ? "**** " + lastFourDigits : lastFourDigits   + " ****",
                                              fullAccountNumber:
                                                  banks[index].ibanNumber,
                                              isLast: isLast,
                                              isFirst: isFirst,
                                              handler: () async {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                await updateBankAccountAndRefreshDetails(
                                                  true,
                                                  index,
                                                  accessToken,
                                                  banks[index].ibanNumber,
                                                  banks[index].bic,
                                                  banks[index].accountTitle.toString(),
                                                  context,
                                                );
                                                setState(() {
                                                  isLoading = false;
                                                });
                                              },

                                              // handler: () async {
                                              //   // Call the function to update the bank account and refresh details
                                              //   await updateBankAccountAndRefreshDetails(
                                              //       index,
                                              //       accessToken,
                                              //       banks[index]
                                              //           .ibanNumber,
                                              //       banks[index].bic,
                                              //       context);
                                              // },

                                              // handler: () async {
                                              //   print('before update');
                                              //   var result =
                                              //   await bankpro
                                              //       .updateBankAccount(
                                              //     isPrimary: true,
                                              //     index: index,
                                              //     accountNumber:
                                              //         banks[index].ibanNumber,
                                              //     bic: banks[index].bic,
                                              //     token: accessToken,
                                              //     context: context,
                                              //   );
                                              //   print('after update');
                                              //   await refreshUserDetails();
                                              //
                                              //   if (result ==
                                              //       AuthResult.success) {
                                              //     await refreshUserDetails();
                                              //     // setState(() {
                                              //     //   isLoading = true;
                                              //     // });
                                              //     // // Provider.of<UserProvider>(context, listen: false).banks.clear();
                                              //     //
                                              //     // await Provider.of<UserProvider>(
                                              //     //         context,
                                              //     //         listen: false)
                                              //     //     .getUserDetails(
                                              //     //         token: accessToken,
                                              //     //         context: context);
                                              //     // setState(() {
                                              //     //   isLoading = false;
                                              //     // });
                                              //     // Navigator.pop(context);
                                              //   }
                                              // },
                                              isPrimary:
                                                  banks[index].isPrimary ==
                                                          "true"
                                                      ? true
                                                      : false,
                                              english: isEnglish ? true : false,
                                              isDark: themeNotifier.isDark
                                                  ? true
                                                  : false,
                                              selectedBankName:
                                                 isEnglish ? banks[index].bankName! : banks[index].bankNameAr!,
                                              selectedBic: banks[index].bic!,
                                              selectedAccTitle:
                                                  banks[index].accountTitle ??
                                                      'null',
                                            );
                                          },
                                        ),
                                    )
                                    : SizedBox(),
                              ],
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
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

  Widget paymentCardWidget({
    bool isFirst = false,
    bool isLast = false,
    bool english = false,
    bool isDark = true,
    required String cardNum,
    required String last4Digits,
    required String cardBrand,
    required String regNum,
    required int index,
  }) {
    return Column(
      children: [
        Container(
          height: 6.5.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: _isSelected ? Colors.transparent : AppColors.textColorGrey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // if (english)
                  cardBrand == 'VISA'
                      ? Image.asset(
                          "assets/images/Visa.png",
                          height: 17.sp,
                        )
                      : Container(
                    height: 2.7.h,
                          decoration: BoxDecoration(
                            color:
                                AppColors.textColorGreyShade2.withOpacity(0.27),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.3.sp, vertical: 0.sp),
                            child: Image.asset(
                              cardBrand == 'MASTER'
                                  ? "assets/images/master2.png"
                                  : "assets/images/mada_pay.png",
                              height: 18.sp,
                              width: 18.sp,
                            ),
                          ),
                        ),
                // if (!english)
                //   GestureDetector(
                //     onTap: () => showPopupCardRemove(
                //         isDark, cardNum, regNum, cardBrand, last4Digits),
                //     child: Image.asset(
                //       "assets/images/cancel.png",
                //       height: 16.sp,
                //       color: isDark
                //           ? AppColors.textColorWhite
                //           : AppColors.textColorBlack,
                //     ),
                //   ),
                // if (!english) Spacer(),
                // SizedBox(
                //   width: 0.5.h,
                // ),
                SizedBox(
                  width: 2.w,
                ),
                Text(
                  cardNum.substring(0, cardNum.length - 2) +
                      ' **** **** ' +
                      last4Digits,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textColorWhite
                        : AppColors.textColorBlack,
                  ),
                ),
                // if (english)
                  Spacer(),
                // if (english)
                  GestureDetector(
                    onTap: () => showPopupCardRemove(
                        isDark, english , cardNum, regNum, cardBrand, last4Digits ),
                    child: Image.asset(
                      "assets/images/cancel.png",
                      height: 16.sp,
                    ),
                  ),
                // if (!english)
                //   cardBrand == 'VISA'
                //       ? Image.asset(
                //           "assets/images/Visa.png",
                //           height: 18.sp,
                //         )
                //       : Container(
                //           decoration: BoxDecoration(
                //             color:
                //                 AppColors.textColorGreyShade2.withOpacity(0.27),
                //             borderRadius: BorderRadius.circular(3),
                //           ),
                //           child: Padding(
                //             padding: EdgeInsets.symmetric(
                //                 horizontal: 5.2.sp, vertical: 1.5.sp),
                //             child: Image.asset(
                //               cardBrand == 'MASTER'
                //                   ? "assets/images/master2.png"
                //                   : "assets/images/mada_pay.png",
                //               height: 16.sp,
                //             ),
                //           ),
                //         ),
              ],
            ),
          ),
        ),
        // if (!isLast)
        //   Divider(
        //     color: AppColors.textColorGrey,
        //   )
      ],
    );
  }

  Widget bankingDetailsWidget({
    bool isFirst = false,
    bool isLast = false,
    bool english = false,
    bool isPrimary = false,
    required Function handler,
    bool isDark = true,
    String accountNumber = "****",
    String selectedAccTitle = "",
    String selectedBic = "",
    required String fullAccountNumber,
    required String selectedBankName,
  }) {
    return Column(
      children: [
        Container(
          height: 6.5.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: _isSelectedBank
                  ? Colors.transparent
                  : AppColors.textColorGrey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                left: english ? 10.sp : 0, right: english ? 0 : 10.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  // color: Colors.red,
                  width: selectedBankName.toString().length > 12 ? 30.w:25.w,
                  child: Text(
                    selectedBankName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppColors.textColorWhite
                            : AppColors.textColorBlack),
                  ),
                ),
                SizedBox(
                  width: 1.w,
                ),
                isPrimary
                    ? Padding(
                        padding: EdgeInsets.only(top: 0.sp),
                        child: Container(
                          width: 16.w,
                          child: Text(
                            ("(" + "primary".tr() + ")"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 10.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColorGrey),
                          ),
                        ),
                      )
                    : SizedBox(height: 3.sp),
                Spacer(),
                Container(
                  width: 20.w,
               // color: Colors.red,
                  child: Text(
                    accountNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11.5.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppColors.textColorWhite
                            : AppColors.textColorBlack),
                  ),
                ),
                PopupMenuButton<String>(
                  color: isDark
                      ? AppColors.textFieldParentDark
                      : AppColors.textColorWhite,
                  shadowColor: Colors.transparent,
                  splashRadius: 1.0,
                  surfaceTintColor: Colors.transparent,
                  icon: Align(
                    alignment:
                        english ? Alignment.centerRight : Alignment.centerLeft,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Icon(
                          Icons.more_vert,
                          color: isDark
                              ? AppColors.textColorWhite
                              : AppColors.textColorBlack,
                        ),
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20),
                  ),
                  elevation: 0,
                  onSelected: (value) {

                    print("Selected: $value");
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<String>>[
                      if (!isPrimary)
                        PopupMenuItem<String>(
                          value: 'Make Primary '.tr(),
                          onTap: () async {
                            print('before han');

                            handler();

                            print('after han');
                          },
                          child: Row(
                            children: [
                              Text(
                                'Make Primary'.tr(),
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: isDark
                                        ? AppColors.textColorWhite
                                        : AppColors.textColorBlack,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13.sp),
                              ),
                              Text(
                                'Make Prim',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.transparent,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13.sp),
                              ),
                            ],
                          ),
                        ),
                      PopupMenuItem<String>(
                        value: 'Delete Account'.tr(),
                        onTap: () => showPopupDeleteBank(
                          isDark,
                          accountNumber,
                          fullAccountNumber,
                          selectedBankName,
                        ),
                        child: Text(
                          'Delete Account'.tr(),
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack,
                              fontWeight: FontWeight.w400,
                              fontSize: 13.sp),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Update'.tr(),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WalletUpdateBank(
                                    accountNumber: fullAccountNumber,
                                    isPrimary: isPrimary.toString(),
                                    bankName: selectedBankName,
                                    bic: selectedBic,
                                    accountTitle: selectedAccTitle,
                                  )),
                        ),
                        child: Text(
                          'Update'.tr(),
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack,
                              fontWeight: FontWeight.w400,
                              fontSize: 13.sp),
                        ),
                      ),
                    ];
                  },
                  offset: Offset(0, 40),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future showPopupDeleteBank(
    bool isDark,
    String accNum,
    String fullAccNum,
    String bankName,
  ) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.85;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Colors.transparent,
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                    height: 43.h,
                    width: dialogWidth,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.showDialogClr
                          : AppColors.textColorWhite,
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
                      children: [
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          'Are you sure you want to delete this bank account?'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.sp),
                          height: 6.5.h,
                          decoration: BoxDecoration(
                            color: AppColors.textColorGrey.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.sp),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  // color: Colors.yellow,
                                  width: 35.w,
                                  child: Text(
                                    bankName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.textColorWhite
                                          : AppColors.textColorBlack,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  width: 20.w,
                                  // color: Colors.red,
                                  child: Text(
                                    accNum,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      color: isDark
                                          ? AppColors.textColorWhite
                                          : AppColors.textColorBlack,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: AppButton(
                            title: 'Delete'.tr(),
                            handler: () async {
                              setState(() {
                                isDeleteBankLoading = true;
                              });
                              var result = await Provider.of<BankProvider>(
                                      context,
                                      listen: false)
                                  .deleteBankAccount(
                                      context: context,
                                      token: accessToken,
                                      accountNumber: fullAccNum);

                              setState(() {
                                isDeleteBankLoading = false;
                              });
                              if (result == AuthResult.success) {
                                Navigator.pop(context);
                              }
                            },
                            isGradient: false,
                            isLoading: isDeleteBankLoading,
                            color: AppColors.deleteAccountBtnColor
                                .withOpacity(0.10),
                            textColor: AppColors.textColorBlack,
                            buttonWithBorderColor: AppColors.errorColor,
                            isGradientWithBorder: true,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: AppButton(
                            title: 'Cancel'.tr(),
                            handler: () {
                              Navigator.pop(context);
                            },
                            isGradient: false,
                            textColor: isDark
                                ? AppColors.textColorWhite
                                : AppColors.textColorBlack.withOpacity(0.8),
                            color: AppColors.appSecondButton.withOpacity(0.10),
                            isGradientWithBorder: true,
                            secondBtnBorderClr: true,
                          ),
                        ),
                        Expanded(child: SizedBox())
                      ],
                    ),
                  )));
        });
      },
    );
  }

  Future showPopupCardRemove(
    bool isDark,
    bool isEnglish,
    String cardNum,
    String regNum,
    String cardBrand,
    String last4digits,
  ) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.85;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Colors.transparent,
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                    height: 43.h,
                    width: dialogWidth,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.showDialogClr
                          : AppColors.textColorWhite,
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
                      children: [
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          'Are you sure you want to delete this card?'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 22.sp),
                          height: 6.5.h,
                          decoration: BoxDecoration(
                            color: AppColors.textColorGrey.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.sp),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Spacer(),
                                Text(
                                 isEnglish ? ' **** ' + last4digits : last4digits + ' **** ' ,
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? AppColors.textColorWhite
                                        : AppColors.textColorBlack,
                                  ),
                                ),
                                SizedBox(
                                  width: 2.w,
                                ),
                                cardBrand == 'VISA'
                                    ? Image.asset(
                                        "assets/images/Visa.png",
                                        height: 18.sp,
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.textColorGreyShade2
                                              .withOpacity(0.27),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5.2.sp,
                                              vertical: 1.5.sp),
                                          child: Image.asset(
                                            cardBrand == 'MASTER'
                                                ? "assets/images/master_card.png"
                                                : "assets/images/mada_pay.png",
                                            height: 16.sp,
                                            width: 18.sp,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: AppButton(
                            title: 'Remove'.tr(),
                            handler: () async {
                              setState(() {
                                isDialogLoading = true;
                              });
                              var result = await Provider.of<CardProvider>(
                                      context,
                                      listen: false)
                                  .deletePaymentCards(
                                      token: accessToken,
                                      tokenId: regNum,
                                      context: context);
                              setState(() {
                                isDialogLoading = false;
                              });
                              if (result == AuthResult.success) {
                                await Provider.of<TransactionProvider>(context,
                                        listen: false)
                                    .removeSelectedCardNum();
                                // refreshPage();
                                await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          WalletBankingAndPaymentEmpty()),
                                );
                              }
                            },
                            isLoading: isDialogLoading,
                            isGradient: false,

                            color: AppColors.deleteAccountBtnColor
                                .withOpacity(0.10),
                            textColor: AppColors.textColorWhite,
                            buttonWithBorderColor: AppColors.errorColor,
                            isGradientWithBorder: true,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: AppButton(
                            title: 'Cancel'.tr(),
                            handler: () {
                              Navigator.pop(context);
                            },
                            isGradient: false,
                            textColor: isDark
                                ? AppColors.textColorWhite
                                : AppColors.textColorBlack.withOpacity(0.8),
                            color: AppColors.appSecondButton.withOpacity(0.10),
                            isGradientWithBorder: true,
                            secondBtnBorderClr: true,
                          ),
                        ),
                        Expanded(child: SizedBox())
                      ],
                    ),
                  )));
        });
      },
    );
  }
}
