import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/colors.dart';
import '../../providers/assets_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/main_header.dart';

class NftsCollectionDetails extends StatefulWidget {
  const NftsCollectionDetails();

  static const routeName = 'nfts_collection_details';

  @override
  State<NftsCollectionDetails> createState() => _NftsCollectionDetailsState();
}

class _NftsCollectionDetailsState extends State<NftsCollectionDetails> {
  var accessToken;

  final scrollController = ScrollController();

  String replaceMiddleWithDots(String input) {
    // if (input.length <= 20) {
    //   // If the input string is 30 characters or less, return it as is.
    //   return input;
    // }
    //
    // final int middleIndex = input.length ~/ 2; // Find the middle index
    // final int startIndex = middleIndex - 15; // Calculate the start index
    // final int endIndex = middleIndex + 15; // Calculate the end index
    //
    // // Split the input string into three parts and join them with '...'
    // final String result =
    //     input.substring(0, startIndex) + '...' + input.substring(endIndex);

    return input.toString();
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
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(dateTime);
  }

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  var isLoading = false;

  void initState() {
    getAccessToken();
    // TODO: implement initState
    super.initState();
  }

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Future<void> didChangeDependencies() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    await getAccessToken();
    setState(() {
      isLoading = true;
    });
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    await Provider.of<AssetsProvider>(context, listen: false)
        .getCollectionDetails(
      token: accessToken,
      type: 'collection',
      id: args["collectionId"],
      isEnglish:isEnglish,
    );

    setState(() {
      isLoading = false;
    });
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final assetsDetails = Provider.of<AssetsProvider>(context, listen: false);
    print('checking image');
    print(args["bannerLink"]);
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: Column(
                      children: [
                        MainHeader(
                          title:  isLoading
                              ? 'Collection Name'.tr()
                              : assetsDetails.tokenName,
                          subTitle:  isLoading
                              ? '.......'
                              : replaceMiddleWithDotsCollectionId(
                              assetsDetails.tokenId),
                          showSubTitle: true,
                          showLogo: true,
                          logoPath: assetsDetails.logoImage,
                          isLoadingImage: isLoading,
                        ),
                        // SizedBox(height: 3.h),
                        Expanded(
                            child: isLoading
                                ? Container(
                                    height: 88.h,
                                    width: double.infinity,
                                    color: Colors.black,
                                  )
                                : ListView(
                                    padding: EdgeInsets.only(top: 2.h),
                                    controller: scrollController,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10.sp),
                                        // color: Colors.red,
                                        height: 47.h,
                                        width: 45.h,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.sp),
                                          child: Image.network(
                                            assetsDetails.image,
                                            fit: BoxFit.cover,
                                            errorBuilder: (BuildContext context,
                                                Object exception,
                                                StackTrace? stackTrace) {
                                              return Image.asset(
                                                'assets/images/nft.png',
                                                // Path to your placeholder image
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Divider(
                                          color: AppColors
                                              .transactionSummNeoBorder),
                                      SizedBox(height: 2.h),
                                      nftsDetailsWidget(
                                        title: 'Created:'.tr(),
                                        details:
                                            formatDate(assetsDetails.createdAt),
                                        isDark:
                                            themeNotifier.isDark ? true : false,
                                          isEnglish: isEnglish,
                                      ),
                                      nftsDetailsWidget(
                                        title: 'Collection ID:'.tr(),
                                        func: () => _launchURL(
                                            "https://www.mjraexplorer.com/collection/" +
                                                assetsDetails.tokenId),
                                        details:
                                            replaceMiddleWithDotsCollectionId(
                                                assetsDetails.tokenId),
                                        isDark:
                                            themeNotifier.isDark ? true : false,
                                        color: AppColors.textColorToska,
                                        isEnglish: isEnglish,
                                      ),
                                      if (assetsDetails.creatorName != null)
                                        nftsDetailsWidget(
                                          title: 'Creator:'.tr(),
                                          func: () => _launchURL(
                                              "https://www.mjraexplorer.com/address/" +
                                                  assetsDetails.creatorAddress),
                                          details: replaceMiddleWithDots(
                                                  assetsDetails.creatorName) ??
                                              "N/A",
                                          isDark: themeNotifier.isDark
                                              ? true
                                              : false,
                                          color: AppColors.textColorToska,
                                          isEnglish: isEnglish,
                                        ),
                                      if (assetsDetails.creatorRoyalty !=
                                          "null")
                                        nftsDetailsWidget(
                                          title: 'Creator royalty:'.tr(),
                                          details:
                                              assetsDetails.creatorRoyalty +
                                                      "%" ??
                                                  "N/A",
                                          isDark: themeNotifier.isDark
                                              ? true
                                              : false,
                                          isEnglish: isEnglish,
                                        ),
                                      if (assetsDetails.ownerName != "null")
                                        nftsDetailsWidget(
                                          title: 'Owned by:'.tr(),
                                          func: () => _launchURL(
                                              "https://www.mjraexplorer.com/address/" +
                                                  assetsDetails.ownerAddress),
                                          details: replaceMiddleWithDots(
                                                  assetsDetails.ownerName) ??
                                              "N/A",
                                          isDark: themeNotifier.isDark
                                              ? true
                                              : false,
                                          color: AppColors.textColorToska,
                                          isEnglish: isEnglish,
                                        ),
                                      if (assetsDetails.collectionItems !=
                                          "null")
                                        nftsDetailsWidget(
                                          title: 'Collection Items:'.tr(),
                                          details: replaceMiddleWithDots(
                                                  assetsDetails
                                                      .collectionItems) ??
                                              "N/A",
                                          isDark: themeNotifier.isDark
                                              ? true
                                              : false,
                                          isEnglish: isEnglish,
                                        ),
                                      nftsDetailsWidget(
                                        title: 'Collection Status:'.tr(),
                                        details: assetsDetails.status,
                                        isDark:
                                            themeNotifier.isDark ? true : false,
                                        isEnglish: isEnglish,
                                      ),
                                      if (assetsDetails.listingType != "null")
                                        nftsDetailsWidget(
                                          title: 'Listing Type:'.tr(),
                                          details: assetsDetails.listingType,
                                          isDark: themeNotifier.isDark
                                              ? true
                                              : false,
                                          isEnglish: isEnglish,
                                        ),
                                      // if(args["nftIds"] != null)
                                      //   nftsDetailsWidget(
                                      //     title: 'Collection Items:'.tr(),
                                      //     details: args["nftIds"].toString(),
                                      //     isDark: themeNotifier.isDark ? true : false,
                                      //   ),
                                      if (assetsDetails.standard != "null")
                                        nftsDetailsWidget(
                                          title: 'Collection Standard:'.tr(),
                                          details: assetsDetails.standard,
                                          isDark: themeNotifier.isDark
                                              ? true
                                              : false,
                                          isEnglish: isEnglish,
                                        ),
                                      if (assetsDetails.chain != "null")
                                        nftsDetailsWidget(
                                          title: 'Chain:'.tr(),
                                          details: assetsDetails.chain,
                                          isDark: themeNotifier.isDark
                                              ? true
                                              : false,
                                          isEnglish: isEnglish,
                                        ),
                                      if (assetsDetails.burnable != "null")
                                        nftsDetailsWidget(
                                          title: 'Burn Control:'.tr(),
                                          details:
                                              assetsDetails.burnable == "true"
                                                  ? "On"
                                                  : "Off",
                                          isDark: themeNotifier.isDark
                                              ? true
                                              : false,
                                          isEnglish: isEnglish,
                                        ),
                                      SizedBox(height: 2.h,),
                                    ],
                                  )),
                        // SizedBox(height: 2.h),
                      ],
                    )),
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

  Widget nftsDetailsWidget({
    required String title,
    required String details,
    Color? color,
    bool isDark = true,
    bool isEnglish = true,
    Function? func,
  }) {
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
          GestureDetector(
            onTap: () => func!(),
            child: Container(
              width: 45.w,
              // color: Colors.yellow,
              child: Align(
                alignment: isEnglish ? Alignment.centerRight:Alignment.centerLeft,
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
          ),
        ],
      ),
    );
  }
}
