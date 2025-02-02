import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/providers/card_provider.dart';
import 'package:hesa_wallet/screens/user_transaction_summaries_with_payment/transaction_request.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../constants/colors.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/main_header.dart';
import '../userpayment_and_bankingpages/wallet_banking_and_payment_empty.dart';

class WebviewHelper extends StatefulWidget {
  final String checkoutId;
  bool fromTransactionReq;

  WebviewHelper({
    required this.checkoutId,
    this.fromTransactionReq=false,
  });

  @override
  State<WebviewHelper> createState() => _WebviewHelperState();
}

class _WebviewHelperState extends State<WebviewHelper> {
  late WebViewController _controller;
  final String htmlFilePath = 'assets/html/add_card_form.html';
  String accessToken = '';

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  Future<String> _loadHtmlFromAssets(String filePath) async {
    String fileHtmlContents = await rootBundle.loadString(filePath);
    String updatedHtml = fileHtmlContents.replaceAll(
      'checkoutId=55CCB91132C12F2C6BF6D75E28026CD1.uat01-vm-tx01',
      'checkoutId=${widget.checkoutId}',
    );

    updatedHtml = updatedHtml.replaceAll(
      'data-brands="VISA MASTER AMEX"',
      Provider.of<
          TransactionProvider>(
          context,
          listen: false)
          .selectedCardBrand ==
          "MADA"
          ? 'data-brands="MADA"'
          : Provider.of<
          TransactionProvider>(
          context,
          listen: false)
          .selectedCardBrand=="MASTER" ? 'data-brands="MASTER"':'data-brands="VISA"'
    );
    return Uri.dataFromString(
      updatedHtml,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString();
  }

  void _updateCheckoutId(
      WebViewController controller, String newCheckoutId) async {
    await controller.evaluateJavascript("updateCheckoutId('$newCheckoutId');");
  }

  void _checkPageContent() async {
    String pageContent = await _controller.evaluateJavascript("document.body.innerText");
    if (pageContent.contains('Successfully')) {
      checkFormFilledStatus(widget.checkoutId);
    }
  }

  checkFormFilledStatus(String checkoutID) async {
    if (!widget.fromTransactionReq) {
      Future.delayed(Duration(seconds: 1), () async {
      Navigator.pop(context);
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WalletBankingAndPaymentEmpty()),
      );
    });} else {
      await Provider.of<UserProvider>(context, listen: false)
          .getUserDetails(token: accessToken, context: context);
      Future.delayed(Duration(seconds: 1), () async {
      Navigator.pop(context, true);
    });}
  }

  // checkFormFilledStatus(String checkoutID) async {
  //   if(!widget.fromTransactionReq){
  //     Navigator.pop(context);
  //     await Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) =>
  //               WalletBankingAndPaymentEmpty()
  //       ),
  //     ).then((value) => print('after going'));
  //   } else {
  //     await Provider.of<UserProvider>(context, listen: false)
  //         .getUserDetails(token: accessToken, context: context);
  //     Navigator.pop(context, true);
  //   }
  //
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAccessToken();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        checkFormFilledStatus(
            widget.checkoutId);
        return true;
      },
      child: FutureBuilder<String>(
        future: _loadHtmlFromAssets(htmlFilePath),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: Column(
                children: [
                  MainHeader(title: 'Add Card'.tr(),
                      handler: (){ checkFormFilledStatus(widget.checkoutId);

                      }
                  ),
                  Expanded(
                    child: Container(
                      child: Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
                        child: WebView(
                          onWebViewCreated: (WebViewController webViewController) {
                            _controller = webViewController;
                          },
                          onPageFinished: (String url) async {
                            _updateCheckoutId(_controller, widget.checkoutId);
                            _checkPageContent();
                          },
                          initialUrl: snapshot.data!,
                          javascriptMode: JavascriptMode.unrestricted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
