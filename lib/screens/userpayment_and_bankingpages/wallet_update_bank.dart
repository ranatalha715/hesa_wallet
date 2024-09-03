import 'dart:async';
import 'dart:ui';

import 'package:animated_checkmark/animated_checkmark.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
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
import '../../models/bank_model.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';
import '../../widgets/otp_dialog.dart';
import '../signup_signin/terms_conditions.dart';

class WalletUpdateBank extends StatefulWidget {
  final String? accountNumber;
  final String? bankName;
  final String? accountTitle;
  final String? bic;
  final String? isPrimary;

  const WalletUpdateBank(
      {Key? key,
      this.accountNumber,
      this.bankName,
      this.accountTitle,
      this.bic,
      this.isPrimary})
      : super(key: key);

  @override
  State<WalletUpdateBank> createState() => _WalletUpdateBankState();
}

class _WalletUpdateBankState extends State<WalletUpdateBank> {
  final TextEditingController _ibannumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
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
  bool isEditAble = false;
  var selectedValue;
  bool isDropdownOpen = false;
  var _isLoading = false;
  var _isInit = true;
  bool isButtonActive = false;
  bool isOtpButtonActive = false;
  bool _isTextFieldFocused = false;
  String editAccountNumber = '';
  String editAccountTitle = '';
  String editBic = '';
  String editBankName = '';
  String editIsPrimary = '';
  Timer? _timer;
  int _timeLeft = 60;
  bool _isTimerActive = false;
  var _isLoadingResend = false;
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
    // accessToken = prefs.getString('accessToken')!;
    // print(accessToken);
    // print(accessToken);
  }

  List<BankName> allBanks=[];
  List<BankName> _filteredBanks = [];

  void _filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<BankName> filteredList = allBanks.where((bank) {
        String bankNameLower = bank.bankName.trim().toLowerCase();
        // String bankNameArLower = bank.bankNameAr.trim().toLowerCase();
        String queryLower = query.trim().toLowerCase();

        // Match either the English or Arabic bank name
        return bankNameLower.contains(queryLower);
        // ||
        // bankNameArLower.contains(queryLower);
      }).toList();
      // List<BankName> filteredList = allBanks
      //     .where((bank) =>
      //     bank.bankName.toLowerCase().contains(query.toLowerCase()))
      //     .toList();
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
    setState(() {
      editAccountNumber = widget.accountNumber!;
      editAccountTitle = widget.accountTitle!;
      editIsPrimary = widget.isPrimary!;
      editBic = widget.bic!;
      editBankName = widget.bankName!;

      _ibannumberController.text = editAccountNumber;
      _accountholdernamerController.text = editAccountTitle;
      _bankNameController.text = editBankName;
    });

    super.initState();
  }

  init() async {
    await getAccessToken();
    await Provider.of<BankProvider>(context, listen: false)
        .getAllBanks(accessToken);

    allBanks =  Provider.of<BankProvider>(context, listen: false).banks;
    // await Future.delayed(
    //     const Duration(
    //         milliseconds: 1000));
    _filteredBanks = allBanks;
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _ibannumberController.text.isNotEmpty &&
          _accountholdernamerController.text.isNotEmpty &&
          // _isChecked &&
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
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    var banks = Provider.of<BankProvider>(context, listen: false).banks;
    final bank = Provider.of<BankProvider>(context, listen: false);
    // print("testing" + _selectedBank);
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
                body: Column(children: [
                  MainHeader(title: 'Edit Bank Account'.tr()),
                  // SizedBox(
                  //   height: 4.h,

                  Expanded(
                    child: Container(
                      // color: Colors.red,
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
                                                  // Navigator.pushReplacement(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //       builder: (context) =>
                                                  //           AccountInformation()
                                                  //   ),
                                                  // );
                                                  setState(() {
                                                    isEditAble = false;
                                                  });
                                                },
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    decoration: TextDecoration
                                                        .underline,
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
                                  if (!isEditAble)
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
                                  if (!isEditAble)
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                  if (!isEditAble)
                                    TextFieldParent(
                                      child: TextField(
                                          readOnly: isEditAble ? false : true,
                                          controller: _bankNameController,
                                          focusNode: _ibanfocusNode,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.next,
                                          // scrollPadding: EdgeInsets.only(
                                          //     bottom: MediaQuery.of(context)
                                          //             .viewInsets
                                          //             .bottom +
                                          //         200),
                                          onEditingComplete: () {
                                            _beneficaryNamefocusNode
                                                .requestFocus();
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
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 16.0),
                                            hintText:
                                                'Enter account IBAN number'
                                                    .tr(),
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
                                                  color: isEditAble
                                                      ? AppColors
                                                          .focusTextFieldColor
                                                      : Colors.transparent,
                                                )),
                                            // labelText: 'Enter your password',
                                          ),
                                          cursorColor: AppColors.textColorGrey),
                                    ),
                                  if (isEditAble)
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                  if (isEditAble)
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
                                  if (isEditAble)
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                  if (isEditAble)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                                                color: AppColors
                                                    .textFieldParentDark,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8.0),
                                                  topRight:
                                                      Radius.circular(8.0),
                                                  bottomLeft: Radius.circular(
                                                      _isSelected ? 8.0 : 8.0),
                                                  // Adjust as needed
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
                                                    // SizedBox(
                                                    //   width: 0.5.h,
                                                    // ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0),
                                                      child: Container(
                                                        width: 65.w,
                                                        child: Text(
                                                          _selectedBank == ""
                                                              ? widget.bankName!
                                                              : _selectedBank,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              fontSize: 10.2.sp,
                                                              color: themeNotifier
                                                                      .isDark
                                                                  ? _selectedBank ==
                                                                          ""
                                                                      ? AppColors
                                                                          .textColorWhite
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
                                                  height: _filteredBanks
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
                                                              .withOpacity(
                                                                  0.10),
                                                          // Shadow color
                                                          offset: Offset(0, 4),
                                                          // Pushes the shadow down, removes the top shadow
                                                          blurRadius: 3,
                                                          // Adjust the blur radius to change shadow size
                                                          spreadRadius:
                                                              0.5, // Optional: Adjust spread radius if needed
                                                        ),
                                                      ],
                                                      // color: AppColors.errorColor,
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
                                                  child: Container(
                                                    height: 6.5.h,
                                                    decoration:
                                                    BoxDecoration(
                                                      color: AppColors
                                                          .transactionFeeBorder,
                                                      borderRadius:
                                                      BorderRadius.only(
                                                        topLeft:
                                                        Radius.circular(
                                                            8.0),
                                                        // Radius for top-left corner
                                                        topRight:
                                                        Radius.circular(
                                                            8.0),
                                                        bottomLeft:
                                                        Radius.circular(
                                                            8.0),
                                                        bottomRight:
                                                        Radius.circular(
                                                            8.0), // Radius for top-right corner
                                                      ),
                                                    ),
                                                    child: TextField(
                                                      // autofocus: true,
                                                      controller:
                                                          _searchController,
                                                      cursorColor: AppColors
                                                          .textColorGrey,
                                                      onChanged: (value) {
                                                        print("Search Query: $value");
                                                        _filterSearchResults(
                                                            value);
                                                      },
                                                      style: TextStyle(
                                                          fontSize: 10.2.sp,
                                                          color: themeNotifier
                                                                  .isDark
                                                              ? AppColors
                                                                  .textColorWhite
                                                              : AppColors
                                                                  .textColorBlack,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          // Off-white color,
                                                          fontFamily: 'Inter'),
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10.0,
                                                                    horizontal:
                                                                        16.0),
                                                        hintText: 'Search'.tr(),
                                                        hintStyle: TextStyle(
                                                            fontSize: 10.2.sp,
                                                            color: AppColors
                                                                .textColorGrey,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            // Off-white color,
                                                            fontFamily:
                                                                'Inter'),
                                                        suffixIcon: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  13.sp),
                                                          child: Image.asset(
                                                            "assets/images/search.png",
                                                            // height: 10.sp,
                                                            // width: 10.sp,
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
                                                                  // Off-white color
                                                                  // width: 2.0,
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
                                                        // labelText: 'Enter your password',
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
                                        readOnly: isEditAble ? false : true,
                                        controller: _ibannumberController,
                                        focusNode: _ibanfocusNode,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.next,
                                        // scrollPadding: EdgeInsets.only(
                                        //     bottom: MediaQuery.of(context)
                                        //             .viewInsets
                                        //             .bottom +
                                        //         200),
                                        onEditingComplete: () {
                                          _beneficaryNamefocusNode
                                              .requestFocus();
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
                                                color: isEditAble
                                                    ? AppColors
                                                        .focusTextFieldColor
                                                    : Colors.transparent,
                                              )),
                                          // labelText: 'Enter your password',
                                        ),
                                        cursorColor: AppColors.textColorGrey),
                                  ),
                                  if (_ibannumberController.text.isEmpty &&
                                      isValidating)
                                    Padding(
                                      padding: EdgeInsets.only(top: 7.sp),
                                      child: Text(
                                        // "*Please enter a valid email address".tr(),
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
                                        readOnly: isEditAble ? false : true,
                                        controller:
                                            _accountholdernamerController,
                                        focusNode: _beneficaryNamefocusNode,
                                        textInputAction: TextInputAction.done,
                                        scrollPadding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom +
                                                150),
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
                                          hintText: 'Full name'.tr(),
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
                                                        _accountholdernamerController
                                                            .text.isEmpty)
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
                                          // labelText: 'Enter your password',
                                        ),
                                        cursorColor: AppColors.textColorGrey),
                                  ),
                                  if (_accountholdernamerController
                                          .text.isEmpty &&
                                      isValidating)
                                    Padding(
                                      padding: EdgeInsets.only(top: 7.sp),
                                      child: Text(
                                        // "*Please enter a valid email address".tr(),
                                        "*Name should not be empty",
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.errorColor),
                                      ),
                                    ),
                                  SizedBox(
                                    height: _isSelected?6.5.h:31.h,
                                  ),
                                  if (isEditAble)
                                    Container(
                                      color: themeNotifier.isDark
                                          ? AppColors.backgroundColor
                                          : AppColors.textColorWhite,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 30.sp, left: 1.sp, right: 1.sp),
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
                                                  padding:
                                                  EdgeInsets.only(left: 4.sp),
                                                  child: GestureDetector(
                                                    onTap: () => setState(() {
                                                      _isChecked = !_isChecked;
                                                    }),
                                                    child: Container(
                                                      height: 2.4.h,
                                                      width: 2.4.h,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              2)),
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
                                                            // Animate the color
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
                                                // SizedBox(
                                                //   width: 2.w,
                                                // ),
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
                                                              // TextSpan(
                                                              //     text: ' of payment receiving.'
                                                              //         .tr(),
                                                              //     style: TextStyle(
                                                              //         color: AppColors
                                                              //             .textColorGrey,
                                                              //         fontWeight:
                                                              //         FontWeight.w400,
                                                              //         fontSize: 12.sp,
                                                              //         fontFamily: 'Inter'))
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

                                            // SizedBox(height: 3.h,),
                                            AppButton(
                                              title: 'Update'.tr(),
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
                                                      .updateBankAccountStep1(
                                                    bic: _selectedBankBic,
                                                    context: context,
                                                    token: accessToken,
                                                    isPrimary:
                                                    widget.isPrimary == "true"
                                                        ? true
                                                        : false, accountNumber: _ibannumberController.text, accountTitle: _accountholdernamerController.text,
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
                                                            .updateBankAccountStep2(
                                                            context: context,
                                                            token: accessToken,
                                                            code: Provider.of<
                                                                AuthProvider>(
                                                                context,
                                                                listen: false)
                                                                .codeFromOtpBoxes);
                                                        setState(() {
                                                          _isLoading = false;
                                                        });
                                                        print("after adding bank");
                                                        if (resultsecond ==
                                                            AuthResult.success) {
                                                          Navigator.pop(context);
                                                          updateSuccessDialog();



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
                                                                token:
                                                                accessToken);
                                                            setState(() {
                                                              _isLoadingResend =
                                                              false;
                                                            });
                                                            if (result ==
                                                                AuthResult.success) {
                                                              startTimer();
                                                            }
                                                          } catch (error) {
                                                            print("Error: $error");
                                                            // _showToast('An error occurred'); // Show an error message
                                                          } finally {
                                                            setState(() {
                                                              _isLoadingResend =
                                                              false;
                                                            });
                                                          }
                                                        } else {}
                                                      },
                                                      firstTitle: 'Verify',
                                                      secondTitle: 'Resend code: ',

                                                      // "${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}",

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
                                                      secondBtnTextColor: _timeLeft !=
                                                          0
                                                          ? AppColors.textColorBlack
                                                          .withOpacity(0.8)
                                                          : AppColors.textColorWhite,
                                                      // themeNotifier.isDark
                                                      //     ? AppColors.textColorWhite
                                                      //     : AppColors.textColorBlack
                                                      //         .withOpacity(0.8),
                                                      isLoading: _isLoading,
                                                    );
                                                  }
                                                }
                                              },
                                              isLoading: _isLoading,
                                              isGradient: true,
                                              color: Colors.transparent,
                                              // textColor: AppColors.textColorGreyShade2,
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
                ])),
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
          // mainAxisAlignment: english ? MainAxisAlignment.start : MainAxisAlignment.end,

          children: [
            // if (isFirst)
            //   Divider(
            //     color: AppColors.textColorGrey,
            //   ),
            Container(
              height: 5.5.h,
              decoration: BoxDecoration(
                color: AppColors.textFieldParentDark,
                // border: Border.all(
                //   color: _isSelected
                //       ? Colors.transparent
                //       : AppColors.textColorGrey,
                //   width: 1.0,
                // ),
                // borderRadius: BorderRadius.circular(8.0),
                borderRadius: BorderRadius.only(
                  bottomLeft:
                      Radius.circular(_isSelected && !isLast ? 0.0 : 8.0),
                  // Radius for top-left corner
                  bottomRight:
                      Radius.circular(_isSelected && !isLast ? 0.0 : 8.0),
                  topLeft: Radius.circular(_isSelected ? 0.0 : 8.0),
                  topRight: Radius.circular(
                      _isSelected ? 0.0 : 8.0), // Radius for top-right corner
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
                      // color: Colors.red,
                      width: 70.w,
                      child: Text(
                        bankName,
                        // "SNB (Saudi National Bank)".tr(),
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
            // if (!isLast)
            //   Divider(
            //     color: AppColors.textColorGrey,
            //   ),
            // if (isLast)
            //   SizedBox(
            //     height: 1.h,
            //   ),
          ],
        ),
      ),
    );
  }
  void updateSuccessDialog(){
      showDialog(
        context: context,
        builder: (BuildContext
        context) {
      final screenWidth =
          MediaQuery.of(
              context)
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
              builder:
                  (context) =>
                  WalletBankingAndPaymentEmpty()),
        );
      }

      Future.delayed(
          Duration(
              seconds: 3),
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
                dialogWidth,
                decoration:
                BoxDecoration(
                  // border: Border.all(
                  //     width:
                  //         0.1.h,
                  //     color: AppColors.textColorGrey),
                  color: AppColors.showDialogClr,
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child:
                Column(
                  mainAxisAlignment:
                  MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height:
                      4.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Update success'.tr(),
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color:  AppColors.textColorWhite),
                        ),
                        SizedBox(
                            width: 3.sp),
                        Align(
                          alignment:
                          Alignment.bottomCenter,
                          child:
                          Image.asset(
                            "assets/images/check_success.png",
                            height: 3.h,
                            width: 3.h,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: 2.h),
                    Text(
                      'Your bank details have been updated successfully.'.tr(),
                      textAlign:
                      TextAlign.center,
                      maxLines:
                      2,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11.sp,
                          color:  AppColors.textColorGrey),
                    ),
                    SizedBox(
                      height:
                      4.h,
                    ),
                  ],
                ),
              )),
        ); });
    });
} }
