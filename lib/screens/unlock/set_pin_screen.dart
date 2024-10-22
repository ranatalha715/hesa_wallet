import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hesa_wallet/screens/unlock/set_confirm_pin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({Key? key}) : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  late Timer _timer;
  String selectedNumber = '';
  // List<String> numbers = List.filled(6, '');
  // List<String> numbersToSave = List.filled(6, '');
  List<String> numbers = List.generate(6, (index) => '');
  List<String> numbersToSave = List.generate(6, (index) => '');
  bool isLastFieldFilled = false;

  @override
  void initState() {
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
        isLastFieldFilled = numbers[5].isNotEmpty;
      });
    });
  }
  Future<void> savePasscode(String passcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("passcode", passcode);
    print("Passcode saved: $passcode");
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
  //     setState(() async {
  //       // Create a copy of the numbers list
  //       List<String> originalNumbers = List<String>.from(numbers);
  //
  //       // Print the original numbers
  //       print("Original numbers:");
  //       print(originalNumbers);
  //
  //       isLastFieldFilled = originalNumbers[0].isNotEmpty;
  //     });
  //   });
  // }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                'Enter New Pin'.tr(),
                style: TextStyle(
                    fontSize: 13.sp,
                    color: isLastFieldFilled
                        ? AppColors.activeButtonColor
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
                  circularTextField(0),
                  circularTextField(1),
                  circularTextField(2),
                  circularTextField(3),
                  circularTextField(4),
                  circularTextField(5),
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
                  // SizedBox(height: 2.h,)
                  // Align(
                  //   alignment: Alignment.bottomCenter,
                  //   child: Text(
                  //     'I Forget My Pin',
                  //     style: TextStyle(
                  //         fontSize: 13.sp,
                  //         color: AppColors.textColorGreen,
                  //         fontWeight: FontWeight.w500,
                  //         fontFamily: 'Blogger Sans'),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget circularTextField(int index) {
    return GestureDetector(
      child: Container(
        height: 5.h,
        width: 5.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: isLastFieldFilled
                ? AppColors.activeButtonColor
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(40),
          color: isLastFieldFilled
              ? Colors.transparent
              : Colors.grey.withOpacity(0.2),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: numbers[index] == '*' ? 4.5.sp : 0),
            child: Text(
              numbers[index],
              style: TextStyle(
                fontSize: 17.sp,
                color: AppColors.activeButtonColor,
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

  Widget digitBox(String number, {String? imagePath}) {
    return InkWell(
      hoverColor: Colors.grey.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
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
            ? setState(()  {
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
                    resultToSave +=
                    numbersToSave[i]; // Append the existing number to the result
                  }
                }
                print("passcode" + resultToSave);
                if (resultToSave.length == 6) {
                  Future.delayed(Duration(seconds: 1), () {
                    // Your code here that will be executed after the delay
                    Navigator.of(context).pushReplacementNamed(
                        SetConfirmPinScreen.routeName,
                        arguments: {
                          'passcode': resultToSave,
                        });
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
              :
          Image.asset(
            "assets/images/delete_button.png",
            height: 21.sp,
            width: 21.sp,
            color:
                AppColors.textColorWhite,
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
}
