import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';

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
        isFirstFieldFilled = numbers[0].isNotEmpty;
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
     final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
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

                'Confirm Pin',
                style: TextStyle(
                    fontSize: 13.sp,
                    color: isFirstFieldFilled
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
                      digitBox('1', passcodeToSet: args!['passcode']),
                      digitBox('2', passcodeToSet: args['passcode']),
                      digitBox('3', passcodeToSet: args['passcode']),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      digitBox('4', passcodeToSet: args['passcode']),
                      digitBox('5', passcodeToSet: args['passcode']),
                      digitBox('6', passcodeToSet: args['passcode']),
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
                    children: [
                      digitBox(''),
                      digitBox('0', passcodeToSet: args['passcode']),
                      digitBox(
                        '',
                        imagePath: 'assets/images/remove_button.png',
                      ),
                    ],
                  ),
                  // SizedBox(height: 2.h,)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'I Forget My Pin',
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textColorGreen,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Blogger Sans'),
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

  Widget circularTextField(int index) {
    return GestureDetector(
      child: Container(
        height: 5.h,
        width: 5.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: isFirstFieldFilled
                ? AppColors.activeButtonColor
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

  Widget digitBox(String number, {String? imagePath, Map<String, dynamic>? passcodeToSet }) {
    return InkWell(
      hoverColor: Colors.grey.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        imagePath == null
            ? setState(() {
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
          if (resultToSave.length == 6 ) {
            print('now saving');
            if(passcodeToSet==resultToSave) {
              savePasscode(resultToSave);
            }
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
        height: 5.h,
        width: 5.h,
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
            imagePath,
            height: 13.sp,
            width: 13.sp,
          ),
        ),
      ),
    );
  }
}
