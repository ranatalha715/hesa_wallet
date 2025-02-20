import 'dart:async';
import 'dart:ui';
import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesa_wallet/providers/payment_fees.dart';
import 'package:hesa_wallet/providers/token_provider.dart';
import 'package:hesa_wallet/screens/settings/faq_&_support.dart';
import 'package:hesa_wallet/screens/unlock/set_confirm_pin_screen.dart';
import 'package:hesa_wallet/screens/user_profile_pages/nfts_details.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/dialog_button.dart';
import 'package:hesa_wallet/widgets/restart_widget.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:uni_links/uni_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hesa_wallet/constants/app_deep_linking.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:easy_localization/easy_localization.dart' as localized;
import 'package:hesa_wallet/providers/assets_provider.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/providers/bank_provider.dart';
import 'package:hesa_wallet/providers/card_provider.dart';
import 'package:hesa_wallet/providers/nfts_provider.dart';
import 'package:hesa_wallet/providers/theme_provider.dart';
import 'package:hesa_wallet/providers/transaction_provider.dart';
import 'package:hesa_wallet/providers/user_provider.dart';
import 'package:hesa_wallet/screens/connection_requests_pages/connect_dapp.dart';
import 'package:hesa_wallet/screens/signup_signin/signin_with_email.dart';
import 'package:hesa_wallet/screens/signup_signin/signup_with_email.dart';
import 'package:hesa_wallet/screens/signup_signin/terms_conditions.dart';
import 'package:hesa_wallet/screens/signup_signin/wallet.dart';
import 'package:hesa_wallet/screens/user_profile_pages/nfts_collection_details.dart';
import 'package:hesa_wallet/screens/user_profile_pages/transaction_summary.dart';
import 'package:hesa_wallet/screens/user_profile_pages/wallet_tokens_nfts.dart';
import 'package:hesa_wallet/screens/user_transaction_summaries_with_payment/transaction_req_acceptreject.dart';
import 'package:hesa_wallet/screens/user_transaction_summaries_with_payment/transaction_request.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:uni_links/uni_links.dart';
import 'constants/T&C.dart';
import 'constants/app_link_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
 final AppLinksService appLinksService =   AppLinksService(context: navigatorKey.currentContext!);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localized.EasyLocalization.ensureInitialized();
   // appLinksService = await AppLinksService(context: navigatorKey.currentContext!);
  // const AndroidInitializationSettings initializationSettingsAndroid =
  // const AndroidInitializationSettings initializationSettingsAndroid =
  // AndroidInitializationSettings('@mipmap/ic_launcher');
  // final InitializationSettings initializationSettings =
  // InitializationSettings(android: initializationSettingsAndroid);
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // HyperPay.init("", "");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
        // DevicePreview(Re Enter PIN
        // enabled: !kReleaseMode,
        // builder: (context) =>
        RestartWidget(child:
        MultiProvider(
            providers: [
          ChangeNotifierProvider(
            create: (_) => ThemeProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => AuthProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => UserProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => TransactionProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => AssetsProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => BankProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => NftsProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => CardProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => TokenProvider(),
          ),
          ChangeNotifierProvider(create: (_) => PaymentFees()),
        ],
            // DevicePreview(
            // enabled: !kReleaseMode,
            // builder: (context) =>
            child: localized.EasyLocalization(
                supportedLocales: const [
                  Locale('en', 'US'),
                  Locale('ar', 'AE')
                ],
                path: 'assets/translations',
                fallbackLocale: Locale('en', 'US'),
                saveLocale: true,
                child:
                    //   DevicePreview(
                    //  enabled: !kReleaseMode,
                    // builder: (context) =>
                    MyApp()))
    ));
    // );
    const channel = MethodChannel('com.example.hesa_wallet');
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final PageController _pageController = PageController(initialPage: 0);
  var accessToken = '';
  var refreshToken = '';

  Timer? _redDotTimer;
  late FToast fToast;
  bool isOverlayVisible = false;
  bool isWifiOn = true;
  bool fromNeoApp = false;
  var user;
  late final AppLinks _appLinks;




  Future<void> checkWifiStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isWifiOn = (connectivityResult == ConnectivityResult.wifi);
      isWifiOn = connectivityResult == ConnectivityResult.none ? false : true;
    });
    if (!isWifiOn) {
      noInternetDialog(context);
    }
  }
  Future<void> fetchActivities() async {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    await transactionProvider.getWalletActivitiesRedDOt(
      accessToken: accessToken,
      context: context,
      refresh: true,
      isEnglish: true,
    );

    if (transactionProvider.activitiesForRedDot.isNotEmpty) {
      final latestActivityTime = transactionProvider.activitiesForRedDot
          .map((activity) => DateTime.parse(activity.time))
          .reduce((a, b) => a.isAfter(b) ? a : b)
          .toIso8601String();
      await callRedDotLogic(latestActivityTime);
    } else {
    }
  }

  Future<void> callRedDotLogic(String latestActivityTime) async {
    final prefs = await SharedPreferences.getInstance();
    final storedActivityTime = prefs.getString('lastActivityTime') ?? '';
    final savedShowRedDot = prefs.getBool('showRedDot') ?? false;
    final savedConfirmedRedDot = prefs.getBool('confirmedRedDot') ?? false;
    if (storedActivityTime != latestActivityTime) {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      transactionProvider.showRedDot = true;
      transactionProvider.confirmedRedDot = true;
      await prefs.setString('lastActivityTime', latestActivityTime);
      await prefs.setBool('showRedDot', true);
      await prefs.setBool('confirmedRedDot', true);
    } else {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      transactionProvider.showRedDot = savedShowRedDot;
      transactionProvider.confirmedRedDot = savedConfirmedRedDot;
    }
  }
  Timer? _timer;
  StreamSubscription<String?>? _linkSubscription;

  void clearLinkStream() {
    getLinksStream()
        .drain();
  }

  // @override
  // initState()  {
  //   super.initState();
  //   generateFcmToken();
  //   AppDeepLinking().initDeeplink();
  //   WidgetsBinding.instance.addObserver(this);
  //   fToast = FToast();
  //   fToast.init(context);
  //   getAccessToken();
  //   Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
  //     checkWifiStatus();
  //   });
  //   Timer.periodic(Duration(seconds: 3), (timer) async {
  //     getAccessToken();
  //    Provider.of<TransactionProvider>(context,listen: false).initializeRedDotState();
  //        fetchActivities();
  //   });
  //   Timer.periodic(Duration(seconds: 30), (timer) async {
  //     await Provider.of<AuthProvider>(context, listen: false)
  //         .updateFCM(FCM: fcmToken, token: accessToken, context: context);
  //   });
  //   Timer.periodic(Duration(minutes: 25), (timer) async {
  //     await Provider.of<AuthProvider>(context, listen: false).refreshToken(
  //         refreshToken: refreshToken, context: context, token: accessToken);
  //   });
  // }
  @override
  void initState() {
    super.initState();
    generateFcmToken();
    AppDeepLinking().initDeeplink();
    WidgetsBinding.instance.addObserver(this);
    getAccessToken();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      checkWifiStatus();
    });
    Timer.periodic(Duration(seconds: 3), (timer) async {
      getAccessToken();
      Provider.of<TransactionProvider>(context, listen: false)
          .initializeRedDotState();
      fetchActivities();
    });
    Timer.periodic(Duration(seconds: 30), (timer) async {
      await Provider.of<AuthProvider>(context, listen: false)
          .updateFCM(FCM: fcmToken, token: accessToken, context: context);
    });
    Timer.periodic(Duration(minutes: 25), (timer) async {
      await Provider.of<AuthProvider>(context, listen: false).refreshToken(
          refreshToken: refreshToken, context: context, token: accessToken);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
    } else if (state == AppLifecycleState.resumed) {
    }
  }

  void handleDisconnection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('disconnectionTime', DateTime.now().toString());
    await prefs.setBool('isConnected', false);
    setState(() {});
    await Future.delayed(Duration(seconds: 2), () {});
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert!'),
          content: Text('Disconnected Successfully'),
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

  Future<void> initUniLinks() async {
    try {
      print('trying');
      await getLinksStream().firstWhere((String? link) {
        if (link != null) {
          Uri uri = Uri.parse(link);
          String? operation = uri.queryParameters['operation'];
          String? logoFromNeo = uri.queryParameters['logo'];
          String? siteUrl = uri.queryParameters['siteUrl'];
          print("print operation");
          print(operation);

          if (operation != null && operation == 'connectWallet') {
            Provider.of<UserProvider>(context, listen: false)
                .navigateToNeoForConnectWallet = true;

            Provider.of<TransactionProvider>(context, listen: false)
                .logoFromNeo = logoFromNeo;
            Provider.of<TransactionProvider>(context, listen: false).siteUrl =
                siteUrl;
            setState(() {
              isOverlayVisible = Provider.of<UserProvider>(context,
                      listen: false)
                  .navigateToNeoForConnectWallet; // Set overlay visibility to true
            });

            print("check kro" +
                Provider.of<UserProvider>(context, listen: false)
                    .navigateToNeoForConnectWallet
                    .toString());
          } else if (operation != null && operation == 'DisconnectWallet') {
            handleDisconnection();
          } else {
            Provider.of<UserProvider>(context, listen: false)
                .navigateToNeoForConnectWallet = false;

            setState(() {
              isOverlayVisible = Provider.of<UserProvider>(context,
                      listen: false)
                  .navigateToNeoForConnectWallet; // Set overlay visibility to false
            });
          }
          return true; // Exit the loop after processing
        } else {
          Provider.of<UserProvider>(context, listen: false)
              .navigateToNeoForConnectWallet = false;

          setState(() {
            isOverlayVisible = Provider.of<UserProvider>(context, listen: false)
                .navigateToNeoForConnectWallet; // Set overlay visibility to false
          });
        }

        return false;
      });

      print('trying end');
      clearLinkStream();
    } catch (e) {
      print('Error initializing UniLinks: $e');
      print('trying error');
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  // getAccessToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   accessToken = prefs.getString('accessToken')!;
  //   refreshToken = prefs.getString('refreshToken')!;
  //   await Provider.of<UserProvider>(context, listen: false)
  //       .getUserDetails(token: accessToken, context: context);
  //   var user = await Provider.of<UserProvider>(context, listen: false);
  //   print('test wallet address');
  //   print(user.walletAddress);
  //   print('test access token');
  //   print(accessToken);
  //   if(accessToken!=""){
  //   await appLinksService.initializeAppLinks(
  //       user.walletAddress
  //   );}
  //   if (isTokenExpired(accessToken)) {
  //     prefs.remove('accessToken');
  //     prefs.remove('refreshToken');
  //     await Provider.of<AuthProvider>(context, listen: false).refreshToken(
  //         refreshToken: refreshToken, context: context, token: accessToken);
  //   } else {}
  //   navigateToLoginPage(context);
  // }
  Future<void> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken') ?? "";
    refreshToken = prefs.getString('refreshToken') ?? "";

    // If token is empty, clear user data
    if (accessToken.isEmpty) {
      Provider.of<UserProvider>(context, listen: false).clearUserData();
      // Provider.of<AuthProvider>(context, listen: false).clearTokens();
      accessToken="";
      refreshToken="";
      return;
    }
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
    var user = Provider.of<UserProvider>(context, listen: false);
    print('test wallet address');
    print(user.walletAddress);
    print('test access token');
    print(accessToken);

    if (accessToken!="" && user.walletAddress!='') {
      await appLinksService.initializeAppLinks(user.walletAddress);
    }
    if (isTokenExpired(accessToken)) {
      prefs.remove('accessToken');
      prefs.remove('refreshToken');

      await Provider.of<AuthProvider>(context, listen: false).refreshToken(
          refreshToken: refreshToken, context: context, token: accessToken);
    }
  }

  navigateToLoginPage(BuildContext context) async {
   await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Wallet()),
          (Route<dynamic> route) => false,
    );
    await AppDeepLinking().openNftApp(
      {
        "operation": "disconnectWallet",
        "walletAddress":
        Provider.of<UserProvider>(
            context,
            listen: false)
            .walletAddress,
        "userName":
        Provider.of<UserProvider>(
            context,
            listen: false)
            .userName,
        "userIcon":
        Provider.of<UserProvider>(
            context,
            listen: false)
            .userAvatar,
        "response":
        'Wallet disconnected successfully'
      },
    );
  }

  String fcmToken = 'Waiting for FCM token...';

  generateFcmToken() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.getToken().then((newToken) {
      print("fcm===" + newToken!);
      setState(() {
        fcmToken = newToken;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final emailVerified =
        Provider.of<UserProvider>(context, listen: false).isEmailVerified;
    return Sizer(builder: (context, orientation, deviceType) {
      return Consumer<ThemeProvider>(
          builder: (context, ThemeProvider themeProvider, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          theme: themeProvider.isDark
              ? ThemeData(
                  brightness: Brightness.dark,
                  fontFamily: 'Inter',
                  hintColor: AppColors.backgroundColor,
                  highlightColor: Colors.transparent,
                )
              : ThemeData(
                  brightness: Brightness.light,
                  fontFamily: 'Inter',
                  hintColor: AppColors.backgroundColor,
                ),
          debugShowCheckedModeBanner: false,
          home:
          // BeerListView(),
              _buildContent(),
          // FAQAndSupport(),
          // TermsAndConditions(),
          // Provider.of<TokenProvider>(
          //   context,
          //   context,devic
          // ).isTokenEmpty
          // accessToken == ""
          //     ? Stack(
          //         children: [
          //           Wallet(),
          //           if (!isWifiOn)
          //             LoaderBluredScreen(
          //               isWifiOn: false,
          //             )
          //         ],
          //       )
          //     : isOverlayVisible
          //         ? const ConnectDapp()
          //         :
          //         //fromNeoApp will be used later
          //         Stack(
          //             children: [
          //               // PinScreen(),
          //
          //               WalletTokensNfts(),
          //
          //               // TransactionRequestAcceptReject(),
          //
          //               // Consumer<UserProvider>(builder: (context, user, child) {
          //               //   return user.navigateToNeoForConnectWallet
          //               //       ? const
          //
          //               //       : const SizedBox();
          //               // }),
          //               // if (!emailVerified)
          //               //   OnboardingAddEmail(),
          //
          //               if (!isWifiOn)
          //                 LoaderBluredScreen(
          //                   isWifiOn: false,
          //                 ),
          //
          //               // Container(
          //               //   margin: EdgeInsets.only(top: 20.h),
          //               //   height: 15.h,
          //               //   width: 50.h,
          //               //   color: Colors.white,
          //               //   child: Center(child: Text(_receivedData)),
          //               // )
          //             ],
          //           ),
          routes: {
            SignUpWithEmail.routeName: (context) => const SignUpWithEmail(),
            SigninWithEmail.routeName: (context) => const SigninWithEmail(),
            WalletTokensNfts.routeName: (context) => const WalletTokensNfts(),
            TransactionRequestAcceptReject.routeName: (context) =>
                const TransactionRequestAcceptReject(),
            TransactionRequest.routeName: (context) =>
                const TransactionRequest(),
            TermsAndConditions.routeName: (context) => TermsAndConditions(),
            NftsCollectionDetails.routeName: (context) =>
                const NftsCollectionDetails(),
            SetConfirmPinScreen.routeName: (context) =>
                const SetConfirmPinScreen(),
            NftsDetails.routeName: (context) => const NftsDetails(),
            TransactionSummary.routeName: (context) =>
                const TransactionSummary(),
            ConnectDapp.routeName: (context) => const ConnectDapp(),
          },
        );
      });
    });
  }

  _showToast(String message, {int duration = 2000}) {
    Widget toast = Container(
      height: 60,
      // width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: AppColors.textColorWhite.withOpacity(0.5),
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              color: Colors.transparent,
              child: Text(
                message,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                // .toUpperCase(),
                style: TextStyle(
                        color: AppColors.backgroundColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold)
                    .apply(fontWeightDelta: -2),
              ),
            ),
          ),
          // Spacer(),
        ],
      ),
    );
    fToast.showToast(
        child: toast,
        toastDuration: Duration(milliseconds: duration),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: Center(child: child),
            top: 43.0,
            left: 20,
            right: 20,
          );
        });
  }

  void noInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.85;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                height: 35.h,
                width: dialogWidth,
                decoration: BoxDecoration(
                  color: AppColors.showDialogClr,
                  // border: Border.all(
                  //     width: 0.1.h,
                  //     color: AppColors.textColorGrey),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 4.h,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Image.asset(
                          "assets/images/no_internethesa.png",
                          height: 7.h,
                          color: AppColors.textColorWhite,
                          // width: 104,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'No internet access'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17.5.sp,
                              color: AppColors.textColorWhite),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Lorem ipsum dolor sit amet, consec adipiscing elit ultrices arcu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textColorGreyShade2
                                  .withOpacity(0.4),
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Spacer(),
                      DialogButton(
                          title: 'Reconnect'.tr(),
                          handler: () {},
                          // isLoading: isLoading,
                          // isGradient: true,
                          color: AppColors.textColorWhite),
                      Spacer(),
                    ],
                  ),
                ),
              )),
        );
      },
    );
  }

  Widget _buildContent() {
    return FutureBuilder<void>(
      // future: AppLinksService(context: null).initializeAppLinks(userWalletAddress),
      future: null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return accessToken.isEmpty ?  Wallet() : WalletTokensNfts();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          if (accessToken.isEmpty) {
            return Stack(
              children: [
                Wallet(),
                if (!isWifiOn)
                  LoaderBluredScreen(
                    isWifiOn: false,
                  ),
              ],
            );
          } else if (!isOverlayVisible) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => WalletTokensNfts()),
                (Route<dynamic> route) => false,
              );
            });
            return WalletTokensNfts();
          } else if (isOverlayVisible) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => ConnectDapp()),
                (Route<dynamic> route) => false,
              );
            });
            return ConnectDapp();
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => WalletTokensNfts()),
                (Route<dynamic> route) => false,
              );
            });
            return WalletTokensNfts();
          }
        }
      },
    );
  }
}

bool isTokenExpired(String token) {
  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  int? exp = decodedToken['exp'];

  if (exp != null) {
    DateTime expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return expirationDate.isBefore(DateTime.now());
  }
  return true;
}
