import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/screens/signup_signin/signup_with_email.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/app_header.dart';
import 'package:hesa_wallet/widgets/button.dart';
import 'package:hesa_wallet/widgets/main_header.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/theme_provider.dart';

class SignupWithMobile extends StatefulWidget {
  const SignupWithMobile({Key? key}) : super(key: key);

  @override
  State<SignupWithMobile> createState() => _SignupWithMobileState();
}

class _SignupWithMobileState extends State<SignupWithMobile> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _identificationtypeController =
      TextEditingController();
  final TextEditingController _identificationnumberController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode idTypeFocusNode = FocusNode();
  FocusNode idNumFocusNode = FocusNode();

// Create more FocusNode instances as needed for other fieldsident

  bool _isSelected = false;
  bool _isSelectedNationality = false;
  bool _isChecked = false;
  bool isValidating = false;
  var _selectedIDType = '';
  var _selectedNationalityType = '';
  bool isButtonActive = false;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Listen for changes in the text fields and update the button state
    _firstnameController.addListener(_updateButtonState);
    _lastnameController.addListener(_updateButtonState);
    _identificationnumberController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _firstnameController.text.isNotEmpty &&
          _lastnameController.text.isNotEmpty &&
          // _selectedNationalityType != "" &&
          _selectedIDType != "" &&
          // _isChecked &&
          _identificationnumberController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    // Clean up the controllers when they are no longer needed
    _firstnameController.dispose();
    _lastnameController.dispose();
    _identificationnumberController.dispose();
    super.dispose();
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
            body: Column(
              children: [
                MainHeader(title: 'Create a Wallet'.tr()),
                // SizedBox(
                //   height: 2.h,
                // ),
                Expanded(
                  child: Container(
                    height: 85.h,
                    // color: AppColors.gradientColor1,
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
                                // SizedBox(
                                //   height: 3.h,
                                // ),
                                // Text(
                                //   "Let's get started".tr(),
                                //   style: TextStyle(
                                //       color: themeNotifier.isDark
                                //           ? AppColors.textColorWhite
                                //           : AppColors.textColorBlack,
                                //       fontWeight: FontWeight.w600,
                                //       fontSize: 17.5.sp,
                                //       fontFamily: 'Inter'),
                                // ),
                                // SizedBox(
                                //   height: 1.h,
                                // ),
                                // Text(
                                //   "Please fill in your identity information to authentic your identity."
                                //       .tr(),
                                //   style: TextStyle(
                                //       // height: 1.4,
                                //       color: AppColors.textColorGrey,
                                //       fontWeight: FontWeight.w400,
                                //       fontSize: 11.7.sp,
                                //       fontFamily: 'Inter'),
                                // ),
                                SizedBox(
                                  height: 4.h,
                                ),
                                Align(
                                  alignment: isEnglish
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: Text(
                                    'First name'.tr(),
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
                                  child:
                                  TextField(
                                      focusNode: firstNameFocusNode,
                                      textInputAction: TextInputAction.next,
                                      onEditingComplete: () {
                                        lastNameFocusNode.requestFocus();
                                      },
                                      controller: _firstnameController,
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
                                        // border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 16.0),
                                        hintText: 'Enter first name'.tr(),
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
                                              color: Colors.transparent,
                                              // Off-white color
                                              // width: 2.0,
                                            )),
                                        // labelText: 'Enter your password',
                                      ),

                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_firstnameController.text.isEmpty &&
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
                                    'Last name'.tr(),
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
                                      focusNode: lastNameFocusNode,
                                      textInputAction: TextInputAction.next,
                                      onEditingComplete: () {
                                        idNumFocusNode.requestFocus();
                                      },
                                      controller: _lastnameController,
                                      keyboardType: TextInputType.name,
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom+100),
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
                                            vertical: 10.0, horizontal: 16.0),
                                        hintText: 'Enter last name'.tr(),
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
                                              color: Colors.transparent,
                                              // Off-white color
                                              // width: 2.0,
                                            )),
                                        // labelText: 'Enter your password',
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
                                        fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                // SizedBox(
                                //   height: 1.h,
                                // ),
                                // Align(
                                //   alignment: isEnglish
                                //       ? Alignment.centerLeft
                                //       : Alignment.centerRight,
                                //   child: Text(
                                //     'Nationality'.tr(),
                                //     style: TextStyle(
                                //         fontSize: 11.7.sp,
                                //         fontFamily: 'Inter',
                                //         fontWeight: FontWeight.w600,
                                //         color: themeNotifier.isDark
                                //             ? AppColors.textColorWhite
                                //             : AppColors.textColorBlack),
                                //   ),
                                // ),
                                // SizedBox(
                                //   height: 1.h,
                                // ),
                                // Container(
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(8.0),
                                //   ),
                                //   child: Column(
                                //     children: [
                                //       GestureDetector(
                                //         onTap: () => setState(() {
                                //           _isSelectedNationality =
                                //               !_isSelectedNationality;
                                //         }),
                                //         child: Container(
                                //           height: 6.5.h,
                                //           decoration: BoxDecoration(
                                //             color: AppColors.textFieldParentDark,
                                //             borderRadius: BorderRadius.only(
                                //               topLeft: Radius.circular(8.0),
                                //               topRight: Radius.circular(8.0),
                                //               bottomLeft: Radius.circular(
                                //                   _isSelectedNationality
                                //                       ? 0.0
                                //                       : 8.0), // Adjust as needed
                                //               bottomRight: Radius.circular(
                                //                   _isSelectedNationality
                                //                       ? 0.0
                                //                       : 8.0), // Adjust as needed
                                //             ),
                                //           ),
                                //           child: Padding(
                                //             padding: const EdgeInsets.symmetric(
                                //                 horizontal: 5),
                                //             child: Row(
                                //               mainAxisAlignment:
                                //                   MainAxisAlignment.start,
                                //               crossAxisAlignment:
                                //                   CrossAxisAlignment.center,
                                //               children: [
                                //                 Padding(
                                //                   padding:
                                //                       const EdgeInsets.symmetric(
                                //                           horizontal: 8.0),
                                //                   child: Text(
                                //                     _selectedNationalityType == ''
                                //                         ? 'Nationality'.tr()
                                //                         : _selectedNationalityType,
                                //                     style: TextStyle(
                                //                         fontWeight: FontWeight.w400,
                                //                         fontSize: 10.2.sp,
                                //                         color:
                                //                             _selectedNationalityType ==
                                //                                         '' ||
                                //                                     !themeNotifier
                                //                                         .isDark
                                //                                 ? AppColors
                                //                                     .footerColor
                                //                                 : AppColors
                                //                                     .textColorWhite),
                                //                   ),
                                //                 ),
                                //                 Spacer(),
                                //                 Padding(
                                //                   padding: const EdgeInsets.only(
                                //                       right: 10),
                                //                   child: Icon(
                                //                     _isSelectedNationality
                                //                         ? Icons.keyboard_arrow_up
                                //                         : Icons.keyboard_arrow_down,
                                //                     size: 21.sp,
                                //                     color: AppColors.textColorGrey,
                                //                   ),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //       // if (_isSelectedNationality)
                                //       //   ListView(
                                //       //     controller: _scrollController,
                                //       //     padding: EdgeInsets.zero,
                                //       //     shrinkWrap: true,
                                //       //     children: [
                                //       //       nationalityWidget(
                                //       //         // isFirst: true,
                                //       //         name: 'Pakistani'.tr(),
                                //       //         isDark: themeNotifier.isDark
                                //       //             ? true
                                //       //             : false,
                                //       //       ),
                                //       //       nationalityWidget(
                                //       //         name: 'Saudi'.tr(),
                                //       //         isDark: themeNotifier.isDark
                                //       //             ? true
                                //       //             : false,
                                //       //       ),
                                //       //       nationalityWidget(
                                //       //         isLast: true,
                                //       //         name: 'Indian'.tr(),
                                //       //         isDark: themeNotifier.isDark
                                //       //             ? true
                                //       //             : false,
                                //       //       ),
                                //       //     ],
                                //       //   )
                                //     ],
                                //   ),
                                // ),
                                // SizedBox(
                                //   height: 2.h,
                                // ),
                                Align(
                                  alignment: isEnglish
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: Text(
                                    'Identification type'.tr(),
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
                                Container(
                                  decoration: BoxDecoration(
                                    // border: Border.all(
                                    //   color: _isSelected
                                    //       ? AppColors.textColorGrey
                                    //       : Colors.transparent,
                                    //   width: 1.0,
                                    // ),
                                    borderRadius: BorderRadius.circular(8.0),
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
                                            // border: Border.all(
                                            //   color: _isSelected
                                            //       ? Colors.transparent
                                            //       : AppColors.textColorGrey,
                                            //   width: 1.0,
                                            // ),
                                            color: AppColors.textFieldParentDark,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8.0),
                                              topRight: Radius.circular(8.0),
                                              bottomLeft: Radius.circular(
                                                  _isSelected ? 0.0 : 8.0),
                                              // Adjust as needed
                                              bottomRight: Radius.circular(
                                                  _isSelected
                                                      ? 0.0
                                                      : 8.0), // Adjust as needed
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // SizedBox(
                                                //   width: 0.5.h,
                                                // ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8.0),
                                                  child: Text(
                                                    _selectedIDType == ''
                                                        ? 'National ID - Iqama'.tr()
                                                        : _selectedIDType,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: 10.2.sp,
                                                        color: _selectedIDType ==
                                                                    '' ||
                                                                !themeNotifier
                                                                    .isDark
                                                            ? AppColors.footerColor
                                                            : AppColors
                                                                .textColorWhite),
                                                  ),
                                                ),
                                                Spacer(),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      right: 10),
                                                  child: Icon(
                                                    _isSelected
                                                        ? Icons.keyboard_arrow_up
                                                        : Icons.keyboard_arrow_down,
                                                    size: 21.sp,
                                                    color: AppColors.textColorGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_isSelected)
                                        ListView(
                                          controller: _scrollController,
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          children: [
                                            identificationTypeWidget(
                                              isFirst: true,
                                              name: 'National ID'.tr(),
                                              isDark: themeNotifier.isDark
                                                  ? true
                                                  : false,
                                            ),
                                            identificationTypeWidget(
                                              isLast: true,
                                              name: 'Residence Iqama'.tr(),
                                              isDark: themeNotifier.isDark
                                                  ? true
                                                  : false,
                                            ),
                                          ],
                                        )
                                    ],
                                  ),
                                ),
                                if(_selectedIDType == '' && isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      "*Identification type should not be empty",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                // if (_isSelected)
                                SizedBox(
                                  height: 2.h,
                                ),
                                // // if (_isSelected)
                                Align(
                                  alignment: isEnglish
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: Text(
                                    'Identification number'.tr(),
                                    style: TextStyle(
                                        fontSize: 11.7.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        color: themeNotifier.isDark
                                            ? AppColors.textColorWhite
                                            : AppColors.textColorBlack),
                                  ),
                                ),
                                // if (_isSelected)
                                SizedBox(
                                  height: 1.h,
                                ),
                                // if (_isSelected)
                                TextFieldParent(
                                  child: TextField(
                                      focusNode: idNumFocusNode,
                                      textInputAction: TextInputAction.done,
                                      // onEditingComplete: () {
                                      // },
                                      controller: _identificationnumberController,
                                      keyboardType: TextInputType.number,
                                      scrollPadding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom*30),
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
                                            vertical: 10.0, horizontal: 16.0),
                                        hintText:
                                            'Enter Identification number'.tr(),
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
                                              color: Colors.transparent,
                                              // Off-white color
                                              // width: 2.0,
                                            )),
                                        // labelText: 'Enter your password',
                                      ),
                                      cursorColor: AppColors.textColorGrey),
                                ),
                                if (_identificationnumberController.text.isEmpty &&
                                    isValidating)
                                  Padding(
                                    padding: EdgeInsets.only(top: 7.sp),
                                    child: Text(
                                      // "*This ID number is previously registered",
                                      "*Identification number should not be empty",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                          fontSize: 10.sp,
                                          color: AppColors.errorColor),
                                    ),
                                  ),
                                // Container(color: AppColors.gradientColor1, height: 200,)
                                SizedBox(
                                  height: 22.h,
                                ),

                                Container(
                                  // color: AppColors.errorColor,
                                  color: themeNotifier.isDark
                                      ? AppColors.backgroundColor
                                      : AppColors.textColorWhite,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 1.5.h,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5, top: 2),
                                            child: GestureDetector(
                                              onTap: () => setState(() {
                                                _isChecked = !_isChecked;
                                              }),
                                              child: Container(
                                                height: 2.4.h,
                                                width: 2.4.h,
                                                decoration: BoxDecoration(
                                                  // gradient: LinearGradient(
                                                  //   colors: [
                                                  //     _isChecked
                                                  //         ? Color(0xff92B928)
                                                  //         : Colors.transparent,
                                                  //     _isChecked
                                                  //         ? Color(0xffC9C317)
                                                  //         : Colors.transparent
                                                  //   ],
                                                  // ),
                                                    border: Border.all(
                                                        color: AppColors.textColorWhite,
                                                        width: 1),
                                                    borderRadius: BorderRadius.circular(2)),
                                                child: _isChecked
                                                    ? Align(
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.check_rounded,
                                                    size: 8.2.sp,
                                                    color: AppColors.textColorWhite,
                                                  ),
                                                )
                                                    : SizedBox(),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 3.w,
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: Text(
                                                'I adhere that all the information provided is true and legally proven.'
                                                    .tr(),
                                                style: TextStyle(
                                                    color: AppColors.textColorWhite,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 9.sp,
                                                    fontFamily: 'Inter'),
                                                maxLines: 2,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      // Expanded(child: SizedBox()),
                                      AppButton(
                                          title: 'Continue'.tr(),
                                          isactive: isButtonActive
                                              // _firstnameController.text.isNotEmpty &&
                                              //         _lastnameController.text.isNotEmpty &&
                                              //         _identificationnumberController
                                              //             .text.isNotEmpty
                                              &&
                                              _isChecked
                                              ? true
                                              : false,
                                          handler: () async {
                                            setState(() {
                                              isValidating = true;
                                            });
                                            if (_firstnameController.text.isNotEmpty &&
                                                _lastnameController.text.isNotEmpty &&
                                                _identificationnumberController.text.isNotEmpty
                                            // &&
                                            // _identificationtypeController.text.isNotEmpty
                                            ) {
                                              setState(() {
                                                _isLoading = true;
                                                if (_isLoading) {
                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                }
                                              });
                                              await Future.delayed(Duration(milliseconds: 1500),
                                                      (){});
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              Navigator.of(context).pushNamed(
                                                  SignUpWithEmail.routeName,
                                                  arguments: {
                                                    'firstName': _firstnameController.text,
                                                    'lastName': _lastnameController.text,
                                                    'id': _identificationnumberController.text,
                                                    'idType': _selectedIDType,
                                                  });
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) => SignUpWithEmail(),
                                              //   ),
                                              // );
                                            }
                                          },
                                          isGradient: true,
                                          color: Colors.transparent),
                                      // SizedBox(
                                      //   height: 1.h,
                                      // )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 3.h,
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
          ),
          if(_isLoading)
            LoaderBluredScreen()
        ],
      );
    });
  }

  Widget identificationTypeWidget({
    bool isFirst = false,
    bool isLast = false,
    bool isDark = true,
    required String name,
  }) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedIDType = name;
        _isSelected = false;
      }),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isLast ? 8.0 : 0.0), // Adjust as needed
            bottomRight:
                Radius.circular(isLast ? 8.0 : 0.0), // Adjust as needed
          ),
          color: AppColors.textFieldParentDark, // Your desired background color
        ),
        child: Column(
          children: [
            // if (isFirst)
            //   Divider(
            //     color: AppColors.textColorGrey,
            //   ),
            Container(
              height: 5.h,
              decoration: BoxDecoration(
                // border: Border.all(
                //   color: _isSelected
                //       ? Colors.transparent
                //       : AppColors.textColorGrey,
                //   width: 1.0,
                // ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 5.sp : 0),
                      child: Text(
                        name,
                        style: TextStyle(
                            fontSize: 11.7.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textColorWhite
                                : AppColors.textColorBlack),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // if (!isLast)
            //   Divider(
            //     color: AppColors.textColorGrey,
            //   ),
            // if (isLast)
            SizedBox(
              height: 1.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget nationalityWidget({
    bool isFirst = false,
    bool isLast = false,
    bool isDark = true,
    required String name,
  }) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedNationalityType = name;
        _isSelectedNationality = false;
      }),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isLast ? 8.0 : 0.0), // Adjust as needed
            bottomRight:
                Radius.circular(isLast ? 8.0 : 0.0), // Adjust as needed
          ),
          color: AppColors.textFieldParentDark, // Your desired background color
        ),
        child: Column(
          children: [
            Container(
              height: 5.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 5.sp : 0),
                      child: Text(
                        name,
                        style: TextStyle(
                            fontSize: 11.7.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textColorWhite
                                : AppColors.textColorBlack),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // if (!isLast)
            //   Divider(
            //     color: AppColors.textColorGrey,
            //   ),
            // if (isLast)
            SizedBox(
              height: 1.h,
            ),
          ],
        ),
      ),
    );
  }
}
