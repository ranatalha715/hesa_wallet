import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';
import 'image_placeholder.dart';

class WalletActivityWidget extends StatefulWidget {
  final String title, subTitle, image, time, siteURL;
  final int? priceNormal;
  final String? priceUp;
  final String? priceDown;
  final bool isPending;
  final Function handler;
  final Uint8List? bytes;

  const WalletActivityWidget(
      {Key? key,
      required this.title,
      required this.subTitle,
      required this.image,
      required this.siteURL,
      this.isPending = false,
      this.priceDown,
      this.priceNormal,
      this.priceUp,
      this.bytes,
      required this.time,
      required this.handler})
      : super(key: key);

  @override
  State<WalletActivityWidget> createState() => _WalletActivityWidgetState();
}

class _WalletActivityWidgetState extends State<WalletActivityWidget> {
  var accessToken;
  var index;

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Wrap asynchronous code in a try-catch block to handle any potential errors
    try {
      // Retrieve the access token
      getAccessToken().then((accessToken) {
        // Fetch wallet activities using the access token
        Provider.of<TransactionProvider>(context, listen: false)
            .getWalletActivities(
          accessToken: accessToken,
          context: context,
        )
            .catchError((error) {
          print("Error fetching wallet activities: $error");
        });
      }).catchError((error) {
        print("Error retrieving access token: $error");
        // You can show a snackbar or any other error handling mechanism here
      });
    } catch (error) {
      print("Error in didChangeDependencies: $error");
      // You can show a snackbar or any other error handling mechanism here
    }
  }

  // @override
  // Future<void> didChangeDependencies() async {
  //   // TODO: implement didChangeDependencies
  //   await getAccessToken();
  //   await Provider.of<TransactionProvider>(context, listen: false)
  //       .getWalletActivities(accessToken: accessToken, context: context);
  //   super.didChangeDependencies();
  // }

  String formatCurrency(String? numberString) {
    // Check if the string is null or empty
    if (numberString == null || numberString.isEmpty) {
      return "0"; // Return a default value if input is invalid
    }

    try {
      // Convert the string to a number (num handles both int and double)
      num number = num.parse(numberString);

      // Create a NumberFormat object for Saudi currency style
      final formatter = NumberFormat("#,##0.##", "en_US");

      // Format the number with commas
      return formatter.format(number);
    } catch (e) {
      // Handle any format exceptions and return a fallback
      return "Invalid Number";
    }
  }

  @override
  Widget build(BuildContext context) {

    final activities =
        Provider.of<TransactionProvider>(context, listen: false).activities;
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return GestureDetector(
        onTap: () => widget.handler(),
        child: Container(
          margin: EdgeInsets.only(bottom: themeNotifier.isDark ? 2.sp : 0.8.sp),
          height: 12.h,
          // height: 10.7.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            border: Border(
              bottom: BorderSide(
                color: themeNotifier.isDark
                    ? AppColors.textFieldParentDark
                    : AppColors.activityDividerClrLight.withOpacity(0.35),
                // Specify your desired border color here
                width: 1, // Specify your desired border width here
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 20.sp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.sp),
                  child: widget.title == "Site Connected" ||
                      widget.title == "Site Disconnected"
                      ?
                  Stack(
                    children: [
                      ShimmerPlaceholder(),
                      Container(
                        color: AppColors.profileHeaderDark,
                        height: 40.sp,
                        width: 40.sp,
                        child: Padding(
                          padding:  EdgeInsets.all(1.sp),
                          child: Image.memory(
                            widget.bytes!,
                            // 'https://images.pexels.com/photos/14354112/pexels-photo-14354112.jpeg?auto=compress&cs=tinysrgb&w=800',
                            // fit: BoxFit.cover,

                          ),
                        ),
                      ),
                    ],
                  ):
                  Image.network(
                    widget.image,
                    // 'https://images.pexels.com/photos/14354112/pexels-photo-14354112.jpeg?auto=compress&cs=tinysrgb&w=800',
                    fit: BoxFit.cover,
                    height: 40.sp,
                    width: 40.sp,
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                Container(
                  width: 68.w,
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            color: Colors.transparent,
                            width: 50.w,
                            child: Text(
                              widget.subTitle == 'Site Connected'
                                  ? 'Connect Success'
                                  : widget.subTitle == 'Site Disconnected'
                                      ? 'Disconnect Success'
                                      : widget.subTitle,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 9.sp,
                                  color: AppColors.textColorGreyShade2),
                            ),
                          ),
                          Text(
                            widget.time,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 9.sp,
                                color: AppColors.textColorGreyShade2),
                          ),
                        ],
                      ),
                      SizedBox(height: isEnglish ? 0.3.h : 0.02.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 47.w,
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.7.sp,
                                  // fontSize: 11.7.sp,
                                  color: themeNotifier.isDark
                                      ? AppColors.textColorWhite
                                      : AppColors.textColorBlack),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // if (!widget.isPending &&
                          //     widget.priceUp != null &&
                          //     widget.priceNormal == null)
                          //   Text(
                          //     "+${widget.priceUp} SAR",
                          //     style: TextStyle(
                          //         fontWeight: FontWeight.w500,
                          //         fontSize: 10.2.sp,
                          //         // fontSize: 10.5.sp,
                          //         color: AppColors.activityPricegreenClr),
                          //   ),
                          // if (!widget.isPending &&
                          //     widget.priceNormal == null &&
                          //     widget.priceUp == null &&
                          //     widget.priceDown != null)
                          //   Text(
                          //     "-${widget.priceDown} SAR",
                          //     style: TextStyle(
                          //         fontWeight: FontWeight.w500,
                          //         fontSize: 10.2.sp,
                          //         // fontSize: 10.5.sp,
                          //         color: AppColors.activityPriceredClr),
                          //   ),
                        ],
                      ),
                      SizedBox(height: isEnglish ? 0.3.h : 0.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            // color: Colors.yellow,
                            width: 42.w,
                            child: Text(
                              widget.siteURL,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 9.sp,
                                  color: AppColors.textColorGreyShade2),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // if (activities[index].transactionType == 'Site Connected')
                          // if (activities[index].transactionType != null && activities[index].transactionType == 'Site Connected')
                          if (widget.isPending)
                            Container(
                              // margin: EdgeInsets.only(top: 6.sp),
                              decoration: BoxDecoration(
                                color: themeNotifier.isDark
                                    ? AppColors.tagFillClrDark
                                    : AppColors.tabColorlightMode,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.sp,
                                    vertical: isEnglish ? 4.sp : 3.5.sp),
                                child: Text(
                                  widget.title == 'Site Connected'
                                      ? 'Connected'
                                      : 'Disconnected',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 8.sp,
                                      color: AppColors.textColorWhite),
                                ),
                              ),
                            ),
                          // if (!widget.isPending && widget.priceNormal != null)
                          //   Text(
                          //     "${widget.priceNormal} SAR",
                          //     style: TextStyle(
                          //         fontWeight: FontWeight.w500,
                          //         fontSize: 10.5.sp,
                          //         color: themeNotifier.isDark
                          //             ? AppColors.textColorWhite
                          //             : AppColors.textColorGreyShade2),
                          //   ),
                          if (!widget.isPending && widget.priceUp != null && widget.priceUp !='0'
                              // &&
                              // widget.priceNormal == null
                              )
                            Text(
                              "${formatCurrency(widget.priceUp)} "+ "SAR".tr(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.2.sp,
                                  // fontSize: 10.5.sp,
                                  color: AppColors.activityPricegreenClr),
                            ),
                          if (!widget.isPending &&
                              // widget.priceNormal == null &&
                              widget.priceUp == null &&
                              widget.priceDown != null  && widget.priceDown !='0')
                            Container(
                              // color: Colors.blue,
                              width: 23.w,
                              child: Text(
                                "${formatCurrency(widget.priceDown)} "+ "SAR".tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: isEnglish ? TextAlign.right : TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10.2.sp,
                                    // fontSize: 10.5.sp,
                                    color: AppColors.textColorGreyShade2),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
