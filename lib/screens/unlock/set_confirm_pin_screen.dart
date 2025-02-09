import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/screens/user_profile_pages/wallet_tokens_nfts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../widgets/main_header.dart';

class SetConfirmPinScreen extends StatefulWidget {
  static const routeName = '/SetConfirmPinScreen';

  const SetConfirmPinScreen({Key? key}) : super(key: key);

  @override
  State<SetConfirmPinScreen> createState() => _SetConfirmPinScreenState();
}

class _SetConfirmPinScreenState extends State<SetConfirmPinScreen> {
  late Timer _timer;
  String selectedNumber = '';
  List<String> numbers = List.generate(6, (index) => '');
  List<String> numbersToSave = List.generate(6, (index) => '');
  bool isFirstFieldFilled = false;
  bool isMatched = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        // Convert entered digits to asterisks
        for (int i = 0; i < numbers.length; i++) {
          if (numbers[i].isNotEmpty) {
            numbers[i] = '*';
          }
        }
        isFirstFieldFilled = numbers[5].isNotEmpty;
      });
    });
  }

  Future<void> savePasscode(String passcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString("passcode", passcode);
    print("Passcode saved: $passcode");
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = context.locale;
    bool isEnglish = currentLocale.languageCode == 'en' ? true : false;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          MainHeader(title: 'Set PIN'.tr()),
          Container(
            height: 8.h,
            // color: Colors.redAccent
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Re Enter PIN'.tr(),
                style: TextStyle(
                    fontSize: 13.sp,
                    color: isFirstFieldFilled
                        ? isMatched
                            ? AppColors.activeButtonColor
                            : AppColors.errorColor
                        : AppColors.textColorWhite,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'inter'),
              ),
            ),
          ),
          Container(
            height: 13.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: isEnglish
                    ? [
                        circularTextField(0, isMatched),
                        circularTextField(1, isMatched),
                        circularTextField(2, isMatched),
                        circularTextField(3, isMatched),
                        circularTextField(4, isMatched),
                        circularTextField(5, isMatched),
                      ]
                    : [
                        circularTextField(5, isMatched),
                        circularTextField(4, isMatched),
                        circularTextField(3, isMatched),
                        circularTextField(2, isMatched),
                        circularTextField(1, isMatched),
                        circularTextField(0, isMatched),
                      ],
              ),
            ),
          ),
          Container(
            height: 64.h,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: isEnglish
                        ? [
                            digitBox('1', passcodeToSet: args!['passcode']),
                            digitBox('2', passcodeToSet: args['passcode']),
                            digitBox('3', passcodeToSet: args['passcode']),
                          ]
                        : [
                            digitBox('3', passcodeToSet: args!['passcode']),
                            digitBox('2', passcodeToSet: args['passcode']),
                            digitBox('1', passcodeToSet: args['passcode']),
                          ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: isEnglish
                        ? [
                            digitBox('4', passcodeToSet: args['passcode']),
                            digitBox('5', passcodeToSet: args['passcode']),
                            digitBox('6', passcodeToSet: args['passcode']),
                          ]
                        : [
                            digitBox('6', passcodeToSet: args['passcode']),
                            digitBox('5', passcodeToSet: args['passcode']),
                            digitBox('4', passcodeToSet: args['passcode']),
                          ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      digitBox('7', passcodeToSet: args['passcode']),
                      digitBox('8', passcodeToSet: args['passcode']),
                      digitBox('9', passcodeToSet: args['passcode']),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: isEnglish
                        ? [
                            digitBox(''),
                            digitBox('0', passcodeToSet: args['passcode']),
                            digitBox(
                              '',
                              imagePath: 'assets/images/remove_button.png',
                            ),
                          ]
                        : [
                            digitBox(
                              '',
                              imagePath: 'assets/images/remove_button.png',
                            ),
                            digitBox('0', passcodeToSet: args['passcode']),
                            digitBox(
                              '',
                            ),
                          ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget circularTextField(int index, bool isMatched) {
    return GestureDetector(
      child: Container(
        height: 5.h,
        width: 5.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: isFirstFieldFilled
                ? isMatched
                    ? AppColors.activeButtonColor
                    : AppColors.errorColor
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(40),
          color: isFirstFieldFilled
              ? Colors.transparent
              : Colors.grey.withOpacity(0.2),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: numbers[index] == '*' ? 5.sp : 0),
            child: Text(
              numbers[index],
              style: TextStyle(
                fontSize: 17.sp,
                color: isMatched
                    ? AppColors.activeButtonColor
                    : AppColors.errorColor,
                fontWeight: FontWeight.w400,
                fontFamily: 'ArialASDCF',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget pinBox(String number) {
    return Container(
        height: 5.h,
        width: 5.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: AppColors.textColorGreyShade2.withOpacity(0.05),
        ),
        child: Center(
            child: Text(
          number,
          style: TextStyle(
            fontSize: 24.sp,
            color: number.isNotEmpty
                ? AppColors.textColorWhite
                : Colors.black, // Adjust color based on selection
            fontWeight: FontWeight.w400,
            fontFamily: 'ArialASDCF',
          ),
        )));
  }

  Widget digitBox(String number, {String? imagePath, String? passcodeToSet}) {
    return InkWell(
      hoverColor: Colors.grey.withOpacity(0.2),
      borderRadius: BorderRadius.circular(50.sp),
      onLongPress: () {
        setState(() {
          for (int i = 0; i < numbers.length; i++) {
            numbers[i] = '';
          }
          for (int i = 0; i < numbersToSave.length; i++) {
            numbersToSave[i] = '';
          }
        });
      },
      onTap: () {
        imagePath == null
            ? setState(() {
                String result = '';
                String resultToSave = '';
                for (int i = 0; i < numbers.length; i++) {
                  if (numbers[i].isEmpty) {
                    numbers[i] = number;
                    result += number;
                    break;
                  } else {
                    result += numbers[i];
                  }
                }
                for (int i = 0; i < numbersToSave.length; i++) {
                  if (numbersToSave[i].isEmpty) {
                    numbersToSave[i] = number;
                    resultToSave += number;
                    break;
                  } else {
                    resultToSave += numbersToSave[i];
                  }
                }
                print("confirm passcode" + resultToSave);
                if (resultToSave.length == 6) {
                  print('now saving');
                  if (passcodeToSet == resultToSave) {
                    setState(() {
                      isMatched = true;
                    });
                    savePasscode(resultToSave);
                    Future.delayed(Duration(seconds: 2), () {
                      // Your code here that will be executed after the delay
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WalletTokensNfts(),
                        ),
                      );
                    });
                  } else {
                    setState(() {
                      isMatched = false;
                    });
                  }
                }
              })
            : setState(() {
                isMatched = false;
                for (int i = numbers.length - 1; i >= 0; i--) {
                  if (numbers[i].isNotEmpty) {
                    numbers[i] = '';
                    break;
                  }
                }
                for (int i = numbersToSave.length - 1; i >= 0; i--) {
                  if (numbersToSave[i].isNotEmpty) {
                    numbersToSave[i] = '';
                    break;
                  }
                }
              });
      },
      child: Container(
        height: 7.h,
        width: 7.h,
        decoration: BoxDecoration(),
        child: Center(
          child: imagePath == null
              ? Text(
                  number,
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: AppColors.textColorWhite,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'ArialASDCF',
                  ),
                )
              : Image.asset(
                  "assets/images/delete_button.png",
                  height: 21.sp,
                  width: 21.sp,
                  color: AppColors.textColorWhite,
                ),
        ),
      ),
    );
  }
}
