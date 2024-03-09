import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/providers/payment_fees.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';

class PaymentFeesWidget extends StatefulWidget {
  final String params;

  PaymentFeesWidget({required this.params});

  @override
  State<PaymentFeesWidget> createState() => _PaymentFeesWidgetState();
}

class _PaymentFeesWidgetState extends State<PaymentFeesWidget> {
  var _isInit=true;
  var isLoading=false;
  @override
  void initState() {
    Provider.of<PaymentFees>(context, listen: false)
        .paymentFeesForMintNFT(params: widget.params);

    // TODO: implement initState
    super.initState();
  }
  @override
  void didChangeDependencies() {
    if(_isInit) {
      setState(() {
        isLoading=true;
      });
      Provider.of<PaymentFees>(context, listen: false)
          .paymentFeesForMintNFT(params: widget.params);
      setState(() {
        isLoading=false;
      });
    }
    _isInit=false;

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return
      isLoading ? CircularProgressIndicator():
      Consumer<PaymentFees>(builder: (context, paymentFee, child) {
        return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return

      Container(
      decoration: BoxDecoration(
          color: AppColors.transactionFeeContainer,
          borderRadius:
          BorderRadius.circular(10.sp),
          border: Border.all(
              color:
              AppColors.errorColor)),
      child: Padding(
        padding: EdgeInsets.only(
            top: 13.sp,
            left: 13.sp,
            right: 13.sp,
            bottom: 7.sp),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // SizedBox(
            //   height: 4.h,
            // ),
            Text(
              'Transaction fees'.tr(),
              style: TextStyle(
                  color: themeNotifier.isDark
                      ? AppColors.textColorWhite
                      : AppColors.textColorBlack,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600),
            ),
            Divider(
              color: AppColors.textColorGrey,
            ),
            SizedBox(
              height: 1.h,
            ),
            transactionFeesWidget(
              title: 'Sale value'.tr(),
              details: 'N/A',
              showCurrency: true,
              isDark: themeNotifier.isDark
                  ? true
                  : false,
            ),
            transactionFeesWidget(
              title: 'Minting fee'.tr(),
              details: paymentFee.platformMintingFees,
              showCurrency: true,
              isDark: themeNotifier.isDark
                  ? true
                  : false,
            ),
            transactionFeesWidget(
              title:
              'Platform sale commission'.tr(),
              details: 'N/A',
              showCurrency: true,
              isDark: themeNotifier.isDark
                  ? true
                  : false,
            ),
            transactionFeesWidget(
              title: 'Network fee'.tr(),
              details: paymentFee.networkFees,
              showCurrency: true,
              isDark: themeNotifier.isDark
                  ? true
                  : false,
            ),
            transactionFeesWidget(
              title: 'Payment processing fee'.tr(),
              details: paymentFee.paymentProcessingFee,
              showCurrency: true,
              isDark: themeNotifier.isDark
                  ? true
                  : false,
            ),
            Divider(
              color: AppColors.textColorGrey,
            ),
            transactionFeesWidget(
              title: 'Total Receivable Amount'.tr(),
              details: paymentFee.totalFees,
              showCurrency: true,
              boldDetails: true,
              isDark: themeNotifier.isDark
                  ? true
                  : false,
            ),
            SizedBox(
              height: 1.h,
            ),
            Text(
              'The transaction request is automatically signed and submitted to the Blockchain once this transaction is paid.'
                  .tr(),
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 10.5.sp,
                  color: AppColors
                      .textColorGreyShade2),
            ),
            SizedBox(
              height: 2.h,
            ),
          ],
        ),
      ),
    );
  });
  });
  }
  Widget transactionFeesWidget({
    required String title,
    required String details,
    bool isDark = true,
    bool showCurrency = false,
    bool boldDetails = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            // color: Colors.yellow,
            width: 45.w,
            child: Text(
              title,
              style: TextStyle(
                  color: AppColors.textColorWhite,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(
            width: 5.sp,
          ),
          Container(
            // color: Colors.red,
            width: 25.w,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                details != 'N/A' && showCurrency ? details + ' SAR' : details,
                style: TextStyle(
                    color: isDark
                        ? AppColors.textColorWhite
                        : AppColors.textColorBlack,
                    fontSize: 11.sp,
                    fontWeight:
                    boldDetails ? FontWeight.w800 : FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
