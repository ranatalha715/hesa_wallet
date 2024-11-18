import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/screens/settings/change_password.dart';
import 'package:hesa_wallet/screens/unlock/set_pin_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:local_auth/error_codes.dart' as local_auth_error;
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/main_header.dart';


class SecurityAndPrivacy extends StatefulWidget {
  const SecurityAndPrivacy({Key? key}) : super(key: key);

  @override
  State<SecurityAndPrivacy> createState() => _SecurityAndPrivacyState();
}

class _SecurityAndPrivacyState extends State<SecurityAndPrivacy> {
  bool _isSelected = false;
  final ScrollController _scrollController = ScrollController();
  final _localAuthentication = LocalAuthentication();
  bool _isUserAuthorized = false;
  var _isLoading = false;
  var _isinit = true;
  var accessToken;
  bool _isPasscodeSet =false;

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    print(accessToken);
  }

  init() async {
    await getAccessToken();
    Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if (_isinit) {
      setState(() {
        _isLoading = true;
      });
      init();
      setState(() {
        _isLoading = false;
      });
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  getAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isUserAuthorized = prefs.getBool("fingerPrint") ?? false;
  }

  getPasscode() async {
    print('printing');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final passcode = prefs.getString('passcode')!;
    if(passcode!=""){
      _isPasscodeSet = true;
    }
    else{
      _isPasscodeSet = false;
    }
    print("ispasscodeset" + _isPasscodeSet.toString());
  }

  @override
  void initState() {
    getAuthStatus();
    getPasscode();
    super.initState();
  }


  Future<void> authenticateUser() async {
    bool isAuthorized = false;
    try {
      isAuthorized = await _localAuthentication.authenticate(
        localizedReason: "Please authenticate to see account balance",
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (exception) {
      if (exception.code == local_auth_error.notAvailable ||
          exception.code == local_auth_error.passcodeNotSet ||
          exception.code == local_auth_error.notEnrolled) {
      }
    }

    if (!mounted) return;

    setState(() {
      _isUserAuthorized = isAuthorized;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('fingerPrint', _isUserAuthorized);
  }

  @override
  Widget build(BuildContext context) {
    final isEmailVerified =
        Provider.of<UserProvider>(context, listen: false).isEmailVerified;
    final verifiedEmail =
        Provider.of<UserProvider>(context, listen: false).verifiedEmail;
    print('email');
    print(verifiedEmail);
    print(isEmailVerified);
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: Column(
              children: [
                MainHeader(title: 'Security & privacy'.tr()),
                SizedBox(
                  height: 5.h,
                ),
                Expanded(
                  child: Container(
                    // color: AppColors.errorColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.sp),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                              },
                              child: Container(
                                // height: 10.7.h,
                                decoration: BoxDecoration(
                                  color: AppColors.textFieldParentDark,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 13.sp, vertical: 10.sp),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.sp),
                                            color: isEmailVerified != 'true'
                                                ? AppColors.errorColor
                                                    .withOpacity(0.07)
                                                : AppColors.textColorGreen
                                                    .withOpacity(0.07)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Image.asset(
                                            isEmailVerified == 'true'
                                                ? "assets/images/secure.png"
                                                : "assets/images/privacyrisk.png",
                                            height: 3.h,
                                            width: 3.h,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2.5.h,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isEmailVerified == "true"
                                                ? "Your account is secured".tr()
                                                : 'Your account is at risk'
                                                    .tr(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 11.7.sp,
                                                color: themeNotifier.isDark
                                                    ? AppColors.textColorWhite
                                                    : AppColors.textColorBlack),
                                          ),
                                          SizedBox(
                                            height: 1.h,
                                          ),
                                          if (isEmailVerified == "true")
                                            Text(
                                              verifiedEmail,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 10.sp,
                                                  color: AppColors
                                                      .emailSecurityVerified),
                                            ),
                                          SizedBox(
                                            height: 0.8.h,
                                          ),
                                          if (isEmailVerified != "true")
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.sp),
                                                  color: AppColors.errorColor
                                                      .withOpacity(0.07)),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 9.sp,
                                                    vertical: 3.sp),
                                                child: Text(
                                                  'Email not verified'.tr(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 9.sp,
                                                    color: AppColors.errorColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      _isSelected = !_isSelected;
                                    }),
                                    child: Container(
                                      height: 6.5.h,
                                      decoration: BoxDecoration(
                                        color:
                                        AppColors.textFieldParentDark,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8.0),
                                          topRight: Radius.circular(8.0),
                                          bottomLeft: Radius.circular(
                                              _isSelected
                                                  ? 8.0
                                                  : 8.0),
                                          // Adjust as needed
                                          bottomRight: Radius.circular(
                                              _isSelected
                                                  ? 8.0
                                                  : 8.0), // Adjust as needed
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20.sp),
                                              child: Image.asset(
                                                _isUserAuthorized && _isPasscodeSet
                                                    ? "assets/images/biometric_true.png"
                                                    : "assets/images/alert_biometric.png",
                                                height: 2.6.h,
                                                width: 2.6.h,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 1.h,
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20.sp),
                                              child: Text(
                                                'Biometric lock'.tr(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 11.7.sp,
                                                    color: themeNotifier.isDark
                                                        ? AppColors
                                                            .textColorWhite
                                                        : AppColors
                                                            .textColorBlack),
                                              ),
                                            ),
                                            Spacer(),
                                            Container(
                                                margin: EdgeInsets.only(
                                                    right: 8.sp),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.sp),
                                                    color: AppColors
                                                        .textColorGrey
                                                        .withOpacity(0.10)),
                                                child: Icon(
                                                  _isSelected
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                          .keyboard_arrow_down,
                                                  size: 21.sp,
                                                  color: themeNotifier.isDark
                                                      ? AppColors.textColorWhite
                                                      : AppColors
                                                          .textColorBlack,
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_isSelected)
                                    Container(
                                      margin: EdgeInsets.only(left: 1.sp, right: 1.sp,  top: 0.4.h),
                                      decoration: BoxDecoration(
                                        color: AppColors.textFieldParentDark,
                                        borderRadius: BorderRadius.all(Radius.circular(8.sp)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.10), // Shadow color
                                            offset: Offset(0, 4), // Pushes the shadow down, removes the top shadow
                                            blurRadius: 3, // Adjust the blur radius to change shadow size
                                            spreadRadius: 0.5,  // Optional: Adjust spread radius if needed
                                          ),
                                        ],
                                      ),
                                      child: ListView(
                                        controller: _scrollController,
                                        padding: EdgeInsets.only(top: 0.4.h),
                                        shrinkWrap: true,
                                        children: [
                                          // biometricLock(
                                          //     isFirst: true,
                                          //     imageUrl:
                                          //         "assets/images/face_Id2.png",
                                          //     title: 'Face ID'.tr(),
                                          //     // subTitle: 'Have been set up'.tr(),
                                          //     subTitle:
                                          //         'Have not been set up'.tr(),
                                          //
                                          //     // isSet: true,
                                          //     setUpHandler: () {},
                                          //     isDark: themeNotifier.isDark
                                          //         ? true
                                          //         : false),
                                          // biometricLock(
                                          //     // isLast: true,
                                          //     imageUrl:
                                          //         "assets/images/finger_id2.png",
                                          //     title: 'Finger ID'.tr(),
                                          //     subTitle: _isUserAuthorized
                                          //         ? "Have been set up".tr()
                                          //         : "Have not been set up".tr(),
                                          //     setUpHandler: authenticateUser,
                                          //     isSet: _isUserAuthorized
                                          //         ? true
                                          //         : false,
                                          //     isDark: themeNotifier.isDark
                                          //         ? true
                                          //         : false),
                                          biometricLock(
                                              isLast: true,
                                              isFirst: true,
                                              imageUrl:
                                                  "assets/images/passcode.png",
                                              title: 'Pin'.tr(),
                                              subTitle:
                                                  _isPasscodeSet
                                                      ? "Have been set up".tr()
                                                      :
                                                  "Have not been set up".tr(),
                                              setUpHandler: () => Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PinScreen()),
                                                  ),
                                              isSet: _isPasscodeSet
                                                  ? true
                                                  : false,
                                              isDark: themeNotifier.isDark
                                                  ? true
                                                  : false),
                                        ],
                                      ),
                                    )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChangePassword()),
                              ),
                              child: Container(
                                height: 6.5.h,
                                decoration: BoxDecoration(
                                  color: AppColors.textFieldParentDark,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(right: 5, top: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.sp),
                                        child: Image.asset(
                                          "assets/images/passwordlock.png",
                                          height: 7.h,
                                          width: 7.h,
                                          color: themeNotifier.isDark
                                              ? AppColors.textColorWhite
                                              : AppColors.textColorBlack,
                                        ),
                                      ),
                                      Text(
                                        'Change password'.tr(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 11.7.sp,
                                            color: themeNotifier.isDark
                                                ? AppColors.textColorWhite
                                                : AppColors.textColorBlack),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   height: 3.h,
                            // ),
                            // Text(
                            //   'Activity sessions'.tr(),
                            //   style: TextStyle(
                            //       fontSize: 17.5.sp,
                            //       fontWeight: FontWeight.w600,
                            //       color: themeNotifier.isDark
                            //           ? AppColors.textColorWhite
                            //           : AppColors.textColorBlack),
                            // ),
                            // SizedBox(
                            //   height: 2.h,
                            // ),
                            // Container(
                            //   decoration: BoxDecoration(
                            //     border: Border.all(
                            //       color: AppColors.textColorGrey,
                            //       width: 1.0,
                            //     ),
                            //     borderRadius: BorderRadius.circular(8.0),
                            //   ),
                            //   child: Column(
                            //     children: [
                            //       Container(
                            //         height: 6.5.h,
                            //         decoration: BoxDecoration(
                            //           // border: Border.all(
                            //           //   // color: _isSelected ? Colors.transparent: AppColors.textColorGrey,
                            //           //   width: 1.0,
                            //           // ),
                            //           borderRadius: BorderRadius.circular(8.0),
                            //         ),
                            //         child: Padding(
                            //           padding: const EdgeInsets.only(
                            //               left: 5, right: 5, top: 5),
                            //           child: Row(
                            //             mainAxisAlignment: MainAxisAlignment.end,
                            //             children: [
                            //               Padding(
                            //                 padding: EdgeInsets.all(9.sp),
                            //                 child: Image.asset(
                            //                   "assets/images/handphone_laptop.png",
                            //                   height: 4.h,
                            //                   width: 4.h,
                            //                   color: themeNotifier.isDark
                            //                       ? AppColors.textColorWhite
                            //                       : AppColors.textColorBlack,
                            //                 ),
                            //               ),
                            //               // SizedBox(
                            //               //   width: 0.5.h,
                            //               // ),
                            //               Text(
                            //                 'Activity sessions'.tr(),
                            //                 style: TextStyle(
                            //                     fontWeight: FontWeight.w500,
                            //                     fontSize: 11.7.sp,
                            //                     color: themeNotifier.isDark
                            //                         ? AppColors.textColorWhite
                            //                         : AppColors.textColorBlack),
                            //               ),
                            //               Spacer(),
                            //               // GestureDetector(
                            //               //   onTap:()=> setState(() {
                            //               //     _isSelected = !_isSelected;
                            //               //   }),
                            //               //   child: Icon(
                            //               //     _isSelected ?  Icons.keyboard_arrow_down :Icons.keyboard_arrow_up,
                            //               //     size: 21.sp,
                            //               //     color: AppColors.textColorWhite,
                            //               //   ),
                            //               // )
                            //             ],
                            //           ),
                            //         ),
                            //       ),
                            //       // if(_isSelected)
                            //       ListView(
                            //         controller: _scrollController,
                            //         padding: EdgeInsets.zero,
                            //         shrinkWrap: true,
                            //         children: [
                            //           activitySessionWidget(
                            //               isFirst: true,
                            //               isDark:
                            //                   themeNotifier.isDark ? true : false),
                            //           activitySessionWidget(
                            //               isDark:
                            //                   themeNotifier.isDark ? true : false),
                            //           activitySessionWidget(
                            //               isLast: true,
                            //               isDark:
                            //                   themeNotifier.isDark ? true : false),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 5.h,
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) LoaderBluredScreen()
        ],
      );
    });
  }

  Widget activitySessionWidget({
    bool isFirst = false,
    bool isLast = false,
    bool isDark = true,
  }) {
    return Column(
      children: [
        if (isFirst)
          Divider(
            color: AppColors.textColorGrey,
          ),
        Container(
          height: 8.5.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(9),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.sp),
                        color: isDark
                            ? AppColors.textColorWhite
                            : AppColors.textColorGreyShade2.withOpacity(0.5)),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        "assets/images/iphone.png",
                        // "assets/images/AElanguage.png",
                        height: 3.h,
                        width: 3.h,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Iphone 14 Pro Max',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11.7.sp,
                          color: isDark
                              ? AppColors.textColorWhite
                              : AppColors.textColorBlack),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '192.68.0.73',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 10.sp,
                          color: AppColors.textColorGreyShade2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            color: AppColors.textColorGrey,
          )
      ],
    );
  }

  Widget biometricLock(
      {bool isFirst = false,
      bool isLast = false,
      required String imageUrl,
      required String title,
      required String subTitle,
      bool isSet = false,
      required Function setUpHandler,
      bool isDark = true}) {
    return Column(
      children: [
        Container(
          height: 8.5.h,
          decoration: BoxDecoration(
            color: AppColors.textFieldParentDark,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(isLast ? 8.0 : 0.0), // Adjust as needed
              bottomRight:
              Radius.circular(isLast ? 8.0 : 0.0,), // Adjust as needed
              topRight:
              Radius.circular(isFirst ? 8.0 : 0.0,),
              topLeft:
              Radius.circular(isFirst ? 8.0 : 0.0,), // Adjust as needed
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(9),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.sp),
                        color: isDark
                            ? AppColors.textClrGreyIconsContainerSecurity
                                .withOpacity(0.10)
                            : AppColors.textColorGreyShade2.withOpacity(0.5)),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        imageUrl,
                        height: 3.h,
                        width: 3.h,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11.7.sp,
                          color: isDark
                              ? AppColors.textColorWhite
                              : AppColors.textColorBlack,
                          fontFamily: 'Blogger Sans'),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      subTitle,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 10.sp,
                          color: isSet
                              ? AppColors.textColorGreen
                              : AppColors.errorColor),
                    ),
                  ],
                ),
                Spacer(),
                if (!isSet)
                  GestureDetector(
                    onTap: () => setUpHandler(),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.sp),
                          color: AppColors.textColorGrey.withOpacity(0.10)
                          // border: Border.all(color: AppColors.textColorGrey.withOpacity(0.10))
                          ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        child: Text(
                          'Set up'.tr(),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack),
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  width: 1.h,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
