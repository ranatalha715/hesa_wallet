import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../providers/assets_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/main_header.dart';

class NftsCollectionDetails extends StatefulWidget {
  const NftsCollectionDetails();

  static const routeName='nfts_collection_details';



  @override
  State<NftsCollectionDetails> createState() => _NftsCollectionDetailsState();

}


class _NftsCollectionDetailsState extends State<NftsCollectionDetails> {
  var accessToken;

  final scrollController=ScrollController();
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

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  var isLoading=false;
  void initState() {
    getAccessToken();
    // TODO: implement initState
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    await getAccessToken();
    setState(() {
      isLoading=true;
    });



    await Provider.of<AssetsProvider>(context, listen: false).getCollectionDetails(
      token: accessToken,
      type: 'collection',
      id: args["collectionId"],);

    setState(() {
      isLoading=false;
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
    final assetsDetails=Provider.of<AssetsProvider>(context, listen: false);
    print('checking image');
    print(args["bannerLink"]);
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child)
    {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
          body:
          isLoading ? Center(child: CircularProgressIndicator(),):
          Column(
            children: [
              MainHeader(
                title: assetsDetails.tokenName,
                subTitle:  replaceMiddleWithDotsCollectionId(assetsDetails.tokenId),
                showSubTitle: true,
                showLogo: true,
                logoPath: assetsDetails.logoImage,
              ),
              SizedBox(height: 3.h),
              Expanded(child: ListView(
                padding: EdgeInsets.zero,
                controller: scrollController,
                children: [
                  Container(
                    // color: Colors.red,
                    height: 47.h,
                    width: 45.h,
                    child:  ClipRRect(
                      borderRadius: BorderRadius.circular(12.sp),
                      child: Image.network(assetsDetails.image, fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          return Image.asset(
                            'assets/images/nft.png', // Path to your placeholder image
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),),
                  Divider(color: AppColors.transactionSummNeoBorder),
                  SizedBox(height:2.h),
                  nftsDetailsWidget(
                    title: 'Created:'.tr(),
                    details: formatDate(assetsDetails.createdAt),
                    isDark: themeNotifier.isDark ? true : false,
                  ),
                  nftsDetailsWidget(
                    title: 'Collection ID:'.tr(),
                    details: replaceMiddleWithDotsCollectionId(assetsDetails.tokenId),
                    isDark: themeNotifier.isDark ? true : false,
                    color: AppColors.textColorToska,
                  ),
                  if(assetsDetails.creatorName != null)
                    nftsDetailsWidget(
                      title: 'Creator:'.tr(),
                      details: replaceMiddleWithDots(assetsDetails.creatorName)?? "N/A",
                      isDark: themeNotifier.isDark ? true : false,
                      color: AppColors.textColorToska,
                    ),
                  if(assetsDetails.creatorRoyalty  != "null")
                    nftsDetailsWidget(
                      title: 'Creator royalty:'.tr(),
                      details: assetsDetails.creatorRoyalty + "%" ?? "N/A",
                      isDark: themeNotifier.isDark ? true : false,
                    ),
                  if(assetsDetails.ownerName != "null")
                    nftsDetailsWidget(
                      title: 'Owned by:'.tr(),
                      details: replaceMiddleWithDots(assetsDetails.ownerName)?? "N/A",
                      isDark: themeNotifier.isDark ? true : false,
                      color: AppColors.textColorToska,
                    ),
                  if(assetsDetails.collectionItems != "null")
                    nftsDetailsWidget(
                      title: 'collection Items:'.tr(),
                      details: replaceMiddleWithDots(assetsDetails.collectionItems)?? "N/A",
                      isDark: themeNotifier.isDark ? true : false,
                    ),
                  nftsDetailsWidget(
                    title: 'Collection Status:'.tr(),
                    details: assetsDetails.status,
                    isDark: themeNotifier.isDark ? true : false,
                  ),
                  if (assetsDetails.listingType != "null")
                    nftsDetailsWidget(
                      title: 'Listing Type:'.tr(),
                      details: assetsDetails.listingType,
                      isDark: themeNotifier.isDark ? true : false,
                    ),
                  // if(args["nftIds"] != null)
                  //   nftsDetailsWidget(
                  //     title: 'Collection Items:'.tr(),
                  //     details: args["nftIds"].toString(),
                  //     isDark: themeNotifier.isDark ? true : false,
                  //   ),
                  if(assetsDetails.standard!= "null")
                    nftsDetailsWidget(
                      title: 'Collection Standard:'.tr(),
                      details: assetsDetails.standard,
                      isDark: themeNotifier.isDark ? true : false,
                    ),
                  if(assetsDetails.chain != "null")
                    nftsDetailsWidget(
                      title: 'Chain:'.tr(),
                      details: assetsDetails.chain,
                      isDark: themeNotifier.isDark ? true : false,
                    ),
                  if (assetsDetails.burnable != "null")
                    nftsDetailsWidget(
                      title: 'Burn Control:'.tr(),
                      details: assetsDetails.burnable=="true" ? "On" : "Off",
                      isDark: themeNotifier.isDark ? true : false,
                    )
                ],
              )),
              SizedBox(height: 2.h),
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
