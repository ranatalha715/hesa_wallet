import 'dart:async';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:deep_linking/deep_linking.dart';

// import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesa_wallet/providers/payment_fees.dart';
import 'package:hesa_wallet/providers/token_provider.dart';
import 'package:hesa_wallet/screens/onboarding_notifications/verify_email.dart';
import 'package:hesa_wallet/screens/unlock/set_confirm_pin_screen.dart';
import 'package:hesa_wallet/screens/unlock/set_pin_screen.dart';
import 'package:hesa_wallet/screens/unlock/unlock.dart';
import 'package:hesa_wallet/screens/user_profile_pages/nfts_details.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/dialog_button.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:deepinking_module/deep_linking.dart';
import 'package:uni_links/uni_links.dart';
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
import 'package:hesa_wallet/screens/account_recovery/reset_email.dart';
import 'package:hesa_wallet/screens/account_recovery/reset_password.dart';
import 'package:hesa_wallet/screens/connection_requests_pages/connect_dapp.dart';
import 'package:hesa_wallet/screens/delete_account_confirmation/delete_account_disclaimer.dart';
import 'package:hesa_wallet/screens/finger_print.dart';
import 'package:hesa_wallet/screens/onboarding_notifications/onboarding_add_email.dart';
import 'package:hesa_wallet/screens/settings/account_information.dart';
import 'package:hesa_wallet/screens/settings/change_password.dart';
import 'package:hesa_wallet/screens/settings/faq_&_support.dart';
import 'package:hesa_wallet/screens/settings/language.dart';
import 'package:hesa_wallet/screens/settings/security_and_privacy.dart';
import 'package:hesa_wallet/screens/settings/settings.dart';
import 'package:hesa_wallet/screens/signup_signin/signin_with_email.dart';
import 'package:hesa_wallet/screens/signup_signin/signin_with_mobile.dart';
import 'package:hesa_wallet/screens/signup_signin/signup_with_email.dart';
import 'package:hesa_wallet/screens/signup_signin/signup_with_mobile.dart';
import 'package:hesa_wallet/screens/signup_signin/terms_conditions.dart';
import 'package:hesa_wallet/screens/signup_signin/wallet.dart';
import 'package:hesa_wallet/screens/signup_signin/welcome_screen.dart';
import 'package:hesa_wallet/screens/testscroll.dart';
import 'package:hesa_wallet/screens/user_profile_pages/nfts_collection_details.dart';
import 'package:hesa_wallet/screens/user_profile_pages/transaction_summary.dart';
import 'package:hesa_wallet/screens/user_profile_pages/wallet_activity.dart';
import 'package:hesa_wallet/screens/user_profile_pages/connected_sites.dart';
import 'package:hesa_wallet/screens/user_profile_pages/wallet_tokens_nfts.dart';
import 'package:hesa_wallet/screens/user_transaction_summaries_with_payment/transaction_req_acceptreject.dart';
import 'package:hesa_wallet/screens/user_transaction_summaries_with_payment/transaction_request.dart';
import 'package:hesa_wallet/screens/userpayment_and_bankingpages/wallet_add_bank.dart';
import 'package:hesa_wallet/screens/userpayment_and_bankingpages/wallet_add_card.dart';
import 'package:hesa_wallet/screens/userpayment_and_bankingpages/wallet_banking_and_payment_empty.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localized.EasyLocalization.ensureInitialized();
  // WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // HyperPay.init("", "");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Disable landscape mode
    DeviceOrientation.portraitDown, // Disable landscape mode
  ]).then((_) {
    runApp(
        // DevicePreview(
        // enabled: !kReleaseMode,
        // builder: (context) =>
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
                // path to your language files
                fallbackLocale: Locale('en', 'US'),
                saveLocale: true,
                child: MyApp()))
        // )
        );
    // Register the MethodChannel with the same unique name as in the NFT app
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

  late FToast fToast;
  bool isOverlayVisible = false;
  bool isWifiOn = true;
  bool fromNeoApp = false;
  var user;

  // late OverlayEntry overlayEntry = OverlayEntry(builder: (context) => Container());
  Future<void> checkWifiStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isWifiOn = (connectivityResult == ConnectivityResult.wifi);
      isWifiOn = connectivityResult == ConnectivityResult.none ? false : true;
    });

    // if (!isWifiOn) {
    //   noInternetDialog(context);
    // }
  }

  callRedDotLogic() async {
    final prefs = await SharedPreferences.getInstance();
    var numActivity = prefs.getInt('numOfActivities') ?? 0;
    await Provider.of<TransactionProvider>(context, listen: false)
        .getWalletActivities(
            accessToken: accessToken, context: context, refresh: true);

    Provider.of<TransactionProvider>(context, listen: false).showRedDot =
        numActivity !=
                Provider.of<TransactionProvider>(context, listen: false)
                    .activities
                    .length
            ? true
            : false;
    print('testing red dot');
    print(numActivity);
    print(Provider.of<TransactionProvider>(context, listen: false)
        .activities
        .length);
    print(Provider.of<TransactionProvider>(context, listen: false).showRedDot);
    await prefs.setInt(
        'numOfActivities',
        Provider.of<TransactionProvider>(context, listen: false)
            .activities
            .length);
  }

  Timer? _timer;
  StreamSubscription<String?>? _linkSubscription;
  void clearLinkStream() {
    // Cancel or reset the link stream if possible
    getLinksStream().drain();  // This will stop the stream from emitting more items

    print('Link stream has been cleared.');
  }

  @override
  initState() {
    super.initState();
    generateFcmToken();
    AppDeepLinking().initDeeplink();
    fToast = FToast();
    fToast.init(context);
    this.initUniLinks();
    getAccessToken();
    // Future.delayed(Duration(seconds: 2), () {
    //   if(accessToken !='') {
    //     Provider.of<AuthProvider>(context, listen: false)
    //       .updateFCM(FCM: fcmToken, token: accessToken, context: context);
    //
    //   }
    // });

    WidgetsBinding.instance.addObserver(this);

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      checkWifiStatus();
    }); // 31 jan
    // initUniLinks();
    // startPeriodicChecking();
    print('recieved data' + _receivedData);
    Timer.periodic(Duration(seconds: 3), (timer) async {
      getAccessToken();
      callRedDotLogic();
      // initUniLinks();
      // print('isEmailVerified');
      // print(Provider.of<UserProvider>(context, listen: false)
      //     .isEmailVerified);
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

  String _receivedData = 'No UniLink data received';
  bool _uniLinkHandled = false;

  // Future<void> initUniLinks() async {
  //   try {
  //     // Handle the initial link
  //     final initialLink = await getInitialLink();
  //     if (initialLink != null) {
  //       _handleIncomingLink(initialLink);
  //     }
  //
  //     // Handle subsequent links
  //     _linkSubscription = linkStream.listen((String? link) {
  //       if (link != null) {
  //         _handleIncomingLink(link);
  //       }
  //     }, onError: (err) {
  //       print('Error listening for UniLinks: $err');
  //     });
  //   } catch (e) {
  //     print('Error initializing UniLinks: $e');
  //     // Handle error as necessary
  //   }
  // }
  //
  // void _handleIncomingLink(String link) {
  //   if (_uniLinkHandled) {
  //     return;
  //   }
  //   setState(() {
  //     _receivedData = link;
  //   });
  //
  //   Uri uri = Uri.parse(link);
  //   String? operation = uri.queryParameters['operation'];
  //   print('operation this: ' + operation.toString());
  //   if (operation != null && operation == 'connectWallet') {
  //     // Navigate to ConnectWalletScreen
  //     setState(() {
  //       Provider.of<UserProvider>(context, listen: false).navigateToNeoForConnectWallet = true;
  //       print("check kro: " +
  //           Provider.of<UserProvider>(context, listen: false)
  //               .navigateToNeoForConnectWallet
  //               .toString());
  //     });
  //     _uniLinkHandled = true;
  //     // Navigator.push(
  //     //   context,
  //     //   MaterialPageRoute(builder: (context) => ConnectWalletScreen()),
  //     // );
  //
  //     // Kill or remove the UniLink from the app lifecycle
  //     _linkSubscription?.cancel();
  //     _linkSubscription = null;
  //   } else {
  //     Provider.of<UserProvider>(context, listen: false).navigateToNeoForConnectWallet = false;
  //   }
  // }
  Future<void> initUniLinks() async {
    try {
      print('trying');
      await getLinksStream().firstWhere((String? link) {
        if (link != null) {
          Uri uri = Uri.parse(link);
          String? operation = uri.queryParameters['operation'];
          print("print operation");
          print(operation);

          if (operation != null && operation == 'connectWallet') {
            Provider.of<UserProvider>(context, listen: false)
                .navigateToNeoForConnectWallet = true;

            setState(() {
              isOverlayVisible = Provider.of<UserProvider>(context, listen: false)
                  .navigateToNeoForConnectWallet;  // Set overlay visibility to true
            });

            print("check kro" +
                Provider.of<UserProvider>(context, listen: false)
                    .navigateToNeoForConnectWallet
                    .toString());
          } else {
            Provider.of<UserProvider>(context, listen: false)
                .navigateToNeoForConnectWallet = false;

            setState(() {
              isOverlayVisible = Provider.of<UserProvider>(context, listen: false)
                  .navigateToNeoForConnectWallet;  // Set overlay visibility to false
            });
          }
          return true; // Exit the loop after processing
        } else{
          Provider.of<UserProvider>(context, listen: false)
              .navigateToNeoForConnectWallet = false;

          setState(() {
            isOverlayVisible = Provider.of<UserProvider>(context, listen: false)
                .navigateToNeoForConnectWallet;  // Set overlay visibility to false
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


  // Future<void> initUniLinks() async {
  //   try {
  //     print('trying');
  //     // AppDeepLinking().initDeeplink(); muzamil recommended
  //     getLinksStream().listen((String? link) {
  //       if (link != null) {
  //         setState(() {
  //           _receivedData = link;
  //         });
  //
  //         Uri uri = Uri.parse(link);
  //         String? operation = uri.queryParameters['operation'];
  //         print("print operation");
  //         print(operation);
  //
  //         if (operation != null && operation == 'connectWallet') {
  //
  //
  //
  //           Provider.of<UserProvider>(context, listen: false)
  //               .navigateToNeoForConnectWallet = true;
  //
  //           print("check kro" +
  //               Provider.of<UserProvider>(context, listen: false)
  //                   .navigateToNeoForConnectWallet
  //                   .toString());
  //
  //         } else {
  //           Provider.of<UserProvider>(context, listen: false)
  //               .navigateToNeoForConnectWallet = false;
  //         }
  //       }
  //     });
  //     print('trying end');
  //   } catch (e) {
  //     print('Error initializing UniLinks: $e');
  //     print('trying error');
  //
  //   }
  // }

  // payable non payable functions
@override
  void didChangeDependencies() {
  // isOverlayVisible = Provider.of<UserProvider>(context, listen: false)
  //     .navigateToNeoForConnectWallet;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {

      // setState(() {
      //   isOverlayVisible=false;
      // });
      // print('app paused');
      // SystemNavigator.pop();
      // initUniLinks();
      // // App goes into the background
      //
      // setState(() {
      //   isOverlayVisible = Provider.of<UserProvider>(context, listen: false)
      //       .navigateToNeoForConnectWallet;
      // });
      // _showLockScreen();


    }
    else if (state == AppLifecycleState.resumed) {
      // SystemNavigator.pop();
      // setState(() {
      //   isOverlayVisible=false;
      // });
      // initUniLinks();
      // App comes back to the foreground
      // print('app resumed');
      //
      // setState(() {
      //   isOverlayVisible = false;
      //       // Provider.of<UserProvider>(context, listen: false)
      //       // .navigateToNeoForConnectWallet;
      // });
      // _hideLockScreen();
    }
    else{}
    // print('isOverlayVisible');
    // print(isOverlayVisible);
  }

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    refreshToken = prefs.getString('refreshToken')!;

    if (isTokenExpired(accessToken)) {
      prefs.remove('accessToken');
      Provider.of<AuthProvider>(context, listen: false).refreshToken(
          refreshToken: refreshToken, context: context, token: accessToken);
      // setState(() {
      //   accessToken = '';
      // });
      // _showToast('Session Expired!');
    } else {}
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
    print('isOverlayVisible testing');
    print(isOverlayVisible);
    return Sizer(builder: (context, orientation, deviceType) {
      return Consumer<ThemeProvider>(
          builder: (context, ThemeProvider themeProvider, _) {
        return MaterialApp(
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
          // ConnectDapp(),
          _buildContent(),
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
            TermsAndConditions.routeName: (context) =>
                const TermsAndConditions(),
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

    // Custom Toast Position
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
      future: initUniLinks(),  // Call the modified initUniLinks function
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the deep link to be processed
        return accessToken.isEmpty ? const Wallet(): WalletTokensNfts();
            // Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Handle any errors
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // The future is complete, return your content based on the overlay visibility
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
          }  else if (!isOverlayVisible){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => WalletTokensNfts()),
                    (Route<dynamic> route) => false,
              );
            });
            return WalletTokensNfts();
          }
          else if (isOverlayVisible) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => ConnectDapp()),
                    (Route<dynamic> route) => false,
              );
            });
            return ConnectDapp();
          }
          else {
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

  return true; // If no expiry information is found, consider it expired
}
