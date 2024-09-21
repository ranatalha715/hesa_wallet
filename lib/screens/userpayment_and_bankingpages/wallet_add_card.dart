import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/screens/userpayment_and_bankingpages/wallet_banking_and_payment_empty.dart';
import 'package:hesa_wallet/widgets/button.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:hyperpay_plugin/flutter_hyperpay.dart';
import 'package:hyperpay_plugin/model/custom_ui.dart';
import 'package:hyperpay_plugin/model/ready_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../constants/inapp_settings.dart';
import '../../providers/card_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dialog_button.dart';
import '../../widgets/main_header.dart';
import '../../widgets/telegram_swipe_test.dart';
import '../web_view/webview_helper.dart';

class WalletAddCard extends StatefulWidget {
final String tokenizedCheckoutId;
bool fromTransactionReq;
   WalletAddCard ({required this.tokenizedCheckoutId, this.fromTransactionReq=false});
  // const WalletAddCard({Key? key}, req) : super(key: key);

  @override
  State<WalletAddCard> createState() => _WalletAddCardState();
}

class _WalletAddCardState extends State<WalletAddCard> {
  final TextEditingController _cardnumberController = TextEditingController();
  final TextEditingController _cardnameController = TextEditingController();
  final TextEditingController _expirydateController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController otp5Controller = TextEditingController();
  final TextEditingController otp6Controller = TextEditingController();

  String displayedText = '';
  String formattedExpiryDate = '';
  String displayedName = '';
  String accessToken = '';
  bool isCardLoading = false;
  bool isButtonActive = false;

  void _updateButtonState() {
    setState(() {
      isButtonActive = _cardnumberController.text.isNotEmpty &&
          _cardnameController.text.isNotEmpty &&
          _expirydateController.text.isNotEmpty &&
          _codeController.text.isNotEmpty;
    });
  }

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  String addSpacesToText(String input) {
    final chunkSize = 4;
    final chunks = <String>[];

    for (int i = 0; i < input.length; i += chunkSize) {
      final end =
          (i + chunkSize <= input.length) ? i + chunkSize : input.length;
      chunks.add(input.substring(i, end));
    }

    return chunks.join(' ');
  }

  FocusNode firstFieldFocusNode = FocusNode();
  FocusNode secondFieldFocusNode = FocusNode();
  FocusNode thirdFieldFocusNode = FocusNode();
  FocusNode forthFieldFocusNode = FocusNode();
  FocusNode fifthFieldFocusNode = FocusNode();
  FocusNode sixthFieldFocusNode = FocusNode();
  late FlutterHyperPay flutterHyperPay;
  late FToast fToast;

  _showToast(String message, {int duration = 1000}) {
    Widget toast = Container(
      height: 60,
      // width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: AppColors.textColorWhite.withOpacity(0.5),
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              color: Colors.transparent,
              child: Text(
                message,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                // .toUpperCase(),
                style: TextStyle(
                        color: AppColors.backgroundColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold)
                    .apply(fontWeightDelta: -2),
              ),
            ),
          ),
          // Spacer(),
        ],
      ),
    );

    // Custom Toast Position
    fToast.showToast(
        child: toast,
        toastDuration: Duration(milliseconds: duration),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: Center(child: child),
            top: 43.0,
            left: 20,
            right: 20,
          );
        });
  }

  @override
  void initState() {

    // Future.delayed(Duration(seconds: 2), () {
    //   //
    //   otpCardVerificationDialog();  });
    super.initState();
    _expirydateController.addListener(_formatExpiryDate);
    _cardnameController.addListener(_updateButtonState);
    _cardnameController.addListener(_updateButtonState);
    _expirydateController.addListener(_updateButtonState);
    _codeController.addListener(_updateButtonState);
    getAccessToken();
    flutterHyperPay = FlutterHyperPay(
      shopperResultUrl:
          // getShopperResultUrl(
          //     Provider.of<TransactionProvider>(context, listen: false).checkoutId
          // ),
          // "http://161.35.16.112:3001/payable-transactions/process?paymentId=" + Provider.of<TransactionProvider>(context, listen: false).checkoutId,
          // InAppPaymentSetting.getShopperResultUrl(''),
          InAppPaymentSetting.shopperResultUrl,
      paymentMode: PaymentMode.test,
      lang: 'eng',
    );
    fToast = FToast();
    fToast.init(context);
  }

  // void payRequestNowReadyUI(
  //     {required List<String> brandsName, required String checkoutId}) async {
  //   PaymentResultData paymentResultData;
  //   paymentResultData = await flutterHyperPay.readyUICards(
  //     readyUI: ReadyUI(
  //       brandsName: brandsName,
  //       checkoutId: checkoutId,
  //       // checkoutId: checkoutId,
  //       merchantIdApplePayIOS: InAppPaymentSetting.merchantId,
  //       countryCodeApplePayIOS: InAppPaymentSetting.countryCode,
  //       companyNameApplePayIOS: "Test Co",
  //       themColorHexIOS: "#000000",
  //       // FOR IOS ONLY
  //       setStorePaymentDetailsMode: true, // default
  //     ),
  //   );

  payRequestNowCustomUi({
    required String brandName,
    required String checkoutId,
    required String cardNumber,
    required String holderName,
    required String month,
    required String year,
    required String cvv,
    // currency: 'SAR',
    // amount: '5000',
    // paymentType: 'DebitCard',
    // createRegistration: false,
  }) async {
    PaymentResultData paymentResultData;

    paymentResultData = await flutterHyperPay.customUICards(
      customUI: CustomUI(
        brandName: brandName,
        checkoutId: '',
        cardNumber: cardNumber,
        holderName: holderName,
        month: month,
        year: year,
        cvv: cvv,
        // enabledTokenization: true, // default
      ),
    );
    if (paymentResultData.paymentResult == PaymentResult.success ||
        paymentResultData.paymentResult == PaymentResult.sync) {
      Provider.of<TransactionProvider>(context, listen: false)
          .payableTransactionProcess(
              token: accessToken, paymentId: checkoutId, context: context);
      _showToast('Payment Successfull!');
      print('running');
    } else {
      print('it is not running');
      _showToast('Payment Failed');
    }
  }

  void _formatExpiryDate() {
    final text = _expirydateController.text;
    if (text.length == 2 && !_expirydateController.text.contains('/')) {
      _expirydateController.text = text + '/';
      _expirydateController.selection = TextSelection.fromPosition(
          TextPosition(offset: _expirydateController.text.length));
    }
  }


  Future<String> _loadHtmlFromAssets(String filePath) async {
    String fileHtmlContents = await rootBundle.loadString(filePath);
    return Uri.dataFromString(
      fileHtmlContents,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString();
  }

  // void _updateCheckoutId(WebViewController controller, String id) async {
  //   // Execute JavaScript code in the WebView to set the checkout ID
  //   await controller.runJavaScript("updateCheckoutId('$id')");
  // }

  checkFormFilledStatus(String checkoutID) async {

    print('Now you should run the add card function');
    // Provider.of<CardProvider>(context, listen:false).tokenizeCardVerify(token: accessToken, context: context,
    //     checkoutId: checkoutID,  brand: Provider.of<
    //       TransactionProvider>(
    //       context,
    //       listen: false)
    //       .selectedCardBrand,);
    //bilal ka function call hoga (3rd api)


  }

  @override
  Widget build(BuildContext context) {

    final String htmlFilePath = 'assets/html/tokenization.html';
    final formattedText = addSpacesToText(displayedText);
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,

        body:  WebviewHelper(
          checkoutId:
          // "9F4B6C935993EC7B0BE32A2B1BE13493.uat01-vm-tx03"
          widget.tokenizedCheckoutId,
          fromTransactionReq: widget.fromTransactionReq,
        ),
      );
      //   Scaffold(
      //   backgroundColor: themeNotifier.isDark
      //       ? AppColors.backgroundColor
      //       : AppColors.textColorWhite,
      //   body:
      //   Stack(
      //     children: [
      //       SingleChildScrollView(
      //         child: Column(
      //           children: [
      //             MainHeader(title: 'Card details'.tr()),
      //             SizedBox(
      //               height: 4.h,
      //             ),
      //             Container(
      //               color: Colors.transparent,
      //               height: 83.h,
      //               child: SingleChildScrollView(
      //                 child: Container(
      //                   height: 45.h,
      //                   width: double.infinity,
      //                   color: Colors.transparent,
      //                   child: Padding(
      //                     padding: EdgeInsets.symmetric(
      //                       horizontal: 20,
      //                     ),
      //                     child: Column(
      //                       crossAxisAlignment: CrossAxisAlignment.start,
      //                       children: [
      //                         // SizedBox(
      //                         //   height: 3.h,
      //                         // ),
      //                         Align(
      //                           alignment: Alignment.centerLeft,
      //                           child: Row(
      //                             mainAxisAlignment:
      //                                 MainAxisAlignment.spaceBetween,
      //                             crossAxisAlignment: CrossAxisAlignment.center,
      //                             children: [
      //                               Text(
      //                                 'Card number'.tr(),
      //                                 style: TextStyle(
      //                                     fontSize: 11.7.sp,
      //                                     fontFamily: 'Inter',
      //                                     fontWeight: FontWeight.w600,
      //                                     color: themeNotifier.isDark
      //                                         ? AppColors.textColorWhite
      //                                         : AppColors.textColorBlack),
      //                               ),
      //                             ],
      //                           ),
      //                         ),
      //                         SizedBox(
      //                           height: 1.h,
      //                         ),
      //                         TextFieldParent(
      //                           child: TextField(
      //                               maxLength: 16,
      //                               inputFormatters: [
      //                                 LengthLimitingTextInputFormatter(16)
      //                               ],
      //                               controller: _cardnumberController,
      //                               keyboardType: TextInputType.number,
      //                               scrollPadding: EdgeInsets.only(
      //                                   bottom: MediaQuery.of(context)
      //                                           .viewInsets
      //                                           .bottom +
      //                                       150),
      //                               style: TextStyle(
      //                                   fontSize: 10.2.sp,
      //                                   color: themeNotifier.isDark
      //                                       ? AppColors.textColorWhite
      //                                       : AppColors.textColorBlack,
      //                                   fontWeight: FontWeight.w400,
      //                                   // Off-white color,
      //                                   fontFamily: 'Inter'),
      //                               decoration: InputDecoration(
      //                                 contentPadding: EdgeInsets.symmetric(
      //                                     horizontal: 14.sp),
      //                                 counterStyle: TextStyle(
      //                                     color: Colors.transparent,
      //                                     fontSize: 0),
      //                                 hintText: 'Enter card number'.tr(),
      //                                 hintStyle: TextStyle(
      //                                     fontSize: 10.2.sp,
      //                                     color: AppColors.textColorGrey,
      //                                     fontWeight: FontWeight.w400,
      //                                     // Off-white color,
      //                                     fontFamily: 'Inter'),
      //                                 enabledBorder: OutlineInputBorder(
      //                                     borderRadius:
      //                                         BorderRadius.circular(8.0),
      //                                     borderSide: BorderSide(
      //                                       color: Colors.transparent,
      //                                       // Off-white color
      //                                       // width: 2.0,
      //                                     )),
      //                                 focusedBorder: OutlineInputBorder(
      //                                   borderRadius:
      //                                       BorderRadius.circular(8.0),
      //                                   borderSide: BorderSide(
      //                                     color: Colors.transparent,
      //                                     // Off-white color
      //                                     // width: 2.0,
      //                                   ),
      //                                 ),
      //                                 suffixIcon: _cardnumberController.text.length==4 ? Padding(
      //                                   padding:  EdgeInsets.symmetric(horizontal: 5.sp, vertical: 10.sp),
      //                                   child: Image.asset(
      //                                     // cardNum.startsWith('4',0) ?
      //                                     "assets/images/Visa.png",
      //                                     height: 5.sp,
      //                                      width: 5.sp,
      //                                     // color: t
      //                                     //     ? AppColors.textColorWhite
      //                                     //     : AppColors.textColorBlack,
      //
      //                                   ),
      //                                 ) : SizedBox(),
      //                               ),
      //                               onChanged: (value) {
      //                                 // Update the displayedText whenever the text changes
      //                                 setState(() {
      //                                   displayedText = value;
      //                                 });
      //                               },
      //                               cursorColor: AppColors.textColorGrey),
      //                         ),
      //
      //                         // other text fields
      //
      //                         // SizedBox(
      //                         //   height: 2.h,
      //                         // ),
      //                         // Align(
      //                         //   alignment: isEnglish
      //                         //       ? Alignment.centerLeft
      //                         //       : Alignment.centerRight,
      //                         //   child: Text(
      //                         //     'Name on card'.tr(),
      //                         //     style: TextStyle(
      //                         //         fontSize: 11.7.sp,
      //                         //         fontFamily: 'Inter',
      //                         //         fontWeight: FontWeight.w600,
      //                         //         color: themeNotifier.isDark
      //                         //             ? AppColors.textColorWhite
      //                         //             : AppColors.textColorBlack),
      //                         //   ),
      //                         // ),
      //                         // SizedBox(
      //                         //   height: 1.h,
      //                         // ),
      //                         // TextFieldParent(
      //                         //   child: TextField(
      //                         //       controller: _cardnameController,
      //                         //       keyboardType: TextInputType.text,
      //                         //       scrollPadding: EdgeInsets.only(
      //                         //           bottom: MediaQuery.of(context)
      //                         //                   .viewInsets
      //                         //                   .bottom +
      //                         //               150),
      //                         //       style: TextStyle(
      //                         //           fontSize: 10.2.sp,
      //                         //           color: themeNotifier.isDark
      //                         //               ? AppColors.textColorWhite
      //                         //               : AppColors.textColorBlack,
      //                         //           fontWeight: FontWeight.w400,
      //                         //           // Off-white color,
      //                         //           fontFamily: 'Inter'),
      //                         //       decoration: InputDecoration(
      //                         //         border: InputBorder.none,
      //                         //         contentPadding: EdgeInsets.symmetric(
      //                         //             vertical: 10.0, horizontal: 16.0),
      //                         //         hintText: 'Enter name on card'.tr(),
      //                         //         hintStyle: TextStyle(
      //                         //             fontSize: 10.2.sp,
      //                         //             color: AppColors.textColorGrey,
      //                         //             fontWeight: FontWeight.w400,
      //                         //             // Off-white color,
      //                         //             fontFamily: 'Inter'),
      //                         //         enabledBorder: OutlineInputBorder(
      //                         //             borderRadius:
      //                         //                 BorderRadius.circular(8.0),
      //                         //             borderSide: BorderSide(
      //                         //               color: Colors.transparent,
      //                         //               // Off-white color
      //                         //               // width: 2.0,
      //                         //             )),
      //                         //         focusedBorder: OutlineInputBorder(
      //                         //             borderRadius:
      //                         //                 BorderRadius.circular(8.0),
      //                         //             borderSide: BorderSide(
      //                         //               color: Colors.transparent,
      //                         //               // Off-white color
      //                         //               // width: 2.0,
      //                         //             )),
      //                         //         // labelText: 'Enter your password',
      //                         //       ),
      //                         //       onChanged: (value) {
      //                         //         // Update the displayedText whenever the text changes
      //                         //         setState(() {
      //                         //           displayedName = value;
      //                         //         });
      //                         //       },
      //                         //       cursorColor: AppColors.textColorGrey),
      //                         // ),
      //                         // SizedBox(
      //                         //   height: 2.h,
      //                         // ),
      //                         // Row(
      //                         //   children: [
      //                         //     Container(
      //                         //       color: Colors.transparent,
      //                         //       width: 40.w,
      //                         //       child: Column(
      //                         //         children: [
      //                         //           Align(
      //                         //             alignment: isEnglish
      //                         //                 ? Alignment.centerLeft
      //                         //                 : Alignment.centerRight,
      //                         //             child: Text(
      //                         //               'Expiry date'.tr(),
      //                         //               style: TextStyle(
      //                         //                   fontSize: 11.7.sp,
      //                         //                   fontFamily: 'Inter',
      //                         //                   fontWeight: FontWeight.w600,
      //                         //                   color: themeNotifier.isDark
      //                         //                       ? AppColors.textColorWhite
      //                         //                       : AppColors.textColorBlack),
      //                         //             ),
      //                         //           ),
      //                         //           SizedBox(
      //                         //             height: 1.h,
      //                         //           ),
      //                         //           TextFieldParent(
      //                         //             child: TextField(
      //                         //                 maxLength: 5,
      //                         //                 inputFormatters: [
      //                         //                   LengthLimitingTextInputFormatter(
      //                         //                       5)
      //                         //                 ],
      //                         //                 controller: _expirydateController,
      //                         //                 keyboardType:
      //                         //                     TextInputType.datetime,
      //                         //                 scrollPadding: EdgeInsets.only(
      //                         //                     bottom: MediaQuery.of(context)
      //                         //                             .viewInsets
      //                         //                             .bottom +
      //                         //                         150),
      //                         //                 style: TextStyle(
      //                         //                     fontSize: 10.2.sp,
      //                         //                     color: themeNotifier.isDark
      //                         //                         ? AppColors.textColorWhite
      //                         //                         : AppColors
      //                         //                             .textColorBlack,
      //                         //                     fontWeight: FontWeight.w400,
      //                         //                     // Off-white color,
      //                         //                     fontFamily: 'Inter'),
      //                         //                 decoration: InputDecoration(
      //                         //                   contentPadding:
      //                         //                       EdgeInsets.symmetric(
      //                         //                           vertical: 10.0,
      //                         //                           horizontal: 16.0),
      //                         //                   counterStyle: TextStyle(
      //                         //                       color: Colors.transparent,
      //                         //                       fontSize: 0),
      //                         //                   border: InputBorder.none,
      //                         //                   hintText: 'MM/YY'.tr(),
      //                         //                   hintStyle: TextStyle(
      //                         //                     fontSize: 10.2.sp,
      //                         //                     color:
      //                         //                         AppColors.textColorGrey,
      //                         //                     fontWeight: FontWeight.w400,
      //                         //                     // Off-white color,
      //                         //                     fontFamily: 'Inter',
      //                         //                   ),
      //                         //
      //                         //                   enabledBorder:
      //                         //                       OutlineInputBorder(
      //                         //                           borderRadius:
      //                         //                               BorderRadius
      //                         //                                   .circular(8.0),
      //                         //                           borderSide: BorderSide(
      //                         //                             color: Colors
      //                         //                                 .transparent,
      //                         //                             // Off-white color
      //                         //                             // width: 2.0,
      //                         //                           )),
      //                         //                   focusedBorder:
      //                         //                       OutlineInputBorder(
      //                         //                           borderRadius:
      //                         //                               BorderRadius
      //                         //                                   .circular(8.0),
      //                         //                           borderSide: BorderSide(
      //                         //                             color: Colors
      //                         //                                 .transparent,
      //                         //                             // Off-white color
      //                         //                             // width: 2.0,
      //                         //                           )),
      //                         //                   // labelText: 'Enter your password',
      //                         //                 ),
      //                         //                 onChanged: (value) {
      //                         //                   // Update the displayedText whenever the text changes
      //                         //                   setState(() {
      //                         //                     formattedExpiryDate = value;
      //                         //                   });
      //                         //                 },
      //                         //                 cursorColor:
      //                         //                     AppColors.textColorGrey),
      //                         //           )
      //                         //         ],
      //                         //       ),
      //                         //     ),
      //                         //     Spacer(),
      //                         //     Container(
      //                         //       color: Colors.transparent,
      //                         //       width: 40.w,
      //                         //       child: Column(
      //                         //         children: [
      //                         //           Align(
      //                         //             alignment: isEnglish
      //                         //                 ? Alignment.centerLeft
      //                         //                 : Alignment.centerRight,
      //                         //             child: Text(
      //                         //               'Security code'.tr(),
      //                         //               style: TextStyle(
      //                         //                   fontSize: 11.7.sp,
      //                         //                   fontFamily: 'Inter',
      //                         //                   fontWeight: FontWeight.w600,
      //                         //                   color: themeNotifier.isDark
      //                         //                       ? AppColors.textColorWhite
      //                         //                       : AppColors.textColorBlack),
      //                         //             ),
      //                         //           ),
      //                         //           SizedBox(
      //                         //             height: 1.h,
      //                         //           ),
      //                         //           TextFieldParent(
      //                         //             child: TextField(
      //                         //                 maxLength: 3,
      //                         //                 controller: _codeController,
      //                         //                 keyboardType:
      //                         //                     TextInputType.number,
      //                         //                 scrollPadding: EdgeInsets.only(
      //                         //                     bottom: MediaQuery.of(context)
      //                         //                         .viewInsets
      //                         //                         .bottom),
      //                         //                 style: TextStyle(
      //                         //                     fontSize: 10.2.sp,
      //                         //                     color: themeNotifier.isDark
      //                         //                         ? AppColors.textColorWhite
      //                         //                         : AppColors
      //                         //                             .textColorBlack,
      //                         //                     fontWeight: FontWeight.w400,
      //                         //                     // Off-white color,
      //                         //                     fontFamily: 'Inter'),
      //                         //                 decoration: InputDecoration(
      //                         //                   counterStyle: TextStyle(
      //                         //                     color: Colors.transparent,
      //                         //                     fontSize: 0,
      //                         //                   ),
      //                         //                   contentPadding:
      //                         //                       EdgeInsets.symmetric(
      //                         //                           vertical: 10.0,
      //                         //                           horizontal: 16.0),
      //                         //                   hintText: 'XXX',
      //                         //                   hintStyle: TextStyle(
      //                         //                       fontSize: 10.2.sp,
      //                         //                       color:
      //                         //                           AppColors.textColorGrey,
      //                         //                       fontWeight: FontWeight.w400,
      //                         //                       // Off-white color,
      //                         //                       fontFamily: 'Inter'),
      //                         //                   enabledBorder:
      //                         //                       OutlineInputBorder(
      //                         //                           borderRadius:
      //                         //                               BorderRadius
      //                         //                                   .circular(8.0),
      //                         //                           borderSide: BorderSide(
      //                         //                             color: Colors
      //                         //                                 .transparent,
      //                         //                             // Off-white color
      //                         //                             // width: 2.0,
      //                         //                           )),
      //                         //                   focusedBorder:
      //                         //                       OutlineInputBorder(
      //                         //                           borderRadius:
      //                         //                               BorderRadius
      //                         //                                   .circular(8.0),
      //                         //                           borderSide: BorderSide(
      //                         //                             color: Colors
      //                         //                                 .transparent,
      //                         //                             // Off-white color
      //                         //                             // width: 2.0,
      //                         //                           )),
      //                         //                   // labelText: 'Enter your password',
      //                         //                 ),
      //                         //                 cursorColor:
      //                         //                     AppColors.textColorGrey),
      //                         //           )
      //                         //         ],
      //                         //       ),
      //                         //     ),
      //                         //   ],
      //                         // ),
      //
      //                         // Spacer(),
      //
      //
      //
      //                       ],
      //                     ),
      //                   ),
      //                 ),
      //                 // SizedBox(
      //                 //   height: 6.h,
      //                 // )
      //               ),
      //             )
      //           ],
      //         ),
      //       ),
      //       Positioned(
      //           bottom: 20,
      //           left: 20,
      //           right: 20,
      //           child: AppButton(
      //             title: 'Add card'.tr(),
      //             isactive: isButtonActive,
      //             handler: () async {
      //               // if(_cardnumberController.text.isNotEmpty){
      //               setState(() {
      //                 isCardLoading = true;
      //               });
      //               final result = await Provider.of<TransactionProvider>(
      //                   context,
      //                   listen: false)
      //                   .tokenizeCardRequest(
      //                   token: token,
      //                   // bin: _cardnumberController.text.substring(0, 6),
      //                   context: context);
      //               setState(() {
      //                 isCardLoading = false;
      //               });
      //               if (result == AuthResult.success) {
      //                WebviewHelper(
      //                  checkoutId: Provider.of<TransactionProvider>(
      //                      context,
      //                      listen: false).tokenizedCheckoutId,
      //                );
      //               }
      //               },
      //               // showDialog(
      //               //   context: context,
      //               //   builder: (BuildContext context) {
      //               //     final screenWidth =
      //               //         MediaQuery.of(context).size.width;
      //               //     final dialogWidth = screenWidth * 0.85;
      //               //     return Dialog(
      //               //       shape: RoundedRectangleBorder(
      //               //         borderRadius:
      //               //             BorderRadius.circular(8.0),
      //               //       ),
      //               //       backgroundColor: Colors.transparent,
      //               //       child: BackdropFilter(
      //               //           filter: ImageFilter.blur(
      //               //               sigmaX: 7, sigmaY: 7),
      //               //           child: Container(
      //               //             height: 55.h,
      //               //             width: dialogWidth,
      //               //             decoration: BoxDecoration(
      //               //               color: themeNotifier.isDark
      //               //                   ? AppColors.showDialogClr
      //               //                   : AppColors.textColorWhite,
      //               //               // color: AppColors.backgroundColor,
      //               //               borderRadius:
      //               //                   BorderRadius.circular(15),
      //               //             ),
      //               //             child: Column(
      //               //               children: [
      //               //                 SizedBox(
      //               //                   height: 3.h,
      //               //                 ),
      //               //                 Align(
      //               //                   alignment:
      //               //                       Alignment.bottomCenter,
      //               //                   child: Image.asset(
      //               //                     "assets/images/svg_icon.png",
      //               //                     height: 5.9.h,
      //               //                     width: 5.6.h,
      //               //                   ),
      //               //                 ),
      //               //                 SizedBox(height: 2.h),
      //               //                 Text(
      //               //                   'OTP verification'.tr(),
      //               //                   style: TextStyle(
      //               //                       fontWeight:
      //               //                           FontWeight.w600,
      //               //                       fontSize: 17.5.sp,
      //               //                       color: themeNotifier
      //               //                               .isDark
      //               //                           ? AppColors
      //               //                               .textColorWhite
      //               //                           : AppColors
      //               //                               .textColorBlack),
      //               //                 ),
      //               //                 SizedBox(
      //               //                   height: 2.h,
      //               //                 ),
      //               //                 Row(
      //               //                   mainAxisAlignment:
      //               //                       MainAxisAlignment.center,
      //               //                   children: [
      //               //                     otpContainer(
      //               //                       focusNode:
      //               //                           firstFieldFocusNode,
      //               //                       controller:
      //               //                       otp1Controller,
      //               //                       previousFocusNode: firstFieldFocusNode,
      //               //                       handler: () => FocusScope
      //               //                               .of(context)
      //               //                           .requestFocus(
      //               //                               secondFieldFocusNode),
      //               //                     ),
      //               //                     SizedBox(
      //               //                       width: 1.h,
      //               //                     ),
      //               //                     otpContainer(
      //               //                       focusNode:
      //               //                           secondFieldFocusNode,
      //               //                       controller:
      //               //                       otp2Controller,
      //               //                       previousFocusNode: firstFieldFocusNode,
      //               //                       handler: () => FocusScope
      //               //                               .of(context)
      //               //                           .requestFocus(
      //               //                               thirdFieldFocusNode),
      //               //                     ),
      //               //                     SizedBox(
      //               //                       width: 1.h,
      //               //                     ),
      //               //                     otpContainer(
      //               //                       focusNode:
      //               //                           thirdFieldFocusNode,
      //               //                       controller:
      //               //                       otp3Controller,
      //               //                       previousFocusNode: secondFieldFocusNode,
      //               //                       handler: () => FocusScope
      //               //                               .of(context)
      //               //                           .requestFocus(
      //               //                               forthFieldFocusNode),
      //               //                     ),
      //               //                     SizedBox(
      //               //                       width: 1.h,
      //               //                     ),
      //               //                     otpContainer(
      //               //                       focusNode:
      //               //                           forthFieldFocusNode,
      //               //                       controller:
      //               //                       otp4Controller,
      //               //                       previousFocusNode: thirdFieldFocusNode,
      //               //                       handler: () => FocusScope
      //               //                               .of(context)
      //               //                           .requestFocus(
      //               //                               fifthFieldFocusNode),
      //               //                     ),
      //               //                     SizedBox(
      //               //                       width: 1.h,
      //               //                     ),
      //               //                     otpContainer(
      //               //                       focusNode:
      //               //                           fifthFieldFocusNode,
      //               //                       controller:
      //               //                       otp5Controller,
      //               //                       previousFocusNode: forthFieldFocusNode,
      //               //                       handler: () => FocusScope
      //               //                               .of(context)
      //               //                           .requestFocus(
      //               //                               sixthFieldFocusNode),
      //               //                     ),
      //               //                     SizedBox(
      //               //                       width: 1.h,
      //               //                     ),
      //               //                     otpContainer(
      //               //                       focusNode:
      //               //                           sixthFieldFocusNode,
      //               //                       controller:
      //               //                       otp6Controller,
      //               //                       previousFocusNode: fifthFieldFocusNode,
      //               //                       handler: () => null,
      //               //                     ),
      //               //                   ],
      //               //                 ),
      //               //                 // SizedBox(height: 1.h,),
      //               //                 // Text(
      //               //                 //   '*Incorrect verification code ',
      //               //                 //   style: TextStyle(
      //               //                 //       color: AppColors.errorColor,
      //               //                 //       fontSize: 10.2.sp,
      //               //                 //       fontWeight:
      //               //                 //       FontWeight.w400),
      //               //                 // ),
      //               //                 SizedBox(
      //               //                   height: 2.h,
      //               //                 ),
      //               //                 Text(
      //               //                   'Please enter the correct verification code sent your mobile number.'
      //               //                       .tr(),
      //               //                   textAlign: TextAlign.center,
      //               //                   style: TextStyle(
      //               //                       height: 1.4,
      //               //                       color: AppColors
      //               //                           .textColorGrey,
      //               //                       fontSize: 10.2.sp,
      //               //                       fontWeight:
      //               //                           FontWeight.w400),
      //               //                 ),
      //               //                 Expanded(child: SizedBox()),
      //               //
      //               //                 Padding(
      //               //                   padding: const EdgeInsets
      //               //                       .symmetric(
      //               //                       horizontal: 22),
      //               //                   child: AppButton(
      //               //                     title: 'Verify'.tr(),
      //               //                     handler: () {
      //               //                       Navigator.pop(context);
      //               //                       showDialog(
      //               //                         context: context,
      //               //                         builder: (BuildContext
      //               //                             context) {
      //               //                           final screenWidth =
      //               //                               MediaQuery.of(
      //               //                                       context)
      //               //                                   .size
      //               //                                   .width;
      //               //                           final dialogWidth =
      //               //                               screenWidth *
      //               //                                   0.85;
      //               //                           void
      //               //                               closeDialogAndNavigate() {
      //               //                             Navigator.of(
      //               //                                     context)
      //               //                                 .pop(); // Close the dialog
      //               //                             // Navigator.of(context).pop(); // Close the dialog
      //               //                             Navigator.push(
      //               //                               context,
      //               //                               MaterialPageRoute(
      //               //                                   builder:
      //               //                                       (context) =>
      //               //                                           WalletBankingAndPaymentEmpty()),
      //               //                             );
      //               //                           }
      //               //
      //               //                           Future.delayed(
      //               //                               Duration(
      //               //                                   seconds: 3),
      //               //                               closeDialogAndNavigate);
      //               //                           return Dialog(
      //               //                             shape:
      //               //                                 RoundedRectangleBorder(
      //               //                               borderRadius:
      //               //                                   BorderRadius
      //               //                                       .circular(
      //               //                                           8.0),
      //               //                             ),
      //               //                             backgroundColor:
      //               //                                 Colors
      //               //                                     .transparent,
      //               //                             child:
      //               //                                 BackdropFilter(
      //               //                                     filter: ImageFilter.blur(
      //               //                                         sigmaX:
      //               //                                             7,
      //               //                                         sigmaY:
      //               //                                             7),
      //               //                                     child:
      //               //                                         Container(
      //               //                                       height:
      //               //                                           23.h,
      //               //                                       width:
      //               //                                           dialogWidth,
      //               //                                       decoration:
      //               //                                           BoxDecoration(
      //               //
      //               //                                         color: themeNotifier.isDark
      //               //                                             ? AppColors.showDialogClr
      //               //                                             : AppColors.textColorWhite,
      //               //                                         borderRadius:
      //               //                                             BorderRadius.circular(15),
      //               //                                       ),
      //               //                                       child:
      //               //                                           Column(
      //               //                                         mainAxisAlignment:
      //               //                                             MainAxisAlignment.start,
      //               //                                         children: [
      //               //                                           SizedBox(
      //               //                                             height:
      //               //                                                 4.h,
      //               //                                           ),
      //               //                                           Align(
      //               //                                             alignment:
      //               //                                                 Alignment.bottomCenter,
      //               //                                             child:
      //               //                                                 Image.asset(
      //               //                                               "assets/images/add_card.png",
      //               //                                               height: 6.h,
      //               //                                               width: 5.8.h,
      //               //                                             ),
      //               //                                           ),
      //               //                                           SizedBox(
      //               //                                               height: 2.h),
      //               //                                           Text(
      //               //                                             'Your Payment Card has been added'.tr(),
      //               //                                             textAlign:
      //               //                                                 TextAlign.center,
      //               //                                             maxLines:
      //               //                                                 2,
      //               //                                             style: TextStyle(
      //               //                                                 fontWeight: FontWeight.w600,
      //               //                                                 fontSize: 17.sp,
      //               //                                                 color: themeNotifier.isDark ? AppColors.textColorWhite : AppColors.textColorBlack),
      //               //                                           ),
      //               //                                           SizedBox(
      //               //                                             height:
      //               //                                                 4.h,
      //               //                                           ),
      //               //                                         ],
      //               //                                       ),
      //               //                                     )),
      //               //                           );
      //               //                         },
      //               //                       );
      //               //                     },
      //               //                     isGradient: true,
      //               //                     color: Colors.transparent,
      //               //                     textColor: AppColors
      //               //                         .textColorBlack,
      //               //                   ),
      //               //                 ),
      //               //                 SizedBox(height: 2.h),
      //               //                 Padding(
      //               //                   padding: const EdgeInsets
      //               //                       .symmetric(
      //               //                       horizontal: 22),
      //               //                   child: AppButton(
      //               //                       title: 'Resend code 06:00'
      //               //                           .tr(),
      //               //                       handler: () {
      //               //                         // Navigator.push(
      //               //                         //   context,
      //               //                         //   MaterialPageRoute(
      //               //                         //     builder: (context) => TermsAndConditions(),
      //               //                         //   ),
      //               //                         // );
      //               //                       },
      //               //                       isGradient: false,
      //               //                       textColor: themeNotifier
      //               //                               .isDark
      //               //                           ? AppColors
      //               //                               .textColorWhite
      //               //                           : AppColors
      //               //                               .textColorBlack
      //               //                               .withOpacity(0.8),
      //               //                       color:
      //               //                           Colors.transparent),
      //               //                 ),
      //               //                 Expanded(child: SizedBox()),
      //               //               ],
      //               //             ),
      //               //           )),
      //               //     );
      //               //   },
      //               // );
      //               // },
      //
      //
      //             isLoading: isCardLoading,
      //             isGradient: true,
      //             color: Colors.transparent,
      //             // textColor: AppColors.textColorGreyShade2,
      //           ))
      //     ],
      //   ),
      // );
    });
  }

  void otpCardVerificationDialog({bool isDark = true}){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth =
            MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.85;
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
                  height: 54.h,
                  width: dialogWidth,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors
                        .showDialogClr
                        : AppColors
                        .textColorWhite,
                    // color: Colors.redAccent,
                    borderRadius:
                    BorderRadius.circular(
                        15),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 4.h,
                      ),
                      Align(
                        alignment: Alignment
                            .bottomCenter,
                        child: Image.asset(
                          "assets/images/svg_icon.png",
                          color: AppColors.textColorWhite,
                          height: 5.9.h,
                          width: 5.6.h,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'OTP verification'.tr(),
                        style: TextStyle(
                            fontWeight:
                            FontWeight.w600,
                            fontSize: 17.5.sp,
                            color: isDark
                                ? AppColors
                                .textColorWhite
                                : AppColors
                                .textColorBlack),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Container(
                        // color: Colors.red,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: [
                            otpContainer(
                              controller:
                              otp1Controller,
                              focusNode:
                              firstFieldFocusNode,
                              previousFocusNode:
                              firstFieldFocusNode,
                              handler: () => FocusScope
                                  .of(context)
                                  .requestFocus(
                                  secondFieldFocusNode),
                            ),
                            SizedBox(
                              width: 0.8.h,
                            ),
                            otpContainer(
                              controller:
                              otp2Controller,
                              focusNode:
                              secondFieldFocusNode,
                              previousFocusNode:
                              firstFieldFocusNode,
                              handler: () => FocusScope
                                  .of(context)
                                  .requestFocus(
                                  thirdFieldFocusNode),
                            ),
                            SizedBox(
                              width: 0.8.h,
                            ),
                            otpContainer(
                              controller:
                              otp3Controller,
                              focusNode:
                              thirdFieldFocusNode,
                              previousFocusNode:
                              secondFieldFocusNode,
                              handler: () => FocusScope
                                  .of(context)
                                  .requestFocus(
                                  forthFieldFocusNode),
                            ),
                            SizedBox(
                              width: 0.8.h,
                            ),
                            otpContainer(
                              controller:
                              otp4Controller,
                              focusNode:
                              forthFieldFocusNode,
                              previousFocusNode:
                              thirdFieldFocusNode,
                              handler: () => FocusScope
                                  .of(context)
                                  .requestFocus(
                                  fifthFieldFocusNode),
                            ),
                            SizedBox(
                              width: 0.8.h,
                            ),
                            otpContainer(
                              controller:
                              otp5Controller,
                              focusNode:
                              fifthFieldFocusNode,
                              previousFocusNode:
                              forthFieldFocusNode,
                              handler: () => FocusScope
                                  .of(context)
                                  .requestFocus(
                                  sixthFieldFocusNode),
                            ),
                            SizedBox(
                              width: 0.8.h,
                            ),
                            otpContainer(
                              controller:
                              otp6Controller,
                              focusNode:
                              sixthFieldFocusNode,
                              previousFocusNode:
                              fifthFieldFocusNode,
                              handler: () => null,
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(
                      //   height: 2.h,
                      // ),
                      // Text(
                      //   '*Incorrect verification code'
                      //       .tr(),
                      //   style: TextStyle(
                      //       color: AppColors
                      //           .errorColor,
                      //       fontSize: 10.2.sp,
                      //       fontWeight:
                      //       FontWeight
                      //           .w400),
                      // ),
                      //
                      SizedBox(height: 2.h,),
                  Text(
                      'Enter sms verification code'
                          .tr(),
                      style: TextStyle(
                          color: AppColors
                              .textColorGreyShade2,
                          fontSize: 10.2.sp,
                          fontWeight:
                          FontWeight
                              .w400),
                    ),
                      SizedBox(height: 2.h,),
                      // Expanded(
                      //     child: SizedBox()),
                      Padding(
                          padding:
                          EdgeInsets
                              .symmetric(
                              horizontal:
                              22.sp),
                          child: DialogButton(
                            title:
                            'Verify'.tr(),
                            handler: ()=> null,
                            // isGradient: true,
                            // isLoading:
                            // _isLoading,
                            color: Colors
                                .transparent,
                            textColor: AppColors
                                .textColorBlack,
                          )
                      ),
                      SizedBox(height: 2.h),
                      Padding(
                        padding:
                         EdgeInsets
                            .symmetric(
                            horizontal: 22.sp),
                        child: AppButton(
                            title:
                            'Resend code 06:00'
                                .tr(),
                            handler: () => null,
                            // isLoading:
                            // _isLoadingResend,
                            isGradient: false,
                            textColor: isDark
                                ? AppColors
                                .textColorWhite
                                : AppColors
                                .textColorBlack
                                .withOpacity(
                                0.8),
                            color: Colors
                                .transparent),
                      ),
                      Expanded(
                          child: SizedBox()),

                    ],
                  ),
                )),
          );
        });
      },
    );
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
}
