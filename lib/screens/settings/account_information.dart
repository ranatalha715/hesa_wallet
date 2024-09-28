import 'dart:async';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/providers/user_provider.dart';
import 'dart:io' as OS;
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/button.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/main_header.dart';
import '../../widgets/otp_dialog.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({Key? key}) : super(key: key);

  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _identificationNumberController =
      TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();

  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController otp5Controller = TextEditingController();
  final TextEditingController otp6Controller = TextEditingController();

  FocusNode firstFieldFocusNode = FocusNode();
  FocusNode secondFieldFocusNode = FocusNode();
  FocusNode thirdFieldFocusNode = FocusNode();
  FocusNode forthFieldFocusNode = FocusNode();
  FocusNode fifthFieldFocusNode = FocusNode();
  FocusNode sixthFieldFocusNode = FocusNode();

  String firstName = '';
  String lastName = '';
  String mobileNum = '';
  String idNumber = '';
  bool isOtpButtonActive = false;
  String username = '';
  String email = '';
  String nationality = '';
  int _timeLeft = 60;
  Timer? _timer;
  bool _isTimerActive = false;
  var _isLoadingResend = false;
  late StreamController<int> _events;
  bool isValidating = false;
  bool isButtonActive = false;
  bool isKeyboardVisible = false;
  bool isEditAble = false;
  var _isLoading = false;
  var accessToken = "";

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    // print(accessToken);
  }

  void startTimer() {
    // Cancel the previous timer if it's active
    _timer?.cancel();
    _timeLeft = 60;
    _isTimerActive = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
      }
      print(_timeLeft);
      _events.add(_timeLeft);
    });
  }

  Future<void> init() async {
    await getAccessToken();
    print("this is token" + accessToken);
    var userDetails = await Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    await Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);
    setState(() {
      _isLoading = false;
    });
    setState(() {
      mobileNum = userDetails
          .mobileNum!;
      _numberController.text = mobileNum.substring(4);
      firstName = userDetails
          .firstName!;
      _firstnameController.text = firstName;
      lastName = userDetails
          .lastName!;
      _lastnameController.text = lastName;
      idNumber = userDetails
          .idNumber!;
      _identificationNumberController.text = idNumber;
      username = userDetails
          .userName!;
      _usernameController.text = username;
      email = userDetails
          .verifiedEmail!;
      _emailController.text = email;
      nationality = userDetails
          .userNationality!;
      _nationalityController.text = nationality;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
    _events = new StreamController<int>();
    _events.add(60);
    // getAccessToken();
    _firstnameController.addListener(_updateButtonState);
    _usernameController.addListener(_updateButtonState);
    _numberController.addListener(_updateButtonState);
    _lastnameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _nationalityController.addListener(_updateButtonState);
    _identificationNumberController.addListener(_updateButtonState);
    otp1Controller.addListener(_updateOtpButtonState);
    otp2Controller.addListener(_updateOtpButtonState);
    otp3Controller.addListener(_updateOtpButtonState);
    otp4Controller.addListener(_updateOtpButtonState);
    otp5Controller.addListener(_updateOtpButtonState);
    otp6Controller.addListener(_updateOtpButtonState);
    KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
  });}

  void _updateOtpButtonState() {
    setState(() {
      isOtpButtonActive = otp1Controller.text.isNotEmpty &&
          otp2Controller.text.isNotEmpty &&
          otp3Controller.text.isNotEmpty &&
          otp4Controller.text.isNotEmpty &&
          otp5Controller.text.isNotEmpty &&
          otp6Controller.text.isNotEmpty;
    });
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _firstnameController.text.isNotEmpty &&
          _lastnameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _numberController.text.isNotEmpty;
    });
  }

  Future<void> _refreshData() async {
    Navigator.pop(context);
    setState(() {
      _isLoading = true;
    });
    Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(token: accessToken, context: context);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _usernameController.dispose();
    _numberController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _nationalityController.dispose();
    _nationalityController.dispose();
    _identificationNumberController.dispose();
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    otp5Controller.dispose();
    otp6Controller.dispose();
    _events.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: themeNotifier.isDark
                ? AppColors.backgroundColor
                : AppColors.textColorWhite,
            body: Stack(
              children: [
                Column(
                  children: [
                    MainHeader(title: 'Account information'.tr()),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                        alignment: Alignment.centerRight,
                                        child: isEditAble
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                    right: 2.sp,
                                                    top: 18.sp,
                                                    bottom: 10.sp),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              AccountInformation()),
                                                    );
                                                    setState(() {
                                                      isEditAble = false;
                                                    });
                                                  },
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                      decoration:
                                                          TextDecoration.underline,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isEditAble = true;
                                                  });
                                                },
                                                child: Image.asset(
                                                  "assets/images/edit_information.png",
                                                  height: 6.h,
                                                  width: 6.w,
                                                ),
                                              )),
                                    Align(
                                      alignment: isEnglish
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: Text(
                                        'First Name'.tr(),
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
                                          readOnly: isEditAble ? false : true,
                                          controller: _firstnameController,
                                          keyboardType: TextInputType.name,
                                          // scrollPadding: EdgeInsets.only(
                                          //     bottom: MediaQuery.of(context)
                                          //             .viewInsets
                                          //             .bottom +
                                          //         200),
                                          style: TextStyle(
                                              fontSize: 10.2.sp,
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Inter'),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: OS.Platform.isIOS ? 13.5.sp : 10.0, horizontal:   OS.Platform.isIOS ? 10.sp :16.0),
                                            // hintText: 'No payment card have been added',
                                            hintStyle: TextStyle(
                                                fontSize: 10.2.sp,
                                                color: AppColors.textColorGrey,
                                                fontWeight: FontWeight.w400,
                                                // Off-white color,
                                                fontFamily: 'Inter'),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: _firstnameController
                                                              .text.isEmpty &&
                                                          isValidating &&
                                                          isEditAble
                                                      ? AppColors.errorColor
                                                      : Colors.transparent,
                                                )),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: isEditAble
                                                      ? AppColors
                                                          .focusTextFieldColor
                                                      : Colors.transparent,
                                                )),
                                          ),
                                          cursorColor: AppColors.textColorGrey),
                                    ),
                                    if (_firstnameController.text.isEmpty &&
                                        isEditAble &&
                                        isValidating)
                                      Padding(
                                        padding: EdgeInsets.only(top: 7.sp),
                                        child: Text(
                                          "*Enter first name",
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.errorColor),
                                        ),
                                      ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    Align(
                                      alignment: isEnglish
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: Text(
                                        'Last Name'.tr(),
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
                                          readOnly: isEditAble ? false : true,
                                          controller: _lastnameController,
                                          keyboardType: TextInputType.name,
                                          // scrollPadding: EdgeInsets.only(
                                          //     bottom: MediaQuery.of(context)
                                          //         .viewInsets
                                          //         .bottom),
                                          style: TextStyle(
                                              fontSize: 10.2.sp,
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack,
                                              fontWeight: FontWeight.w400,
                                              // Off-white color,
                                              fontFamily: 'Inter'),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: OS.Platform.isIOS ? 13.5.sp : 10.0, horizontal:   OS.Platform.isIOS ? 10.sp :16.0),
                                            hintStyle: TextStyle(
                                                fontSize: 10.2.sp,
                                                color: AppColors.textColorGrey,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Inter'),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: _lastnameController
                                                              .text.isEmpty &&
                                                          isValidating
                                                      ? AppColors.errorColor
                                                      : Colors.transparent,
                                                  // Off-white color
                                                  // width: 2.0,
                                                )),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: isEditAble
                                                      ? AppColors
                                                          .focusTextFieldColor
                                                      : Colors.transparent,
                                                )),
                                          ),
                                          cursorColor: AppColors.textColorGrey),
                                    ),
                                    if (_lastnameController.text.isEmpty &&
                                        isValidating)
                                      Padding(
                                        padding: EdgeInsets.only(top: 7.sp),
                                        child: Text(
                                          "*Enter last name",
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.errorColor),
                                        ),
                                      ),
                                    if (!isEditAble)
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                    if (!isEditAble)
                                      Align(
                                        alignment: isEnglish
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: Text(
                                          'Username'.tr(),
                                          style: TextStyle(
                                              fontSize: 11.7.sp,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack),
                                        ),
                                      ),
                                    if (!isEditAble)
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                    if (!isEditAble)
                                      TextFieldParent(
                                        child: TextField(
                                            readOnly: true,
                                            controller: _usernameController,
                                            keyboardType: TextInputType.name,
                                            scrollPadding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom),
                                            style: TextStyle(
                                                fontSize: 10.2.sp,
                                                color: themeNotifier.isDark
                                                    ? AppColors.textColorWhite
                                                    : AppColors.textColorBlack,
                                                fontWeight: FontWeight.w400,
                                                // Off-white color,
                                                fontFamily: 'Inter'),
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(
                                                  vertical: OS.Platform.isIOS ? 13.5.sp : 10.0, horizontal:   OS.Platform.isIOS ? 10.sp :16.0),
                                              hintStyle: TextStyle(
                                                  fontSize: 10.2.sp,
                                                  color: AppColors.textColorGrey,
                                                  fontWeight: FontWeight.w400,
                                                  // Off-white color,
                                                  fontFamily: 'Inter'),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                    // Off-white color
                                                    // width: 2.0,
                                                  )),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                  borderSide: BorderSide(
                                                    color: isEditAble
                                                        ? AppColors
                                                            .focusTextFieldColor
                                                        : Colors.transparent,
                                                  )),
                                              // labelText: 'Enter your password',
                                            ),
                                            cursorColor: AppColors.textColorGrey),
                                      ),

                                    if (_usernameController.text.isEmpty &&
                                        isValidating &&
                                        !isEditAble)
                                      Padding(
                                        padding: EdgeInsets.only(top: 7.sp),
                                        child: Text(
                                          "*Enter username",
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.errorColor),
                                        ),
                                      ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    Align(
                                      alignment: isEnglish
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: Text(
                                        'Email Address'.tr(),
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
                                          readOnly: isEditAble ? false : true,
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          // scrollPadding: EdgeInsets.only(
                                          //     bottom: MediaQuery.of(context)
                                          //         .viewInsets
                                          //         .bottom),
                                          style: TextStyle(
                                              fontSize: 10.2.sp,
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack,
                                              fontWeight: FontWeight.w400,
                                              // Off-white color,
                                              fontFamily: 'Inter'),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: OS.Platform.isIOS ? 13.5.sp : 10.0, horizontal:   OS.Platform.isIOS ? 10.sp :16.0),
                                            hintStyle: TextStyle(
                                                fontSize: 10.2.sp,
                                                color: AppColors.textColorGrey,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Inter'),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: _emailController
                                                              .text.isEmpty &&
                                                          isValidating
                                                      ? AppColors.errorColor
                                                      : Colors.transparent,
                                                )),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: isEditAble
                                                      ? AppColors
                                                          .focusTextFieldColor
                                                      : Colors.transparent,
                                                )),
                                          ),
                                          cursorColor: AppColors.textColorGrey),
                                    ),
                                    if (_emailController.text.isEmpty &&
                                        isValidating)
                                      Padding(
                                        padding: EdgeInsets.only(top: 7.sp),
                                        child: Text(
                                          "*Enter Email",
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.errorColor),
                                        ),
                                      ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    Align(
                                      alignment: isEnglish
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: Text(
                                        'Mobile Number'.tr(),
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
                                          readOnly: isEditAble ? false : true,
                                          controller: _numberController,
                                          scrollPadding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                              fontSize: 10.2.sp,
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack,
                                              fontWeight: FontWeight.w400,
                                              // Off-white color,
                                              fontFamily: 'Inter'),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: OS.Platform.isIOS ? 13.5.sp : 10.0, horizontal:   OS.Platform.isIOS ? 10.sp :16.0),
                                            // hintText: 'Enter your Mobile Number',
                                            hintStyle: TextStyle(
                                                fontSize: 10.2.sp,
                                                color: AppColors.textColorGrey,
                                                fontWeight: FontWeight.w400,
                                                // Off-white color,
                                                fontFamily: 'Inter'),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: _numberController
                                                              .text.isEmpty &&
                                                          isValidating
                                                      ? AppColors.errorColor
                                                      : Colors.transparent,
                                                )),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: isEditAble
                                                      ? AppColors
                                                          .focusTextFieldColor
                                                      : Colors.transparent,
                                                )),

                                            prefixIcon: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 12.sp,
                                                  top: OS.Platform.isIOS ? 10.sp :12.4.sp,
                                                  right: 12.sp),
                                              child: Text(
                                                '+966',
                                                style: TextStyle(
                                                  color: themeNotifier.isDark
                                                      ? AppColors.textColorWhite
                                                      : AppColors.textColorBlack,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          cursorColor: AppColors.textColorGrey),
                                    ),
                                    if (_numberController.text.isEmpty &&
                                        isValidating)
                                      Padding(
                                        padding: EdgeInsets.only(top: 7.sp),
                                        child: Text(
                                          "*Enter number",
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.errorColor),
                                        ),
                                      ),
                                    if (!isEditAble)
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                    if (!isEditAble)
                                      Align(
                                        alignment: isEnglish
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: Text(
                                          'Nationality'.tr(),
                                          style: TextStyle(
                                              fontSize: 11.7.sp,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack),
                                        ),
                                      ),
                                    if (!isEditAble)
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                    if (!isEditAble)
                                      TextFieldParent(
                                        child: TextField(
                                            readOnly: true,
                                            controller: _nationalityController,
                                            keyboardType: TextInputType.name,
                                            scrollPadding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom),
                                            style: TextStyle(
                                                fontSize: 10.2.sp,
                                                color: themeNotifier.isDark
                                                    ? AppColors.textColorWhite
                                                    : AppColors.textColorBlack,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Inter'),
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(
                                                  vertical: OS.Platform.isIOS ? 13.5.sp : 10.0, horizontal:   OS.Platform.isIOS ? 10.sp :16.0),
                                              // hintText: 'No banking have been added',
                                              hintStyle: TextStyle(
                                                  fontSize: 10.2.sp,
                                                  color: AppColors.textColorGrey,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Inter'),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                  )),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                  )),
                                            ),
                                            cursorColor: AppColors.textColorGrey),
                                      ),
                                    if (_nationalityController.text.isEmpty &&
                                        isValidating &&
                                        !isEditAble)
                                      Padding(
                                        padding: EdgeInsets.only(top: 7.sp),
                                        child: Text(
                                          "*Enter Nationality",
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.errorColor),
                                        ),
                                      ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    if (!isEditAble)
                                      Align(
                                        alignment: isEnglish
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: Text(
                                          'Identification Number'.tr(),
                                          style: TextStyle(
                                              fontSize: 11.7.sp,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack),
                                        ),
                                      ),
                                    if (!isEditAble)
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                    if (!isEditAble)
                                      TextFieldParent(
                                        child: TextField(
                                            readOnly: true,
                                            controller:
                                                _identificationNumberController,
                                            keyboardType: TextInputType.name,
                                            scrollPadding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom),
                                            style: TextStyle(
                                                fontSize: 10.2.sp,
                                                color: themeNotifier.isDark
                                                    ? AppColors.textColorWhite
                                                    : AppColors.textColorBlack,
                                                fontWeight: FontWeight.w400,
                                                // Off-white color,
                                                fontFamily: 'Inter'),
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(
                                                  vertical: OS.Platform.isIOS ? 13.5.sp : 10.0, horizontal:   OS.Platform.isIOS ? 10.sp :16.0),
                                              // hintText: 'No banking have been added',
                                              hintStyle: TextStyle(
                                                  fontSize: 10.2.sp,
                                                  color: AppColors.textColorGrey,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Inter'),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                  )),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                  )),
                                            ),
                                            cursorColor: AppColors.textColorGrey),
                                      ),
                                    if (_identificationNumberController
                                            .text.isEmpty &&
                                        isValidating &&
                                        !isEditAble)
                                      Padding(
                                        padding: EdgeInsets.only(top: 7.sp),
                                        child: Text(
                                          "*Enter Identification Number",
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.errorColor),
                                        ),
                                      ),
                                    SizedBox(
                                      height: 19.h,
                                    ),
                                    if (isEditAble)
                                      Column(
                                        children: [
                                          Container(
                                            height: 2.h,
                                            width: double.infinity,
                                            color: AppColors.backgroundColor,
                                          ),
                                          Container(
                                            color: AppColors.backgroundColor,
                                            child: AppButton(
                                                title: 'Save changes'.tr(),
                                                isactive:
                                                    isEditAble && isButtonActive
                                                        ? true
                                                        : false,
                                                handler: () async {
                                                  setState(() {
                                                    isValidating = true;
                                                  });

                                                  if (isButtonActive &&
                                                      isEditAble == true) {
                                                    setState(() {
                                                      _isLoading = true;
                                                      if (_isLoading) {
                                                        FocusManager
                                                            .instance.primaryFocus
                                                            ?.unfocus();
                                                      }
                                                    });
                                                    var result = await Provider
                                                            .of<UserProvider>(
                                                                context,
                                                                listen: false)
                                                        .userUpdateStep1(
                                                      firstName:
                                                          _firstnameController
                                                              .text,
                                                      lastName:
                                                          _lastnameController
                                                              .text,
                                                      email:
                                                          _emailController.text,
                                                      mobileNumber: '+966' +
                                                          _numberController.text,
                                                      context: context,
                                                      token: accessToken,
                                                    );
                                                    await Future.delayed(
                                                        Duration(
                                                            milliseconds: 1000),
                                                        () {});
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                    if (result ==
                                                        AuthResult.success) {
                                                      print(
                                                          "Result is successful");
                                                      startTimer();
                                                      otpDialog(
                                                        fromAuth: false,
                                                        fromUser: true,
                                                        incorrect:
                                                            auth.otpErrorResponse,
                                                        // onClose: ()=> removeRoutes(),
                                                        events: _events,
                                                        firstBtnHandler:
                                                            () async {
                                                          setState(() {
                                                            _isLoading = true;
                                                          });
                                                          await Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      1000));
                                                          print('loading popup' +
                                                              _isLoading
                                                                  .toString());
                                                          final userUpdateWithOtpStep2 =
                                                              await Provider.of<
                                                                          UserProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .userUpdateStep2(
                                                            context: context,
                                                            code: Provider.of<
                                                                        AuthProvider>(
                                                                    context,
                                                                    listen: false)
                                                                .codeFromOtpBoxes,
                                                            token: accessToken,
                                                          );
                                                          setState(() {
                                                            _isLoading = false;
                                                          });
                                                          print('loading popup 2' +
                                                              _isLoading
                                                                  .toString());
                                                          if (userUpdateWithOtpStep2 ==
                                                              AuthResult
                                                                  .success) {
                                                            await Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                    500));
                                                            Navigator.pop(
                                                                context);
                                                            Navigator
                                                                .pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          AccountInformation()),
                                                            );
                                                          }
                                                        },
                                                        secondBtnHandler:
                                                            () async {
                                                          if (_timeLeft == 0) {
                                                            print(
                                                                'resend function calling');
                                                            try {
                                                              setState(() {
                                                                _isLoadingResend =
                                                                    true;
                                                              });
                                                              final result = await Provider.of<
                                                                          UserProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .userUpdateResendOtp(
                                                                      token:
                                                                          accessToken,
                                                                      context:
                                                                          context);
                                                              setState(() {
                                                                _isLoadingResend =
                                                                    false;
                                                              });
                                                              if (result ==
                                                                  AuthResult
                                                                      .success) {
                                                                startTimer();
                                                              }
                                                            } catch (error) {
                                                              print(
                                                                  "Error: $error");
                                                            } finally {
                                                              setState(() {
                                                                _isLoadingResend =
                                                                    false;
                                                              });
                                                            }
                                                          } else {}
                                                        },
                                                        firstTitle: 'Confirm',
                                                        secondTitle: 'Resend code ',

                                                        context: context,
                                                        isDark:
                                                            themeNotifier.isDark,
                                                        isFirstButtonActive:
                                                            isOtpButtonActive,
                                                        isSecondButtonActive:
                                                            false,
                                                        otp1Controller:
                                                            otp1Controller,
                                                        otp2Controller:
                                                            otp2Controller,
                                                        otp3Controller:
                                                            otp3Controller,
                                                        otp4Controller:
                                                            otp4Controller,
                                                        otp5Controller:
                                                            otp5Controller,
                                                        otp6Controller:
                                                            otp6Controller,
                                                        firstFieldFocusNode:
                                                            firstFieldFocusNode,
                                                        secondFieldFocusNode:
                                                            secondFieldFocusNode,
                                                        thirdFieldFocusNode:
                                                            thirdFieldFocusNode,
                                                        forthFieldFocusNode:
                                                            forthFieldFocusNode,
                                                        fifthFieldFocusNode:
                                                            fifthFieldFocusNode,
                                                        sixthFieldFocusNode:
                                                            sixthFieldFocusNode,
                                                        firstBtnBgColor: AppColors
                                                            .activeButtonColor,
                                                        firstBtnTextColor:
                                                            AppColors
                                                                .textColorBlack,
                                                        secondBtnBgColor:
                                                            Colors.transparent,
                                                        secondBtnTextColor:
                                                            _timeLeft != 0
                                                                ? AppColors
                                                                    .textColorBlack
                                                                    .withOpacity(
                                                                        0.8)
                                                                : AppColors
                                                                    .textColorWhite,
                                                        isLoading:
                                                            _isLoadingResend ||
                                                                _isLoading,
                                                      );
                                                    }
                                                  }
                                                },

                                                isGradient: true,
                                                color: AppColors.textColorBlack),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (OS.Platform.isIOS)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: KeyboardVisibilityBuilder(builder: (context, child) {
                      return Visibility(
                          visible: isKeyboardVisible,
                          child: GestureDetector(
                            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                            child: Container(
                                height: 3.h,
                                color: AppColors.profileHeaderDark,
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        'Done',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.5.sp,
                                            fontWeight: FontWeight.bold)
                                            .apply(fontWeightDelta: -1),
                                      ),
                                    ))),
                          ));
                    }),
                  ),
              ],
            ),
          ),
          if (_isLoading) LoaderBluredScreen()
        ],
      );
    });
  }
}
