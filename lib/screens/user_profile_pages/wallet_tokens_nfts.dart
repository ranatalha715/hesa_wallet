import 'dart:ui';
import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesa_wallet/providers/transaction_provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/widgets/nfts_collection_divisions/nfts_collections_division.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../constants/app_deep_linking.dart';
import '../../constants/string_utils.dart';
import '../../main.dart';
import '../../providers/assets_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/app_drawer.dart';
import '../connection_requests_pages/connect_dapp.dart';
import '../unlock/unlock.dart';

class WalletTokensNfts extends StatefulWidget {
  static const routeName = 'nfts-page';
  const WalletTokensNfts({Key? key}) : super(key: key);
  @override
  State<WalletTokensNfts> createState() => _WalletTokensNftsState();
}
class _WalletTokensNftsState extends State<WalletTokensNfts>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  late TabController _tabController;
  final scrollcontroller = ScrollController();
  late FToast fToast;
  var _isSelected = 0;
  var accessToken;
  var _isinit = true;
  int selectedCategoryIndex = 0;
  bool _isloading = false;
  bool showCopiedMsg = false;
  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }

  var userWalletAddress;
  Future<void> init() async {
    setState(() {
      _isloading = true;
    });
    await getAccessToken();
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
    var user = await Provider.of<UserProvider>(context, listen: false);

    // await appLinksService.initializeAppLinks(
    //     user.walletAddress
    // );
    // await Provider.of<AssetsProvider>(context, listen: false).getListedAssets(
    //   token: accessToken,
    //   context: context,
    //   walletAddress: user.walletAddress!,
    //   ownerType: 'owner',
    //   type: 'all',
    //   isEnglish: isEnglish,
    // );
    // await Provider.of<AssetsProvider>(context, listen: false).getCreatedAssets(
    //   token: accessToken,
    //   context: context,
    //   walletAddress: user.walletAddress!,
    //   ownerType: 'creator',
    //   type: 'all',
    //   isEnglish: isEnglish,
    // );
    // await Provider.of<AssetsProvider>(context, listen: false).getOwnedAssets(
    //   token: accessToken,
    //   context: context,
    //   walletAddress: user.walletAddress!,
    //   ownerType: 'owner',
    //   type: 'all',
    //   isEnglish: isEnglish,
    // );
    // await Provider.of<AssetsProvider>(context, listen: false).getAllAssets(
    //   token: accessToken,
    //   context: context,
    //   walletAddress: user.walletAddress!,
    //   ownerType: 'both',
    //   type: 'all',
    //   isEnglish: isEnglish,
    // );
    setState(() {
      _isloading = false;
    });
    loadTabData(selectedCategoryIndex);
  }

  Future<void> loadTabData(int tabIndex) async {
    setState(() {
      _isloading = true;
    });

    var user = Provider.of<UserProvider>(context, listen: false);

    switch (tabIndex) {
      case 0:
        await Provider.of<AssetsProvider>(context, listen: false).getAllAssets(
          token: accessToken,
          context: context,
          walletAddress: user.walletAddress!,
          ownerType: 'both',
          type: 'all',
          isEnglish: true,
        );
        break;
      case 1:
        await Provider.of<AssetsProvider>(context, listen: false).getOwnedAssets(
          token: accessToken,
          context: context,
          walletAddress: user.walletAddress!,
          ownerType: 'owner',
          type: 'all',
          isEnglish: true,
        );
        break;
      case 2:
        await Provider.of<AssetsProvider>(context, listen: false).getCreatedAssets(
          token: accessToken,
          context: context,
          walletAddress: user.walletAddress!,
          ownerType: 'creator',
          type: 'all',
          isEnglish: true,
        );
        break;
      case 3:
        await Provider.of<AssetsProvider>(context, listen: false).getListedAssets(
          token: accessToken,
          context: context,
          walletAddress: user.walletAddress!,
          ownerType: 'owner',
          type: 'all',
          isEnglish: true,
        );
        break;
    }
    setState(() {
      _isloading = false;
    });
  }

  void onTabChanged(int index) {
    setState(() {
      selectedCategoryIndex = index;
    });
    loadTabData(index);
  }


  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final passcode = prefs.getString('passcode');
    final setLockScreen = prefs.getBool('setLockScreen') ?? false;
    return {
      'passcode': passcode,
      'setLockScreen': setLockScreen,
    };
  }

  setLockScreenStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('setLockScreen', value);
  }

  bool _isPasscodeSet = false;

  getPasscode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final passcode = prefs.getString('passcode') ?? '';
    if (passcode != "") {
      _isPasscodeSet = true;
    } else {
      _isPasscodeSet = false;
    }
  }

  @override
  void initState() {
    super.initState();
    getPasscode();
    // initUniLinks1();
    // AppDeepLinking().openNftApp({});
    // AppDeepLinking().initDeeplink();
    _tabController = TabController(length: 2, vsync: this);
     init();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
      AppColors.profileHeaderDark,
    ));
    callRedDotLogic();
  }

  var savedShowRedDot;
  callRedDotLogic() async {
    final prefs = await SharedPreferences.getInstance();
    savedShowRedDot = prefs.getBool('showRedDot') ?? false;
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.profileHeaderDark,
    ));
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isinit) {
      init();
    }
    _isinit = false;
    super.didChangeDependencies();
  }
  void onCategorySelected(int index) {
    setState(() {
      selectedCategoryIndex = index;
    });
  }

  void handleDisconnection1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('disconnectionTime', DateTime.now().toString());
    await prefs.setBool('isConnected', false);
    setState(() {});
    await Future.delayed(Duration(seconds: 2), () {});
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert!'.tr()),
          content: Text('Disconnected Successfully'.tr()),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
   handleDisconnection() async {
    print('handling disconnection');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('disconnectionTime', DateTime.now().toString());
    await prefs.setBool('isConnected', false);
    setState(() {});
    await Future.delayed(Duration(seconds: 1), () {});
    return Dialog(
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
            8.0),
      ),
      backgroundColor:
      Colors
          .transparent,
      child:
      BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX:
              7,
              sigmaY:
              7),
          child:
          Container(
            height:
            23.h,
            width:
            100,
            decoration:
            BoxDecoration(
              color:  AppColors.errorColor ,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textColorBlack.withOpacity(0.95),
                  offset: Offset(0, 0),
                  blurRadius: 10,
                  spreadRadius: 0.4,
                ),
              ],
            ),
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 4.h,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    "assets/images/disconnect.png",
                    height: 5.h,
                    color: AppColors
                        .textColorWhite,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Your wallet has been disconnected'.tr(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp, color: AppColors.textColorWhite),
                ),
                SizedBox(
                  height: 4.h,
                ),
              ],
            ),
          )),
    );
  }

  Future<void> initUniLinks1() async {
    try {
      await getLinksStream().firstWhere((String? link) {
        if (link != null) {
          Uri uri = Uri.parse(link);
          String? operation = uri.queryParameters['operation'];
          String? logoFromNeo = uri.queryParameters['logo'];
          String? siteUrl = uri.queryParameters['siteUrl'];
          if (operation != null && operation == 'connectWallet') {
            Provider.of<UserProvider>(context, listen: false)
                .navigateToNeoForConnectWallet = true;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ConnectDapp()),
                  (Route<dynamic> route) => false,
            );
            Provider.of<TransactionProvider>(context, listen: false)
                .logoFromNeo = logoFromNeo;
            Provider.of<TransactionProvider>(context, listen: false).siteUrl =
                siteUrl;
          } else if (operation != null && operation == 'disconnectWallet') {
            handleDisconnection1();
          } else {
            Provider.of<UserProvider>(context, listen: false)
                .navigateToNeoForConnectWallet = false;
          }
          return true;
        } else {
          Provider.of<UserProvider>(context, listen: false)
              .navigateToNeoForConnectWallet = false;
        }
        return false;
      });
    } catch (e) {
    }
  }

  bool showLockedScreen = false;

  @override
  Widget build(BuildContext context) {
    final nftsAll =
        Provider.of<AssetsProvider>(context, listen: false).assetsAll;
    final nftsCollectionAll =
        Provider.of<AssetsProvider>(context, listen: false).assetsCollectionAll;
    final nftsListed =
        Provider.of<AssetsProvider>(context, listen: false).assetsListed;
    final collectionListed = Provider.of<AssetsProvider>(context, listen: false)
        .assetsCollectionListed;
    final nftsCreated =
        Provider.of<AssetsProvider>(context, listen: false).assetsCreated;
    final nftsCollectionCreated =
        Provider.of<AssetsProvider>(context, listen: false)
            .assetsCollectionCreated;
    final nftsOwned =
        Provider.of<AssetsProvider>(context, listen: false).assetsOwned;
    final nftsCollectionOwnedByUser =
        Provider.of<AssetsProvider>(context, listen: false)
            .assetsCollectionOwned;
    print(Provider.of<TransactionProvider>(context, listen: false).showRedDot);
    return Consumer<UserProvider>(builder: (context, user, child) {
      return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
        return Stack(
          children: [
            FutureBuilder<Map<String, dynamic>>(
                future: getSettings(),
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    if (snapshot.hasData) {
                      final passcode = snapshot.data!['passcode'] as String?;
                      final setLockScreen =
                      snapshot.data!['setLockScreen'] as bool;
                      print("setLockScreen && passcode");
                      print(setLockScreen.toString() + passcode.toString());
                      if (setLockScreen
                      || Provider.of<TransactionProvider>(context, listen: false).showRedDot
                      // passcode != null &&
                      // passcode.isNotEmpty
                      ) {
                        return Unlock();
                        // return WelcomeScreen(handler: (){});
                        // Navigate to the pin screen
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => WelcomeScreen(
                          //             handler: () {},
                          //           )),
                          // );
                        });
                      }
                    }
                  }
                  return Scaffold(
                    key: _key,
                    drawer: AppDrawer(),
                    backgroundColor: themeNotifier.isDark
                        ? AppColors.backgroundColor
                        : AppColors.textColorWhite,
                    body: Stack(
                      children: [
                        SafeArea(
                          child: NestedScrollView(
                            headerSliverBuilder: (context, innerBoxIsScrolled) => [
                              SliverOverlapAbsorber(
                                  handle: NestedScrollView
                                      .sliverOverlapAbsorberHandleFor(context),
                                  sliver: SliverSafeArea(
                                    top: false,
                                    sliver:
                                    SliverAppBar(
                                      expandedHeight: 29.h,
                                      collapsedHeight: 8.h,
                                      backgroundColor: AppColors.backgroundColor,
                                      elevation: 0,
                                      pinned: true,
                                      floating: false,
                                      snap: false,
                                      stretch: true,
                                      leading: Stack(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: 10.sp,
                                              left: 14.sp,
                                              right: 20.sp,
                                              bottom: 8.sp,
                                            ),
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _key.currentState!.openDrawer(),
                                              child:
                                                  Icon(
                                                    Icons.menu_rounded,
                                                    color: themeNotifier.isDark
                                                        ? AppColors.textColorWhite
                                                        : AppColors.textColorBlack,
                                                    size: 25.sp,
                                                  ),
                                            ),
                                          ),
                                          Consumer<TransactionProvider>(builder:
                                              (context, TransactionProvider trP,
                                              _) {
                                            return Positioned(
                                              right: 10,
                                              top: 12,
                                              child: Container(
                                                height: 4.3.sp,
                                                width: 4.3.sp,
                                                decoration: BoxDecoration(
                                                  color:
                                                  trP.showRedDot
                                                      ? AppColors.errorColor
                                                      : Colors.transparent,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      10.sp),
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                      actions: [
                                        GestureDetector(
                                          onTap: () {
                                            setLockScreenStatus(true);
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Unlock()),
                                                  (Route<dynamic> route) =>
                                              false,
                                            );
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                bottom: 5.sp, right: 15.sp),
                                            child: Image.asset(
                                              "assets/images/lock.png",
                                              height: 19.sp,
                                              width: 19.sp,
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack,
                                            ),
                                          ),
                                        ),
                                      ],
                                      flexibleSpace: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: AppColors.profileHeaderDark,
                                        ),
                                        child: FlexibleSpaceBar(
                                            collapseMode: CollapseMode.parallax,
                                            expandedTitleScale: 1,
                                            stretchModes: [
                                            ],
                                            background: Stack(
                                              children: [
                                                Positioned(
                                                    top: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Container(
                                                      color: AppColors
                                                          .profileHeaderDark,
                                                      height: 10.h,
                                                    ),
                                                ),
                                                Positioned(
                                                  top: 63,
                                                  left: 0,
                                                  right: 0,
                                                  child: Container(
                                                    color:
                                                    AppColors.backgroundColor,
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          height: 2.h,
                                                        ),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              color: AppColors
                                                                  .textColorGrey,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  100)
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets.all(
                                                                1.sp),
                                                            child: Container(
                                                              height: 60.sp,
                                                              width: 60.sp,
                                                              decoration: BoxDecoration(
                                                                  color: AppColors
                                                                      .backgroundColor,
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      100)),
                                                              child: Padding(
                                                                padding:
                                                                EdgeInsets.all(
                                                                    1.sp),
                                                                child: ClipRRect(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      100),
                                                                  child:
                                                                  user.userAvatar !=
                                                                      null
                                                                      ? Image
                                                                      .network(
                                                                    user.userAvatar!,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                      : Padding(
                                                                    padding:
                                                                    EdgeInsets.all(4.sp),
                                                                    child:
                                                                    Image.asset(
                                                                      "assets/images/user_placeholder.png",
                                                                      color:
                                                                      AppColors.textColorGrey,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 2.h,
                                                        ),

                                                        Text(
                                                          user.userName != null
                                                              ? user.userName!
                                                              : 'username.mjra'
                                                              .tr(),
                                                          style: TextStyle(
                                                              fontSize: 11.7.sp,
                                                              fontFamily:
                                                              'Blogger Sans',
                                                              fontWeight:
                                                              FontWeight.w700,
                                                              color: themeNotifier
                                                                  .isDark
                                                                  ? AppColors
                                                                  .textColorWhite
                                                                  : AppColors
                                                                  .textColorBlack),
                                                        ),
                                                        SizedBox(
                                                          height: 0.5.h,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () => _copyToClipboard(user.walletAddress!),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                user.walletAddress != null
                                                                    ? truncateTo13Digits(user.walletAddress!)
                                                                    : "...",
                                                                style: TextStyle(
                                                                  fontSize: 9.5.sp,
                                                                  fontFamily: 'Blogger Sans',
                                                                  fontWeight: FontWeight.w500,
                                                                  color: AppColors.textColorGrey,
                                                                ),
                                                              ),
                                                              SizedBox(width: 3),
                                                              Icon(
                                                                Icons.copy,
                                                                size: 10.sp, // Adjust the size as needed
                                                                color: AppColors.textColorGrey,
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        SizedBox(
                                                          height: 8.h,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                  )),
                              SliverPersistentHeader(
                                  pinned: true,
                                  delegate: FixedHeaderDelegate(
                                      tabController: _tabController)
                              ),
                            ],
                            body: TabBarView(controller: _tabController, children: [
                              CustomScrollView(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                slivers: [
                                  SliverList(
                                    delegate: SliverChildListDelegate([
                                      _isloading
                                          ? Container(
                                          height: 50.h,
                                          child: Center(
                                              child: LoaderBluredScreen()))
                                          : Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20.h,
                                        ),
                                        child: Text(
                                          "You have no Tokens".tr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: themeNotifier.isDark
                                                  ? AppColors
                                                  .textColorGreyShade2
                                                  : AppColors.textColorBlack,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12.sp,
                                              fontFamily: 'Blogger Sans'),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                              CustomScrollView(
                                slivers: [
                                  SliverList(
                                    delegate: SliverChildListDelegate([
                                  Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                              height: 8.h,
                                              width: 100.w,
                                              color: themeNotifier.isDark
                                                  ? AppColors.backgroundColor
                                                  : AppColors.textColorWhite,
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                Axis.horizontal,
                                                child: Padding(
                                                  padding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 16.sp,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      NFTCategoryWidget(
                                                        title: "All".tr(),
                                                        isFirst: true,
                                                        index: 0,
                                                        handler: (){
                                                            onCategorySelected(
                                                                0);
                                                            onTabChanged(0);
                                                            ;}
                                                      ),
                                                      NFTCategoryWidget(
                                                          title: "Owned".tr(),
                                                          index: 1,
                                                          handler: () {
                                                            // setState(() {
                                                            //   _isloading =
                                                            //   true;
                                                            // });
                                                            onCategorySelected(
                                                                1);
                                                            // setState(() {
                                                            //   _isloading =
                                                            //   false;
                                                            // });
                                                            onTabChanged(1);
                                                          }),
                                                      NFTCategoryWidget(
                                                        title: "Created".tr(),
                                                        index: 2,
                                                        handler: () {
                                                            onCategorySelected(
                                                                2);
                                                            onTabChanged(2);
                                                        }
                                                      ),
                                                      NFTCategoryWidget(
                                                        title: "Listed".tr(),
                                                        index: 3,
                                                        handler: (){
                                                            onCategorySelected(3);
                                                            onTabChanged(3);
                                                        }
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )),
                                          _isloading
                                              ? Container(
                                            height: 50.h,
                                            child: Center(
                                                child: LoaderBluredScreen()),
                                          ) :
                                          Container(
                                            child: bottomSpaceContent(
                                              nftsCollectionAll,
                                              nftsAll,
                                              nftsCollectionOwnedByUser,
                                              nftsOwned,
                                              themeNotifier.isDark,
                                              nftsCollectionCreated,
                                              nftsCreated,
                                              nftsListed,
                                              collectionListed,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                            ]),
                          ),
                        ),
                        // if (_isloading)
                        //   Positioned(
                        //     top: 12.h,
                        //     bottom: 0,
                        //     left: 0,
                        //     right: 0,
                        //     child: LoaderBluredScreen(),)
                      ],
                    ),
                  );
                }),

          ],
        );
      });
    });
  }
  Widget NFTCategoryWidget(
      {required String title,
        Function? handler,
        bool isFirst = false,
        required int index}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = index;
        });
        handler!();
      },
      child: Container(
        margin: EdgeInsets.only(right: 10.sp),
        decoration: BoxDecoration(
            color: _isSelected == index
                ? AppColors.hexaGreen.withOpacity(0.10)
                : AppColors.profileHeaderDark,
            border: Border.all(
                color: _isSelected == index
                    ? AppColors.hexaGreen
                    : Colors.transparent,
                width: 1),
            borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 13.sp, vertical: 8.sp),
          child: Row(
            children: [
              if (!isFirst)
                SizedBox(
                  width: 4.sp,
                ),
              Text(
                title,
                style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: _isSelected == index
                        ? AppColors.hexaGreen
                        : AppColors.textColorGreyShade2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomSpaceContent(
      var nftsCollectionAll,
      var nftsAll,
      var nftsCollectionOwnedByUser,
      var nftsOwned,
      var isDark,
      var nftsCollectionCreated,
      var nftsCreated,
      var nftsListed,
      var nftsCollectionListed,
      ) {
    switch (selectedCategoryIndex) {
      case 0:
        return NftsCollectionDivision(
            nftsCollection: nftsCollectionAll,
            nfts:
            nftsAll);
      case 1:
        return NftsCollectionDivision(
          nftsCollection: nftsCollectionOwnedByUser,
          nfts: nftsOwned,
        );

      case 2:
        return NftsCollectionDivision(
          nftsCollection: nftsCollectionCreated,
          nfts: nftsCreated,
        );
      case 3:
        return NftsCollectionDivision(
          nftsCollection: nftsCollectionListed,
          nfts: nftsListed,
        );
      default:
        return Container();
    }
  }
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      showCopiedMsg = true;
    });
    Future.delayed(Duration(milliseconds: 3000), () {
      setState(() {
        showCopiedMsg = false;
      });
    });
  }
}
class FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  TabController tabController;
  FixedHeaderDelegate({required this.tabController});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.backgroundColor,
      child: Column(
        children: [
          TabBar(
            controller: tabController,
            indicatorColor: AppColors.activeButtonColor,
            unselectedLabelColor: AppColors.textColorGrey,
            labelColor: AppColors.textColorWhite,
            labelStyle: TextStyle(
                color: AppColors.textColorWhite,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: "     " + 'Tokens'.tr() + "     "),
              Tab(text: "      " + 'NFTs'.tr() + "       "),
            ],
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => kToolbarHeight;
  @override
  double get minExtent =>
      kToolbarHeight;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}