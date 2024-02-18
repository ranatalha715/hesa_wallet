import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';

class PinScreen extends StatefulWidget {
  // const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String selectedNumber = '';
  List<String> numbers = List.generate(6, (index) => '');
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
                    color: AppColors.textColorWhite,
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
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  circularTextField(0),
                  circularTextField(1),
                  circularTextField(2),
                  circularTextField(3),
                  circularTextField(4),
                  circularTextField(5),
                  // pinBox(selectedNumber),
                  // pinBox(selectedNumber),
                  // pinBox(selectedNumber),
                  // pinBox(selectedNumber),
                  // pinBox(selectedNumber),
                  // pinBox(selectedNumber),
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
                      digitBox(''),
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
      onTap: () {
        _showKeyboard(context, index);
      },
      child: Container(
        height: 5.h,
        width: 5.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.grey.withOpacity(0.2),
        ),
        child: Center(
          child: Text(
            numbers[index],
            style: TextStyle(
              fontSize: 24.sp,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontFamily: 'ArialASDCF',
            ),
          ),
        ),
      ),
    );
  }

  void _showKeyboard(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300.h,
          child: Column(
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  children: List.generate(
                    9,
                        (i) {
                      final number = (i + 1) % 10; // Display 1-9 and 0
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            numbers[index] = number.toString();
                          });
                          Navigator.pop(context); // Close the keyboard
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: Text(
                            number.toString(),
                            style: TextStyle(fontSize: 24.sp, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    color: number.isNotEmpty ? AppColors.textColorWhite : Colors.black, // Adjust color based on selection
    fontWeight: FontWeight.w400,
    fontFamily: 'ArialASDCF',
    ),
    ))
    );
  }

  Widget digitBox(String number) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedNumber = number;
        });
      },
      child: Container(
        height: 5.h,
        width: 5.h,
        decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(40),
            // color:Colors.white.withOpacity(0.5),
            ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 24.sp,
              color: AppColors.textColorWhite,
              fontWeight: FontWeight.w400,
              fontFamily: 'ArialASDCF',
            ),
          ),
        ),
      ),
    );
  }
}
