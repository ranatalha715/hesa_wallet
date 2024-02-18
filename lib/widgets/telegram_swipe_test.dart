import 'package:flutter/material.dart';

class TelegramSwipeBackApp extends StatefulWidget {
  final List<Widget> pages;

  TelegramSwipeBackApp({required this.pages});

  @override
  _TelegramSwipeBackAppState createState() => _TelegramSwipeBackAppState();
}

class _TelegramSwipeBackAppState extends State<TelegramSwipeBackApp> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.pages.length - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleSwipeBack() {
    if (_pageController.page! > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _handleSwipeBack();
        }
      },
      child: PageView(
        controller: _pageController,
        physics: BouncingScrollPhysics(),
        children: widget.pages,
      ),
    );
  }
}
