import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../providers/theme_provider.dart';

class WalletActivityWidget extends StatefulWidget {
  final String title, subTitle, image, time, siteURL;
  final int?
  priceNormal;
  final String? priceUp;
  final String? priceDown;
  final bool isPending;
  final Function handler;

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
      required this.time,
      required this.handler})
      : super(key: key);

  @override
  State<WalletActivityWidget> createState() => _WalletActivityWidgetState();
}

class _WalletActivityWidgetState extends State<WalletActivityWidget> {
  @override
  Widget build(BuildContext context) {
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
                  child: Image.network(
                    'https://images.pexels.com/photos/14354112/pexels-photo-14354112.jpeg?auto=compress&cs=tinysrgb&w=800',
                    // widget.image,
                    // Replace with your image assets
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
                              widget.subTitle,
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
                      SizedBox(height: isEnglish ? 0.3.h:0.02.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 47.w,
                            // color: Colors.yellow,
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
                      SizedBox(height: isEnglish? 0.3.h: 0.0),
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
                                  fontSize: 10.sp,
                                  color: AppColors.textColorGreyShade2),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                                    horizontal: 13.sp, vertical: isEnglish ?  4.sp : 3.5.sp),
                                child: Text(
                                  'Pending'.tr(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 9.sp,
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
                          if (!widget.isPending &&
                              widget.priceUp != null
                              // &&
                              // widget.priceNormal == null
                          )
                            Text(
                              "+${widget.priceUp} SAR",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.2.sp,
                                  // fontSize: 10.5.sp,
                                  color: AppColors.activityPricegreenClr),
                            ),
                          if (!widget.isPending &&
                              // widget.priceNormal == null &&
                              widget.priceUp == null &&
                              widget.priceDown != null)
                            Text(
                              "-${widget.priceDown} SAR",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.2.sp,
                                  // fontSize: 10.5.sp,
                                  color: AppColors.activityPriceredClr),
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
