import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/providers/theme_provider.dart';
import 'package:hesa_wallet/screens/settings/account_information.dart';
import 'package:hesa_wallet/screens/settings/language.dart';
import 'package:hesa_wallet/screens/settings/security_and_privacy.dart';
import 'package:hesa_wallet/screens/signup_signin/terms_conditions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/app_deep_linking.dart';
import '../../constants/colors.dart';
import '../../constants/configs.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/animated_loader/animated_loader.dart';
import '../../widgets/app_header.dart';
import '../../widgets/button.dart';
import '../../widgets/dialog_button.dart';
import '../../widgets/main_header.dart';
import '../delete_account_confirmation/delete_account_disclaimer.dart';
import '../signup_signin/wallet.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var isLoading = false;
  var accessToken = '';
  var refreshToken = '';
  var _isLoading = false;
  var _isinit= true;

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    refreshToken = prefs.getString('refreshToken')!;

  }

  deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('accessToken');
    prefs.remove('refreshToken');
    prefs.remove('siteUrl');
  }

  init() async {
    await getAccessToken();
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
  }

  logOutFunction(bool isDark) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.85;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Colors.transparent,
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                child: Container(
                  height: 33.h,
                  width: dialogWidth,
                  decoration: BoxDecoration(
                    // border: Border.all(
                    //     width: 0.1.h, color: AppColors.textColorGrey),
                    color: isDark
                        ? AppColors.showDialogClr
                        : AppColors.textColorWhite,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 4.h,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.sp),
                        child: Text(
                          'Are you sure you want to log out?'.tr(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                              color: isDark
                                  ? AppColors.textColorWhite
                                  : AppColors.textColorBlack),
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Expanded(child: SizedBox()),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: AppButton(
                            title: 'Cancel'.tr(),
                            handler: () {
                              Navigator.pop(context);
                            },
                            isGradient: false,
                            color: AppColors.appSecondButton.withOpacity(0.10),
                            textColor: isDark
                                ? AppColors.textColorWhite
                                : AppColors.textColorBlack.withOpacity(0.8),)
                        // color: Colors.transparent),
                      ),

                      SizedBox(height: 2.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: DialogButton(
                          title: 'Log out'.tr(),
                          handler: () async {
                            // if (isLoading) return;

                            try {
                              setState(() {
                                isLoading = true;
                              });
                              final resultLogout = await Provider.of<AuthProvider>(
                                  context,
                                  listen: false)
                                  .logoutUser(token: accessToken, refreshToken: refreshToken, context: context);

                              setState(() {
                                isLoading = false;
                              });
                              if (resultLogout == AuthResult.success) {
                                print('printing navigator');
                                deleteToken();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Wallet(),
                                  ),
                                      (route) =>
                                  false, // This predicate ensures that all previous routes are removed.
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
                              } else{
                                print('Logout Failed');
                              }
                            } catch (error) {
                              print("Error: $error");
                              // _showToast('An error occurred'); // Show an error message
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          isLoading: isLoading,
                          // isGradient: true,
                          color: AppColors.appSecondButton.withOpacity(0.10),
                          textColor: AppColors.errorColor,
                        ),
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                )),
          );
        });
      },
    );
  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if(_isinit){
      getAccessToken();
      // setState(() {
      //   _isLoading=true;
      // });
      // await Future.delayed(Duration(milliseconds: 900), () {
      //   print('This code will be executed after 2 seconds');
      // });
      // setState(() {
      //   _isLoading=false;
      // });
    }
    _isinit=false;
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack
        (
        children: [
          Scaffold(
            backgroundColor:
                themeNotifier.isDark ? AppColors.backgroundColor : Colors.white,
            body: SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MainHeader(title: 'Settings'.tr()),
                  // Column(
                  //   children: [
                  //     // Container(
                  //     //   height: 10.h,
                  //     //   width: double.infinity,
                  //     //   margin: EdgeInsets.only(left: 20.sp, right: 20.sp, top: 20.sp),
                  //     //   decoration: BoxDecoration(
                  //     //     color: AppColors.accountAtRisk,
                  //     //     // borderRadius: BorderRadius.circular(5.sp),
                  //     //     border: Border(
                  //     //         left: BorderSide(
                  //     //           color: AppColors.verifyAccount, // Left border color
                  //     //           width: 3.0,          // Left border width
                  //     //         ),
                  //     //     )
                  //     //   ),
                  //     //   child: Padding(
                  //     //     padding:  EdgeInsets.symmetric(horizontal: 10.sp),
                  //     //     child: Row(
                  //     //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //     //       children: [
                  //     //         Align(
                  //     //           alignment: Alignment.topCenter,
                  //     //           child: Padding(
                  //     //             padding:  EdgeInsets.only(top: 14.sp),
                  //     //             child: Image.asset(
                  //     //               "assets/images/accoun_trisk.png",
                  //     //               height: 18.sp,
                  //     //               width: 18.sp,
                  //     //             ),
                  //     //           ),
                  //     //         ),
                  //     //         SizedBox(
                  //     //           width: 2.w,
                  //     //         ),
                  //     //         Container(
                  //     //           width: 45.w,
                  //     //           color: Colors.transparent,
                  //     //           child:
                  //     //           Column(
                  //     //             mainAxisAlignment: MainAxisAlignment.center,
                  //     //             crossAxisAlignment: CrossAxisAlignment.start,
                  //     //             children: [
                  //     //               Text(
                  //     //                 'Account at risk!',
                  //     //                 style: TextStyle(
                  //     //                   fontWeight: FontWeight.w600,
                  //     //                   color: AppColors.blackColour,
                  //     //                   fontSize: 10.sp,
                  //     //                 ),
                  //     //               ),
                  //     //               SizedBox(height: 0.5.h,),
                  //     //               Text(
                  //     //                 'Email is not verified yet, tap the \nbutton to verify your information',
                  //     //                 maxLines: 2,
                  //     //                 style: TextStyle(
                  //     //                   fontWeight: FontWeight.w400,
                  //     //                   color: AppColors.verifyAccount,
                  //     //                   fontSize: 7.3.sp,
                  //     //
                  //     //                 ),
                  //     //               )
                  //     //             ],
                  //     //           ),
                  //     //         ),
                  //     //         Spacer(),
                  //     //         Text(
                  //     //           'Verify Account',
                  //     //           style: TextStyle(
                  //     //             fontWeight: FontWeight.w600,
                  //     //             color: AppColors.verifyAccount,
                  //     //             fontSize: 8.8.sp,
                  //     //             // height: 18,
                  //     //           ),
                  //     //         ),
                  //     //       ],
                  //     //     ),
                  //     //   ),
                  //     // ),
                  //   ],
                  // ),
                  // SizedBox(height: 2.h,),
                  Container(
                    height: 77.h,
                    // color: Colors.red,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 2.h,
                            ),
                            SettingsWidget(
                                title: 'Account information'.tr(),
                                imagePath: "assets/images/account.png",
                                imageHeight: 2.1.h,
                                imageWidth: 2.1.h,
                                index: 0,
                                isDark: themeNotifier.isDark ? true : false,
                                handler: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AccountInformation()),
                                    )),
                            // Divider(color: AppColors.textColorWhite, height: 2.h,),
                            SettingsWidget(
                                title: 'Security & privacy'.tr(),
                                imagePath: "assets/images/privacyrisk.png",
                                imageHeight: 2.8.h,
                                imageWidth: 2.8.h,
                                index: 1,
                                color: AppColors.errorColor,
                                isDark: themeNotifier.isDark ? true : false,
                                handler: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SecurityAndPrivacy()),
                                    )),
                            SettingsWidget(
                                title: 'Language'.tr(),
                                imagePath: "assets/images/world.png",
                                imageHeight: 3.2.h,
                                imageWidth: 3.2.h,
                                index: 2,
                                isDark: themeNotifier.isDark ? true : false,
                                handler: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Language()),
                                    )),
                            // Stack(
                            //   children: [
                            //     SettingsWidget(
                            //         title: 'Appearance'.tr(),
                            //         imagePath: "assets/images/appearance.png",
                            //         imageHeight: 2.7.h,
                            //         imageWidth: 2.7.h,
                            //         index: 4,
                            //         isDark: themeNotifier.isDark ? true : false,
                            //         handler: () => Navigator.push(
                            //               context,
                            //               MaterialPageRoute(
                            //                   builder: (context) =>
                            //                       DeleteAccountDisclaimer()),
                            //             )),
                            //     Positioned(
                            //       right: isEnglish ? 10 : null,
                            //       left: isEnglish ? null : 10,
                            //       bottom: 20,
                            //       child: Container(
                            //         // height: 3.h,
                            //         // width: 3.h,
                            //         decoration: BoxDecoration(
                            //             // color: AppColors.errorColor,
                            //             // color: AppColors.gradientColor1,
                            //             borderRadius: BorderRadius.circular(20),
                            //             border: Border.all(
                            //                 color: AppColors.textColorGrey)),
                            //         child: Padding(
                            //           padding: EdgeInsets.symmetric(
                            //               vertical: 3.sp, horizontal: 4.sp),
                            //           child: Row(
                            //             crossAxisAlignment:
                            //                 CrossAxisAlignment.center,
                            //             children: [
                            //               GestureDetector(
                            //                 onTap: () {
                            //                   themeNotifier.isDark
                            //                       ? themeNotifier.isDark = false
                            //                       : themeNotifier.isDark = true;
                            //                   // Provider.of<ThemeProvider>(
                            //                   //     context, listen: false)
                            //                   //     .toggleTheme();
                            //                   // setState(() {
                            //                   //   _selectedTheme =
                            //                   //   'darkTheme';
                            //                   // });
                            //                 },
                            //                 child: Container(
                            //                   decoration: BoxDecoration(
                            //                       color: themeNotifier.isDark
                            //                           ? AppColors.textColorWhite
                            //                           : Colors.transparent,
                            //                       borderRadius:
                            //                           BorderRadius.circular(30)),
                            //                   child: Padding(
                            //                     padding: EdgeInsets.all(4.sp),
                            //                     child: Image.asset(
                            //                       "assets/images/dark.png",
                            //                       color: themeNotifier.isDark
                            //                           ? Colors.black
                            //                           : AppColors.tabColorlightMode,
                            //                       height: 2.h,
                            //                       width: 2.h,
                            //                     ),
                            //                   ),
                            //                 ),
                            //               ),
                            //               SizedBox(
                            //                 width: 0.5.h,
                            //               ),
                            //               GestureDetector(
                            //                 onTap: () {
                            //                   themeNotifier.isDark
                            //                       ? themeNotifier.isDark = false
                            //                       : themeNotifier.isDark = true;
                            //                   // Provider.of<ThemeProvider>(
                            //                   //     context, listen: false)
                            //                   //     .toggleTheme();
                            //                   // setState(() {
                            //                   //   _selectedTheme =
                            //                   //   'lightTheme';
                            //                   // });
                            //                 },
                            //                 child: Container(
                            //                   decoration: BoxDecoration(
                            //                       color: themeNotifier.isDark
                            //                           ? Colors.transparent
                            //                           : AppColors.tabColorlightMode,
                            //                       borderRadius:
                            //                           BorderRadius.circular(30)),
                            //                   child: Padding(
                            //                     padding: EdgeInsets.all(4.sp),
                            //                     child: Image.asset(
                            //                       "assets/images/light.png",
                            //                       color: themeNotifier.isDark
                            //                           ? AppColors.textColorGrey
                            //                           : AppColors.textColorWhite,
                            //                       height: 2.h,
                            //                       width: 2.h,
                            //                     ),
                            //                   ),
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //       ),
                            //     )
                            //   ],
                            // ),
                            SettingsWidget(
                                title: 'Term and conditions'.tr(),
                                imagePath: "assets/images/termandcondition.png",
                                imageHeight: 3.2.h,
                                imageWidth: 3.2.h,
                                index: 3,
                                isDark: themeNotifier.isDark ? true : false,
                                handler: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TermsAndConditions()),
                                    )),
                            SettingsWidget(
                                title: 'Logout'.tr(),
                                imagePath: "assets/images/draweroption7.png",
                                imageHeight: 3.2.h,
                                imageWidth: 3.2.h,
                                index: 3,
                                isDark: themeNotifier.isDark ? true : false,
                                handler: () {
                                  Navigator.pop(context);
                                  logOutFunction(themeNotifier.isDark);
                                }),
                            SettingsWidget(
                                title: 'Delete account'.tr(),
                                imagePath: "assets/images/deleteaccount.png",
                                imageHeight: 3.h,
                                imageWidth: 3.h,
                                index: 4,
                                isDark: themeNotifier.isDark ? true : false,
                                handler: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DeleteAccountDisclaimer()),
                                    )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if(_isLoading)
            LoaderBluredScreen()
        ],
      );
    });
  }

  Widget SettingsWidget(
      {required String title,
      required String imagePath,
      required double imageHeight,
      required double imageWidth,
      required int index,
      Color color = AppColors.textColorWhite,
      Function? handler,
      bool isDark = true}) {
    return GestureDetector(
      onTap: () => handler!(),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.sp),
        height: 7.5.h,
        decoration: BoxDecoration(
            // color: AppColors.gradientColor1,
            ),
        // color: index == selectedIndex ? Colors.yellow:AppColors.textColorWhite.withOpacity(0.05),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 3.h,
                    width: 3.h,
                    color: Colors.transparent,
                    child: Center(
                      child: Image.asset(
                        imagePath,
                        color: color == AppColors.errorColor
                            ? color
                            : isDark
                                ? AppColors.textColorWhite
                                : AppColors.tabColorlightMode,
                        fit: BoxFit.cover,
                        // AppColors.backgroundColor,
                        // height: imageHeight,
                        // width: imageWidth,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                        color: isDark
                            ? AppColors.textColorWhite
                            : AppColors.tabColorlightMode,
                        // AppColors.textColorBlack,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.7.sp,
                        fontFamily: 'Inter'),
                  ),
                ],
              ),
              SizedBox(
                height: 1.5.h,
              ),
              // Divider(
              //   color: isDark
              //       ? AppColors.transactionSummNeoBorder
              //       : AppColors.backgroundColor,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
