import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/footer_text.dart';
import 'package:hesa_wallet/constants/styles.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/screens/account_recovery/reset_email.dart';
import 'package:hesa_wallet/screens/signup_signin/wallet.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../providers/theme_provider.dart';
import '../../widgets/text_field_parent.dart';
import '../user_profile_pages/wallet_tokens_nfts.dart';

class WelcomeScreen extends StatefulWidget {
  final Function handler;
  const WelcomeScreen({Key? key, required this.handler}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _obscurePassword = true;
  var _isLoading = false;
  var _savedPassCode;
  bool isButtonActive = false;

  final TextEditingController _passwordController = TextEditingController();

  void _updateButtonState() {
    setState(() {
      isButtonActive = _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }


  getSavedPassCode() async {
    final prefs = await SharedPreferences.getInstance();
    _savedPassCode = prefs.getString('passcode') ?? "";
  }

  @override
   void initState()  {
    getSavedPassCode();
    _passwordController.addListener(_updateButtonState);
    _passwordController.addListener(_limitInputLength);
    // TODO: implement initState
    super.initState();

  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  bool isValidating = false;



  void _limitInputLength() {
    if (_passwordController.text.length > 6) {
      _passwordController.text = _passwordController.text.substring(0, 6);
      _passwordController.selection = TextSelection.fromPosition(
        TextPosition(offset: _passwordController.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      height: 60.h,
                      width: 100.w,
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Spacer(
                            flex: 2,
                          ),
                          Text(
                            'Account Locked'.tr(),
                            style: TextStyle(
                                color: themeNotifier.isDark
                                    ? AppColors.textColorWhite
                                    : AppColors.textColorBlack,
                                fontWeight: FontWeight.w700,
                                fontSize: 25.sp,
                                fontFamily: 'Blogger Sans'),
                          ),
                          Spacer(
                            flex: 1,
                          ),
                        ],
                      )),
                  Container(
                    height: 40.h,
                    // color: Colors.grey,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.sp,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: SizedBox(),
                          ),

                          Align(
                            alignment: isEnglish
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Text(
                              'Password'.tr(),
                              style: TextStyle(
                                  fontSize: 11.7.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: themeNotifier.isDark
                                      ? AppColors.textColorWhite
                                      : AppColors.textColorBlack),
                            ),
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          TextFieldParent(
                            child: TextField(
                              keyboardType: TextInputType.number,
                                // maxLength: 6,
                                scrollPadding: EdgeInsets.only(
                                    bottom:
                                        MediaQuery.of(context).viewInsets.bottom /
                                            1.8),
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(
                                    fontSize: 10.2.sp,
                                    color: themeNotifier.isDark
                                        ? AppColors.textColorWhite
                                        : AppColors.textColorBlack,
                                    fontWeight: FontWeight.w400,
                                    // Off-white color,
                                    fontFamily: 'Inter'),
                                decoration: InputDecoration(
                                  // fillColor: AppColors.profileHeaderDark,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 16.0),
                                  hintText: 'Enter your password'.tr(),
                                  hintStyle: TextStyle(
                                      fontSize: 10.2.sp,
                                      color: AppColors.textColorGrey,
                                      fontWeight: FontWeight.w400,
                                      // Off-white color,
                                      fontFamily: 'Inter'),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        // Off-white color
                                        // width: 2.0,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        // Off-white color
                                        // width: 2.0,
                                      )),
                                  // labelText: 'Enter your password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.textColorGrey,
                                      size: 17.5.sp,
                                    ),
                                    onPressed: _togglePasswordVisibility,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                  ),
                                ),
                                cursorColor: AppColors.textColorGrey),
                          ),
                          if (_passwordController.text.isEmpty && isValidating)
                            Padding(
                              padding: EdgeInsets.only(top: 7.sp),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "*Enter your password",
                                  /* textAlign :TextAlign.left,*/
                                  style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.errorColor),
                                ),
                              ),
                            ),
                          if (_passwordController.text.isNotEmpty && isValidating
                          && _passwordController.text !=
                                  _savedPassCode
                          )
                            Padding(
                              padding: EdgeInsets.only(top: 7.sp),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "*Enter correct pin",
                                  /* textAlign :TextAlign.left,*/
                                  style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.errorColor),
                                ),
                              ),
                            ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResetEmail(),
                                ),
                              ),
                              child: Text(
                                'Forgot password?'.tr(),
                                style: TextStyle(
                                  fontSize: 11.7.sp,
                                  fontWeight: FontWeight.bold,
                                  color: themeNotifier.isDark
                                      ? AppColors.textColorGrey
                                      : AppColors.textColorBlack,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          // Expanded(child: SizedBox()),
                          // Spacer(flex: 1,),

                          SizedBox(
                            height: 6.h,
                          ),
                          AppButton(
                              title: 'Unlock'.tr(),
                              isactive: isButtonActive ? true : false,
                              handler: () async {
                                setState(() {
                                  isValidating = true;
                                });
                                if(_passwordController.text.isNotEmpty) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await Future.delayed(
                                      Duration(milliseconds: 1500),
                                          () {});
                                  if (_passwordController.text ==
                                      _savedPassCode) {
                                    widget.handler();
                                  }

                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => WalletTokensNfts(),
                                //   ),
                                // );
                              },
                              isGradient: true,
                              color: Colors.transparent),
                          SizedBox(
                            height: 9.h,
                          ),
                          // Spacer(flex: 2,),

                          // FooterText(),
                          //   SizedBox(
                          //     height: 2.h,
                          //   )
                        ],
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
}
