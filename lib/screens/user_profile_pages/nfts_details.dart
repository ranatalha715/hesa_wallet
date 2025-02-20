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
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../constants/colors.dart';
import '../../constants/string_utils.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/main_header.dart';

class NftsDetails extends StatefulWidget {
  const NftsDetails();

  static const routeName = 'nfts_details';

  @override
  State<NftsDetails> createState() => _NftsDetailsState();
}

class _NftsDetailsState extends State<NftsDetails> {
  var accessToken;
  var _isInit = true;

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  var isLoading = false;
  final scrollController = ScrollController();

  @override
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
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(milliseconds: 500), () {
    });

    if (_isInit) {
      final args = await ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>?;
      await getAccessToken();
      Locale currentLocale = context.locale;
      bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
      await Provider.of<AssetsProvider>(context, listen: false)
          .getNftCollectionDetails(
        token: accessToken,
        type: 'nft',
        id: args!["tokenId"],
        isEnglish: isEnglish,
      );
    }
    _isInit = false;
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
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: Column(
                children: [
                  MainHeader(
                    title:
                        isLoading ? 'NFT Name'.tr() : assetsDetails.tokenName,
                    subTitle: isLoading
                        ? '.......'
                        : truncateTo13Digits(
                            assetsDetails.tokenId),
                    showSubTitle: true,
                  ),
                  // SizedBox(height: 3.h),
                  Expanded(
                    child: Container(
                      // color: Colors.red,
                      child: isLoading
                          ? Container(
                              height: 88.h,
                              width: double.infinity,
                              color: Colors.black,
                            )
                          : ListView(
                              controller: scrollController,
                              padding: EdgeInsets.only(top: 2.h),
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 10.sp,
                                  ),
                                  // color: Colors.red,
                                  height: 47.h,
                                  width: 45.h,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.sp),
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
                                  // Image.asset(
                                  //   "assets/images/nfts_placeholder.png",
                                  //   fit: BoxFit.cover,
                                  // ),
                                ),
                                Divider(
                                    color: AppColors.transactionSummNeoBorder),
                                SizedBox(height: 2.h),
                                nftsDetailsWidget(
                                    title: 'Created:'.tr(),
                                    details:
                                        formatDate(assetsDetails.createdAt),
                                    isDark: themeNotifier.isDark ? true : false,
                                    isEnglish: isEnglish),
                                // // nftsDetailsWidget(
                                // //   title: 'Status:'.tr(),
                                // //   details: args["status"] ?? 'N/A',
                                // //   isDark: themeNotifier.isDark ? true : false,
                                // // ),
                                nftsDetailsWidget(
                                    title: 'Token ID:'.tr(),
                                    func: () => _launchURL(
                                        "https://www.mjraexplorer.com/nft/" +
                                            assetsDetails.tokenId),
                                    details: truncateTo13Digits(
                                        assetsDetails.tokenId),
                                    // replaceMiddleWithDotsCollectionId(args["tokenId"]),
                                    isDark: themeNotifier.isDark ? true : false,
                                    isEnglish: isEnglish,
                                    color: AppColors.textColorToska),
                                if (assetsDetails.collectionId != "" &&
                                    assetsDetails.collectionId != null)
                                  nftsDetailsWidget(
                                    title: 'Collection ID:'.tr(),
                                    func: () =>
                                        _launchURL(
                                            "https://www.mjraexplorer.com/collection/" +
                                                assetsDetails.collectionId),
                                    details: truncateTo13Digits(
                                        assetsDetails.collectionId),
                                    isDark: themeNotifier.isDark ? true : false,
                                    isEnglish: isEnglish,
                                      color: AppColors.textColorToska,
                                  ),
                                if (assetsDetails.creatorRoyalty != "null")
                                  nftsDetailsWidget(
                                    title: 'Creator royalty:'.tr(),
                                    details: assetsDetails.creatorRoyalty + '%',
                                    isDark: themeNotifier.isDark ? true : false,
                                    isEnglish: isEnglish,
                                  ),
                                if (assetsDetails.numberOfEdtions != null &&
                                    assetsDetails.numberOfEdtions == '' &&
                                    assetsDetails.numberOfEdtions == 'Unknown')
                                  nftsDetailsWidget(
                                    title: 'Editions:'.tr(),
                                    details: assetsDetails.numberOfEdtions,
                                    isDark: themeNotifier.isDark ? true : false,
                                    isEnglish: isEnglish,
                                  ),
                                if (assetsDetails.creatorName != null)
                                  nftsDetailsWidget(
                                    title: 'Creator:'.tr(),
                                    func: () => _launchURL(
                                        "https://www.mjraexplorer.com/address/" +
                                            assetsDetails.creatorAddress),
                                    details: truncateTo13Digits(
                                            assetsDetails.creatorName) ??
                                        "N/A",
                                    isDark: themeNotifier.isDark ? true : false,
                                    isEnglish: isEnglish,
                                    color: AppColors.textColorToska,
                                  ),
                                if (assetsDetails.ownerName != "null" &&
                                    assetsDetails.ownerName == '' &&
                                    assetsDetails.ownerName == 'Unknown')
                                  nftsDetailsWidget(
                                    title: 'Owned by:'.tr(),
                                    func: () => _launchURL(
                                        "https://www.mjraexplorer.com/address/" +
                                            assetsDetails.ownerAddress),
                                    details: assetsDetails.ownerName,
                                    // replaceMiddleWithDots(args["ownerId"]) ?? "N/A",
                                    isDark: themeNotifier.isDark ? true : false,
                                    color: AppColors.textColorToska,
                                    isEnglish: isEnglish,
                                  ),
                                // if (args["nftIds"] != "null")
                                //   nftsDetailsWidget(
                                //     title: 'Collection Items:'.tr(),
                                //     details: args["nftIds"],
                                //     isDark: themeNotifier.isDark ? true : false,
                                //   ),
                                if (assetsDetails.status != "null")
                                  nftsDetailsWidget(
                                    title: 'Token Status:'.tr(),
                                    details: assetsDetails.status,
                                    isDark: themeNotifier.isDark ? true : false,
                                    isEnglish: isEnglish,
                                  ),
                                if (assetsDetails.listingType != "null" &&
                                    assetsDetails.listingType == '' &&
                                    assetsDetails.listingType == 'Unknown')
                                  nftsDetailsWidget(
                                    title: 'Listing Type:'.tr(),
                                    details: assetsDetails.listingType,
                                    isDark: themeNotifier.isDark ? true : false,
                                    isEnglish: isEnglish,
                                  ),
                                if (assetsDetails.collectionName != "null")
                                  nftsDetailsWidget(
                                    title: 'Collection Name:'.tr(),
                                    details: assetsDetails.collectionName,
                                    isDark: themeNotifier.isDark ? true : false,
                                    isEnglish: isEnglish,
                                    color: AppColors.collectionName,
                                  ),
                                if (assetsDetails.isListable != "null")
                                  nftsDetailsWidget(
                                    title: 'Listable status:'.tr(),
                                    details: assetsDetails.isListable == 'true'
                                        ? 'Listable'
                                        : 'Not Listable',
                                    isDark: themeNotifier.isDark ? true : false,
                                    isEnglish: isEnglish,
                                  ),
                                nftsDetailsWidget(
                                  title: 'Token Standard:'.tr(),
                                  details: assetsDetails.standard,
                                  isDark: themeNotifier.isDark ? true : false,
                                  isEnglish: isEnglish,
                                ),
                                nftsDetailsWidget(
                                  title: 'Blockchain:'.tr(),
                                  details: assetsDetails.chain,
                                  isDark: themeNotifier.isDark ? true : false,
                                  isEnglish: isEnglish,
                                ),
                                if (assetsDetails.burnable != "null")
                                  nftsDetailsWidget(
                                    title: 'Burnable status:'.tr(),
                                    details: assetsDetails.burnable == "true"
                                        ? "Enabled"
                                        : "Disabled",
                                    isDark: themeNotifier.isDark ? true : false,
                                    isEnglish: isEnglish,
                                  ),
                                SizedBox(
                                  height: 2.h,
                                ),
                              ],
                            ),
                    ),
                  ),
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

  Widget nftsDetailsWidget(
      {required String title,
      required String details,
      Color? color,
      bool isDark = true,
      bool isEnglish = true,
      Function? func}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp, left: 20.sp, right: 20.sp),
      child: Row(
        children: [
          Container(
            width: 38.w,
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
              child: Align(
                alignment:
                    isEnglish ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  details,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
