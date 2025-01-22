import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/configs.dart';
import '../../models/nfts_model.dart';
import '../../providers/assets_provider.dart';
import '../../providers/nfts_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../nft_collections_design.dart';
import '../nfts_design.dart';
import '../wallet_nfts_titles.dart';

class NftsCollectionDivision extends StatefulWidget {
  List<NftsCollectionModel> nftsCollection;
  List<NftsModel> nfts;

  NftsCollectionDivision({
    required this.nftsCollection,
    required this.nfts,
  });

  @override
  State<NftsCollectionDivision> createState() => _NftsCollectionDivisionState();
}

class _NftsCollectionDivisionState extends State<NftsCollectionDivision> {
  final scrollcontroller = ScrollController();
  final scrollController = ScrollController();
  bool isOpenCollection = false;
  bool isOpenNfts = false;
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreItems = true;
  var accessToken;
  var userWalletAddress;

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    init();
  }

  Future<void> init() async {
    await getAccessToken();
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
    var user = await Provider.of<UserProvider>(context, listen: false);
    userWalletAddress = user.walletAddress;
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
        hasMoreItems &&
        !isLoadingMore) {
      loadMoreData();
    }
  }

  Future<void> loadMoreData() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });
    var user = await Provider.of<UserProvider>(context, listen: false);
    userWalletAddress = user.walletAddress;
    try {
      await Provider.of<AssetsProvider>(context, listen: false).getAllAssets(
        token: accessToken,
        context: context,
        walletAddress: user.walletAddress!,
        ownerType: 'both',
        type: 'all',
        isEnglish: true,
      );

      setState(() {
        currentPage ++; // Increment page for the next fetch
      });
    } catch (error) {
      print("Error loading more data: $error");
    } finally {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Container(
        // color: Colors.yellow,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WalletNftsTitles(
                title: 'NFT Collections'.tr(),
                isDark: themeNotifier.isDark,
                length: widget.nftsCollection.length,
                handler: () => setState(() {
                  isOpenCollection = !isOpenCollection;
                  print(isOpenCollection);
                }),
                isOpened: isOpenCollection,
              ),
              if (isOpenCollection)
                widget.nftsCollection.length == 0
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 7.h, horizontal: 20.w),
                          child: Text(
                            "You have no NFT Collections".tr(),
                            style: TextStyle(
                                color: themeNotifier.isDark
                                    ? AppColors.textColorGreyShade2
                                    : AppColors.textColorBlack,
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                                fontFamily: 'Blogger Sans'),
                          ),
                        ),
                      )
                    : Container(
                        child: GridView.count(
                          controller: scrollcontroller,
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          padding: EdgeInsets.only(
                              left: 14.sp,
                              right: 14.sp,
                              bottom: 12.sp,
                              top: 12.sp),
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 1 / 1.3,
                          // Number of columns in the grid
                          children: List.generate(
                              widget.nftsCollection.length,
                              // Number of images in the grid
                              (index) => NftsCollectionDesign(
                                    nftsCollection:
                                        widget.nftsCollection[index],
                                  )),
                        ),
                      ),
              if (!isOpenCollection)
                SizedBox(
                  height: 2.h,
                ),
              WalletNftsTitles(
                title: 'NFTs'.tr(),
                isDark: themeNotifier.isDark,
                length: widget.nfts.length,
                handler: () => setState(() {
                  isOpenNfts = !isOpenNfts;
                }),
                isOpened: isOpenNfts,
              ),
              if (!isOpenNfts)
                SizedBox(
                  height: 3.h,
                ),
              if (isOpenNfts)
                widget.nfts.length == 0
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 7.h, horizontal: 20.w),
                          child: Text(
                            "You have no NFTs".tr(),
                            style: TextStyle(
                                color: themeNotifier.isDark
                                    ? AppColors.textColorGreyShade2
                                    : AppColors.textColorBlack,
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                                fontFamily: 'Blogger Sans'),
                          ),
                        ),
                      )
                    : Container(
                        child:
                        GridView.count(
                          crossAxisCount: 2,
                          // This is a named argument.
                          controller: scrollController,
                          // Named argument.
                          shrinkWrap: true,
                          // Named argument.
                          padding: EdgeInsets.only(
                            left: 14.sp,
                            right: 14.sp,
                            bottom: 12.sp,
                            top: 12.sp,
                          ),
                          // Named argument.
                          crossAxisSpacing: 20,
                          // Named argument.
                          mainAxisSpacing: 20,
                          // Named argument.
                          childAspectRatio: 1 / 1.3,
                          // Named argument.
                          children: [
                            ...List.generate(
                              widget.nfts.length,
                              (index) => NftsDesign(
                                nfts: widget.nfts[index],
                              ),
                            ),
                            if (isLoadingMore)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(color:   AppColors.hexaGreen,),
                                ),
                              ),
                          ],
                        ),

                        // GridView.count(
                        //   controller: scrollcontroller,
                        //   shrinkWrap: true,
                        //   crossAxisCount: 2,
                        //   padding: EdgeInsets.only(
                        //       left: 14.sp, right: 14.sp, bottom: 12.sp, top: 12.sp),
                        //   crossAxisSpacing: 20,
                        //   mainAxisSpacing: 20,
                        //   childAspectRatio: 1 / 1.3,
                        //   // Number of columns in the grid
                        //   children: List.generate(
                        //       widget.nfts.length,
                        //       // Number of images in the grid
                        //           (index) =>
                        //           NftsDesign(
                        //             nfts: widget.nfts[index],
                        //           )),
                        // ),
                      ),
            ],
          ),
        ),
      );
    });
  }
}
