import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/screens/signup_signin/signup_with_email.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:hesa_wallet/widgets/button.dart';
import 'package:hesa_wallet/widgets/main_header.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dart:io' as OS;
import 'package:animated_checkmark/animated_checkmark.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../../constants/configs.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

import '../../widgets/otp_dialog.dart';

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
  final TextEditingController _numberController = TextEditingController();

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

  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode idTypeFocusNode = FocusNode();
  FocusNode idNumFocusNode = FocusNode();
  FocusNode mobileNumFocusNode = FocusNode();
  bool _isSelected = false;
  bool _isSelectedNationality = false;
  bool _isChecked = false;
  var _isLoadingOtpDialoge = false;

  bool isValidating = false;
  var tokenizedUserPL;
  bool isOtpButtonActive = false;
  var _isLoadingResend = false;
  Timer? _timer;
  bool showNumError = false;
  StreamController<int> _events = StreamController<int>.broadcast();

  bool _isTimerActive = false;
  var _selectedIDType = '';
  var accessToken = "";
  String countryValue = "";
  var _selectedNationalityType = '';
  bool isButtonActive = false;
  bool isKeyboardVisible = false;
  var _isLoading = false;
  int _timeLeft = 60;

  getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    // print(accessToken);
  }

  final ScrollController scrollController = ScrollController();
  List<String> _allNationalities = [
    'Afghan',
    'Albanian',
    'Algerian',
    'American',
    'Andorran',
    'Angolan',
    'Antiguan',
    'Argentine',
    'Armenian',
    'Australian',
    'Austrian',
    'Azerbaijani',
    'Bahamian',
    'Bahraini',
    'Bangladeshi',
    'Barbadian',
    'Belarusian',
    'Belgian',
    'Belizean',
    'Beninese',
    'Bhutanese',
    'Bolivian',
    'Bosnian',
    'Botswanan',
    'Brazilian',
    'British',
    'Bruneian',
    'Bulgarian',
    'Burkinabé',
    'Burmese',
    'Burundian',
    'Cabo Verdean',
    'Cambodian',
    'Cameroonian',
    'Canadian',
    'Central African',
    'Chadian',
    'Chilean',
    'Chinese',
    'Colombian',
    'Comoran',
    'Congolese',
    'Costa Rican',
    'Croatian',
    'Cuban',
    'Cypriot',
    'Czech',
    'Danish',
    'Djiboutian',
    'Dominican',
    'Dutch',
    'East Timorese',
    'Ecuadorean',
    'Egyptian',
    'Emirati',
    'Equatorial Guinean',
    'Eritrean',
    'Estonian',
    'Ethiopian',
    'Fijian',
    'Finnish',
    'French',
    'Gabonese',
    'Gambian',
    'Georgian',
    'German',
    'Ghanaian',
    'Greek',
    'Grenadian',
    'Guatemalan',
    'Guinean',
    'Guinea-Bissauan',
    'Guyanese',
    'Haitian',
    'Honduran',
    'Hungarian',
    'Icelander',
    'Indian',
    'Indonesian',
    'Iranian',
    'Iraqi',
    'Irish',
    'Israeli',
    'Italian',
    'Ivorian',
    'Jamaican',
    'Japanese',
    'Jordanian',
    'Kazakh',
    'Kenyan',
    'Kiribati',
    'Kuwaiti',
    'Kyrgyz',
    'Laotian',
    'Latvian',
    'Lebanese',
    'Lesotho',
    'Liberian',
    'Libyan',
    'Liechtensteiner',
    'Lithuanian',
    'Luxembourger',
    'Macedonian',
    'Malagasy',
    'Malawian',
    'Malaysian',
    'Maldivian',
    'Malian',
    'Maltese',
    'Marshallese',
    'Mauritanian',
    'Mauritian',
    'Mexican',
    'Micronesian',
    'Moldovan',
    'Monacan',
    'Mongolian',
    'Montenegrin',
    'Moroccan',
    'Mozambican',
    'Namibian',
    'Nauruan',
    'Nepalese',
    'New Zealander',
    'Nicaraguan',
    'Nigerien',
    'Nigerian',
    'North Korean',
    'Norwegian',
    'Omani',
    'Pakistani',
    'Palauan',
    'Panamanian',
    'Papua New Guinean',
    'Paraguayan',
    'Peruvian',
    'Philippine',
    'Polish',
    'Portuguese',
    'Qatari',
    'Romanian',
    'Russian',
    'Rwandan',
    'Saint Kitts and Nevis',
    'Saint Lucian',
    'Salvadoran',
    'Samoan',
    'San Marinese',
    'Sao Tomean',
    'Saudi',
    'Senegalese',
    'Serbian',
    'Seychellois',
    'Sierra Leonean',
    'Singaporean',
    'Slovak',
    'Slovenian',
    'Solomon Islander',
    'Somali',
    'South African',
    'South Korean',
    'South Sudanese',
    'Spanish',
    'Sri Lankan',
    'Sudanese',
    'Surinamese',
    'Swazi',
    'Swedish',
    'Swiss',
    'Syrian',
    'Taiwanese',
    'Tajik',
    'Tanzanian',
    'Thai',
    'Togolese',
    'Tongan',
    'Trinidadian',
    'Tunisian',
    'Turkish',
    'Turkmen',
    'Tuvaluan',
    'Ugandan',
    'Ukrainian',
    'Uruguayan',
    'Uzbek',
    'Vanuatuan',
    'Venezuelan',
    'Vietnamese',
    'Yemeni',
    'Zambian',
    'Zimbabwean'
  ];
  List<String> _arabicNationalities = [
    'افغاني',
    'الباني',
    'جزائري',
    'امريكي',
    'اندوري',
    'انغولي',
    'انتيغوي',
    'ارجنتيني',
    'ارميني',
    'استرالي',
    'نمساوي',
    'اذربيجاني',
    'باهامي',
    'بحريني',
    'بنغلاديشي',
    'بربادوسي',
    'بيلاروسي',
    'بلجيكي',
    'بليزي',
    'بنيني',
    'بوتاني',
    'بوليفي',
    'بوسني',
    'بوتسواني',
    'برازيلي',
    'بريطاني',
    'بروناي',
    'بلغاري',
    'بوركيني',
    'بورمي',
    'بوروندي',
    'كيب فريدي',
    'كمبودي',
    'كاميروني',
    'كندي',
    'افريقي وسطي',
    'تشادي',
    'تشيلي',
    'صيني',
    'كولومبي',
    'قمري',
    'كونغولي',
    'كوستاريكي',
    'كرواتي',
    'كوبي',
    'قبرصي',
    'تشيكي',
    'دنماركي',
    'جيبوتي',
    'دومينيكاني',
    'هولندي',
    'تيموري شرقي',
    'اكوادوري',
    'مصري',
    'اماراتي',
    'غيني استوائي',
    'اريتري',
    'استوني',
    'اثيوبي',
    'فيجي',
    'فنلندي',
    'فرنسي',
    'غابوني',
    'غامبي',
    'جورجي',
    'الماني',
    'غاني',
    'يوناني',
    'غرينادي',
    'غواتيمالي',
    'غيني',
    'غيني بيساوي',
    'غوياني',
    'هايتي',
    'هندوراسي',
    'مجري',
    'ايسلندي',
    'هندي',
    'اندونيسي',
    'ايراني',
    'عراقي',
    'ايرلندي',
    'اسرائيلي',
    'ايطالي',
    'ساحل العاج',
    'جامايكي',
    'ياباني',
    'اردني',
    'كازاخي',
    'كيني',
    'كيريباتي',
    'كويتي',
    'قرغيزي',
    'لاوسي',
    'لاتفي',
    'لبناني',
    'ليسوتي',
    'ليبيري',
    'ليبي',
    'ليختنشتايني',
    'لتواني',
    'لوكسمبورغي',
    'مقدوني',
    'مدغشقري',
    'مالاوي',
    'ماليزي',
    'مالديفي',
    'مالي',
    'مالطي',
    'مارشالي',
    'موريتاني',
    'موريشيوسي',
    'مكسيكي',
    'مايكرونيزي',
    'مولدوفي',
    'موناكي',
    'منغولي',
    'مونتينيغري',
    'مغربي',
    'موزمبيقي',
    'ناميبي',
    'ناورو',
    'نيبالي',
    'نيوزيلندي',
    'نيكاراغوي',
    'نيجيري',
    'كوري شمالي',
    'نرويجي',
    'عماني',
    'باكستاني',
    'بالاوي',
    'بنمي',
    'بابوا غينيا الجديد',
    'باراغواي',
    'بيروفي',
    'فلبيني',
    'بولندي',
    'برتغالي',
    'قطري',
    'روماني',
    'روسي',
    'رواندي',
    'سانت كيتس ونيفيس',
    'سانت لوسي',
    'سلفادوري',
    'ساموي',
    'سان ماريني',
    'ساو تومي وبرينسيبي',
    'سعودي',
    'سنغالي',
    'صربي',
    'سيشلي',
    'سيراليوني',
    'سنغافوري',
    'سلوفاكي',
    'سلوفيني',
    'جزر سليمان',
    'صومالي',
    'جنوب افريقي',
    'كوري جنوبي',
    'جنوب سوداني',
    'اسباني',
    'سريلانكي',
    'سوداني',
    'سورينامي',
    'سوازي',
    'سويدي',
    'سويسري',
    'سوري',
    'تايواني',
    'طاجيكي',
    'تنزاني',
    'تايلاندي',
    'توغولي',
    'تونغي',
    'ترينيدادي',
    'تونسي',
    'تركي',
    'تركماني',
    'توفالي',
    'اوغندي',
    'اوكراني',
    'اوروغواي',
    'اوزبكي',
    'فانواتي',
    'فنزويلي',
    'فيتنامي',
    'يمني',
    'زامبي',
    'زيمبابوي'
  ];

  List<String> _currentNationalities = [];

  List<String> _filteredNationalities = [];

  void _filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<String> filteredList = _currentNationalities
          .where((nationality) =>
              nationality.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        _filteredNationalities = filteredList;
      });
    } else {
      setState(() {
        _filteredNationalities = _currentNationalities;
      });
    }
  }

  void _updateNationalities() {
    Locale currentLocale = Localizations.localeOf(context);
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    print("isEnglish");
    print(isEnglish);
    setState(() {
      _currentNationalities =
          isEnglish ? _allNationalities : _arabicNationalities;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNationalities();
      _filteredNationalities = _currentNationalities;
    });
    super.initState();
    getAccessToken();
    _events = new StreamController<int>();
    _events.add(60);
    _firstnameController.addListener(_updateButtonState);
    _lastnameController.addListener(_updateButtonState);
    _identificationnumberController.addListener(_updateButtonState);
    _identificationtypeController.addListener(_updateButtonState);
    _numberController.addListener(_updateButtonState);
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
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Locale currentLocale = context.locale;
      bool isEnglish = currentLocale.languageCode == 'en' ? true : false;

      setState(() {
        _currentNationalities =
            isEnglish ? _allNationalities : _arabicNationalities;
      });
    });

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  void _updateButtonState() {
    setState(() {
      isButtonActive = _firstnameController.text.isNotEmpty &&
          _lastnameController.text.isNotEmpty &&
          _identificationnumberController.text.isNotEmpty &&
          _selectedNationalityType != "" &&
          _numberController.text.isNotEmpty &&
          _selectedIDType != "";
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

  void restartCountdown() {
    // Reset the countdown to 60 seconds
    _events.add(60);
    Timer.periodic(Duration(seconds: 1), (timer) async {
      var events;
      if (events.hasListener) {
        final currentTime = await events.stream.first;
        if (currentTime > 0) {
          events.add(currentTime - 1);
        } else {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
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

  void updateDialogBoxButtonState() {
    setState(() {
      isOtpButtonActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    _currentNationalities =
        isEnglish ? _allNationalities : _arabicNationalities;

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
                    MainHeader(title: 'Create a Wallet'.tr()),
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
                                      child: TextField(
                                          textCapitalization:
                                              TextCapitalization.words,
                                          focusNode: firstNameFocusNode,
                                          textInputAction: TextInputAction.next,
                                          onEditingComplete: () {
                                            lastNameFocusNode.requestFocus();
                                          },
                                          controller: _firstnameController,
                                          keyboardType: TextInputType.text,
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
                                              fontFamily: 'Inter'),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: OS.Platform.isIOS
                                                        ? 14.5.sp
                                                        : 10.0,
                                                    horizontal:
                                                        OS.Platform.isIOS
                                                            ? 10.sp
                                                            : 16.0),
                                            hintText: 'Enter first name'.tr(),
                                            hintStyle: TextStyle(
                                                fontSize: 10.2.sp,
                                                color: AppColors.textColorGrey,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Inter'),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: _firstnameController
                                                              .text.isEmpty &&
                                                          isValidating
                                                      ? AppColors.errorColor
                                                      : Colors.transparent,
                                                )),
                                            focusedBorder: OutlineInputBorder(
                                                gapPadding: 0.0,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color: AppColors
                                                      .focusTextFieldColor,
                                                )),
                                          ),
                                          cursorColor: AppColors.textColorGrey),
                                    ),
                                    if (_firstnameController.text.isEmpty &&
                                        isValidating)
                                      Padding(
                                        padding: EdgeInsets.only(top: 7.sp),
                                        child: Text(
                                          "*Enter first name".tr(),
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
                                          textCapitalization:
                                              TextCapitalization.words,
                                          focusNode: lastNameFocusNode,
                                          textInputAction: TextInputAction.next,
                                          onEditingComplete: () {
                                            FocusScope.of(context).unfocus();

                                            setState(() {
                                              _isSelectedNationality = true;
                                            });
                                          },
                                          controller: _lastnameController,
                                          keyboardType: TextInputType.text,
                                          style: TextStyle(
                                              fontSize: 10.2.sp,
                                              color: themeNotifier.isDark
                                                  ? AppColors.textColorWhite
                                                  : AppColors.textColorBlack,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Inter'),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: OS.Platform.isIOS
                                                        ? 14.5.sp
                                                        : 10.0,
                                                    horizontal:
                                                        OS.Platform.isIOS
                                                            ? 10.sp
                                                            : 16.0),
                                            hintText: 'Enter last name'.tr(),
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
                                    if (_lastnameController.text.isEmpty &&
                                        isValidating)
                                      Padding(
                                        padding: EdgeInsets.only(top: 7.sp),
                                        child: Text(
                                          "*Enter last name".tr(),
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
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              // _updateNationalities();
                                              // Future.delayed(Duration(seconds: 10), () {
                                              setState(() {
                                                _isSelectedNationality =
                                                    !_isSelectedNationality;
                                                lastNameFocusNode.unfocus();
                                              });
                                              // });
                                            },
                                            child: Container(
                                              height: 6.5.h,
                                              decoration: BoxDecoration(
                                                color: AppColors
                                                    .textFieldParentDark,
                                                border: Border.all(
                                                  color: !_isSelectedNationality &&
                                                          _selectedNationalityType ==
                                                              '' &&
                                                          isValidating
                                                      ? AppColors.errorColor
                                                      : Colors.transparent,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8.0),
                                                  topRight:
                                                      Radius.circular(8.0),
                                                  bottomLeft: Radius.circular(
                                                      _isSelectedNationality
                                                          ? 8.0
                                                          : 8.0),
                                                  bottomRight: Radius.circular(
                                                      _isSelectedNationality
                                                          ? 8.0
                                                          : 8.0),
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
                                                      child: Text(
                                                        _selectedNationalityType ==
                                                                ''
                                                            ? 'Nationality'.tr()
                                                            : _selectedNationalityType,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 10.2.sp,
                                                            color: _selectedNationalityType ==
                                                                        '' ||
                                                                    !themeNotifier
                                                                        .isDark
                                                                ? AppColors
                                                                    .footerColor
                                                                : AppColors
                                                                    .textColorWhite),
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: Icon(
                                                        _isSelectedNationality
                                                            ? Icons
                                                                .keyboard_arrow_up
                                                            : Icons
                                                                .keyboard_arrow_down,
                                                        size: 21.sp,
                                                        color: AppColors
                                                            .textColorGrey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (_isSelectedNationality)
                                            Container(
                                                margin: EdgeInsets.only(
                                                    left: 1.sp,
                                                    right: 1.sp,
                                                    top: 0.4.h),
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .textFieldParentDark,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              8.sp)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.10),
                                                      // Shadow color
                                                      offset: Offset(0, 4),
                                                      // Pushes the shadow down, removes the top shadow
                                                      blurRadius: 3,
                                                      // Adjust the blur radius to change shadow size
                                                      spreadRadius:
                                                          0.5, // Optional: Adjust spread radius if needed
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      // padding: EdgeInsets.symmetric(horizontal: 10.0),
                                                      height: 6.5.h,
                                                      decoration: BoxDecoration(
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
                                                        cursorColor: AppColors
                                                            .textColorGrey,
                                                        onChanged: (value) {
                                                          _filterSearchResults(
                                                              value);
                                                        },
                                                        style: TextStyle(
                                                            fontSize: 10.2.sp,
                                                            color: AppColors
                                                                .textColorWhite,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            // Off-white color,
                                                            fontFamily:
                                                                'Inter'),
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          16.0),
                                                          hintText:
                                                              'Search'.tr(),
                                                          hintStyle: TextStyle(
                                                              fontSize: 10.2.sp,
                                                              color: AppColors
                                                                  .textColorGrey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
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
                                                    Container(
                                                      height: _filteredNationalities
                                                                      .length ==
                                                                  1 ||
                                                              _filteredNationalities
                                                                      .length ==
                                                                  2
                                                          ? 12.h
                                                          : _filteredNationalities
                                                                      .length ==
                                                                  0
                                                              ? 12.h
                                                              : 18.h,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 10.sp),
                                                        child: ListView.builder(
                                                          controller:
                                                              scrollController,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          // shrinkWrap: true,
                                                          itemCount:
                                                              _filteredNationalities
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            bool isLast = index ==
                                                                _filteredNationalities
                                                                        .length -
                                                                    1;
                                                            return GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  _selectedNationalityType =
                                                                      _filteredNationalities[
                                                                          index];
                                                                  _isSelected =
                                                                      true;
                                                                  _isSelectedNationality =
                                                                      false;
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    bottomLeft:
                                                                        Radius.circular(isLast
                                                                            ? 8.0
                                                                            : 0.0),
                                                                    // Adjust as needed
                                                                    bottomRight:
                                                                        Radius
                                                                            .circular(
                                                                      isLast
                                                                          ? 8.0
                                                                          : 0.0,
                                                                    ),
                                                                    // Adjust as needed
                                                                  ),
                                                                  color: AppColors
                                                                      .textFieldParentDark, // Your desired background color
                                                                ),
                                                                child: Column(
                                                                  children: [
                                                                    // if (isFirst)
                                                                    //   Divider(
                                                                    //     color: AppColors.textColorGrey,
                                                                    //   ),
                                                                    Container(
                                                                      height:
                                                                          5.h,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        // color: Colors.red,
                                                                        // border: Border.all(
                                                                        //   color: _isSelected
                                                                        //       ? Colors.transparent
                                                                        //       : AppColors.textColorGrey,
                                                                        //   width: 1.0,
                                                                        // ),

                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(horizontal: 10.sp),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Padding(
                                                                              padding: EdgeInsets.only(),
                                                                              child: Text(
                                                                                _filteredNationalities[index],
                                                                                style: TextStyle(fontSize: 11.7.sp, fontFamily: 'Inter', fontWeight: FontWeight.w500, color: AppColors.textColorWhite),
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
                                                                      height:
                                                                          1.h,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                            //   ListTile(
                                                            //   title: Text(_filteredNationalities[index]),
                                                            // );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    if (_selectedNationalityType == "" &&
                                        isValidating)
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 7.sp),
                                        child: Text(
                                          "*Nationality should not be empty"
                                              .tr(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.sp,
                                              color: AppColors.errorColor),
                                        ),
                                      ),
                                    SizedBox(
                                      height: 1.h,
                                    ),
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
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: !_isSelected &&
                                                  _selectedIDType == '' &&
                                                  isValidating
                                              ? AppColors.errorColor
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _isSelected = !_isSelected;
                                              });
                                            },
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
                                                      _isSelectedNationality
                                                          ? 8.0
                                                          : 8.0),
                                                  bottomRight: Radius.circular(
                                                      _isSelectedNationality
                                                          ? 8.0
                                                          : 8.0),
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
                                                      child: Text(
                                                        _selectedIDType == ''
                                                            ? 'National ID - Iqama'
                                                                .tr()
                                                            : _selectedIDType ==
                                                                    "NATIONAL_ID"
                                                                ? "National ID"
                                                                    .tr()
                                                                : _selectedIDType ==
                                                                        "IQAMA"
                                                                    ? "Iqama"
                                                                        .tr()
                                                                    : _selectedIDType ==
                                                                            "PASSPORT"
                                                                        ? "Passport"
                                                                            .tr()
                                                                        : _selectedIDType,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 10.2.sp,
                                                            color: _selectedIDType ==
                                                                        '' ||
                                                                    !themeNotifier
                                                                        .isDark
                                                                ? AppColors
                                                                    .footerColor
                                                                : AppColors
                                                                    .textColorWhite),
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
                                                        size: 21.sp,
                                                        color: AppColors
                                                            .textColorGrey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (_isSelected)
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 1.sp,
                                                  right: 1.sp,
                                                  top: 0.4.h),
                                              decoration: BoxDecoration(
                                                color: AppColors
                                                    .textFieldParentDark,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.sp)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.10),
                                                    offset: Offset(0, 4),
                                                    blurRadius: 3,
                                                    spreadRadius: 0.5,
                                                  ),
                                                ],
                                              ),
                                              child: ListView(
                                                controller: _scrollController,
                                                padding:
                                                    EdgeInsets.only(top: 0.4.h),
                                                shrinkWrap: true,
                                                children: [
                                                  identificationTypeWidget(
                                                    isFirst: true,
                                                    name: 'Iqama'.tr(),
                                                    isDark: themeNotifier.isDark
                                                        ? true
                                                        : false,
                                                  ),
                                                  identificationTypeWidget(
                                                    // isLast: false,
                                                    name: 'National ID'.tr(),
                                                    isDark: themeNotifier.isDark
                                                        ? true
                                                        : false,
                                                  ),
                                                  identificationTypeWidget(
                                                    isLast: true,
                                                    name: 'Passport'.tr(),
                                                    isDark: themeNotifier.isDark
                                                        ? true
                                                        : false,
                                                  ),
                                                ],
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                    if (_selectedIDType == '' && isValidating)
                                      Padding(
                                        padding: EdgeInsets.only(top: 7.sp),
                                        child: Text(
                                          "*Identification type should not be empty"
                                              .tr(),
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
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                    TextFieldParent(
                                      child: TextField(
                                          focusNode: idNumFocusNode,
                                          textInputAction: TextInputAction.next,
                                          controller:
                                              _identificationnumberController,
                                          keyboardType: TextInputType.number,
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
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: OS.Platform.isIOS
                                                        ? 14.5.sp
                                                        : 10.0,
                                                    horizontal:
                                                        OS.Platform.isIOS
                                                            ? 10.sp
                                                            : 16.0),
                                            hintText:
                                                'Enter Identification number'
                                                    .tr(),
                                            hintStyle: TextStyle(
                                                fontSize: 10.2.sp,
                                                color: AppColors.textColorGrey,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Inter'),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                  color:
                                                      _identificationnumberController
                                                                  .text
                                                                  .isEmpty &&
                                                              isValidating
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
                                    if (_identificationnumberController
                                            .text.isEmpty &&
                                        isValidating)
                                      Padding(
                                        padding: EdgeInsets.only(top: 7.sp),
                                        child: Text(
                                          "*Identification number should not be empty"
                                              .tr(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.sp,
                                              color: AppColors.errorColor),
                                        ),
                                      ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    // // if (_isSelected)
                                    Align(
                                      alignment: isEnglish
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: Text(
                                        'Mobile number'.tr(),
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
                                          focusNode: mobileNumFocusNode,
                                          textInputAction: TextInputAction.done,
                                          onChanged: (v) {
                                            auth.registerUserErrorResponse =
                                                null;
                                          },
                                          onEditingComplete: () {
                                            FocusScope.of(context).unfocus();
                                          },
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
                                              fontFamily: 'Inter'),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                10),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: OS.Platform.isIOS
                                                        ? 14.5.sp
                                                        : 10.0,
                                                    horizontal:
                                                        OS.Platform.isIOS
                                                            ? 10.sp
                                                            : 16.0),
                                            hintText:
                                                'Enter your mobile number'.tr(),
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
                                                              _numberController
                                                                  .text
                                                                  .isEmpty) ||
                                                          (_numberController
                                                                      .text
                                                                      .length <
                                                                  9 &&
                                                              _numberController
                                                                  .text
                                                                  .isNotEmpty
                                                          // &&
                                                          // isValidating
                                                          ) ||
                                                          auth.registerUserErrorResponse
                                                              .toString()
                                                              .contains(
                                                                  'Mobile number')
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
                                            prefixIcon: Padding(
                                              padding: EdgeInsets.only(
                                                left: 10.sp,
                                                top: OS.Platform.isIOS
                                                    ? 10.sp
                                                    : 12.7.sp,
                                                right: 11.4.sp,
                                              ),
                                              child: Text(
                                                '+966',
                                                style: TextStyle(
                                                  color: themeNotifier.isDark
                                                      ? AppColors.textColorWhite
                                                      : AppColors
                                                          .textColorBlack,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10.2.sp,
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
                                          "*Mobile number should not be empty"
                                              .tr(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.sp,
                                              color: AppColors.errorColor),
                                        ),
                                      ),
                                    if (_numberController.text.length < 9 &&
                                        _numberController.text.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(top: 7.sp),
                                        child: Text(
                                          "*Mobile Number should be minimum 9 Characters"
                                              .tr(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.sp,
                                              color: AppColors.errorColor),
                                        ),
                                      ),
                                    if (auth.registerUserErrorResponse !=
                                            null &&
                                        _numberController.text.isNotEmpty &&
                                        isValidating &&
                                        auth.registerUserErrorResponse
                                            .toString()
                                            .contains('Mobile number'))
                                      Padding(
                                        padding: EdgeInsets.only(top: 7.sp),
                                        child: Text(
                                          isEnglish
                                              ? "*${auth.registerUserErrorResponse}"
                                              : "رقم الجوال موجود بالفعل*",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.sp,
                                              color: AppColors.errorColor),
                                        ),
                                      ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Container(
                                      color: themeNotifier.isDark
                                          ? AppColors.backgroundColor
                                          : AppColors.textColorWhite,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 1.5.h,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5, top: 2),
                                                  child: GestureDetector(
                                                    onTap: () => setState(() {
                                                      _isChecked = !_isChecked;
                                                    }),
                                                    child: AnimatedContainer(
                                                        duration: Duration(
                                                            milliseconds: 300),
                                                        curve: Curves.easeInOut,
                                                        height: 2.4.h,
                                                        width: 2.4.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: _isChecked
                                                              ? AppColors
                                                                  .hexaGreen
                                                              : Colors
                                                                  .transparent,
                                                          // Animate the color
                                                          border: Border.all(
                                                              color: _isChecked
                                                                  ? AppColors
                                                                      .hexaGreen
                                                                  : AppColors
                                                                      .textColorWhite,
                                                              width: 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(2),
                                                        ),
                                                        child: Checkmark(
                                                          checked: _isChecked,
                                                          indeterminate: false,
                                                          size: 11.sp,
                                                          color: Colors.black,
                                                          drawCross: false,
                                                          drawDash: false,
                                                        )),
                                                  )),
                                              SizedBox(
                                                width: 3.w,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: Text(
                                                    'I adhere that all the information provided is true and legally proven.'
                                                        .tr(),
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .textColorWhite,
                                                        fontWeight:
                                                            FontWeight.w400,
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
                                          AppButton(
                                              title: 'Continue'.tr(),
                                              isactive:
                                                  isButtonActive && _isChecked
                                                      ? true
                                                      : false,
                                              handler: () async {
                                                setState(() {
                                                  isValidating = true;
                                                });
                                                if (isButtonActive &&
                                                    _isChecked) {
                                                  setState(() {
                                                    _isLoading = true;
                                                    if (_isLoading) {
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                    }
                                                  });
                                                  final registerStep1result =
                                                      await Provider.of<
                                                                  AuthProvider>(
                                                              context,
                                                              listen: false)
                                                          .registerUserStep1(
                                                    firstName:
                                                        _firstnameController
                                                            .text,
                                                    lastName:
                                                        _lastnameController
                                                            .text,
                                                    idNumber:
                                                        _identificationnumberController
                                                            .text,
                                                    idType: _selectedIDType,
                                                    nationality:
                                                        _selectedNationalityType,
                                                    mobileNumber:
                                                        _numberController.text,
                                                    context: context,
                                                  );
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                  if (registerStep1result ==
                                                      AuthResult.success) {
                                                    startTimer();
                                                    otpDialog(
                                                      events: _events,
                                                      firstBtnHandler:
                                                          () async {
                                                        try {
                                                          setState(() {
                                                            _isLoadingOtpDialoge =
                                                                true;
                                                          });
                                                          await Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      1000));
                                                          print('loading popup' +
                                                              _isLoadingOtpDialoge
                                                                  .toString());
                                                          final result = await Provider.of<
                                                                      AuthProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .registerUserStep2(
                                                                  context:
                                                                      context,
                                                                  code: Provider.of<
                                                                              AuthProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .codeFromOtpBoxes);
                                                          setState(() {
                                                            _isLoadingOtpDialoge =
                                                                false;
                                                          });
                                                          if (result ==
                                                              AuthResult
                                                                  .success) {
                                                            await Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        500));
                                                            Navigator.of(
                                                                    context)
                                                                .popAndPushNamed(
                                                                    SignUpWithEmail
                                                                        .routeName,
                                                                    arguments: {
                                                                  'firstName':
                                                                      _firstnameController
                                                                          .text,
                                                                  'lastName':
                                                                      _lastnameController
                                                                          .text,
                                                                  'id':
                                                                      _identificationnumberController
                                                                          .text,
                                                                  'idType':
                                                                      _selectedIDType,
                                                                });
                                                          }
                                                        } catch (error) {
                                                          print(
                                                              "Error: $error");
                                                          setState(() {
                                                            _isLoadingOtpDialoge =
                                                                false;
                                                          });
                                                        } finally {
                                                          setState(() {
                                                            _isLoadingOtpDialoge =
                                                                false;
                                                          });
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
                                                                        AuthProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .registerNumResendOtp(
                                                                    context:
                                                                        context,
                                                                    token:
                                                                        accessToken,
                                                                    medium:
                                                                        "sms");
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
                                                      secondTitle:
                                                          'Resend code ',
                                                      context: context,
                                                      isDark:
                                                          themeNotifier.isDark,
                                                      isFirstButtonActive:
                                                          isOtpButtonActive,
                                                      isSecondButtonActive:
                                                          !_isTimerActive,
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
                                                          _isLoadingOtpDialoge,
                                                    );
                                                  }
                                                }
                                              },
                                              isGradient: true,
                                              color: Colors.transparent),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: OS.Platform.isIOS ? 6.h : 4.h,
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
                            onTap: () =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            child: Container(
                                height: 3.h,
                                color: AppColors.profileHeaderDark,
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
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
          if (_isLoading)
            Positioned(
                top: 12.h,
                bottom: 0,
                left: 0,
                right: 0,
                child: LoaderBluredScreen())
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
      onTap: () {
        setState(() {
          _selectedIDType = name == 'National ID' || name == 'هوية وطنية'
              ? 'NATIONAL_ID'
              : name == 'Iqama' || name == 'اقامة'
                  ? 'IQAMA'
                  : name == 'Passport' || name == 'جواز'
                      ? 'PASSPORT'
                      : name;
          _isSelected = false;
        });
        idNumFocusNode.requestFocus();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isLast ? 8.0 : 0.0), // Adjust as needed
            bottomRight: Radius.circular(
              isLast ? 8.0 : 0.0,
            ), // Adjust as needed
            topRight: Radius.circular(
              isFirst ? 8.0 : 0.0,
            ),
            topLeft: Radius.circular(
              isFirst ? 8.0 : 0.0,
            ), // Adjust as needed
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
        _isSelected = true;
        _isSelectedNationality = false;
      }),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isLast ? 8.0 : 0.0), // Adjust as needed
            bottomRight: Radius.circular(
              isLast ? 8.0 : 0.0,
            ),
            topRight: Radius.circular(
              isFirst ? 8.0 : 0.0,
            ),
            topLeft: Radius.circular(
              isFirst ? 8.0 : 0.0,
            ),
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
                      padding: EdgeInsets.only(
                          bottom: isLast ? 5.sp : 0, top: isFirst ? 7.sp : 0),
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
            SizedBox(
              height: 1.h,
            ),
          ],
        ),
      ),
    );
  }
}

extension Capitalizing on String {
  String get capitalized {
    if (isEmpty) return '';
    return replaceFirst(this[0], this[0].toUpperCase());
  }
}
