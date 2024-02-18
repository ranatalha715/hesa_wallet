// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';


import 'colors.dart';




class Styles {


  static InputDecoration authTextFieldDecoration(
      String hintText, Widget? suffix, Function? suffixHandler, Widget? prefix, Function? prefixHandler,) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 14,
          color: AppColors.textColorGrey,
          fontWeight: FontWeight.w400,// Off-white color,
          fontFamily: 'Inter'

      ),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: AppColors.textColorGrey, // Off-white color
            width: 2.0,
          )),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: AppColors.textColorGrey, // Off-white color
            width: 2.0,
          )),
      // labelText: 'Enter your password',
      suffixIcon: GestureDetector(
        onTap: ()=>suffixHandler, child: suffix,
      ),
        prefixIcon: GestureDetector(
          onTap: ()=>prefixHandler, child: prefix,
        )
    );
  }


}
