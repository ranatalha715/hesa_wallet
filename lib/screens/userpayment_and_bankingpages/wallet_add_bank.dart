import 'dart:async';
import 'dart:ui';

import 'package:animated_checkmark/animated_checkmark.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/models/bank_model.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/providers/bank_provider.dart';
import 'package:hesa_wallet/providers/transaction_provider.dart';
import 'package:hesa_wallet/screens/userpayment_and_bankingpages/wallet_banking_and_payment_empty.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/configs.dart';
import '../../constants/styles.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';
import 'dart:io' as OS;
import '../../widgets/otp_dialog.dart';
import '../signup_signin/terms_conditions.dart';

class WalletAddBank extends StatefulWidget {
  const WalletAddBank({Key? key}) : super(key: key);

  @override
  State<WalletAddBank> createState() => _WalletAddBankState();
}

class _WalletAddBankState extends State<WalletAddBank> {
  final TextEditingController _ibannumberController = TextEditingController();
  final TextEditingController _accountholdernamerController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  FocusNode firstFieldFocusNode = FocusNode();
  FocusNode secondFieldFocusNode = FocusNode();
  FocusNode thirdFieldFocusNode = FocusNode();
  FocusNode forthFieldFocusNode = FocusNode();
  FocusNode fifthFieldFocusNode = FocusNode();
  FocusNode sixthFieldFocusNode = FocusNode();

  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController otp5Controller = TextEditingController();
  final TextEditingController otp6Controller = TextEditingController();

  bool _isSelected = false;
  bool _isChecked = false;
  var accessToken = "";
  var _selectedBank = '';
  var _selectedBankBic = '';
  var isValidating = false;
  var selectedValue;
  bool isDropdownOpen = false;
  var _isLoading = false;
  var _isInit = true;
  bool isButtonActive = false;
  bool isOtpButtonActive = false;
  bool _isTextFieldFocused = false;
  Timer? _timer;
  int _timeLeft = 60;
  bool _isTimerActive = false;
  var _isLoadingResend = false;
  bool isKeyboardVisible = false;
  late StreamController<int> _events;
  final ScrollController scrollController = ScrollController();
  FocusNode _ibanfocusNode = FocusNode();
  FocusNode _beneficaryNamefocusNode = FocusNode();
  TextEditingController _searchController = TextEditingController();


  String _searchQuery = "";

  void startTimer() {
    _isTimerActive = true;
    Timer.periodic(Duration(seconds: 1), (timer) {
      (_timeLeft > 0) ? _timeLeft-- : _timer?.cancel();
      print(_timeLeft);
      _events.add(_timeLeft);
    });
  }

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

  void _onFocusChange() {
    setState(() {
      _isTextFieldFocused =
          _ibanfocusNode.hasFocus || _beneficaryNamefocusNode.hasFocus;
      if (_isTextFieldFocused) {
        setState(() {
          _isSelected = false;
        });
      }
    });
  }

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
  }
  List<BankName> allBanks=[];
  List<BankName> _filteredBanks = [];

  void _filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<BankName> filteredList = allBanks.where((bank) {
        String bankNameLower = bank.bankName.trim().toLowerCase();
        String queryLower = query.trim().toLowerCase();
        return bankNameLower.contains(queryLower);

      }).toList();
      print("Filtered List Length: ${filteredList.length}");
      setState(() {
        _filteredBanks = filteredList;
      });
    } else {
      setState(() {
        _filteredBanks = allBanks;
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    Provider.of<BankProvider>(context, listen: false).addBankErrorResponse =
        null;
    getAccessToken();
    _events = new StreamController<int>();
    _events.add(60);
    _ibannumberController.addListener(_updateButtonState);
    _accountholdernamerController.addListener(_updateButtonState);
    _ibanfocusNode.addListener(_onFocusChange);
    _beneficaryNamefocusNode.addListener(_onFocusChange);
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
    });
   // init();
    super.initState();
  }

init() async {
  await getAccessToken();
  await Provider.of<BankProvider>(context, listen: false)
      .getAllBanks(accessToken);

  allBanks =  Provider.of<BankProvider>(context, listen: false).banks;
  _filteredBanks = allBanks;
}

  void _updateButtonState() {
    setState(() {
      isButtonActive = _ibannumberController.text.isNotEmpty &&
          _accountholdernamerController.text.isNotEmpty &&
          _selectedBank != "";
    });
  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      await init();
      setState(() {
        _isLoading = false;
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print("All banks");
    print(_filteredBanks);
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final bank = Provider.of<BankProvider>(context, listen: false);
    print("testing bic" + _selectedBankBic);
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isSelected = false;
          });
        },
        child: Stack(
          children: [
            Scaffold(
                backgroundColor: themeNotifier.isDark
                    ? AppColors.backgroundColor
                    : AppColors.textColorWhite,
                body:
                Stack(
                  children: [
                    Column(children: [
                      MainHeader(title: 'Add Bank Account'.tr()),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: 85.h,
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 17.sp),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 4.h,
                                      ),
                                      Align(
                                        alignment: isEnglish
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: Text(
                                          'Bank'.tr(),
                                          style: TextStyle(
                                              fontSize: 10.2.sp,
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
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () => setState(() {
                                                _isSelected = !_isSelected;
                                                !_isSelected? _filterSearchResults(""):null;
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
                                                        _isSelected ? 8.0 : 8.0),
                                                    bottomRight: Radius.circular(
                                                        _isSelected
                                                            ? 8.0
                                                            : 8.0), // Adjust as needed
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8.0),
                                                        child: Container(
                                                          width: 65.w,
                                                          child: Text(
                                                            _selectedBank == ""
                                                                ? 'Select Bank'.tr()
                                                                : _selectedBank,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight.w500,
                                                                fontSize: 10.2.sp,
                                                                color: themeNotifier
                                                                        .isDark
                                                                    ? _selectedBank ==
                                                                            ""
                                                                        ? AppColors
                                                                            .textColorGrey
                                                                        : AppColors
                                                                            .textColorWhite
                                                                    : AppColors
                                                                        .textColorBlack),
                                                          ),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                right: 10),
                                                        child: Icon(
                                                          _isSelected
                                                              ? Icons
                                                                  .keyboard_arrow_up
                                                              : Icons
                                                                  .keyboard_arrow_down,
                                                          size: 22.sp,
                                                          color: themeNotifier
                                                                  .isDark
                                                              ? AppColors
                                                                  .textColorGrey
                                                              : AppColors
                                                                  .textColorBlack,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (_isSelected)
                                              Stack(
                                                children: [
                                                  Container(
                                                    height:_filteredBanks
                                                        .length ==
                                                        1 ||
                                                        _filteredBanks
                                                            .length ==
                                                            2
                                                        ? 17.h : 24.h,
                                                    margin: EdgeInsets.only(
                                                        left: 1.sp,
                                                        right: 1.sp,
                                                        top: 0.4.h),
                                                    decoration: BoxDecoration(

                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(0.10),
                                                            offset: Offset(0, 4),
                                                            blurRadius: 3,
                                                            spreadRadius:
                                                                0.5,
                                                          ),
                                                        ],
                                                        color: AppColors
                                                            .textFieldParentDark,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                8)),
                                                    child:
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 2.h, top: 0.5.h),
                                                      child:
                                                      ListView.builder(
                                                              controller:
                                                                  scrollController,
                                                              itemCount:
                                                                  _filteredBanks.length,
                                                              shrinkWrap: true,
                                                              padding:
                                                                  EdgeInsets.zero,
                                                              itemBuilder:
                                                                  (context, index) {
                                                                bool isFirst =
                                                                    index == 0;

                                                                bool isLast = index ==
                                                                    _filteredBanks.length -
                                                                        1;

                                                                return

                                                                addBankslist(
                                                                  bankName:
                                                                  _filteredBanks[index]
                                                                          .bankName!,
                                                                  english: isEnglish
                                                                      ? true
                                                                      : false,
                                                                  isDark:
                                                                      themeNotifier
                                                                              .isDark
                                                                          ? true
                                                                          : false,
                                                                  isLast: isLast,
                                                                  bankBic:
                                                                  _filteredBanks[index]
                                                                          .bic,
                                                                  isFirst: isFirst,
                                                                );
                                                              })

                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 4,
                                                    left: 1,
                                                    right: 1,
                                                    child:
                                                    Container(
                                                      height: 6.5.h,
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .transactionFeeBorder,
                                                        borderRadius:
                                                        BorderRadius.only(
                                                          topLeft:
                                                          Radius.circular(8.0),
                                                          topRight:
                                                          Radius.circular(8.0),
                                                          bottomLeft:
                                                          Radius.circular(8.0),
                                                          bottomRight: Radius.circular(
                                                              8.0),
                                                        ),
                                                      ),
                                                      child:
                                                      TextField(
                                                        cursorColor:
                                                        AppColors.textColorGrey,
                                                        onChanged: (value) {
                                                          print("Search Query: $value");
                                                          _filterSearchResults(
                                                              value);
                                                        },
                                                        style: TextStyle(
                                                            fontSize: 10.2.sp,
                                                            color: AppColors
                                                                .textColorWhite,
                                                            fontWeight:
                                                            FontWeight.w400,
                                                            fontFamily: 'Inter'),
                                                        decoration: InputDecoration(
                                                          contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10.0,
                                                              horizontal: 16.0),
                                                          hintText: 'Search'.tr(),
                                                          hintStyle: TextStyle(
                                                              fontSize: 10.2.sp,
                                                              color: AppColors
                                                                  .textColorGrey,
                                                              fontWeight:
                                                              FontWeight.w400,
                                                              fontFamily: 'Inter'),
                                                          suffixIcon: Padding(
                                                            padding: EdgeInsets.all(
                                                                13.sp),
                                                            child: Image.asset(
                                                              "assets/images/search.png",
                                                            ),
                                                          ),
                                                          enabledBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8.0),
                                                              borderSide:
                                                              BorderSide(
                                                                color: Colors
                                                                    .transparent,
                                                              )),
                                                          focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8.0),
                                                              borderSide:
                                                              BorderSide(
                                                                color: AppColors
                                                                    .focusTextFieldColor,
                                                              )),

                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (_selectedBank == '' && isValidating)
                                        Padding(
                                          padding: EdgeInsets.only(top: 7.sp),
                                          child: Text(
                                            "*Please select atleast one bank",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10.sp,
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
                                          'IBAN  Number'.tr(),
                                          style: TextStyle(
                                              fontSize: 10.2.sp,
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
                                            controller: _ibannumberController,
                                            focusNode: _ibanfocusNode,
                                            keyboardType: TextInputType.number,
                                            textInputAction: TextInputAction.next,
                                            onEditingComplete: () {
                                              _beneficaryNamefocusNode.requestFocus();
                                            },
                                            onChanged: (v) {
                                              setState(() {
                                                _isSelected = false;
                                              });
                                              bank.addBankErrorResponse = null;
                                            },
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
                                                  'Enter account IBAN number'.tr(),
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
                                                    color: (isValidating &&
                                                                _ibannumberController
                                                                    .text
                                                                    .isEmpty) ||
                                                            bank.addBankErrorResponse
                                                                .toString()
                                                                .contains(
                                                                    'Invalid bank account')
                                                        ? AppColors.errorColor
                                                        : Colors.transparent,
                                                  )),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                  borderSide: BorderSide(
                                                    color: AppColors
                                                        .focusTextFieldColor,
                                                  )),
                                            ),
                                            cursorColor: AppColors.textColorGrey),
                                      ),
                                      if (_ibannumberController.text.isEmpty &&
                                          isValidating)
                                        Padding(
                                          padding: EdgeInsets.only(top: 7.sp),
                                          child: Text(
                                            "*IBAN number should not be empty",
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.errorColor),
                                          ),
                                        ),
                                      if ((bank.addBankErrorResponse
                                              .toString()
                                              .contains('Invalid bank account')) &&
                                          _ibannumberController.text.isNotEmpty)
                                        Padding(
                                          padding: EdgeInsets.only(top: 7.sp),
                                          child: Text(
                                            "*${bank.addBankErrorResponse}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10.sp,
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
                                          _accountholdernamerController
                                                      .text.length >=
                                                  3
                                              ? 'Account holder name'
                                              : 'Account Beneficiary Name'.tr(),
                                          style: TextStyle(
                                              fontSize: 10.2.sp,
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
                                            controller:
                                                _accountholdernamerController,
                                            focusNode: _beneficaryNamefocusNode,
                                            textInputAction: TextInputAction.done,
                                            style: TextStyle(
                                                fontSize: 10.2.sp,
                                                color: themeNotifier.isDark
                                                    ? AppColors.textColorWhite
                                                    : AppColors.textColorBlack,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Inter'),
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(
                                                  vertical: 10.0, horizontal: 16.0),
                                              hintText: 'Full name'.tr(),
                                              hintStyle: TextStyle(
                                                  fontSize: 10.2.sp,
                                                  color: AppColors.textColorGrey,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Inter'),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                  borderSide: BorderSide(
                                                    color: (isValidating &&
                                                        _accountholdernamerController
                                                            .text
                                                            .isEmpty)
                                                        ? AppColors.errorColor
                                                        : Colors.transparent,
                                                  )),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                  borderSide: BorderSide(
                                                    color: AppColors
                                                        .focusTextFieldColor,
                                                  )),
                                            ),
                                            cursorColor: AppColors.textColorGrey),
                                      ),
                                      if (_accountholdernamerController
                                              .text.isEmpty &&
                                          isValidating)
                                        Padding(
                                          padding: EdgeInsets.only(top: 7.sp),
                                          child: Text(
                                            "*Name should not be empty",
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.errorColor),
                                          ),
                                        ),
                                      SizedBox(
                                        height: _isSelected ?  OS.Platform.isIOS ? 7.5.h :10.h: OS.Platform.isIOS ? 32.h : 34.5.h,
                                      ),
                                      Container(
                                        color: themeNotifier.isDark
                                            ? AppColors.backgroundColor
                                            : AppColors.textColorWhite,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 10.sp, left: 1.sp, right: 1.sp),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                height: 1.5.h,
                                                color: AppColors.backgroundColor,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 4.sp),
                                                    child: GestureDetector(
                                                      onTap: () => setState(() {
                                                        _isChecked = !_isChecked;
                                                      }),
                                                      child:
                                                      Container(
                                                        height: 2.4.h,
                                                        width: 2.4.h,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius.circular(2)),
                                                        child: AnimatedContainer(
                                                            duration: Duration(
                                                                milliseconds: 300),
                                                            curve: Curves.easeInOut,
                                                            height: 2.4.h,
                                                            width: 2.4.h,
                                                            decoration: BoxDecoration(
                                                              color: _isChecked
                                                                  ? AppColors.hexaGreen
                                                                  : Colors.transparent,
                                                              border: Border.all(
                                                                  color: _isChecked
                                                                      ? AppColors
                                                                      .hexaGreen
                                                                      : AppColors
                                                                      .textColorWhite,
                                                                  width: 1),
                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  2),
                                                            ),
                                                            child: Checkmark(
                                                              checked: _isChecked,
                                                              indeterminate: false,
                                                              size: 11.sp,
                                                              color: Colors.black,
                                                              drawCross: false,
                                                              drawDash: false,
                                                            )),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      margin:
                                                      EdgeInsets.only(bottom: 3.sp),
                                                      child: Column(
                                                        children: [
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                    text:
                                                                    'I Agree to the Hesa Wallet '
                                                                        .tr(),
                                                                    style: TextStyle(
                                                                        color: AppColors
                                                                            .textColorWhite,
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                        fontSize: 10.sp,
                                                                        fontFamily:
                                                                        'Inter')),
                                                                TextSpan(
                                                                    recognizer:
                                                                    TapGestureRecognizer()
                                                                      ..onTap = () {

                                                                      },
                                                                    text:
                                                                    'Terms & Conditions'
                                                                        .tr(),
                                                                    style: TextStyle(
                                                                        color: themeNotifier.isDark
                                                                            ? AppColors
                                                                            .textColorToska
                                                                            : AppColors
                                                                            .textColorBlack,
                                                                        decoration:
                                                                        TextDecoration
                                                                            .underline,
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                        fontSize: 10.sp,
                                                                        fontFamily:
                                                                        'Inter')),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              AppButton(
                                                title: 'Add Bank Account'.tr(),
                                                isactive: isButtonActive && _isChecked
                                                    ? true
                                                    : false,
                                                handler: () async {
                                                  setState(() {
                                                    isValidating = true;
                                                  });
                                                  if (_ibannumberController
                                                      .text.isNotEmpty &&
                                                      _accountholdernamerController
                                                          .text.isNotEmpty &&
                                                      _selectedBank != "") {
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                    final result =
                                                    await Provider.of<BankProvider>(
                                                        context,
                                                        listen: false)
                                                        .addBankAccountStep1(
                                                      context: context,
                                                      token: accessToken,
                                                      ibanNumber:
                                                      _ibannumberController.text,
                                                      bankBic: _selectedBankBic,
                                                      accountTitle:
                                                      _accountholdernamerController
                                                          .text,
                                                    );
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                    if (result == AuthResult.success) {
                                                      startTimer();
                                                      otpDialog(
                                                        events: _events,
                                                        firstBtnHandler: () async {
                                                          setState(() {
                                                            _isLoading = true;
                                                          });
                                                          await Future.delayed(
                                                              const Duration(
                                                                  milliseconds: 1000));
                                                          final resultsecond = await Provider
                                                              .of<BankProvider>(
                                                              context,
                                                              listen: false)
                                                              .addBankAccountStep2(
                                                              context: context,
                                                              token: accessToken,
                                                              code: Provider.of<
                                                                  AuthProvider>(
                                                                  context,
                                                                  listen: false)
                                                                  .codeFromOtpBoxes
                                                          );
                                                          setState(() {
                                                            _isLoading = false;
                                                          });
                                                          print("after adding bank");
                                                          if (resultsecond ==
                                                              AuthResult.success) {
                                                            Navigator.pop(context);
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext context) {
                                                                final screenWidth =
                                                                    MediaQuery.of(context)
                                                                        .size
                                                                        .width;
                                                                final dialogWidth =
                                                                    screenWidth * 0.85;
                                                                void
                                                                closeDialogAndNavigate() {
                                                                  Navigator.of(context)
                                                                      .pop(); // Close the dialog
                                                                  // Navigator.of(context).pop(); // Close the
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            WalletBankingAndPaymentEmpty()),
                                                                  );
                                                                }

                                                                Future.delayed(
                                                                    Duration(seconds: 3),
                                                                    closeDialogAndNavigate);
                                                                return StatefulBuilder(
                                                                    builder: (BuildContext
                                                                    context,
                                                                        StateSetter
                                                                        setState) {
                                                                      return Dialog(
                                                                        shape:
                                                                        RoundedRectangleBorder(
                                                                          borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                              8.0),
                                                                        ),
                                                                        backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                        child: BackdropFilter(
                                                                            filter: ImageFilter
                                                                                .blur(
                                                                                sigmaX: 7,
                                                                                sigmaY:
                                                                                7),
                                                                            child: Container(
                                                                              height: 23.h,
                                                                              width:
                                                                              dialogWidth,
                                                                              decoration:
                                                                              BoxDecoration(
                                                                                color: themeNotifier.isDark
                                                                                    ? AppColors
                                                                                    .showDialogClr
                                                                                    : AppColors
                                                                                    .textColorWhite,
                                                                                borderRadius:
                                                                                BorderRadius
                                                                                    .circular(
                                                                                    15),
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: AppColors.textColorBlack.withOpacity(0.95),
                                                                                    offset: Offset(0, 0),
                                                                                    blurRadius: 10,
                                                                                    spreadRadius: 0.4,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              child: Column(
                                                                                mainAxisAlignment:
                                                                                MainAxisAlignment
                                                                                    .start,
                                                                                children: [
                                                                                  SizedBox(
                                                                                    height:
                                                                                    4.h,
                                                                                  ),
                                                                                  Align(
                                                                                    alignment:
                                                                                    Alignment
                                                                                        .bottomCenter,
                                                                                    child: Image
                                                                                        .asset(
                                                                                      "assets/images/bank_popup.png",
                                                                                      height:
                                                                                      6.h,
                                                                                      width:
                                                                                      5.8.h,
                                                                                      color: AppColors.hexaGreen,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                      height:
                                                                                      2.h),
                                                                                  Text(
                                                                                    'Your Bank account has been added'
                                                                                        .tr(),
                                                                                    textAlign:
                                                                                    TextAlign
                                                                                        .center,
                                                                                    maxLines:
                                                                                    2,
                                                                                    style: TextStyle(
                                                                                        fontWeight: FontWeight
                                                                                            .w600,
                                                                                        fontSize: 15
                                                                                            .sp,
                                                                                        color: themeNotifier.isDark
                                                                                            ? AppColors.textColorWhite
                                                                                            : AppColors.textColorBlack),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height:
                                                                                    4.h,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )),
                                                                      );
                                                                    });
                                                              },
                                                            );
                                                          }
                                                        },
                                                        secondBtnHandler: () async {
                                                          if (_timeLeft == 0) {
                                                            print(
                                                                'resend function calling');
                                                            try {
                                                              setState(() {
                                                                _isLoadingResend = true;
                                                              });
                                                              final result = await Provider
                                                                  .of<AuthProvider>(
                                                                  context,
                                                                  listen: false)
                                                                  .sendOTP(
                                                                  context: context,
                                                                  token: accessToken);
                                                              setState(() {
                                                                _isLoadingResend = false;
                                                              });
                                                              if (result ==
                                                                  AuthResult.success) {
                                                                startTimer();
                                                              }
                                                            } catch (error) {
                                                              print("Error: $error");
                                                            } finally {
                                                              setState(() {
                                                                _isLoadingResend = false;
                                                              });
                                                            }
                                                          } else {}
                                                        },
                                                        firstTitle: 'Verify',
                                                        secondTitle: 'Resend code: ',
                                                        context: context,
                                                        isDark: themeNotifier.isDark,
                                                        isFirstButtonActive:
                                                        isOtpButtonActive,
                                                        isSecondButtonActive: false,
                                                        otp1Controller: otp1Controller,
                                                        otp2Controller: otp2Controller,
                                                        otp3Controller: otp3Controller,
                                                        otp4Controller: otp4Controller,
                                                        otp5Controller: otp5Controller,
                                                        otp6Controller: otp6Controller,
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
                                                        firstBtnBgColor:
                                                        AppColors.activeButtonColor,
                                                        firstBtnTextColor:
                                                        AppColors.textColorBlack,
                                                        secondBtnBgColor:
                                                        Colors.transparent,
                                                        secondBtnTextColor: _timeLeft != 0
                                                            ? AppColors.textColorBlack
                                                            .withOpacity(0.8)
                                                            : AppColors.textColorWhite,
                                                        isLoading: _isLoading,
                                                      );
                                                    }
                                                  }
                                                },
                                                isLoading: _isLoading,
                                                isGradient: true,
                                                color: Colors.transparent,
                                              ),
                                              // SizedBox(
                                              //   height: 3.h,
                                              // ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      )
                    ]
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
        ),
      );
    });
  }

  Widget addBankslist({
    required String bankName,
    required String bankBic,
    bool isFirst = false,
    bool isLast = false,
    bool english = false,
    bool isDark = true,
  }) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedBank = bankName;
        _selectedBankBic = bankBic;
        _isSelected = false;
        _ibanfocusNode.requestFocus();
      }),
      child: Container(
        margin: EdgeInsets.only(top: isFirst ? 40.sp: 0),
        child: Column(
          children: [
            Container(
              height: 5.5.h,
              decoration: BoxDecoration(
                color: AppColors.textFieldParentDark,
                borderRadius: BorderRadius.only(
                  bottomLeft:
                      Radius.circular(_isSelected && !isLast ? 0.0 : 8.0),
                  bottomRight:
                      Radius.circular(_isSelected && !isLast ? 0.0 : 8.0),
                  topLeft: Radius.circular(_isSelected ? 0.0 : 8.0),
                  topRight: Radius.circular(
                      _isSelected ? 0.0 : 8.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                child: Row(
                  mainAxisAlignment:
                      english ? MainAxisAlignment.start : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 70.w,
                      child: Text(
                        bankName,
                        style: TextStyle(
                          fontSize: 10.2.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textColorWhite
                              : AppColors.textColorBlack,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}
