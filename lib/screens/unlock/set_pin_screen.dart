import 'dart:async';

import 'package:flutter/material.dart';
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
  List<String> numbers = List.generate(6, (index) => '');
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
                'Enter New Pin',
                style: TextStyle(
                    fontSize: 13.sp,
                    color: isFirstFieldFilled ? AppColors.activeButtonColor : AppColors.textColorWhite,
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
          border: Border.all( color: isFirstFieldFilled  ? AppColors.activeButtonColor:Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(40),
          color: isFirstFieldFilled  ? Colors.transparent:Colors.grey.withOpacity(0.2),
        ),
        child: Center(
          child: Padding(
            padding:  EdgeInsets.only(top:  numbers[index] == '*' ? 5.sp :  0),
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

  Widget digitBox(String number, {String? imagePath}) {
    return GestureDetector(
      onTap: () {
        imagePath == null
            ? setState(() {
                // Append the pressed digit to the pin boxes
                for (int i = 0; i < numbers.length; i++) {
                  if (numbers[i].isEmpty) {
                    numbers[i] = number;
                    break; // Stop after adding the digit to the first empty box
                  }
                }
              })
            : setState(() {
                // Remove the last entered digit
                for (int i = numbers.length - 1; i >= 0; i--) {
                  if (numbers[i].isNotEmpty) {
                    numbers[i] = '';
                    break;
                  }
                }
              });
      },
      child: Container(
        height: 5.h,
        width: 5.h,
        decoration: BoxDecoration(
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
                  imagePath,
                  height: 13.sp,
                  width: 13.sp,
                ),
        ),
      ),
    );
  }
}
