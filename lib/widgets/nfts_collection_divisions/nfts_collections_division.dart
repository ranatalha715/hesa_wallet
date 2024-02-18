import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../models/nfts_model.dart';
import '../../providers/nfts_provider.dart';
import '../../providers/theme_provider.dart';
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
  bool isOpenCollection = false;
  bool isOpenNfts = false;
  // bool isDark = true;

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
                handler: () =>
                    setState(() {
                      isOpenCollection = !isOpenCollection;
                      print(isOpenCollection);
                    }),
                isOpened: isOpenCollection,
              ),
              if(isOpenCollection)
                  widget.nftsCollection.length==0 ?
                  Center(
                    child: Padding(
                      padding:  EdgeInsets.symmetric(vertical: 7.h, horizontal: 20.w),
                      child:
                      Text(
                        "You have no NFT Collections",
                        style: TextStyle(
                            color: themeNotifier.isDark
                                ? AppColors.textColorGreyShade2
                                : AppColors.textColorBlack,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            fontFamily: 'Blogger Sans'),
                      ),
                    ),
                  ):
              Container(
                child: GridView.count(
                  controller: scrollcontroller,
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  padding: EdgeInsets.only(
                      left: 14.sp, right: 14.sp, bottom: 12.sp, top: 12.sp),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1 / 1.3,
                  // Number of columns in the grid
                  children: List.generate(
                      widget.nftsCollection.length,
                      // Number of images in the grid
                          (index) =>
                          NftsCollectionDesign(
                            nftsCollection: widget.nftsCollection[index],
                          )),
                ),
              ),
              if(!isOpenCollection)
              SizedBox(height: 2.h,),
              WalletNftsTitles(
                title: 'NFTs'.tr(),
                isDark: themeNotifier.isDark,
                length: widget.nfts.length,
                handler: () =>
                    setState(() {
                      isOpenNfts = !isOpenNfts;
                    }),
                isOpened: isOpenNfts,
              ),

              if(isOpenNfts)
                widget.nfts.length==0 ?
                  Center(
                    child: Padding(
                      padding:  EdgeInsets.symmetric(vertical: 7.h, horizontal: 20.w),
                      child: Text(
                        "You have no NFTs",
                        style: TextStyle(
                            color: themeNotifier.isDark
                                ? AppColors.textColorGreyShade2
                                : AppColors.textColorBlack,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            fontFamily: 'Blogger Sans'),
                      ),
                    ),
                  ):
              Container(
                child: GridView.count(
                  controller: scrollcontroller,
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  padding: EdgeInsets.only(
                      left: 14.sp, right: 14.sp, bottom: 12.sp, top: 12.sp),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1 / 1.3,
                  // Number of columns in the grid
                  children: List.generate(
                      widget.nfts.length,
                      // Number of images in the grid
                          (index) =>
                          NftsDesign(
                            nfts: widget.nfts[index],
                          )),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
