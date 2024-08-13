import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/footer_text.dart';
import 'package:hesa_wallet/constants/styles.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:hesa_wallet/screens/account_recovery/reset_email.dart';
import 'package:hesa_wallet/screens/signup_signin/wallet.dart';
import 'package:hesa_wallet/screens/unlock/set_pin_screen.dart';
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
  late Timer _timer;
  var _isLoading = false;
  var _savedPassCode;
  bool isButtonActive = false;
  bool isMatched = false;
  List<String> numbers = List.generate(6, (index) => '');
  List<String> numbersToSave = List.generate(6, (index) => '');
  bool isFirstFieldFilled = false;
  bool _pinError = false;

  final TextEditingController _passwordController = TextEditingController();

  void _updateButtonState() {
    setState(() {
      isButtonActive = _passwordController.text.isNotEmpty;
    });
  }

  setLockScreenStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('setLockScreen', value);
  }

  @override
  void initState() {
    getSavedPassCode();
    _passwordController.addListener(_updateButtonState);
    _passwordController.addListener(_limitInputLength);
    // TODO: implement initState
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        // Convert entered digits to asterisks
        for (int i = 0; i < numbers.length; i++) {
          if (numbers[i].isNotEmpty) {
            numbers[i] = '*';
          }
        }
        isFirstFieldFilled = numbers[0].isNotEmpty;
      });
    });
  }

  void clearNumbers() {
    setState(() {
      for (int i = 0; i < numbers.length; i++) {
        numbers[i] = '';
      }
      for (int i = 0; i < numbersToSave.length; i++) {
        numbersToSave[i] = '';
      }
    });
  }


  @override
  void dispose() {
    _passwordController.dispose();
    _timer.cancel();
    super.dispose();
  }

  getSavedPassCode() async {
    final prefs = await SharedPreferences.getInstance();
    _savedPassCode = prefs.getString('passcode') ?? "";
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

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Container(
            height: 20.h,
            // color: Colors.redAccent
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                _pinError ? 'Enter PIN again' : 'Enter PIN to unlock',
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
            height: 15.h,
            // color: Colors.blue,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  circularTextField(0, isMatched),
                  circularTextField(1, isMatched),
                  circularTextField(2, isMatched),
                  circularTextField(3, isMatched),
                  circularTextField(4, isMatched),
                  circularTextField(5, isMatched),
                ],
              ),
            ),
          ),
          Container(
            height: 65.h,
            // color: Colors.yellow,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      digitBox('1'),
                      digitBox('2'),
                      digitBox('3'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      digitBox('4'),
                      digitBox('5'),
                      digitBox('6'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      digitBox('7'),
                      digitBox('8'),
                      digitBox('9'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      digitBox(''),
                      digitBox('0'),
                      digitBox(
                        '',
                        imagePath: 'assets/images/remove_button.png',
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 0.5.h,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PinScreen(),
                        ),
                      ),
                      child: Container(
                        // color: Colors.yellow,
                        // height: 5.h,
                        width: 10.h,
                        child: Center(
                          child: Text(
                            'Forgot PIN',
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.hexaGreen,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Blogger Sans'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }

  Widget digitBox(
    String number, {
    String? imagePath,
  }) {
    return InkWell(
      hoverColor: Colors.grey.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        imagePath == null
            ? setState(() async {
                // Create a variable to store the six values
                String result = '';
                String resultToSave = '';

                // Append the pressed digit to the pin boxes
                for (int i = 0; i < numbers.length; i++) {
                  if (numbers[i].isEmpty) {
                    numbers[i] = number;
                    result += number; // Append the digit to the result
                    break; // Stop after adding the digit to the first empty box
                  } else {
                    result +=
                        numbers[i]; // Append the existing number to the result
                  }
                }
                for (int i = 0; i < numbersToSave.length; i++) {
                  if (numbersToSave[i].isEmpty) {
                    numbersToSave[i] = number;
                    resultToSave += number; // Append the digit to the result
                    break; // Stop after adding the digit to the first empty box
                  } else {
                    resultToSave += numbersToSave[
                        i]; // Append the existing number to the result
                  }
                }
                print("passcode" + resultToSave);
                print("isMatched" + isMatched.toString());
                if (resultToSave.length == 6 &&
                    resultToSave == _savedPassCode) {
                  print(resultToSave + "this one");
                  setState(() {
                    isMatched = true;
                  });

                  Future.delayed(Duration(milliseconds: 700), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WalletTokensNfts(),
                      ),
                    );
                  });
                  setLockScreenStatus(false);
                  // savePasscode(resultToSave);
                  // Navigator.of(context).pushReplacementNamed(
                  //     SetConfirmPinScreen.routeName,
                  //     arguments: {
                  //       'passcode': resultToSave,
                  //     });
                } else if (resultToSave.length == 6 &&
                    resultToSave != _savedPassCode) {
                  setState(() {
                    _pinError = true;
                    isMatched = false;
                  });
                  await Future.delayed(Duration(milliseconds: 500));
                  clearNumbers();
                } else {
                  print("this one" + resultToSave.toString());
                  setState(() {
                    isMatched = false;
                  });
                }

                // Print the result after the loop breaks
              })
            : setState(() {
                // Remove the last entered digit
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
        height: 10.h,
        width: 10.h,
        decoration: BoxDecoration(
            // color: Colors.red
            ),
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
          // Image.asset(
          //         imagePath,
          //         height: 13.sp,
          //         width: 13.sp,
          //       ),
        ),
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
                fontSize: 20.sp,
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
}
