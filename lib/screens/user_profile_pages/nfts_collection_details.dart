import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/main_header.dart';

class NftsCollectionDetails extends StatefulWidget {
  const NftsCollectionDetails();

  static const routeName='nfts_collection_details';



  @override
  State<NftsCollectionDetails> createState() => _NftsCollectionDetailsState();

}


class _NftsCollectionDetailsState extends State<NftsCollectionDetails> {
  String replaceMiddleWithDots(String input) {
    if (input.length <= 20) {
      // If the input string is 30 characters or less, return it as is.
      return input;
    }

    final int middleIndex = input.length ~/ 2; // Find the middle index
    final int startIndex = middleIndex - 15; // Calculate the start index
    final int endIndex = middleIndex + 15; // Calculate the end index

    // Split the input string into three parts and join them with '...'
    final String result =
        input.substring(0, startIndex) + '...' + input.substring(endIndex);

    return result;
  }





  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child)
    {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
          body: Column(
            children: [
              MainHeader(
                title: args["collectionName"],
                subTitle:  replaceMiddleWithDots(args["collectionId"]),
                showSubTitle: true,
              ),
              SizedBox(height: 3.h),
              Container(
                // color: Colors.red,
                height: 47.h,
                width: 42.h,
                child: Image.asset(
                  "assets/images/nfts_placeholder.png",
                  fit: BoxFit.cover,
                ),
              ),
              Divider(color: AppColors.transactionSummNeoBorder),
              SizedBox(height:2.h),
              nftsDetailsWidget(
                title: 'Created:'.tr(),
                details: 'May 24, 2023 04:19:35'.tr(),
                isDark: themeNotifier.isDark ? true : false,
              ),
              nftsDetailsWidget(
                title: 'Collection ID:'.tr(),
                details: args["collectionId"],
                isDark: themeNotifier.isDark ? true : false,
              ),
              nftsDetailsWidget(
                title: 'Creator ID:'.tr(),
                details: replaceMiddleWithDots(args["creatorId"])?? "N/A",
                isDark: themeNotifier.isDark ? true : false,
                color: AppColors.textColorToska,
              ),
              nftsDetailsWidget(
                  title: 'Creator royalty:'.tr(),
                  details: args["creatorRoyalty"] ?? "N/A",
                  isDark: themeNotifier.isDark ? true : false,
              ),
              nftsDetailsWidget(
                title: 'Owned by:'.tr(),
                details: replaceMiddleWithDots(args["ownerId"])?? "N/A",
                isDark: themeNotifier.isDark ? true : false,
                color: AppColors.textColorToska,
              ),
              nftsDetailsWidget(
                title: 'Collection Items:'.tr(),
                details: args["nftsIdsLength"],
                isDark: themeNotifier.isDark ? true : false,
              ),
              nftsDetailsWidget(
                title: 'Collection Standard:'.tr(),
                details: "MTS 1101",
                isDark: themeNotifier.isDark ? true : false,
              ),
            ],
          ));
    });
  }
  Widget nftsDetailsWidget(
      {required String title,
        required String details,
        Color? color,
        bool isDark = true}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp, left: 20.sp, right: 20.sp),
      child: Row(
        children: [
          Container(
            width: 38.w,
            // color: Colors.red,
            child: Text(
              title,
              style: TextStyle(
                  color: isDark
                      ? AppColors.textColorWhite
                      : AppColors.textColorBlack,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Spacer(),
          Container(
            width: 45.w,
            // color: Colors.yellow,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                details,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: color == null ? AppColors.textColorGreyShade2 : color,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}