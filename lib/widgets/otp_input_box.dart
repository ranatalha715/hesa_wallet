import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesa_wallet/widgets/text_field_parent.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';

class OtpInputBox extends StatefulWidget {
  final FocusNode focusNode;
  final FocusNode previousFocusNode;
  final TextEditingController controller;
  final Function handler;
  final bool incorrect;
  final bool? autoFocus;


  const OtpInputBox(
      {required this.focusNode,
      required this.previousFocusNode,
      required this.controller,
      required this.handler,
      this.incorrect=false,
        this.autoFocus=false
      });

  @override
  State<OtpInputBox> createState() => _OtpInputBoxState();
}

class _OtpInputBoxState extends State<OtpInputBox> {
  @override
  Widget build(BuildContext context) {
    return TextFieldParent(
      width: 9.8.w,
      otpHeight: 8.h,
      color: AppColors.transparentBtnBorderColorDark.withOpacity(0.15),
      child:
      TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onChanged: (value) {
          if (value.isEmpty) {
            widget.focusNode.requestFocus();
            if (widget.controller.text.isNotEmpty) {
              widget.controller.clear();
              widget.handler();
            } else {
              // Move focus to the previous SMSVerificationTextField
              // and clear its value recursively
              // FocusScope.of(context).previousFocus();
              widget.previousFocusNode.requestFocus();
            }
          } else {
           widget.handler();
          }
        },
        // onChanged: (value) => handler(),
        keyboardType: TextInputType.number,
        cursorColor: AppColors.textColorGrey,
        // obscureText: true,
        maxLength: 1,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
        ],
        // Hide the entered OTP digits
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.bottom,
        style: TextStyle(
          color: AppColors.textColorWhite,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Blogger Sans'
          // letterSpacing: 16,
        ),
        decoration: InputDecoration(
          counterText: '', // Hide the default character counter
          contentPadding: EdgeInsets.only(top: 16, bottom: 16),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: widget.incorrect ? AppColors.errorColor :Colors.transparent,
                // Off-white color
                // width: 2.0,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: widget.incorrect ? AppColors.errorColor :Colors.transparent,
                // Off-white color
                // width: 2.0,
              )),
        ),
      ),

    );
  }
}
