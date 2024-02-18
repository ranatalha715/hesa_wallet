import 'package:flutter/cupertino.dart';
import 'package:sizer/sizer.dart';

import '../constants/colors.dart';

class TextFieldParent extends StatefulWidget {
  final Widget child;
  final double width;
  final double? otpHeight;
  final Color? color;

  const TextFieldParent({required this.child, this.width = double.infinity, this.otpHeight, this.color});

  @override
  State<TextFieldParent> createState() => _TextFieldParentState();
}

class _TextFieldParentState extends State<TextFieldParent> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.otpHeight == null ? 6.5.h : widget.otpHeight,
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.color ?? AppColors.textFieldParentDark,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: widget.child);
  }
}
