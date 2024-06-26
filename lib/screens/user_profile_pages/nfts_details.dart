import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/main_header.dart';

class NftsDetails extends StatefulWidget {
  const NftsDetails();

  static const routeName = 'nfts_details';

  @override
  State<NftsDetails> createState() => _NftsDetailsState();
}

class _NftsDetailsState extends State<NftsDetails> {
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

  String replaceMiddleWithDotsCollectionId(String input) {
    if (input.length <= 30) {
      return input;
    }

    final int middleIndex = input.length ~/ 2; // Find the middle index
    final int startIndex = middleIndex - 12; // Calculate the start index
    final int endIndex = middleIndex + 9; // Calculate the end index

    // Split the input string into three parts and join them with '...'
    final String result =
        input.substring(0, startIndex) + '...' + input.substring(endIndex);

    return result;
  }

  String formatDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    final DateFormat formatter = DateFormat('MMM dd, yyyy HH:mm:ss');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Column(
            children: [
              MainHeader(
                title: args["tokenName"],
                subTitle: replaceMiddleWithDotsCollectionId(args["tokenId"]),
                showSubTitle: true,
              ),
              SizedBox(height: 3.h),
              Container(
                // color: Colors.red,
                height: 47.h,
                width: 42.h,
                child:
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.sp),
                  child: Image.network(args["image"], fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return Image.asset(
                        'assets/images/nft.png', // Path to your placeholder image
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                // Image.asset(
                //   "assets/images/nfts_placeholder.png",
                //   fit: BoxFit.cover,
                // ),
              ),
              Divider(color: AppColors.transactionSummNeoBorder),
              SizedBox(height: 2.h),
              nftsDetailsWidget(
                title: 'Created:'.tr(),
                details: formatDate(args["createdAt"]),
                isDark: themeNotifier.isDark ? true : false,
              ),
              // // nftsDetailsWidget(
              // //   title: 'Status:'.tr(),
              // //   details: args["status"] ?? 'N/A',
              // //   isDark: themeNotifier.isDark ? true : false,
              // // ),
              nftsDetailsWidget(
                title: 'Token ID:'.tr(),
                details:
                    replaceMiddleWithDotsCollectionId(args["tokenId"]),
                isDark: themeNotifier.isDark ? true : false,
              ),
              if (args["creatorId"] != null)
                nftsDetailsWidget(
                  title: 'Creator ID:'.tr(),
                  details: replaceMiddleWithDots(args["creatorId"]) ?? "N/A",
                  isDark: themeNotifier.isDark ? true : false,
                  color: AppColors.textColorToska,
                ),
              if (args["creatorRoyalty"] != "null")
                nftsDetailsWidget(
                  title: 'Creator royalty:'.tr(),
                  details: args["creatorRoyalty"] + '%',
                  isDark: themeNotifier.isDark ? true : false,
                ),
              if (args["ownerId"] != "null")
                nftsDetailsWidget(
                  title: 'Owned by:'.tr(),
                  details: replaceMiddleWithDots(args["ownerId"]) ?? "N/A",
                  isDark: themeNotifier.isDark ? true : false,
                  color: AppColors.textColorToska,
                ),
              // // if (args["nftIds"] != "null")
              // //   nftsDetailsWidget(
              // //     title: 'Collection Items:'.tr(),
              // //     details: args["nftIds"],
              // //     isDark: themeNotifier.isDark ? true : false,
              // //   ),
              if (args["status"] != "null")
                nftsDetailsWidget(
                  title: 'Token Status:'.tr(),
                  details: args["status"],
                  isDark: themeNotifier.isDark ? true : false,
                ),
              if (args["listingType"] != "null")
                nftsDetailsWidget(
                  title: 'Listing Type:'.tr(),
                  details: args["listingType"],
                  isDark: themeNotifier.isDark ? true : false,
                ),
              if (args["isListable"] != "null")
                nftsDetailsWidget(
                  title: 'Is Listable:'.tr(),
                  details: args["isListable"],
                  isDark: themeNotifier.isDark ? true : false,
                ),
              nftsDetailsWidget(
                title: 'Token Standard:'.tr(),
                details: args["standard"],
                isDark: themeNotifier.isDark ? true : false,
              ),
              nftsDetailsWidget(
                title: 'Chain:'.tr(),
                details: args["chain"],
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
                    color:
                        color == null ? AppColors.textColorGreyShade2 : color,
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
