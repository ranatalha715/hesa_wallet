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

import '../../providers/card_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/button.dart';
import '../../widgets/dialog_button.dart';
import '../../widgets/main_header.dart';

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
  var accessToken = "";
  var isLoading = false;
  var isInit = true;
  var isDialogLoading = false;

  final ScrollController scrollController = ScrollController();

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
    // print(accessToken);
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
      super.didChangeDependencies();
      setState(() {
        isLoading = false;
      });
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

  Future<void> updateBankAccountAndRefreshDetails(int index, String accessToken,
      String ibanNumber, String bic, BuildContext ctx) async {
    setState(() {
      isLoading = true;
    });

    var result = await Provider.of<BankProvider>(context, listen: false)
        .updateBankAccount(
      isPrimary: true,
      // Set isPrimary to true after updating the bank account
      index: index,
      accountNumber: ibanNumber,
      bic: bic,
      token: accessToken,
      context: ctx,
    );

    if (result == AuthResult.success) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WalletBankingAndPaymentEmpty(),
        ),
      );
      // await Provider.of<UserProvider>(context, listen: false)
      //     .getUserDetails(token: accessToken, context: context);

      // await refreshUserDetails(accessToken, context); // Fetch user details after successful bank update
      print('updated success!');
    }

    setState(() {
      // _isSelectedBank = !_isSelectedBank;
      isLoading = false;
    });
  }

  // Future<void> updateBankAccountAndRefreshDetails(int index, String accessToken,
  //     String ibanNumber, String bic, BuildContext context) async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   var result = await Provider.of<BankProvider>(context, listen: false)
  //       .updateBankAccount(
  //     isPrimary: true,
  //     index: index,
  //     accountNumber: ibanNumber,
  //     bic: bic,
  //     token: accessToken,
  //     context: context,
  //   );
  //
  //   if (result == AuthResult.success) {
  //     await refreshUserDetails(accessToken, context);
  //   }
  //
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  Future<void> refreshUserDetails(
      String accessToken, BuildContext context) async {
    // setState(() {
    //   isLoading = true;
    // });

    // await getAccessToken();
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);

    // setState(() {
    //   isLoading = false;
    // });
  }

  void confirmBrandDialogue(Function onCloseHandler,
      {required bool showPopup}) {
    if (showPopup) {
      showDialog(
        context: context,
        // barrierDismissible:
        //     Provider.of<TransactionProvider>(context, listen: false)
        //                 .selectedCardBrand ==
        //             null
        //         ? false
        //         : true,
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
                      // border: Border.all(
                      //     width:
                      //         0.1.h,
                      //     color: AppColors.textColorGrey),
                      color: AppColors.showDialogClr,
                      borderRadius: BorderRadius.circular(15),
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
                                // Navigator.pop(context);
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
                                // Navigator.pop(context);
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
          // print('testabc');
          // print(trPro.selectedCardNum.toString());
          // print(paymentCards[0].bin);
        }
      }
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
                                          // var result = await Provider.of<
                                          //             TransactionProvider>(
                                          //         context,
                                          //         listen: false)
                                          //     .tokenizeCardRequest(
                                          //         token: accessToken,
                                          //         brand: Provider.of<
                                          //                     TransactionProvider>(
                                          //                 context,
                                          //                 listen: false)
                                          //             .selectedCardBrand,
                                          //         context: context);
                                          // if (result == AuthResult.success) {
                                          //   Navigator.pushReplacement(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //       builder: (context) =>
                                          //           WalletAddCard(
                                          //         tokenizedCheckoutId: Provider
                                          //                 .of<TransactionProvider>(
                                          //                     context,
                                          //                     listen: false)
                                          //             .tokenizedCheckoutId,
                                          //       ),
                                          //     ),
                                          //   );
                                          // }
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
                                            size: 10,
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
                                              fontSize: 12.sp,
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
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.textFieldParentDark,
                                // border: Border.all(
                                //   color: _isSelected
                                //       ? AppColors.textColorGrey
                                //       : Colors.transparent,
                                //   // width: 1.0,
                                // ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => paymentCards.isNotEmpty
                                        ? setState(() {
                                            _isSelected = !_isSelected;
                                          })
                                        : {},
                                    child: Container(
                                      height: 6.5.h,
                                      decoration: BoxDecoration(
                                        // border: Border.all(
                                        //   color: _isSelected
                                        //       ? Colors.transparent
                                        //       : themeNotifier.isDark
                                        //           ? AppColors.textColorWhite
                                        //           : AppColors.textColorGrey,
                                        //   width: 1.0,
                                        // ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                                              child: paymentCards.isNotEmpty
                                                  ? Text(
                                                      'Payment Cards'.tr(),
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
                                                  : Text(
                                                      'No payment card have been added'
                                                          .tr(),
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
                                            Spacer(),
                                            if (paymentCards.isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 6.sp),
                                                child: Icon(
                                                  _isSelected
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                          .keyboard_arrow_down,
                                                  size: 27.sp,
                                                  color: themeNotifier.isDark
                                                      ? AppColors.textColorWhite
                                                      : AppColors
                                                          .textColorBlack,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_isSelected)
                                    ListView.builder(
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
                                              // isCardSelected: trPro
                                              //     .selectedCardNum ==
                                              //     paymentCards[
                                              //     index]
                                              //         .bin
                                              //     ? true
                                              //     : false
                                            ),
                                          );
                                          // Card(
                                          //   margin: EdgeInsets.all(8.0),
                                          //   child: ListTile(
                                          //     title: Text('Card ${index + 1}'),
                                          //     subtitle: Text(
                                          //       'BIN: ${paymentCards[index].bin}',
                                          //       style: TextStyle(
                                          //           color: Colors.red),
                                          //     ),
                                          //     onTap: () {
                                          //       // Handle card tap if needed
                                          //     },
                                          //   ));
                                        }),
                                  // ListView(
                                  //   padding: EdgeInsets.zero,
                                  //   shrinkWrap: true,
                                  //   children: [
                                  //     paymentCardWidget(
                                  //       isFirst: true,
                                  //       isDark:
                                  //           themeNotifier.isDark ? true : false,
                                  //       english: isEnglish ? true : false,
                                  //     ),
                                  //     paymentCardWidget(
                                  //       english: isEnglish ? true : false,
                                  //       isDark:
                                  //           themeNotifier.isDark ? true : false,
                                  //     ),
                                  //     paymentCardWidget(
                                  //       isLast: true,
                                  //       english: isEnglish ? true : false,
                                  //       isDark:
                                  //           themeNotifier.isDark ? true : false,
                                  //     ),
                                  //   ],
                                  // )
                                ],
                              ),
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
                                        size: 10,
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
                                          fontSize: 12.sp,
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
                            // isLoading
                            // //     ? Center(
                            //         child: CircularProgressIndicator(
                            //         color: AppColors.activeButtonColor,
                            //       ))
                            //     :
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.textFieldParentDark,
                                // border: Border.all(
                                //   color: _isSelectedBank
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
                                      _isSelectedBank = !_isSelectedBank;
                                    }),
                                    child: Container(
                                      height: 6.5.h,
                                      decoration: BoxDecoration(
                                        // border: Border.all(
                                        //   color: _isSelectedBank
                                        //       ? Colors.transparent
                                        //       : themeNotifier.isDark
                                        //           ? AppColors.textColorWhite
                                        //           : AppColors.textColorGrey,
                                        //   width: 1.0,
                                        // ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                                                child: banks.isNotEmpty
                                                    ? Text(
                                                        'Banking Details'.tr(),
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
                                                    : Text(
                                                        'No banking have been added'
                                                            .tr(),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 11.7.sp,
                                                            color: themeNotifier.isDark
                                                                ? AppColors
                                                                    .textColorGreyShade2
                                                                : AppColors
                                                                    .textColorBlack),
                                                      )),
                                            Spacer(),
                                            if (banks.isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 7.sp),
                                                child: Icon(
                                                  _isSelectedBank
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                          .keyboard_arrow_down,
                                                  size: 27.sp,
                                                  color: themeNotifier.isDark
                                                      ? AppColors.textColorWhite
                                                      : AppColors
                                                          .textColorBlack,
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  _isSelectedBank
                                      ?
                                      //     isLoading
                                      //         ?
                                      // CircularProgressIndicator(
                                      //             color:
                                      //                 AppColors.activeButtonColor,
                                      //           )
                                      //         :
                                      ListView.builder(
                                          controller: scrollController,
                                          itemCount: banks.length,
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context, index) {
                                            bool isFirst = index == 0;
                                            bool isLast =
                                                index == banks.length - 1;

                                            // Extracting the last four characters of the IBAN
                                            String lastFourDigits = banks[index]
                                                .ibanNumber
                                                .substring(
                                                  banks[index]
                                                          .ibanNumber
                                                          .length -
                                                      4,
                                                );
                                            // setState(() {
                                            bankpro.selectedBank =
                                                banks[index].isPrimary == "true"
                                                    ? banks[index].ibanNumber
                                                    : "";
                                            print("selectedBank");
                                            print(bankpro.selectedBank);
                                            // });
                                            return bankingDetailsWidget(
                                              accountNumber:
                                                  "**** " + lastFourDigits,
                                              fullAccountNumber:
                                                  banks[index].ibanNumber,
                                              isLast: isLast,
                                              isFirst: isFirst,
                                              handler: () async {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                // Navigator.pop(context);
                                                await updateBankAccountAndRefreshDetails(
                                                  index,
                                                  accessToken,
                                                  banks[index].ibanNumber,
                                                  banks[index].bic,
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
                                                  banks[index].bankName!,
                                              selectedBic:
                                              banks[index].bic!,
                                              selectedAccTitle:
                                              banks[index].accountTitle ?? 'null',
                                            );
                                          },
                                        )
                                      : SizedBox(),

                                  // isLoading ? CircularProgressIndicator(color: Colors.red,) :
                                  //   ListView.builder(
                                  //       controller: scrollController,
                                  //       itemCount:
                                  //       banks.length,
                                  //       shrinkWrap: true,
                                  //       padding: EdgeInsets.zero,
                                  //       itemBuilder:
                                  //           (context, index) {
                                  //         bool isFirst = index == 0;
                                  //
                                  //         bool isLast = index ==
                                  //             banks.length - 1;
                                  //
                                  //         return  bankingDetailsWidget(
                                  //           accountNumber: banks[index].ibanNumber,
                                  //                   isLast:  isLast,
                                  //                   isFirst:isFirst,
                                  //                   isPrimary:true,
                                  //                   english: isEnglish ? true : false,
                                  //                   isDark: themeNotifier.isDark ? true : false,
                                  //                 );
                                  //       }),
                                  // ListView(
                                  //   padding: EdgeInsets.zero,
                                  //   shrinkWrap: true,
                                  //   children: [
                                  //     bankingDetailsWidget(
                                  //         isFirst: true,
                                  //         english: isEnglish ? true : false,
                                  //         isDark:
                                  //             themeNotifier.isDark ? true : false,
                                  //         isPrimary: true),
                                  //     // paymentCardWidget(),
                                  //     bankingDetailsWidget(
                                  //       isLast: true,
                                  //       english: isEnglish ? true : false,
                                  //       isDark: themeNotifier.isDark ? true : false,
                                  //     ),
                                  //   ],
                                  // )
                                ],
                              ),
                            ),
                            // Container(
                            //   height: 6.5.h,
                            //   child: TextField(
                            //       readOnly: true,
                            //       scrollPadding: EdgeInsets.only(
                            //           bottom: MediaQuery.of(context).viewInsets.bottom),
                            //       style: TextStyle(
                            //           fontSize: 10.2.sp,
                            //           color: AppColors.textColorWhite,
                            //           fontWeight: FontWeight.w400, // Off-white color,
                            //           fontFamily: 'Inter'),
                            //       decoration: InputDecoration(
                            //           contentPadding: EdgeInsets.symmetric(
                            //               vertical: 10.0, horizontal: 16.0),
                            //           hintText: 'Banking Details',
                            //           // hintText: 'No banking have been added',
                            //           hintStyle: TextStyle(
                            //               fontSize: 10.2.sp,
                            //               color: AppColors.textColorWhite,
                            //               // color: AppColors.textColorGrey,
                            //               fontWeight: FontWeight.w400,
                            //               // Off-white color,
                            //               fontFamily: 'Inter'),
                            //           enabledBorder: OutlineInputBorder(
                            //               borderRadius: BorderRadius.circular(8.0),
                            //               borderSide: BorderSide(
                            //                 color: AppColors.textColorWhite,
                            //                 // color: AppColors.textColorGrey,
                            //                 // Off-white color
                            //                 width: 1.0,
                            //               )),
                            //           focusedBorder: OutlineInputBorder(
                            //               borderRadius: BorderRadius.circular(8.0),
                            //               borderSide: BorderSide(
                            //                 color: AppColors.textColorWhite,
                            //                 // Off-white color
                            //                 width: 1.0,
                            //               )),
                            //           // labelText: 'Enter your password',
                            //           suffixIcon: GestureDetector(
                            //             onTap: () => setState(() {
                            //               _selectedBankDetails = !_selectedBankDetails;
                            //             } n),
                            //             child: Padding(
                            //                 padding: const EdgeInsets.only(right: 10),
                            //                 child: _selectedBankDetails
                            //                     ? Icon(
                            //                         Icons.keyboard_arrow_up,
                            //                         size: 21.sp,
                            //                         color: AppColors.textColorWhite,
                            //                       )
                            //                     : Icon(
                            //                         Icons.keyboard_arrow_down,
                            //                         size: 21.sp,
                            //                         color: AppColors.textColorWhite,
                            //                       ),
                            //             ),
                            //           )),
                            //       cursorColor: AppColors.textColorGrey),
                            // ),
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
          if (isLoading) LoaderBluredScreen()
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
        // if (isFirst)
        //   Divider(
        //     color: AppColors.textColorGrey,
        //   ),
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
                if (english)
                  cardBrand == 'VISA'
                      ? Image.asset(
                          "assets/images/Visa.png",
                          height: 18.sp,
                          // color: isDark
                          //     ? AppColors.textColorWhite
                          //     : AppColors.textColorBlack,
                          // width: 20.sp,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color:
                                AppColors.textColorGreyShade2.withOpacity(0.27),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.2.sp, vertical: 1.sp),
                            child: Image.asset(
                              cardBrand == 'MASTER'
                                  ? "assets/images/master_card.png"
                                  : "assets/images/mada_pay.png",
                              height: 18.sp,
                              // color: isDark
                              //     ? AppColors.textColorWhite
                              //     : AppColors.textColorBlack,
                              width: 18.sp,
                            ),
                          ),
                        ),
                if (!english)
                  GestureDetector(
                    onTap: () => showPopupCardRemove(
                        isDark, cardNum, regNum, cardBrand, last4Digits),
                    child: Image.asset(
                      "assets/images/cancel.png",
                      height: 16.sp,
                      color: isDark
                          ? AppColors.textColorWhite
                          : AppColors.textColorBlack,
                      // width: 20.sp,
                    ),
                  ),
                if (!english) Spacer(),
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
                if (english) Spacer(),
                if (english)
                  GestureDetector(
                    onTap: () => showPopupCardRemove(
                        isDark, cardNum, regNum, cardBrand, last4Digits),
                    child: Image.asset(
                      "assets/images/cancel.png",
                      height: 16.sp,
                      // width: 20.sp,
                    ),
                  ),
                if (!english)
                  cardBrand == 'VISA'
                      ? Image.asset(
                          "assets/images/Visa.png",
                          height: 18.sp,
                          // color: isDark
                          //     ? AppColors.textColorWhite
                          //     : AppColors.textColorBlack,
                          // width: 20.sp,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color:
                                AppColors.textColorGreyShade2.withOpacity(0.27),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.2.sp, vertical: 1.5.sp),
                            child: Image.asset(
                              cardBrand == 'MASTER'
                                  ? "assets/images/master_card.png"
                                  : "assets/images/mada_pay.png",
                              height: 16.sp,
                              // color: isDark
                              //     ? AppColors.textColorWhite
                              //     : AppColors.textColorBlack,
                              // width: 20.sp,
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
        // if (isFirst)
        //   Divider(
        //     color: AppColors.textColorGrey,
        //   ),
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
                // SizedBox(width: 1.h),
                // if (isPrimary)
                // Image.asset(
                //   "assets/images/check_circle.png",
                //   height: 4.h,
                //   width: 3.h,
                // ),
                // if (isPrimary) SizedBox(width: 1.h),
                Text(
                  selectedBankName,
                  style: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppColors.textColorWhite
                          : AppColors.textColorBlack),
                ),
                SizedBox(
                  width: 1.w,
                ),
                isPrimary
                    ? Padding(
                        padding: EdgeInsets.only(top: 0.sp),
                        child: Text(
                          ("(" + "primary".tr() + ")"),
                          style: TextStyle(
                              fontSize: 10.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColorGrey),
                        ),
                      )
                    : SizedBox(height: 3.sp),
                // SizedBox(
                //   width: 0.5.h,
                // ),
                // if (!english)
                //   SizedBox(
                //     width: 3.w,
                //   ),
                // if (english)
                Spacer(),
                Text(
                  accountNumber,
                  style: TextStyle(
                      fontSize: 11.5.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppColors.textColorWhite
                          : AppColors.textColorBlack),
                ),
                // if (english) Spacer(),
                // if (!english) Spacer(),
                // SizedBox(
                //   width: 3.w,
                // ),

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
                        20), // Add your preferred radius here
                  ),
                  elevation: 0,
                  onSelected: (value) {
                    // Handle the selected item here
                    print("Selected: $value");
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<String>>[
                      if (!isPrimary)
                        PopupMenuItem<String>(
                          value: 'Make Primary '.tr(),

                            onTap: () async {
                              // setState(() {
                              //   isLoading = true;
                              // });
                              // Call your handler function

                              // Close the popup menu
                              // Navigator.pop(context);
                              // setState(() {
                              //   _isSelectedBank = !_isSelectedBank;
                              // });
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
                      // if (!isPrimary)
                      //   PopupMenuItem<String>(
                      //     height: 0.1,
                      //     child: Divider(
                      //       // height: 2,
                      //       color: AppColors
                      //           .textColorGreyShade3, // Set the desired color for the divider
                      //       // thickness: 2.0, // Set the thickness of the divider
                      //     ),
                      //     enabled: false,
                      //   ),
                      // PopupMenuDivider(),
                      // if(!isPrimary)
                      PopupMenuItem<String>(
                        value: 'Delete Account'.tr(),
                        onTap: ()=> showPopupDeleteBank(
                          isDark,
                          accountNumber,
                          fullAccountNumber,
                          selectedBankName,
                        ),
                        child:  Text(
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
                        onTap:()=>Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WalletUpdateBank(
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
                      // Add more menu options as needed
                    ];
                  },
                  offset: Offset(0, 40),
                ),
              ],
            ),
            // Image.asset(
            //   "assets/images/more_vert.png",
            //   height: 16.sp,
            //   // width: 20.sp,
            // ),
          ),
        ),
        // if (!isLast)
        //   Divider(
        //     color: AppColors.textColorGrey,
        //   )
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
                      // border: Border.all(
                      //     width: 0.1.h, color: AppColors.textColorGrey),
                      // color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          'Are you sure you want to delete this bank account?',
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
                            // border: Border.all(
                            //   color: AppColors.textColorGrey,
                            //   width: 1.0,
                            // ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.sp),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  bankName,
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.textColorWhite
                                        : AppColors.textColorBlack,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  accNum,
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? AppColors.textColorWhite
                                        : AppColors.textColorBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child:
                          AppButton(
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
                              color:
                                  AppColors.appSecondButton.withOpacity(0.10),
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
                      // border: Border.all(
                      //     width: 0.1.h, color: AppColors.textColorGrey),
                      // color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          'Are you sure you want to remove this Card?',
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
                            //   border: Border.all(
                            //     color: AppColors.textColorGrey,
                            //     width: 1.0,
                            //   ),
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
                                  ' **** ' + last4digits,
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
                                        // color: isDark
                                        //     ? AppColors.textColorWhite
                                        //     : AppColors.textColorBlack,
                                        // width: 20.sp,
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
                                            // color: isDark
                                            //     ? AppColors.textColorWhite
                                            //     : AppColors.textColorBlack,
                                            // width: 20.sp,
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
                                            listen: false).removeSelectedCardNum();
                                // refreshPage();
                                await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          WalletBankingAndPaymentEmpty()),
                                );

                                // refreshPage();
                              }
                            },
                            isLoading: isDialogLoading,
                            isGradient: false,
                            // color: Colors.transparent,
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
                            color:
                            AppColors.appSecondButton.withOpacity(0.10),
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
