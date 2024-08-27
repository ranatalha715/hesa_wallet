import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/providers/assets_provider.dart';
import 'package:hesa_wallet/screens/web_view/mjr_explorer_webview.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  var accessToken;
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
  final scrollController=ScrollController();

  @override
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



    await Provider.of<AssetsProvider>(context, listen: false).getNftCollectionDetails(
      token: accessToken,
      type: 'nft',
      id: args["tokenId"],);

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
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: isLoading ? Center(child: CircularProgressIndicator()): Column(
            children: [
              MainHeader(
                title: assetsDetails.tokenName,
                subTitle: replaceMiddleWithDotsCollectionId(assetsDetails.tokenId),
                showSubTitle: true,
              ),
              SizedBox(height: 3.h),
              Expanded(
                child: Container(
                  // color: Colors.red,
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.sp),
                      // color: Colors.red,
                      height: 47.h,
                      width: 45.h,
                      child:
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.sp),
                        child: Image.network(assetsDetails.image, fit: BoxFit.cover,
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
                     details: formatDate(assetsDetails.createdAt),
                     isDark: themeNotifier.isDark ? true : false,
                   ),
                   // // nftsDetailsWidget(
                   // //   title: 'Status:'.tr(),
                   // //   details: args["status"] ?? 'N/A',
                   // //   isDark: themeNotifier.isDark ? true : false,
                   // // ),
                   nftsDetailsWidget(
                       title: 'Token ID:'.tr(),
                       func:()=>  Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => MjrWebviewExplored(
                             url: "https://www.mjraexplorer.com/nft/" + assetsDetails.tokenId,
                           ),
                         ),
                       ),
                       details:
                       replaceMiddleWithDotsCollectionId(assetsDetails.tokenId),
                       // replaceMiddleWithDotsCollectionId(args["tokenId"]),
                       isDark: themeNotifier.isDark ? true : false,
                       color:  AppColors.textColorToska
                   ),

                   if (assetsDetails.creatorName != null)
                     nftsDetailsWidget(
                       title: 'Creator:'.tr(),
                       func:()=>  Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => MjrWebviewExplored(
                             url: "https://www.mjraexplorer.com/address/"+ assetsDetails.creatorName,
                           ),
                         ),
                       ),
                       details: replaceMiddleWithDots(assetsDetails.creatorName) ?? "N/A",
                       isDark: themeNotifier.isDark ? true : false,
                       color: AppColors.textColorToska,
                     ),
                   if (assetsDetails.creatorRoyalty!= "null")
                     nftsDetailsWidget(
                       title: 'Creator royalty:'.tr(),
                       details: assetsDetails.creatorRoyalty + '%',
                       isDark: themeNotifier.isDark ? true : false,
                     ),
                   if (assetsDetails.ownerName!= "null")
                     nftsDetailsWidget(
                       title: 'Owned by:'.tr(),
                       details: assetsDetails.ownerName,
                       // replaceMiddleWithDots(args["ownerId"]) ?? "N/A",
                       isDark: themeNotifier.isDark ? true : false,
                       color: AppColors.textColorToska,
                     ),
                   // // if (args["nftIds"] != "null")
                   // //   nftsDetailsWidget(
                   // //     title: 'Collection Items:'.tr(),
                   // //     details: args["nftIds"],
                   // //     isDark: themeNotifier.isDark ? true : false,
                   // //   ),
                   if (assetsDetails.status!= "null")
                     nftsDetailsWidget(
                       title: 'Token Status:'.tr(),
                       details: assetsDetails.status,
                       isDark: themeNotifier.isDark ? true : false,
                     ),
                   if (assetsDetails.listingType != "null")
                     nftsDetailsWidget(
                       title: 'Listing Type:'.tr(),
                       details: assetsDetails.listingType,
                       isDark: themeNotifier.isDark ? true : false,
                     ),
                   if (assetsDetails.isListable != "null")
                     nftsDetailsWidget(
                       title: 'Is Listable:'.tr(),
                       details: assetsDetails.isListable,
                       isDark: themeNotifier.isDark ? true : false,
                     ),
                   nftsDetailsWidget(
                     title: 'Token Standard:'.tr(),
                     details:assetsDetails.standard,
                     isDark: themeNotifier.isDark ? true : false,
                   ),
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
                  ],),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ));
    });
  }

  Widget nftsDetailsWidget(
      {required String title,
      required String details,
      Color? color,
      bool isDark = true,
      Function? func
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
            onTap: ()=>func!(),
            child: Container(
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
          ),
        ],
      ),
    );
  }
}
